import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/price_alert.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/alert_runtime_store.dart';
import 'package:qima/services/alerts_store.dart';
import 'package:qima/services/cloud_kv_store.dart';
import 'package:qima/services/custom_instrument_store.dart';
import 'package:qima/services/holdings_store.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/services/refresh_pipeline.dart';
import 'package:qima/services/watchlist_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [PriceRepository] whose network-touching methods are stubbed with a
/// scripted price, so `RefreshPipeline.run`/`evaluateAndNotify` can be
/// exercised without hitting real HTTP endpoints.
class _FakePriceRepository extends PriceRepository {
  final Map<String, double> pricesUSD;
  int refreshAllCallCount = 0;

  /// Accumulates every recorded quote per instrument, exactly like the real
  /// `PriceRepository.refreshAll` -> `QuoteHistoryStore.record` path — a
  /// percentMove alert needs an actual multi-point history to compare
  /// against a window, not just the single latest quote.
  final Map<String, List<Quote>> _history = {};

  _FakePriceRepository(this.pricesUSD);

  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async {
    refreshAllCallCount++;
    final result = <String, QuoteSeries>{};
    for (final instrument in instruments) {
      final price = pricesUSD[instrument.id];
      if (price == null) continue;
      final quote = Quote(instrumentID: instrument.id, timestamp: now ?? DateTime.now(), canonicalUSD: price);
      final series = _history.putIfAbsent(instrument.id, () => []);
      series.add(quote);
      result[instrument.id] = QuoteSeries(instrumentID: instrument.id, quotes: List.of(series));
    }
    return result;
  }

  @override
  Future<FXRates> cachedRates() async => FXRates.usdIdentity;
}

/// Records every notification `show` call instead of touching the real
/// `flutter_local_notifications` plugin (unavailable/unbound in a plain
/// `flutter_test` unit test).
class _FakeNotificationService extends NotificationService {
  final List<({int id, String title, String body, String payload})> shown = [];

