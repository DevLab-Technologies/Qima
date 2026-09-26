import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/add_instrument_screen.dart';
import 'package:qima/screens/card_config_screen.dart';
import 'package:qima/screens/custom_ticker_screen.dart';
import 'package:qima/screens/instrument_detail_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';

/// No-ops every network/shared_preferences-touching call `AppCubit` fires in
/// the background (refresh, FX/history backfill) so the widget tests below
/// can exercise the add flow deterministically and offline. `validateCustomTicker`
/// is overridden too, standing in for "the ticker is real" without hitting
/// Yahoo — these tests are about navigation/state, not price validation.
class _FakeRepository extends PriceRepository {
  @override
  Future<double> probePrice(Instrument instrument) async => 100;

  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async => {};

  @override
  Future<FXHistory> backfillFXHistory(List<String> currencies, {bool force = false, DateTime? now}) async =>
      FXHistory.empty;

  @override
  Future<Map<String, QuoteSeries>> backfillInstruments(
    List<Instrument> instruments,
    FXHistory fxHistory, {
    bool force = false,
    DateTime? now,
  }) async =>
      {};
}

/// Polls [condition] in real time (inside the caller's `runAsync` block)
/// until it's true, instead of a fixed real-time sleep and hoping it was
/// long enough. Used to await the ACTUAL completion of `addCard`/
/// `undoAdd`'s real on-disk file IO (and everything chained after it —
/// `CardConfigScreen`'s `onPressed` doesn't return, and doesn't call
/// `completeAdd`'s navigation, until the whole `await cubit.addCard(...)`
/// chain resolves). A fixed delay that's too short leaves this work still
/// in flight when the test (and `tearDown`'s `cubit.close()`) completes,
/// which then throws "Cannot emit new states after calling close" during a
/// LATER test; polling instead of guessing a duration is what actually
/// removes that race.
Future<void> _pollUntil(bool Function() condition, {Duration timeout = const Duration(seconds: 5)}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('_pollUntil: condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// Waits for `addCard`'s own Future to have effectively resolved (via
/// [_pollUntil] on [instrumentID] landing in `seriesByID` — its last `emit`
/// before returning, see its body), THEN also waits out the un-awaited
/// background `refresh()` call `addCard` fires right after for a brand-new
/// instrument if one is still in flight. Both are real on-disk-IO-backed
/// async work that must be fully drained before a test (and `tearDown`'s
/// `cubit.close()`) completes, or either can throw "Cannot emit new states
/// after calling close" into a LATER test.
Future<void> _awaitAddCardSettled(AppCubit cubit, String instrumentID) async {
  await _pollUntil(() => cubit.state.seriesByID.containsKey(instrumentID));
  if (cubit.state.phase == RefreshPhase.refreshing) {
    await cubit.stream.firstWhere((s) => s.phase != RefreshPhase.refreshing).timeout(const Duration(seconds: 5));
  }
}

/// Taps [finder] and awaits the real (file IO) async work it triggers —
/// `addCard`/`addCustomTicker`, and everything `CardConfigScreen`'s/
/// `CustomTickerScreen`'s `onPressed` chains after it (including the
/// `completeAdd` navigation) — actually finishing, via [settled] (built
/// with [_pollUntil]/[_awaitAddCardSettled] from the caller). `runAsync`
/// escapes to a real zone so the awaited Future inside the tapped button's
/// `onPressed` can actually progress in the first place.
Future<void> _tapAndAwaitRealWork(WidgetTester tester, Finder finder, Future<void> Function() settled) async {
  await tester.runAsync(() async {
    await tester.tap(finder, warnIfMissed: false);
    await settled();
  });
}

/// Finds and directly invokes the SnackBarAction's `onPressed` — the
/// SnackBarAction ("Undo") legitimately renders partly outside the default
/// 800x600 test surface, and tapping through the gesture pipeline at an
/// off-screen offset isn't reliable, so this calls the handler directly
/// instead (exactly what a real tap would trigger). Awaits [settled] (built
/// with [_pollUntil]) rather than a fixed sleep, for the same reason as
/// [_tapAndAwaitRealWork]: `onPressed` fires `cubit.undoAdd(...)` without
/// awaiting it (a snackbar action can't await), so its real file IO needs to
/// be awaited some other way before pumping frames again.
Future<void> _tapUndo(WidgetTester tester, Future<void> Function() settled) async {
  final action = tester.widget<SnackBarAction>(find.byType(SnackBarAction));
  await tester.runAsync(() async {
    action.onPressed();
    await settled();
  });
}

/// A bounded stand-in for `pumpAndSettle()`: pumps a fixed number of frames
/// instead of pumping until nothing is scheduled. `WatchlistScreen` starts a
/// 60-second periodic refresh `Timer` in `initState`, which never completes
/// on its own and makes `pumpAndSettle()` time out on any screen that has a
/// `WatchlistScreen` still mounted underneath it (exactly the case once
/// `completeAdd` lands back on the watchlist with the detail screen pushed
/// on top). This settles the page-route transition and the snackbar's
/// entrance animation without waiting on that timer.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _app(AppCubit cubit, {Locale locale = const Locale('en')}) {
  return BlocProvider<AppCubit>.value(
    value: cubit,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const WatchlistScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppCubit cubit;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_add_flow_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    cubit = AppCubit(repository: _FakeRepository());
    cubit.emit(cubit.state.copyWith(initialized: true));
  });

  tearDown(() async {
    cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('the custom-ticker row is always last, even with search matches', (tester) async {
    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'gold');
    await tester.pumpAndSettle();

    // "Gold" (the metal) should be found, and the custom-ticker row's title
    // must be the very last item under it in tab/traversal order.
    expect(find.textContaining('Gold'), findsWidgets);
    final customRowTitleFinder = find.textContaining('as a custom ticker');
    expect(customRowTitleFinder, findsOneWidget);

    final listView = find.byType(ListView).last;
    final scrollable = find.descendant(of: listView, matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(customRowTitleFinder, 200, scrollable: scrollable.first);
    expect(customRowTitleFinder, findsOneWidget);
  });

  testWidgets('the no-results state prefills the custom ticker screen with the query', (tester) async {
    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzznotfound');
    await tester.pumpAndSettle();

    expect(find.textContaining('No matches'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(CustomTickerScreen), findsOneWidget);
    final symbolField = tester.widget<TextField>(find.byType(TextField).first);
    expect(symbolField.controller!.text, 'ZZZNOTFOUND');
  });

  testWidgets('adding from card config lands on [Watchlist, Detail] and Back returns to Watchlist', (tester) async {
    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    await tester.tap(find.text('Gold').first);
    await tester.pumpAndSettle();
    expect(find.byType(CardConfigScreen), findsOneWidget);

    // addCard performs real file IO (the on-disk watchlist store), which
    // doesn't progress under the fake async zone testWidgets normally runs
    // in — runAsync escapes to a real zone so the awaited Future actually
    // completes. See `_awaitAddCardSettled`'s doc comment for why this
    // (rather than an earlier intermediate state) is the real completion
    // signal.
    await _tapAndAwaitRealWork(tester, find.byType(FilledButton), () => _awaitAddCardSettled(cubit, gold.id));
    await _settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    expect(find.byType(CardConfigScreen), findsNothing);
    expect(find.byType(AddInstrumentScreen), findsNothing);
    expect(cubit.state.cards.any((c) => c.instrumentID == gold.id), isTrue);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    expect(navigator.canPop(), isTrue);
    navigator.pop();
    await _settle(tester);

    expect(find.byType(WatchlistScreen), findsOneWidget);
    expect(find.byType(InstrumentDetailScreen), findsNothing);
  });

  testWidgets('the snackbar Undo action removes the card and pops back to the watchlist', (tester) async {
    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    await tester.tap(find.text('Gold').first);
    await tester.pumpAndSettle();
    await _tapAndAwaitRealWork(tester, find.byType(FilledButton), () => _awaitAddCardSettled(cubit, gold.id));
    await _settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    expect(cubit.state.cards, isNotEmpty);

    await _tapUndo(tester, () => _pollUntil(() => cubit.state.cards.isEmpty));
    await _settle(tester);

    expect(cubit.state.cards, isEmpty);
    expect(find.byType(WatchlistScreen), findsOneWidget);
  });

  testWidgets('custom ticker Undo removes a newly-created ticker but keeps a pre-existing one', (tester) async {
    // A pre-existing custom ticker with a card already on the watchlist.
    // `addCustomTicker`/`addCard` do real on-disk file IO, which needs
    // runAsync to actually progress inside a testWidgets body (see
    // `_tapAndAwaitRealWork` above).
    // `preExisting` is a NEW instrument, so `addCard` also fires an
    // un-awaited background `refresh()` — wait for that to settle too
    // (see `_awaitAddCardSettled`'s doc comment), or it can still be in
    // flight when `tearDown` closes the cubit.
    late Instrument preExisting;
    await tester.runAsync(() async {
      preExisting = await cubit.addCustomTicker('PREV', 'Previous Co', assetClass: AssetClass.stock);
      await cubit.addCard(WatchCard(id: 'pre', instrumentID: preExisting.id, currency: 'EUR', unit: PriceUnit.each));
      if (cubit.state.phase == RefreshPhase.refreshing) {
        await cubit.stream.firstWhere((s) => s.phase != RefreshPhase.refreshing).timeout(const Duration(seconds: 5));
      }
    });

    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'NEWCO');
    await tester.pumpAndSettle();
    // "NEWCO" matches nothing in the catalog, so this is the no-results
    // state's FilledButton ("Add NEWCO as custom ticker"), not the grouped-
    // results custom-ticker row.
    expect(find.textContaining('No matches'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(CustomTickerScreen), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Ticker symbol'), 'NEWCO');
    const newInstrumentID = 'stock.NEWCO';
    await _tapAndAwaitRealWork(tester, find.text('Add ticker'), () => _awaitAddCardSettled(cubit, newInstrumentID));
    await _settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    expect(cubit.isCustom(newInstrumentID), isTrue);
    expect(cubit.state.cards.any((c) => c.instrumentID == newInstrumentID), isTrue);

    // `undoAdd` (with a `customInstrumentID`) ends with
    // `removeCustomInstrument`, which reloads the catalog BEFORE removing
    // the card — poll on BOTH conditions so this doesn't resolve on the
    // catalog-reload step alone, ahead of the card actually being gone.
    await _tapUndo(
      tester,
      () => _pollUntil(
        () => !cubit.isCustom(newInstrumentID) && !cubit.state.cards.any((c) => c.instrumentID == newInstrumentID),
      ),
    );
    await _settle(tester);

    expect(cubit.state.cards.any((c) => c.instrumentID == newInstrumentID), isFalse);
    expect(cubit.isCustom(newInstrumentID), isFalse);
    // The pre-existing ticker (and its card) must survive.
    expect(cubit.isCustom(preExisting.id), isTrue);
    expect(cubit.state.cards.any((c) => c.instrumentID == preExisting.id), isTrue);
  });

  testWidgets('adding a duplicate opens the existing card with no Undo action', (tester) async {
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final existing = WatchCard(id: 'existing', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
    // addCard does real on-disk file IO — needs runAsync (see
    // `_tapAndAwaitRealWork` above for why). `existing` is a NEW instrument
    // the first time (this is the only card added so far), so `addCard`
    // also fires an un-awaited background `refresh()` — wait for that to
    // actually settle too (back to `RefreshPhase.idle`), or it can still be
    // in flight when `tearDown` closes the cubit and throws "Cannot emit
    // new states after calling close" into a LATER test.
    await tester.runAsync(() async {
      await cubit.addCard(existing);
      if (cubit.state.phase == RefreshPhase.refreshing) {
        await cubit.stream.firstWhere((s) => s.phase != RefreshPhase.refreshing).timeout(const Duration(seconds: 5));
      }
    });

    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gold').first);
    await tester.pumpAndSettle();
    // Default currency/unit in CardConfigScreen match `existing` (base
    // currency USD, default unit troy ounce), so this reproduces the exact
    // same combo without changing any selector. `addCard`'s duplicate path
    // (`isSameCombo`) returns before its first `await`, so there's no real
    // I/O to bridge with `runAsync` here — a plain tap and frame pumps are
    // enough.
    await tester.tap(find.byType(FilledButton));
    await _settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    expect(cubit.state.cards.length, 1); // no duplicate card was created.
    expect(find.text('Undo'), findsNothing);
    expect(find.textContaining('already in your watchlist'), findsOneWidget);
  });
}
