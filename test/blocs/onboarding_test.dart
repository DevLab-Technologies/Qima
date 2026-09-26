import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/price_alert.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/price_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for `PriceRepository` so `AppCubit.init()` never hits the
/// network — mirrors `restore_from_backup_test.dart`'s `_NoopRepository`.
/// Also fixes [cachedRates] to a small multi-currency table (the real
/// implementation reads an empty on-disk cache in a fresh temp dir, i.e.
/// USD-only) so the base-currency prefill tests have something besides USD
/// to resolve to.
class _NoopRepository extends PriceRepository {
  @override
  Future<FXRates> cachedRates() async => FXRates(
        base: 'USD',
        rates: const {'USD': 1, 'GBP': 0.78, 'EUR': 0.92},
        updatedAt: DateTime(2024, 1, 1),
      );

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

/// Avoids touching the real `flutter_local_notifications` plugin (unbound in
/// a plain widget test) — mirrors `icloud_sync_test.dart`'s
/// `_FakeNotificationService`, needed here because these tests run the real
/// `AppCubit.init()`.
class _FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> isEnabled() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_onboarding_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  AppCubit makeCubit() {
    return AppCubit(repository: _NoopRepository(), notificationService: _FakeNotificationService());
  }

  test('a fresh install (only the seeded default watchlist) shows the tour', () async {
    final cubit = makeCubit();
    await cubit.init();
    expect(cubit.state.shouldShowOnboarding, isTrue);
    await cubit.close();
  });

  test('completing the tour persists the flag so it never shows again', () async {
    final cubit = makeCubit();
    await cubit.init();
    expect(cubit.state.shouldShowOnboarding, isTrue);

    await cubit.completeOnboarding();
    expect(cubit.state.shouldShowOnboarding, isFalse);
    await cubit.close();

    // A second launch on the same device (same on-disk prefs) must not show
    // the tour again — "Never shown again automatically once finished or
    // skipped" (spec "Onboarding tour").
    final second = makeCubit();
    await second.init();
    expect(second.state.shouldShowOnboarding, isFalse);
    await second.close();
  });

  test('skipping (without ever changing anything else) also persists the flag', () async {
    // Skip and "Get started" both call the same `completeOnboarding()` —
    // there is no separate "skipped" vs "finished" flag (spec: "Never shown
    // again automatically once finished or skipped").
    final cubit = makeCubit();
    await cubit.init();
    await cubit.completeOnboarding();
    await cubit.close();

    final second = makeCubit();
    await second.init();
    expect(second.state.shouldShowOnboarding, isFalse);
    await second.close();
  });

  test('an existing install with a customized watchlist is not shown the tour', () async {
    // Simulates a 1.x upgrade: the on-disk watchlist already has a card
    // beyond the seeded defaults before `init()` ever runs. Writes straight
    // through `WatchlistStore` (not `AppCubit.addCard`, which also fires an
    // unawaited background refresh/backfill for a genuinely new instrument
    // that would otherwise still be in flight when this cubit closes).
    final seedCubit = makeCubit();
    await seedCubit.init();
    final eth = InstrumentCatalog.instrument('crypto.ETH')!;
    await seedCubit.watchlistStore
        .upsert(WatchCard(id: 'card-extra', instrumentID: eth.id, currency: 'USD', unit: PriceUnit.each));
    await seedCubit.close();

    final cubit = makeCubit();
    await cubit.init();
    expect(cubit.state.shouldShowOnboarding, isFalse);
    await cubit.close();
  });

  test('an existing install with holdings (default watchlist otherwise) is not shown the tour', () async {
    // Writes straight through `HoldingsStore` (not `AppCubit.saveLot`, whose
    // own unawaited backup-reminder refresh would otherwise still be in
    // flight when this cubit closes).
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final seedCubit = makeCubit();
    await seedCubit.init();
    await seedCubit.holdingsStore.upsert(HoldingLot(
      id: 'lot-1',
      instrumentID: gold.id,
      quantity: 1,
      unit: PriceUnit.troyOunce,
      unitCost: 1900,
      costCurrency: 'USD',
      date: DateTime(2024, 1, 1),
    ));
    await seedCubit.close();

    final cubit = makeCubit();
    await cubit.init();
    expect(cubit.state.shouldShowOnboarding, isFalse);
    await cubit.close();
  });

  test('an existing install with an alert (default watchlist otherwise) is not shown the tour', () async {
    // Writes straight through `AlertsStore`, for the same reason as the
    // holdings case above.
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final seedCubit = makeCubit();
    await seedCubit.init();
    final card = seedCubit.state.cards.firstWhere((c) => c.instrumentID == gold.id);
    await seedCubit.alertsStore.upsert(PriceAlert(
      id: 'alert-1',
      cardID: card.id,
      kind: AlertKind.above,
      target: 2500,
      percent: 0,
      direction: AlertDirection.either,
      window: AlertWindow.h24,
      repeats: false,
      enabled: true,
      createdAt: DateTime(2024, 1, 1),
    ));
    await seedCubit.close();

    final cubit = makeCubit();
    await cubit.init();
    expect(cubit.state.shouldShowOnboarding, isFalse);
    await cubit.close();
  });

  test('base currency prefills from the device region on a fresh install', () async {
    // en_GB maps to GBP via intl's per-locale currency table.
    final cubit = AppCubit(
      repository: _NoopRepository(),
      notificationService: _FakeNotificationService(),
      deviceLocale: const Locale('en', 'GB'),
    );
    await cubit.init();
    expect(cubit.state.shouldShowOnboarding, isTrue);
    expect(cubit.state.baseCurrency, 'GBP');
    await cubit.close();
  });

  test('base currency prefill never overrides an explicitly-set currency', () async {
    final seedCubit = makeCubit();
    await seedCubit.init();
    await seedCubit.setBaseCurrency('EUR');
    await seedCubit.close();

    final cubit = AppCubit(
      repository: _NoopRepository(),
      notificationService: _FakeNotificationService(),
      deviceLocale: const Locale('en', 'GB'),
    );
    await cubit.init();
    expect(cubit.state.baseCurrency, 'EUR');
    await cubit.close();
  });
}