  @override
  Future<void> show({required int id, required String title, required String body, required String payload}) async {
    shown.add((id: id, title: title, body: body, payload: payload));
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_refresh_pipeline_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    // Resets the overlap guard too: it's now persisted via `Preferences`
    // (SharedPreferences-backed) rather than an in-memory static, precisely
    // so it crosses the foreground-app/background-isolate process boundary
    // — see `RefreshPipeline.overlapGuard`'s doc comment. A fresh mock
    // SharedPreferences store each test means each test starts unguarded.
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  const goldCardID = 'card-gold-usd';
  final goldCard = WatchCard(id: goldCardID, instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce);

  Future<
      ({
        WatchlistStore watchlist,
        AlertsStore alerts,
        AlertRuntimeStore runtime,
        _FakeNotificationService notifications,
        _FakePriceRepository repository,
        RefreshPipeline pipeline,
      })> makeHarness(Map<String, double> pricesUSD) async {
    final cloud = LocalOnlyCloudKVStore();
    final watchlistStore = WatchlistStore(cloud: cloud);
    await watchlistStore.upsert(goldCard);

    final alertsStore = AlertsStore(cloud: cloud);
    final runtimeStore = AlertRuntimeStore();
    final notifications = _FakeNotificationService();
    final repository = _FakePriceRepository(pricesUSD);
    final preferences = await Preferences.create(cloud: cloud);

    final pipeline = RefreshPipeline(
      repository: repository,
      watchlistStore: watchlistStore,
      holdingsStore: HoldingsStore(cloud: cloud),
      customInstrumentStore: CustomInstrumentStore(cloud: cloud),
      alertsStore: alertsStore,
      alertRuntimeStore: runtimeStore,
      notificationService: notifications,
      preferences: preferences,
    );

    return (
      watchlist: watchlistStore,
      alerts: alertsStore,
      runtime: runtimeStore,
      notifications: notifications,
      repository: repository,
      pipeline: pipeline,
    );
  }

  group('RefreshPipeline.run (headless, spec Phase 5)', () {
    test('a crossing alert fires exactly once and persists runtime state', () async {
      final h = await makeHarness({'metal.XAU': 1999});
      await h.alerts.upsert(PriceAlert(
        id: 'alert1',
        cardID: goldCardID,
        kind: AlertKind.above,
        target: 2000,
        createdAt: DateTime(2024),
      ));

      // First run: records the baseline (1999 is below target), never fires.
      await h.pipeline.run(isForeground: true, now: DateTime(2024, 6, 1, 12));
      expect(h.notifications.shown, isEmpty);

      // Second run: price crosses above target — fires exactly once.
      h.repository.pricesUSD['metal.XAU'] = 2005;
      await h.pipeline.run(isForeground: true, now: DateTime(2024, 6, 1, 12, 15));
      expect(h.notifications.shown, hasLength(1));
      expect(h.notifications.shown.single.payload, goldCardID);

      final states = await h.runtime.loadAll();
      expect(states['alert1']!.lastSeenPrice, 2005);
      expect(states['alert1']!.lastFiredAt, isNotNull);

      // One-off alert disables itself in the store after firing.
      final alerts = await h.alerts.load();
      expect(alerts.single.enabled, isFalse);
    });

    test('repeat alert can fire again after re-arming', () async {
      final h = await makeHarness({'metal.XAU': 1999});
      await h.alerts.upsert(PriceAlert(
        id: 'alert1',
        cardID: goldCardID,
        kind: AlertKind.above,
        target: 2000,
        repeats: true,
        createdAt: DateTime(2024),
      ));

      await h.pipeline.run(now: DateTime(2024, 6, 1, 12));
      h.repository.pricesUSD['metal.XAU'] = 2005;
      await h.pipeline.run(now: DateTime(2024, 6, 1, 12, 15));
      expect(h.notifications.shown, hasLength(1));

      // Stays above target: no re-fire while still armed-false.
      await h.pipeline.run(now: DateTime(2024, 6, 1, 12, 30));
      expect(h.notifications.shown, hasLength(1));

      // Falls back under target: re-arms, no fire yet.
      h.repository.pricesUSD['metal.XAU'] = 1500;
      await h.pipeline.run(now: DateTime(2024, 6, 1, 12, 45));
      expect(h.notifications.shown, hasLength(1));

      // Crosses again: fires a second time. The alert must still be enabled
      // (repeat alerts never disable themselves).
      h.repository.pricesUSD['metal.XAU'] = 2010;
      await h.pipeline.run(now: DateTime(2024, 6, 1, 13, 0));
      expect(h.notifications.shown, hasLength(2));
      final alerts = await h.alerts.load();
      expect(alerts.single.enabled, isTrue);
    });

    test('never evaluates against a stale/missing price', () async {
      // The fake repository has no price for the gold instrument at all —
      // refreshAll returns an empty map for it, so the pipeline must skip
      // evaluation entirely rather than evaluating against nothing.
      final h = await makeHarness({});
      await h.alerts.upsert(PriceAlert(
        id: 'alert1',
        cardID: goldCardID,
        kind: AlertKind.above,
        target: 2000,
        createdAt: DateTime(2024),
      ));

      await h.pipeline.run(now: DateTime(2024, 6, 1, 12));
      expect(h.notifications.shown, isEmpty);
      final states = await h.runtime.loadAll();
      expect(states, isEmpty);
    });

    test('overlap guard: a background run within a minute of a foreground refresh is skipped entirely', () async {
      final h = await makeHarness({'metal.XAU': 1999});
      await h.alerts.upsert(PriceAlert(
        id: 'alert1',
        cardID: goldCardID,
        kind: AlertKind.above,
        target: 2000,
        createdAt: DateTime(2024),
      ));

      final t0 = DateTime(2024, 6, 1, 12, 0, 0);
      await h.pipeline.run(isForeground: true, now: t0);
      expect(h.repository.refreshAllCallCount, 1);

      // A background run 30 seconds later must be skipped — no fetch, no
      // evaluation — since the foreground refresh already covered this tick.
      h.repository.pricesUSD['metal.XAU'] = 2005;
      await h.pipeline.run(isForeground: false, now: t0.add(const Duration(seconds: 30)));
      expect(h.repository.refreshAllCallCount, 1, reason: 'background run within the overlap guard must not refetch');
      expect(h.notifications.shown, isEmpty);

      // A background run outside the guard window runs normally.
      await h.pipeline.run(isForeground: false, now: t0.add(const Duration(minutes: 2)));
      expect(h.repository.refreshAllCallCount, 2);
      expect(h.notifications.shown, hasLength(1));
    });

    test('percentMove alert evaluated against the converted display series fires once', () async {
      final h = await makeHarness({'metal.XAU': 2000});
      await h.alerts.upsert(PriceAlert(
        id: 'alert1',
        cardID: goldCardID,
        kind: AlertKind.percentMove,
        percent: 0.05,
        direction: AlertDirection.up,
        window: AlertWindow.h24,
        createdAt: DateTime(2024),
      ));

      final t0 = DateTime(2024, 6, 1, 12, 0, 0);
      await h.pipeline.run(now: t0);
      expect(h.notifications.shown, isEmpty);

      // 24h later, price has moved up >5% against the only sample in the
      // window (the one just recorded at t0).
      h.repository.pricesUSD['metal.XAU'] = 2200;
      await h.pipeline.run(now: t0.add(const Duration(hours: 24, minutes: 1)));
      expect(h.notifications.shown, hasLength(1));
    });
  });

  group('RefreshPipeline.evaluateAndNotify (foreground reuse path)', () {
    test('evaluating already-fetched data does not trigger another network refresh', () async {
      final h = await makeHarness({'metal.XAU': 1999});
      await h.alerts.upsert(PriceAlert(
        id: 'alert1',
        cardID: goldCardID,
        kind: AlertKind.above,
        target: 2000,
        createdAt: DateTime(2024),
      ));
      // Prime a baseline below target directly in runtime state — an
      // above/below alert never fires on its very first observation (no
      // crossing to detect yet), so a single evaluateAndNotify call needs a
      // pre-existing lastSeenPrice to be able to observe a crossing at all.
      await h.runtime.updateOne('alert1', (s) => s.copyWith(lastSeenPrice: 1999));

      final alerts = await h.alerts.load();
      final cards = await h.watchlist.load();
      final seriesByID = {
        'metal.XAU': QuoteSeries(
          instrumentID: 'metal.XAU',
          quotes: [Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2024, 6, 1), canonicalUSD: 2005)],
        ),
      };

      await h.pipeline.evaluateAndNotify(
        alerts: alerts,
        cards: cards,
        seriesByID: seriesByID,
        rates: FXRates.usdIdentity,
        fxHistory: (await h.repository.cachedFXHistory()),
        now: DateTime(2024, 6, 1, 12),
      );

      expect(h.repository.refreshAllCallCount, 0, reason: 'evaluateAndNotify must reuse the caller\'s fetch, not refetch');
      expect(h.notifications.shown, hasLength(1));
    });
  });
}
