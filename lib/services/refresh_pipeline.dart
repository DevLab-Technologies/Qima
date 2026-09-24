import 'dart:ui';

import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/alert_evaluation.dart';
import '../models/asset.dart';
import '../models/fx_history.dart';
import '../models/holding.dart';
import '../models/instrument_catalog.dart';
import '../models/money.dart';
import '../models/price_alert.dart';
import '../models/quote.dart';
import '../models/watch_card.dart';
import '../theme/strings.dart';
import 'alert_evaluator.dart';
import 'alert_runtime_store.dart';
import 'alerts_store.dart';
import 'custom_instrument_store.dart';
import 'holdings_store.dart';
import 'home_widget_service.dart';
import 'notification_service.dart';
import 'preferences.dart';
import 'price_converter.dart';
import 'price_repository.dart';
import 'watchlist_store.dart';

/// The single place a price refresh, alert evaluation, notification and
/// widget publish all happen together — used by BOTH the foreground
/// (`AppCubit.refreshAll`) and the background task (spec Phase 5). Having
/// exactly one implementation is what guarantees an alert is evaluated
/// exactly once per refresh regardless of which caller triggered it, and
/// that the foreground and a background run can never both fire the same
/// alert for the same price move (see [overlapGuard]).
///
/// Deliberately independent of [AppCubit]/`BuildContext` — it's constructed
/// straight from stores and the repository so the exact same code path runs
/// headless inside a `workmanager` background isolate, which has no cubit,
/// no widget tree and no localized `BuildContext` (notification strings are
/// therefore resolved via a plain [AppLocalizations] instance, not
/// `AppLocalizations.of(context)`).
class RefreshPipeline {
  final PriceRepository repository;
  final WatchlistStore watchlistStore;
  final HoldingsStore holdingsStore;
  final CustomInstrumentStore customInstrumentStore;
  final AlertsStore alertsStore;
  final AlertRuntimeStore alertRuntimeStore;
  final NotificationService notificationService;
  final Preferences preferences;
  final AlertEvaluator evaluator;

  RefreshPipeline({
    required this.repository,
    required this.watchlistStore,
    required this.holdingsStore,
    required this.customInstrumentStore,
    required this.alertsStore,
    required this.alertRuntimeStore,
    required this.notificationService,
    required this.preferences,
    AlertEvaluator? evaluator,
  }) : evaluator = evaluator ?? const AlertEvaluator();

  /// A `run(isForeground: false)` background call skips alert evaluation
  /// entirely — no fetch, no evaluation — if a prior evaluation from EITHER
  /// the foreground app or a background task already ran within the last
  /// minute: the guard against double-firing an alert when the foreground
  /// timer and a background task overlap (spec Phase 5 "Guard against
  /// double evaluation").
  ///
  /// Persisted via [Preferences.lastAlertEvaluationAt] (backed by
  /// `SharedPreferences`, a real file) rather than an in-memory field: the
  /// foreground app and a `workmanager` background task run as separate Dart
  /// VM instances in separate processes, so an in-memory-only guard could
  /// never actually see the other side's timestamp — only a value persisted
  /// to shared storage crosses that boundary.
  static const Duration overlapGuard = Duration(minutes: 1);

  Future<void> markForegroundRefresh([DateTime? at]) {
    return preferences.setLastAlertEvaluationAt(at ?? DateTime.now());
  }

  bool _withinOverlapGuard(DateTime now) {
    final last = preferences.lastAlertEvaluationAt;
    if (last == null) return false;
    return now.difference(last) < overlapGuard;
  }

