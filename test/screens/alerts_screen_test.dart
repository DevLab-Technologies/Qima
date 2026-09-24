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
import 'package:qima/screens/alerts_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for the real `flutter_local_notifications`-backed
/// [NotificationService] (unavailable/unbound in a plain widget test), so
/// the "Notifications are off" banner test can deterministically control
/// what `AppCubit.refreshNotificationStatus` observes instead of racing the
/// screen's own `initState` check against a real plugin call that always
/// fails in this environment.
class _FakeNotificationService extends NotificationService {
  bool enabled;

  _FakeNotificationService({this.enabled = true});

  @override
  Future<bool> isEnabled() async => enabled;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_alerts_screen_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final goldCard = WatchCard(id: 'card-gold', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
  final silverCard = WatchCard(id: 'card-silver', instrumentID: silver.id, currency: 'USD', unit: PriceUnit.troyOunce);

  Future<AppCubit> makeCubit({
    List<WatchCard> cards = const [],
    List<PriceAlert> alerts = const [],
    bool notificationsEnabled = true,
  }) async {
    final cubit = AppCubit(notificationService: _FakeNotificationService(enabled: notificationsEnabled));
    cubit.preferences = await Preferences.create();
    final now = DateTime(2024, 6, 10);
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      cards: cards,
      alerts: alerts,
      notificationsEnabled: notificationsEnabled,
      seriesByID: {
        for (final c in cards)
          c.instrumentID: QuoteSeries(
            instrumentID: c.instrumentID,
            quotes: [Quote(instrumentID: c.instrumentID, timestamp: now, canonicalUSD: 2000)],
          ),
      },
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
    ));
    return cubit;
  }

  Widget harness(AppCubit cubit) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: const AlertsScreen(),
      ),
    );
  }

  testWidgets('empty state shown when there are no alerts', (tester) async {
    final cubit = await makeCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.alertsScreenEmptyTitle), findsOneWidget);
  });

  testWidgets('alerts are grouped by card, one group per instrument', (tester) async {
    final cubit = await makeCubit(
      cards: [goldCard, silverCard],
      alerts: [
        PriceAlert(id: 'a1', cardID: goldCard.id, kind: AlertKind.above, target: 2100, createdAt: DateTime(2024)),
        PriceAlert(id: 'a2', cardID: goldCard.id, kind: AlertKind.below, target: 1900, createdAt: DateTime(2024)),
        PriceAlert(id: 'a3', cardID: silverCard.id, kind: AlertKind.above, target: 30, createdAt: DateTime(2024)),
      ],
    );
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    // No empty state, and both instrument names appear as group headers.
    expect(find.text(l10n.alertsScreenEmptyTitle), findsNothing);
    expect(find.textContaining('Gold'), findsOneWidget);
    expect(find.textContaining('Silver'), findsOneWidget);

    // Both of gold's alert summaries render under its group.
    expect(find.textContaining(l10n.alertKindAbove), findsNWidgets(2)); // gold above + silver above
    expect(find.textContaining(l10n.alertKindBelow), findsOneWidget);
  });

  testWidgets('an alert for a since-removed card is skipped rather than crashing', (tester) async {
    final cubit = await makeCubit(
      cards: [goldCard], // silverCard NOT in cards
      alerts: [
        PriceAlert(id: 'a1', cardID: goldCard.id, kind: AlertKind.above, target: 2100, createdAt: DateTime(2024)),
        PriceAlert(id: 'orphan', cardID: 'removed-card', kind: AlertKind.above, target: 10, createdAt: DateTime(2024)),
      ],
    );
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    // Only gold's group renders; the orphaned alert (unresolvable card) is
    // silently skipped instead of throwing.
    expect(find.textContaining('Gold'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Notifications are off" banner shows when disabled, and hides once notifications are enabled', (tester) async {
    final fakeNotifications = _FakeNotificationService(enabled: false);
    final cubit = AppCubit(notificationService: fakeNotifications);
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(initialized: true, notificationsEnabled: false));

    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.alertsScreenNotificationsOff), findsOneWidget);
    expect(find.text(l10n.alertsScreenOpenSettings), findsOneWidget);

    // Simulates the user granting the OS permission (e.g. via "Open
    // settings" then coming back): the underlying service now reports
    // enabled, and re-running the same refresh the screen calls on resume
    // updates the banner away.
    fakeNotifications.enabled = true;
    await tester.runAsync(() => cubit.refreshNotificationStatus());
    await tester.pump();

    expect(find.text(l10n.alertsScreenNotificationsOff), findsNothing);
  });

  testWidgets('toggling an alert switch calls setAlertEnabled', (tester) async {
    final cubit = await makeCubit(
      cards: [goldCard],
      alerts: [
        PriceAlert(id: 'a1', cardID: goldCard.id, kind: AlertKind.above, target: 2100, createdAt: DateTime(2024)),
      ],
    );
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    expect(cubit.state.alerts.single.enabled, isTrue);

    await tester.runAsync(() async {
      await tester.tap(find.byType(Switch), warnIfMissed: false);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(cubit.state.alerts.single.enabled, isFalse);
  });
}
