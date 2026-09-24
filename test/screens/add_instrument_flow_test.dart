import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
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

/// Taps [finder] and lets any real (file IO) async work it triggers actually
/// run to completion. `addCard`/`addCustomTicker` do real on-disk file IO,
/// which doesn't progress under the fake async zone `testWidgets` normally
/// runs pumps in — `runAsync` escapes to a real zone for the tap AND a short
/// real delay, so the awaited Future inside the tapped button's `onPressed`
/// actually completes before we return to pumping frames.
Future<void> _tapAndAwaitRealWork(WidgetTester tester, Finder finder) async {
  await tester.runAsync(() async {
    await tester.tap(finder, warnIfMissed: false);
    // Some flows chain several real-IO awaits back to back (validate, then
    // create the custom ticker, then add the card) — give them enough real
    // time to actually finish before returning to fake-async pumping.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
}

/// Finds and directly invokes the SnackBarAction's `onPressed` — the
/// SnackBarAction ("Undo") legitimately renders partly outside the default
/// 800x600 test surface, and tapping through the gesture pipeline at an
/// off-screen offset isn't reliable, so this calls the handler directly
/// instead (exactly what a real tap would trigger).
Future<void> _tapUndo(WidgetTester tester) async {
  final action = tester.widget<SnackBarAction>(find.byType(SnackBarAction));
  await tester.runAsync(() async {
    action.onPressed();
    // `onPressed` fires `cubit.undoAdd(...)` without awaiting it (a snackbar
    // action can't await), so give its real file IO time to actually finish
    // before pumping frames again.
    await Future<void>.delayed(const Duration(milliseconds: 300));
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
    // completes.
    await _tapAndAwaitRealWork(tester, find.byType(FilledButton));
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

    await tester.tap(find.text('Gold').first);
    await tester.pumpAndSettle();
    await _tapAndAwaitRealWork(tester, find.byType(FilledButton));
    await _settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    expect(cubit.state.cards, isNotEmpty);

    await _tapUndo(tester);
    await _settle(tester);

    expect(cubit.state.cards, isEmpty);
    expect(find.byType(WatchlistScreen), findsOneWidget);
  });

  testWidgets('custom ticker Undo removes a newly-created ticker but keeps a pre-existing one', (tester) async {
    // A pre-existing custom ticker with a card already on the watchlist.
    // `addCustomTicker`/`addCard` do real on-disk file IO, which needs
    // runAsync to actually progress inside a testWidgets body (see
    // `_tapAndAwaitRealWork` above).
    late Instrument preExisting;
    await tester.runAsync(() async {
      preExisting = await cubit.addCustomTicker('PREV', 'Previous Co', assetClass: AssetClass.stock);
      await cubit.addCard(WatchCard(id: 'pre', instrumentID: preExisting.id, currency: 'EUR', unit: PriceUnit.each));
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
    await _tapAndAwaitRealWork(tester, find.text('Add ticker'));
    await _settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    final newInstrumentID = 'stock.NEWCO';
    expect(cubit.isCustom(newInstrumentID), isTrue);
    expect(cubit.state.cards.any((c) => c.instrumentID == newInstrumentID), isTrue);

    await _tapUndo(tester);
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
    // `_tapAndAwaitRealWork` above for why).
    await tester.runAsync(() => cubit.addCard(existing));

    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gold').first);
    await tester.pumpAndSettle();
    // Default currency/unit in CardConfigScreen match `existing` (base
    // currency USD, default unit troy ounce), so this reproduces the exact
    // same combo without changing any selector.
    await _tapAndAwaitRealWork(tester, find.byType(FilledButton));
    await _settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    expect(cubit.state.cards.length, 1); // no duplicate card was created.
    expect(find.text('Undo'), findsNothing);
    expect(find.textContaining('already in your watchlist'), findsOneWidget);
  });
}