  /// Runs one full HEADLESS pass: loads cards/lots/alerts fresh from disk,
  /// refreshes prices for every watched/held instrument, evaluates alerts,
  /// notifies for anything that fired, and republishes the home-screen
  /// widgets. This is what the background task calls (spec Phase 5) — it has
  /// no cubit/state to reuse, so it does its own full fetch.
  ///
  /// [isForeground] is only ever `true` when a caller wants the SAME fetch
  /// path outside a cubit (e.g. a headless CLI/test run); the real foreground
  /// app instead calls [evaluateAndNotify] directly from `AppCubit.refreshAll`
  /// so the network fetch and widget publish happen exactly once, not twice.
  /// Background runs (`isForeground: false`) are skipped entirely — no
  /// fetch, no evaluation — when ANY evaluation (foreground or background)
  /// happened within [overlapGuard], since that already did this same work;
  /// the timestamp itself is stamped once evaluation actually runs, inside
  /// [evaluateAndNotify], not here.
  Future<void> run({bool isForeground = false, DateTime? now, AppLocalizations? l10n}) async {
    final effectiveNow = now ?? DateTime.now();

    if (!isForeground && _withinOverlapGuard(effectiveNow)) {
      return;
    }

    final customs = await customInstrumentStore.load();
    InstrumentCatalog.reloadCustom(customs.map((c) => c.instrument).toList());

    final cards = await watchlistStore.load();
    final lots = await holdingsStore.load();
    final alerts = await alertsStore.load();
    final baseCurrency = await preferences.baseCurrency;

    final instruments = _trackedInstruments(cards, lots);
    if (instruments.isEmpty) return;

    final updatedSeries = await repository.refreshAll(instruments, now: effectiveNow);
    if (updatedSeries.isEmpty) return;

    final rates = await repository.cachedRates();
    final fxHistory = await repository.cachedFXHistory();

    await evaluateAndNotify(
      alerts: alerts,
      cards: cards,
      seriesByID: updatedSeries,
      rates: rates,
      fxHistory: fxHistory,
      now: effectiveNow,
      l10n: l10n,
    );

    await _publishWidgets(
      cards: cards,
      lots: lots,
      seriesByID: updatedSeries,
      rates: rates,
      fxHistory: fxHistory,
      baseCurrency: baseCurrency,
    );
  }

  /// Evaluates [alerts] against already-fetched [seriesByID]/[rates] and
  /// notifies for anything that fired — the half of [run] the FOREGROUND app
  /// calls directly (via `AppCubit.refreshAll`) once it already has a fresh
  /// refresh result, so prices are never fetched twice for one refresh.
  /// Also stamps [markForegroundRefresh] so a background run that overlaps
  /// this one skips evaluating the same price tick again (spec Phase 5:
  /// "Guard against double evaluation").
  Future<void> evaluateAndNotify({
    required List<PriceAlert> alerts,
    required List<WatchCard> cards,
    required Map<String, QuoteSeries> seriesByID,
    required FXRates rates,
    required FXHistory fxHistory,
    DateTime? now,
    AppLocalizations? l10n,
  }) async {
    final effectiveNow = now ?? DateTime.now();
    await markForegroundRefresh(effectiveNow);
    if (alerts.isEmpty) return;

    final deliverOnThisDevice = preferences.deliverAlertsOnThisDevice;
    await _evaluateAlerts(
      alerts: alerts,
      cards: cards,
      seriesByID: seriesByID,
      rates: rates,
      fxHistory: fxHistory,
      now: effectiveNow,
      deliverOnThisDevice: deliverOnThisDevice,
      l10n: l10n,
    );
    await alertRuntimeStore.pruneMissing(alerts.map((a) => a.id).toSet());
  }

  List<Instrument> _trackedInstruments(List<WatchCard> cards, List<HoldingLot> lots) {
    final seen = <String>{};
    final result = <Instrument>[];
    for (final card in cards) {
      final instrument = card.instrument;
      if (instrument == null || seen.contains(instrument.id)) continue;
      seen.add(instrument.id);
      result.add(instrument);
    }
    for (final lot in lots) {
      if (seen.contains(lot.instrumentID)) continue;
      final instrument = InstrumentCatalog.instrument(lot.instrumentID);
      if (instrument == null) continue;
      seen.add(instrument.id);
      result.add(instrument);
    }
    return result;
  }

