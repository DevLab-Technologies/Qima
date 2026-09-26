import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/price_alert.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/alert_editor_sheet.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Avoids touching the real `flutter_local_notifications` plugin (which
/// needs a registered platform instance this test's plain widget binding
/// doesn't provide, and would otherwise throw/log a
/// `LateInitializationError` on every `_save()` call) — mirrors
/// `icloud_sync_test.dart`'s `_FakeNotificationService`. [requested] flips
/// to true only once `requestPermission()` has actually resolved, giving
/// tests a precise signal for "the editor's post-save permission request
/// has fully finished", not just "the alert was written".
class _FakeNotificationService extends NotificationService {
  bool requested = false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    requested = true;
    return true;
  }

  @override
  Future<bool> isEnabled() async => true;
}

/// Polls [condition] in real time until it's true, instead of a fixed
/// real-time sleep and hoping it was long enough. `AlertEditorSheet._save`
/// awaits `saveAlert` THEN (for a new alert) `requestNotificationPermission`
/// before popping — a predicate on the alerts list alone resolves after the
/// first of those, not the whole chain, so a caller creating a NEW alert
/// must poll on both having happened (see the `_FakeNotificationService`
/// passed to `populatedCubit`) or this can leave `_save`'s tail end still in
/// flight when the test (and its `AppCubit`) tears down — which then throws
/// into a LATER test.
Future<void> _pollUntil(bool Function() condition, {Duration timeout = const Duration(seconds: 5)}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('_pollUntil: condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// Taps [finder] and awaits the real (file IO) async work its `onPressed`
/// triggers actually finishing, via [settled] (built with [_pollUntil]) —
/// `AppCubit.saveAlert`/`deleteAlert` do real on-disk file IO via
/// `AlertsStore`, which doesn't progress under the fake async zone
/// `testWidgets` normally pumps in. Mirrors
/// `add_instrument_flow_test.dart`'s `_tapAndAwaitRealWork`.
Future<void> _tapAndAwaitRealWork(WidgetTester tester, Finder finder, Future<void> Function() settled) async {
  await tester.runAsync(() async {
    await tester.tap(finder, warnIfMissed: false);
    await settled();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_alert_editor_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final card = WatchCard(id: 'card1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);

  Future<AppCubit> populatedCubit({_FakeNotificationService? notifications}) async {
    final cubit = AppCubit(notificationService: notifications);
    cubit.preferences = await Preferences.create();
    final now = DateTime(2024, 6, 10);
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      cards: [card],
      seriesByID: {
        gold.id: QuoteSeries(instrumentID: gold.id, quotes: [
          Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 2000),
        ]),
      },
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
    ));
    return cubit;
  }

  Widget harness(AppCubit cubit, {PriceAlert? existing}) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AlertEditorSheet.show(context, card: card, existing: existing),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Price mode: entering a target and tapping Create saves an above alert', (tester) async {
    final notifications = _FakeNotificationService();
    final cubit = await populatedCubit(notifications: notifications);
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.alertEditorNewTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '2100');
    await tester.pump();

    final createButton = find.widgetWithText(FilledButton, l10n.alertEditorCreate);
    expect(tester.widget<FilledButton>(createButton).onPressed, isNotNull);

    // A NEW alert also triggers `_save`'s post-save
    // `requestNotificationPermission()` call before it returns — wait for
    // BOTH that and the alert write, or `_save`'s tail can still be in
    // flight when this test tears down the cubit.
    await _tapAndAwaitRealWork(
      tester,
      createButton,
      () => _pollUntil(() => cubit.state.alerts.isNotEmpty && notifications.requested),
    );
    await tester.pumpAndSettle();

    expect(cubit.state.alerts, hasLength(1));
    expect(cubit.state.alerts.single.kind, AlertKind.above);
    expect(cubit.state.alerts.single.target, 2100);
  });

  testWidgets('Price mode: an empty or zero target disables Create', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final createButton = find.widgetWithText(FilledButton, l10n.alertEditorCreate);

    // Empty by default.
    expect(tester.widget<FilledButton>(createButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.pump();
    expect(tester.widget<FilledButton>(createButton).onPressed, isNull);
    expect(find.text(l10n.alertEditorTargetRequired), findsOneWidget);
  });

  testWidgets('% move mode: Create is enabled without a target field, and saves a percentMove alert', (tester) async {
    final notifications = _FakeNotificationService();
    final cubit = await populatedCubit(notifications: notifications);
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.alertEditorTypePercent));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);

    final createButton = find.widgetWithText(FilledButton, l10n.alertEditorCreate);
    expect(tester.widget<FilledButton>(createButton).onPressed, isNotNull);

    // See the previous test's comment: a NEW alert also awaits
    // `requestNotificationPermission()` before `_save` returns.
    await _tapAndAwaitRealWork(
      tester,
      createButton,
      () => _pollUntil(() => cubit.state.alerts.isNotEmpty && notifications.requested),
    );
    await tester.pumpAndSettle();

    expect(cubit.state.alerts, hasLength(1));
    expect(cubit.state.alerts.single.kind, AlertKind.percentMove);
  });

  testWidgets('editing an existing alert pre-fills its fields and Save updates it in place', (tester) async {
    final cubit = await populatedCubit();
    final existing = PriceAlert(
      id: 'existing1',
      cardID: card.id,
      kind: AlertKind.below,
      target: 1800,
      createdAt: DateTime(2024, 1, 1),
    );
    await tester.runAsync(() => cubit.saveAlert(existing));

    await tester.pumpWidget(harness(cubit, existing: existing));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.alertEditorEditTitle), findsOneWidget);
    expect(find.text('1800'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '1750');
    await tester.pump();
    // Editing an EXISTING alert does not trigger `_save`'s
    // `requestNotificationPermission()` follow-up (see its `_isEditing`
    // guard), so the alert write itself is the whole story here.
    await _tapAndAwaitRealWork(
      tester,
      find.widgetWithText(FilledButton, l10n.alertEditorSave),
      () => _pollUntil(() => cubit.state.alerts.length == 1 && cubit.state.alerts.single.target == 1750),
    );
    await tester.pumpAndSettle();

    expect(cubit.state.alerts, hasLength(1));
    expect(cubit.state.alerts.single.target, 1750);
    expect(cubit.state.alerts.single.id, 'existing1');
  });

  testWidgets('deleting an existing alert asks for confirmation and removes it', (tester) async {
    final cubit = await populatedCubit();
    final existing = PriceAlert(
      id: 'existing1',
      cardID: card.id,
      kind: AlertKind.above,
      target: 2100,
      createdAt: DateTime(2024, 1, 1),
    );
    await tester.runAsync(() => cubit.saveAlert(existing));

    await tester.pumpWidget(harness(cubit, existing: existing));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    // The whole tap-dialog-confirm-delete round trip is one continuous
    // `_delete` async chain, so it all has to originate inside a SINGLE
    // `runAsync` block: a `Future`'s `await` continuation always resumes on
    // the zone it started in, regardless of which zone resolves it — opening
    // the confirm dialog outside `runAsync` would strand `_delete`'s
    // post-confirmation code (the real-IO `cubit.deleteAlert` call) on the
    // fake-async test zone, where real file IO never progresses.
    // Waits for the cubit to actually finish deleting (its state stream
    // emits an update with the alert gone), rather than inferring
    // completion from widget-pump idleness — `_delete`'s post-confirmation
    // code runs real file IO (`cubit.deleteAlert`), and a Dart `Future`'s
    // `await` continuation always resumes on the zone it was created in, so
    // whichever tap starts that chain has to happen inside `runAsync` for
    // the real IO to progress at all; waiting on the stream (rather than
    // `pumpAndSettle`, which can report "settled" from real-time frame
    // idleness before a trailing microtask has actually completed) avoids
    // racing the assertion against that IO.
    final deleted = cubit.stream.firstWhere((s) => s.alerts.isEmpty);
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.delete_outline), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.commonDelete), warnIfMissed: false);
      await deleted.timeout(const Duration(seconds: 5));
    });
    await tester.pumpAndSettle();

    expect(cubit.state.alerts, isEmpty);
  });
}