  Future<void> _evaluateAlerts({
    required List<PriceAlert> alerts,
    required List<WatchCard> cards,
    required Map<String, QuoteSeries> seriesByID,
    required FXRates rates,
    required FXHistory fxHistory,
    required DateTime now,
    required bool deliverOnThisDevice,
    AppLocalizations? l10n,
  }) async {
    final cardsByID = {for (final c in cards) c.id: c};
    final runtimeStates = await alertRuntimeStore.loadAll();

    for (final alert in alerts) {
      final card = cardsByID[alert.cardID];
      if (card == null) continue; // Card was removed; leave the orphaned alert alone (surfaced in the Alerts screen).
      final instrument = card.instrument;
      if (instrument == null) continue;
      final series = seriesByID[instrument.id];
      if (series == null || series.isEmpty) continue; // Never evaluate against a stale/missing price.

      final converter = PriceConverter(
        rates: rates,
        currencyCode: card.currency,
        unit: card.unit,
        karat: card.karat,
        history: fxHistory,
      );
      if (!converter.canConvert) continue;

      final currentPrice = converter.moneyForQuote(series.latest!).amount;
      final runtimeState = alertRuntimeStore.stateFor(runtimeStates, alert.id);

      final evaluation = evaluator.evaluate(
        alert: alert,
        currentPrice: currentPrice,
        lastSeenPrice: runtimeState.lastSeenPrice,
        armed: runtimeState.armed,
        now: now,
        pointsForWindow: alert.kind == AlertKind.percentMove ? () => converter.points(series) : null,
      );

      await alertRuntimeStore.updateOne(alert.id, (_) {
        return runtimeState.copyWith(
          lastSeenPrice: evaluation.newLastSeenPrice,
          armed: evaluation.newArmed,
          lastFiredAt: evaluation.fired ? now : runtimeState.lastFiredAt,
        );
      });

      if (evaluation.disableAlert) {
        await alertsStore.upsert(alert.copyWith(enabled: false));
      }

      if (evaluation.fired && deliverOnThisDevice) {
        await _notify(
          alert: alert,
          card: card,
          instrument: instrument,
          converter: converter,
          reason: evaluation.fire!,
          l10n: l10n,
        );
      }
    }
  }

  Future<void> _notify({
    required PriceAlert alert,
    required WatchCard card,
    required Instrument instrument,
    required PriceConverter converter,
    required AlertFireReason reason,
    AppLocalizations? l10n,
  }) async {
    final strings = l10n ?? await AppLocalizations.delegate.load(PlatformDispatcher.instance.locale);
    final name = displayLabelFor(strings, instrument.nameKey);
    final priceText = converter.money(reason.currentPrice).formatted(useFallbackSymbol: true);
    final unitText = card.unit.abbreviationKey ?? '';

    final String title;
    switch (reason.kind) {
      case AlertKind.above:
        title = strings.alertNotificationTitleAbove(name, converter.money(alert.target).formatted(useFallbackSymbol: true));
        break;
      case AlertKind.below:
        title = strings.alertNotificationTitleBelow(name, converter.money(alert.target).formatted(useFallbackSymbol: true));
        break;
      case AlertKind.percentMove:
        final percentText = ((reason.percentChange ?? 0).abs() * 100).toStringAsFixed(1);
        final windowLabel = alert.window == AlertWindow.h24 ? strings.alertWindow24h : strings.alertWindow7d;
        title = strings.alertNotificationTitlePercent(name, percentText, windowLabel);
        break;
    }

    final body = alert.repeats
        ? strings.alertNotificationBodyRepeat(priceText, unitText)
        : strings.alertNotificationBodyOneOff(priceText, unitText);

    await notificationService.show(
      id: notificationIdFor(alert.id),
      title: title,
      body: body,
      payload: card.id,
    );
  }

  Future<void> _publishWidgets({
    required List<WatchCard> cards,
    required List<HoldingLot> lots,
    required Map<String, QuoteSeries> seriesByID,
    required FXRates rates,
    required FXHistory fxHistory,
    required String baseCurrency,
  }) async {
    final hideBalances = preferences.hideBalances;
    final state = AppState(
      initialized: true,
      cards: cards,
      lots: lots,
      seriesByID: seriesByID,
      rates: rates,
      fxHistory: fxHistory,
      baseCurrency: baseCurrency,
      hideBalances: hideBalances,
    );
    await HomeWidgetService.publish(state);
  }
}
