import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/alert_runtime_state.dart';
import '../models/asset.dart';
import '../models/backup.dart';
import '../models/custom_instrument.dart';
import '../models/fx_history.dart';
import '../models/holding.dart';
import '../models/instrument_catalog.dart';
import '../models/instrument_presentation.dart';
import '../models/money.dart';
import '../models/portfolio_history.dart';
import '../models/price_alert.dart';
import '../models/quote.dart';
import '../models/watch_card.dart';
import '../models/chart_range.dart';
import '../services/alert_runtime_store.dart';
import '../services/alerts_store.dart';
import '../services/app_lock_service.dart';
import '../services/background_refresh.dart';
import '../services/backup/backup_service.dart';
import '../services/custom_instrument_store.dart';
import '../services/holdings_store.dart';
import '../services/notification_service.dart';
import '../services/preferences.dart';
import '../services/home_widget_service.dart';
import '../services/price_converter.dart';
import '../services/price_repository.dart';
import '../services/refresh_pipeline.dart';
import '../services/watchlist_store.dart';
import 'app_state.dart';

/// Central state container mirroring `AppModel.swift` (spec §4.1). Wires the
/// [PriceRepository] and the persisted stores to a single [AppState] the UI
/// observes via `flutter_bloc`.
class AppCubit extends Cubit<AppState> {
  static const _refreshFailedKey = 'error.refreshFailed';

  final PriceRepository repository;
  final WatchlistStore watchlistStore;
  final HoldingsStore holdingsStore;
  final CustomInstrumentStore customInstrumentStore;
  final AppLockService appLockService;
  final AlertsStore alertsStore;
  final AlertRuntimeStore alertRuntimeStore;
  final NotificationService notificationService;
  late Preferences preferences;
  late BackupService backupService;
  RefreshPipeline? _pipeline;

  AppCubit({
    PriceRepository? repository,
    WatchlistStore? watchlistStore,
    HoldingsStore? holdingsStore,
    CustomInstrumentStore? customInstrumentStore,
    AppLockService? appLockService,
    AlertsStore? alertsStore,
    AlertRuntimeStore? alertRuntimeStore,
    NotificationService? notificationService,
  })  : repository = repository ?? PriceRepository(),
        watchlistStore = watchlistStore ?? WatchlistStore(),
        holdingsStore = holdingsStore ?? HoldingsStore(),
        customInstrumentStore = customInstrumentStore ?? CustomInstrumentStore(),
        appLockService = appLockService ?? AppLockService(),
        alertsStore = alertsStore ?? AlertsStore(),
        alertRuntimeStore = alertRuntimeStore ?? AlertRuntimeStore(),
        notificationService = notificationService ?? NotificationService(),
        super(AppState());

  // ---------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------

  Future<void> init() async {
    preferences = await Preferences.create();
    backupService = BackupService(
      watchlistStore: watchlistStore,
      holdingsStore: holdingsStore,
      customInstrumentStore: customInstrumentStore,
      alertsStore: alertsStore,
      preferences: preferences,
    );

    final customs = await customInstrumentStore.load();
    InstrumentCatalog.reloadCustom(customs.map((c) => c.instrument).toList());

    final baseCurrency = await preferences.baseCurrency;
    final widgetRefreshInterval = await preferences.widgetRefreshInterval;
    final appLanguage = await preferences.appLanguage;
    final appearance = await preferences.appearance;
    final preferredChartRange = preferences.preferredChartRange;
    final preferredPortfolioRange = preferences.preferredPortfolioRange;
    final hideBalances = preferences.hideBalances;
    final appLockEnabled = preferences.appLockEnabled;
    final lockGrace = preferences.lockGrace;
    final deliverAlertsOnThisDevice = preferences.deliverAlertsOnThisDevice;

    final seedCards = await preferences.seedWatchcards();
    final cards = await _loadCardsSeeding(watchlistStore, seedCards);
    final alerts = await alertsStore.load();

    final lots = await holdingsStore.load();
    final rates = await repository.cachedRates();
    final fxHistory = await repository.cachedFXHistory();

    final seriesByID = <String, QuoteSeries>{};
    for (final instrument in _trackedInstrumentsFor(cards, lots)) {
      seriesByID[instrument.id] = await repository.cachedSeries(instrument);
    }

    await notificationService.init();
    final notificationsEnabled = await notificationService.isEnabled();

    _pipeline = RefreshPipeline(
      repository: repository,
      watchlistStore: watchlistStore,
      holdingsStore: holdingsStore,
      customInstrumentStore: customInstrumentStore,
      alertsStore: alertsStore,
      alertRuntimeStore: alertRuntimeStore,
      notificationService: notificationService,
      preferences: preferences,
      backupService: backupService,
    );

    // Best-effort: registers the periodic background task on platforms that
    // support it (Android always; iOS opportunistically via BGTaskScheduler
    // — see `background_refresh.dart`). Never blocks/fails init.
    unawaited(BackgroundRefresh.register(interval: widgetRefreshInterval.timeInterval));

    emit(state.copyWith(
      initialized: true,
      baseCurrency: baseCurrency,
      widgetRefreshInterval: widgetRefreshInterval,
      appLanguage: appLanguage,
      appearance: appearance,
      alerts: alerts,
      deliverAlertsOnThisDevice: deliverAlertsOnThisDevice,
      notificationsEnabled: notificationsEnabled,
      preferredChartRange: preferredChartRange,
      preferredPortfolioRange: preferredPortfolioRange,
      cards: cards,
      lots: lots,
      rates: rates,
      fxHistory: fxHistory,
      seriesByID: seriesByID,
      hideBalances: hideBalances,
      appLockEnabled: appLockEnabled,
      lockGrace: lockGrace,
      backupReminderDue: backupService.isReminderDue(),
    ));

    startSync();
  }

  /// Recomputes [AppState.backupReminderDue] from [BackupService] — called
  /// after any user-collection mutation (which marks
  /// `dataChangedSinceLastBackup`) and after a successful export/import, so
  /// the Settings/Backup reminder card appears and disappears immediately
  /// rather than waiting for the next unrelated rebuild.
  ///
  /// [backupService] is only assigned in [init] (it needs the async-created
  /// [Preferences] first) — a handful of unit tests construct [AppCubit]
  /// directly and call a mutator without ever calling [init] (they only
  /// care about the watchlist/holdings mutation itself), so this and
  /// [_markDataChanged] tolerate that by treating an un-initialized
  /// [backupService] as "nothing to do yet" rather than throwing.
  Future<void> _refreshBackupReminder() async {
    if (!_backupServiceReady) return;
    final due = backupService.isReminderDue();
    if (due != state.backupReminderDue) {
      emit(state.copyWith(backupReminderDue: due));
    }
  }

  /// Marks that user data changed since the last backup — called by every
  /// watchlist/holdings/custom-ticker/alert mutator so the Phase 6 backup
  /// reminder only fires when there's actually something new to protect.
  Future<void> _markDataChanged() async {
    if (!_backupServiceReady) return;
    await backupService.setDataChangedSinceLastBackup(true);
    await _refreshBackupReminder();
  }

  bool get _backupServiceReady => backupServiceOrNull != null;

  /// Null-safe access to [backupService] for callers that may run before
  /// [init] has finished (or, in tests, before it's called at all) — [init]
  /// assigns [backupService] only after constructing the async-created
  /// [Preferences] it depends on, so it's genuinely unavailable for a brief
  /// window rather than merely inconvenient to check. UI that wants to show
  /// backup status (see `SettingsScreen`'s `_BackupSection`) reads through
  /// this rather than the `late` field directly, so it degrades to an empty
  /// state instead of crashing when rendered that early.
  BackupService? get backupServiceOrNull {
    try {
      return backupService;
    } on Error {
      // `LateInitializationError` before `init()` has run.
      return null;
    }
  }

  /// [WatchlistStore]'s seed callback is synchronous, but seeding the
  /// default watchlist needs the (async) base currency — so seed once here
  /// and pass the precomputed list through.
  Future<List<WatchCard>> _loadCardsSeeding(WatchlistStore store, List<WatchCard> seed) async {
    // The store was already constructed without a seed closure (it doesn't
    // know about it yet at this point in a from-scratch install); load()
    // will seed from an empty local+cloud state using whatever `seed`
    // callback it was given at construction. Since the default
    // [WatchlistStore] takes no seed, replicate the seeding here directly.
    final loaded = await store.load();
    if (loaded.isNotEmpty) return loaded;
    if (seed.isEmpty) return loaded;
    for (final card in seed) {
      await store.upsert(card);
    }
    return store.load();
  }

  /// No-op placeholder for the iCloud external-change observer — a later
  /// pass can wire a real cloud KV store behind [CloudKVStore] without
  /// touching this method's shape.
  void startSync() {}

  Future<void> adoptCloudChanges() async {
    // No-op: local-only sync in this pass.
  }

  // ---------------------------------------------------------------------
  // Derived helpers
  // ---------------------------------------------------------------------

  List<Instrument> _watchInstrumentsFor(List<WatchCard> cards) {
    final seen = <String>{};
    final result = <Instrument>[];
    for (final card in cards) {
      final instrument = card.instrument;
      if (instrument == null || seen.contains(instrument.id)) continue;
      seen.add(instrument.id);
      result.add(instrument);
    }
    return result;
  }

  List<Instrument> get watchInstruments => _watchInstrumentsFor(state.cards);

  /// Union of watchlist instruments and instruments that have holding lots.
  /// Holdings can reference an instrument the user removed (or never added)
  /// to the watchlist, and without this union those lots would be silently
  /// excluded from refresh/backfill and therefore from portfolio valuation.
  List<Instrument> _trackedInstrumentsFor(List<WatchCard> cards, List<HoldingLot> lots) {
    final result = _watchInstrumentsFor(cards);
    final seen = result.map((i) => i.id).toSet();
    for (final lot in lots) {
      if (seen.contains(lot.instrumentID)) continue;
      final instrument = InstrumentCatalog.instrument(lot.instrumentID);
      if (instrument == null) continue;
      seen.add(instrument.id);
      result.add(instrument);
    }
    return result;
  }

  List<Instrument> get trackedInstruments => _trackedInstrumentsFor(state.cards, state.lots);

  InstrumentPresentation presentation(WatchCard card) {
    final instrument = card.instrument ?? InstrumentCatalog.all.first;
    final converter = PriceConverter(
      rates: state.rates,
      currencyCode: card.currency,
      unit: card.unit,
      karat: card.karat,
      history: state.fxHistory,
    );
    final series = state.seriesByID[instrument.id] ?? QuoteSeries.empty(instrument.id);
    return InstrumentPresentation(instrument: instrument, series: series, converter: converter);
  }

  // ---------------------------------------------------------------------
  // Refresh flow
  // ---------------------------------------------------------------------

  Future<void> refreshIfStale({Duration minInterval = const Duration(seconds: 120)}) async {
    final last = state.lastRefresh;
    if (last == null || DateTime.now().difference(last) > minInterval) {
      await refreshAll();
    }
  }

  Future<void> refreshAll({bool silent = false}) async {
    final instruments = trackedInstruments;
    if (!silent) emit(state.copyWith(phase: RefreshPhase.refreshing, clearError: true));
    try {
      final updated = await repository.refreshAll(instruments);
      final rates = await repository.cachedRates();
      final merged = {...state.seriesByID, ...updated};
      if (updated.isEmpty && instruments.isNotEmpty) {
        emit(state.copyWith(
          phase: RefreshPhase.failed,
          errorMessage: _refreshFailedKey,
          rates: rates,
          seriesByID: merged,
        ));
      } else {
        emit(state.copyWith(
          phase: RefreshPhase.idle,
          clearError: true,
          rates: rates,
          seriesByID: merged,
          lastRefresh: DateTime.now(),
        ));
        if (updated.isNotEmpty) {
          await _evaluateAlertsAfterRefresh(seriesByID: merged, rates: rates);
        }
      }
    } catch (e, st) {
      debugPrint('AppCubit: refreshAll failed: $e\n$st');
      emit(state.copyWith(phase: RefreshPhase.failed, errorMessage: _refreshFailedKey));
    }
    // Fire-and-forget: history is larger and shouldn't block live prices.
    unawaited(backfillHistoryIfNeeded());
  }

  /// Runs alert evaluation for the alerts currently in state against a
  /// just-refreshed price snapshot, via the same [RefreshPipeline] the
  /// background task uses (spec Phase 5) — then reloads alerts from disk in
  /// case a one-off alert just disabled itself, so the UI reflects it
  /// immediately without waiting for the next unrelated state change.
  Future<void> _evaluateAlertsAfterRefresh({
    required Map<String, QuoteSeries> seriesByID,
    required FXRates rates,
  }) async {
    final pipeline = _pipeline;
    if (pipeline == null || state.alerts.isEmpty) return;
    try {
      await pipeline.evaluateAndNotify(
        alerts: state.alerts,
        cards: state.cards,
        seriesByID: seriesByID,
        rates: rates,
        fxHistory: state.fxHistory,
      );
      final reloaded = await alertsStore.load();
      if (reloaded != state.alerts) {
        emit(state.copyWith(alerts: reloaded));
      }
    } catch (e, st) {
      debugPrint('AppCubit: alert evaluation failed: $e\n$st');
    }
  }

  Future<void> backfillHistoryIfNeeded() async {
    if (state.isBackfilling) return;
    emit(state.copyWith(isBackfilling: true));
    try {
      final currencies = <String>{
        ...state.cards.map((c) => c.currency),
        ...InstrumentCatalog.fiat.map((i) => i.symbol),
        state.baseCurrency,
      };
      final fxHistory = await repository.backfillFXHistory(currencies.toList());
      final updated = await repository.backfillInstruments(trackedInstruments, fxHistory);
      if (updated.isNotEmpty || fxHistory != state.fxHistory) {
        emit(state.copyWith(
          fxHistory: fxHistory,
          seriesByID: {...state.seriesByID, ...updated},
        ));
      }
    } finally {
      emit(state.copyWith(isBackfilling: false));
    }
  }

  Future<void> loadHistory(Instrument instrument, String currency) async {
    if (state.isLoadingHistory) return;
    emit(state.copyWith(isLoadingHistory: true));
    try {
      final currencies = <String>{currency, state.baseCurrency};
      if (instrument.assetClass == AssetClass.fiat) currencies.add(instrument.symbol);
      final fxHistory = await repository.backfillFXHistory(currencies.toList(), force: true);
      final result = await repository.backfillInstruments([instrument], fxHistory, force: true);
      emit(state.copyWith(
        fxHistory: fxHistory,
        seriesByID: {...state.seriesByID, ...result},
      ));
    } finally {
      emit(state.copyWith(isLoadingHistory: false));
    }
  }

  Future<void> refresh(Instrument instrument) async {
    emit(state.copyWith(phase: RefreshPhase.refreshing, clearError: true));
    try {
      final series = await repository.refresh(instrument);
      final rates = await repository.cachedRates();
      final merged = {...state.seriesByID, instrument.id: series};
      emit(state.copyWith(
        phase: RefreshPhase.idle,
        clearError: true,
        rates: rates,
        seriesByID: merged,
        lastRefresh: DateTime.now(),
      ));
      await _evaluateAlertsAfterRefresh(seriesByID: merged, rates: rates);
    } catch (e, st) {
      debugPrint('AppCubit: refresh(${instrument.id}) failed: $e\n$st');
      emit(state.copyWith(phase: RefreshPhase.failed, errorMessage: _refreshFailedKey));
    }
  }

  // ---------------------------------------------------------------------
  // Watchlist mutations
  // ---------------------------------------------------------------------

  /// Adds [card] to the watchlist, unless a card with the same
  /// instrument/currency/unit/karat combo already exists — in which case the
  /// EXISTING card is returned with `created: false` instead of adding a
  /// duplicate. Callers use `created` to decide whether to show an "added"
  /// or "already in your watchlist" confirmation (see `AddFlowNavigation`).
  Future<({WatchCard card, bool created})> addCard(WatchCard card) async {
    for (final c in state.cards) {
      if (c.isSameCombo(card)) return (card: c, created: false);
    }

    final isNewInstrument = card.instrument != null && !state.seriesByID.containsKey(card.instrumentID);
    final cards = await watchlistStore.upsert(card);
    emit(state.copyWith(cards: cards));
    unawaited(_markDataChanged());

    if (isNewInstrument) {
      final instrument = card.instrument!;
      final cached = await repository.cachedSeries(instrument);
      emit(state.copyWith(seriesByID: {...state.seriesByID, instrument.id: cached}));
      unawaited(refresh(instrument));
      unawaited(backfillHistoryIfNeeded());
    }
    return (card: card, created: true);
  }

  /// Reverses a just-completed add-instrument flow: removes [card] from the
  /// watchlist, and — if [customInstrumentID] is given (the ticker was
  /// created fresh in that same flow, not a pre-existing custom ticker) —
  /// also removes the custom instrument itself, but only when no other
  /// watchlist card still references it (a user could have added the same
  /// freshly-created ticker at two currencies before hitting Undo on one).
  Future<void> undoAdd(WatchCard card, {String? customInstrumentID}) async {
    await removeCard(card.id);
    if (customInstrumentID == null) return;
    final stillUsed = state.cards.any((c) => c.instrumentID == customInstrumentID);
    if (!stillUsed) {
      await removeCustomInstrument(customInstrumentID);
    }
  }

  Future<void> updateCard(WatchCard card) async {
    final cards = await watchlistStore.upsert(card);
    emit(state.copyWith(cards: cards));
    unawaited(_markDataChanged());
  }

  Future<void> removeCard(String id) async {
    final cards = await watchlistStore.delete(id);
    emit(state.copyWith(cards: cards));
    unawaited(_markDataChanged());
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= state.cards.length) return;
    await removeCard(state.cards[index].id);
  }

  Future<void> move(int fromIndex, int toIndex) async {
    final cards = List.of(state.cards);
    final item = cards.removeAt(fromIndex);
    cards.insert(toIndex > fromIndex ? toIndex - 1 : toIndex, item);
    emit(state.copyWith(cards: cards));
    await watchlistStore.setOrder(cards.map((c) => c.id).toList());
    unawaited(_markDataChanged());
  }

  // ---------------------------------------------------------------------
  // Custom tickers
  // ---------------------------------------------------------------------

  List<CustomInstrument> _customCache = const [];

  Future<List<CustomInstrument>> customInstruments() async {
    _customCache = await customInstrumentStore.load();
    return _customCache;
  }

  bool isCustom(String instrumentID) {
    final builtInIds = InstrumentCatalog.builtIn.map((i) => i.id).toSet();
    final resolved = InstrumentCatalog.instrument(instrumentID) != null;
    return resolved && !builtInIds.contains(instrumentID);
  }

  Future<Instrument> validateCustomTicker(String symbol, String? name, {AssetClass assetClass = AssetClass.stock}) async {
    final candidate = CustomInstrument(symbol: symbol, name: name, assetClass: assetClass);
    await repository.probePrice(candidate.instrument);
    return candidate.instrument;
  }

  Future<Instrument> addCustomTicker(String symbol, String? name, {AssetClass assetClass = AssetClass.stock}) async {
    final candidate = CustomInstrument(symbol: symbol, name: name, assetClass: assetClass);
    await customInstrumentStore.upsert(candidate);
    final customs = await customInstrumentStore.load();
    InstrumentCatalog.reloadCustom(customs.map((c) => c.instrument).toList());
    unawaited(_markDataChanged());
    return candidate.instrument;
  }

  Future<void> removeCustomInstrument(String instrumentID) async {
    final customs = await customInstrumentStore.load();
    CustomInstrument? match;
    for (final c in customs) {
      if (c.instrumentID == instrumentID) {
        match = c;
        break;
      }
    }
    if (match != null) {
      await customInstrumentStore.delete(match.id);
      unawaited(_markDataChanged());
      final reloaded = await customInstrumentStore.load();
      InstrumentCatalog.reloadCustom(reloaded.map((c) => c.instrument).toList());
    }
    final toRemove = state.cards.where((c) => c.instrumentID == instrumentID).map((c) => c.id).toList();
    for (final id in toRemove) {
      await removeCard(id);
    }
  }

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------

  Future<void> setBaseCurrency(String value) async {
    if (value == state.baseCurrency) return;
    await preferences.setBaseCurrency(value);
    emit(state.copyWith(baseCurrency: value));
  }

  Future<void> setAppLanguage(AppLanguage value) async {
    if (value == state.appLanguage) return;
    await preferences.setAppLanguage(value);
    emit(state.copyWith(appLanguage: value));
  }

  Future<void> setAppearance(Appearance value) async {
    if (value == state.appearance) return;
    await preferences.setAppearance(value);
    emit(state.copyWith(appearance: value));
  }

  Future<void> setPreferredChartRange(ChartRange value) async {
    if (value.isExtended || value == state.preferredChartRange) return;
    await preferences.setPreferredChartRange(value);
    emit(state.copyWith(preferredChartRange: value));
  }

  Future<void> setPreferredPortfolioRange(ChartRange value) async {
    if (!ChartRange.portfolioSelectable.contains(value) || value == state.preferredPortfolioRange) return;
    await preferences.setPreferredPortfolioRange(value);
    emit(state.copyWith(preferredPortfolioRange: value));
  }

  Future<void> setWidgetRefreshInterval(WidgetRefreshInterval value) async {
    if (value == state.widgetRefreshInterval) return;
    await preferences.setWidgetRefreshInterval(value);
    emit(state.copyWith(widgetRefreshInterval: value));
    // Re-registering replaces the periodic task with the new cadence
    // (Android: `ExistingPeriodicWorkPolicy.update`; iOS: the next
    // BGTaskScheduler submission simply uses the new earliest-begin delay —
    // see `background_refresh.dart`), so this finally gives the setting a
    // real effect (spec Phase 5).
    unawaited(BackgroundRefresh.register(interval: value.timeInterval));
  }

  // ---------------------------------------------------------------------
  // Privacy: hide balances + app lock
  // ---------------------------------------------------------------------

  Future<void> toggleHideBalances() async {
    final value = !state.hideBalances;
    await preferences.setHideBalances(value);
    emit(state.copyWith(hideBalances: value));
  }

  Future<void> setHideBalances(bool value) async {
    if (value == state.hideBalances) return;
    await preferences.setHideBalances(value);
    emit(state.copyWith(hideBalances: value));
  }

  /// Enabling app lock requires a successful authentication first — the
  /// user proves they can actually unlock before the app starts depending on
  /// it. Returns whether the setting ended up enabled: `true` on success,
  /// `false` if authentication failed/was cancelled (the switch should
  /// bounce back to off). Disabling never needs authentication.
  Future<bool> setAppLockEnabled(bool value, {String reason = 'Confirm it\'s you to enable App lock'}) async {
    if (!value) {
      await preferences.setAppLockEnabled(false);
      emit(state.copyWith(appLockEnabled: false));
      return true;
    }
    final authenticated = await appLockService.authenticate(reason: reason);
    if (!authenticated) return false;
    await preferences.setAppLockEnabled(true);
    emit(state.copyWith(appLockEnabled: true));
    return true;
  }

  Future<void> setLockGrace(LockGrace value) async {
    if (value == state.lockGrace) return;
    await preferences.setLockGrace(value);
    emit(state.copyWith(lockGrace: value));
  }

  // ---------------------------------------------------------------------
  // Holdings
  // ---------------------------------------------------------------------

  double? latestUSD(String instrumentID) => state.seriesByID[instrumentID]?.latest?.canonicalUSD;

  List<HoldingLot> lotsFor(Instrument instrument) {
    final list = state.lots.where((l) => l.instrumentID == instrument.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  HoldingValuation? valuationFor(Instrument instrument, String currency) {
    return HoldingValuation.aggregate(
      lots: lotsFor(instrument),
      rates: state.rates,
      displayCurrency: currency,
      latestUSD: latestUSD,
    );
  }

  HoldingValuation? valuationForLot(HoldingLot lot, String currency) {
    return HoldingValuation.aggregate(
      lots: [lot],
      rates: state.rates,
      displayCurrency: currency,
      latestUSD: latestUSD,
    );
  }

  HoldingValuation? get portfolioValuation => HoldingValuation.aggregate(
        lots: state.lots,
        rates: state.rates,
        displayCurrency: state.baseCurrency,
        latestUSD: latestUSD,
      );

  List<HeldInstrument> get heldInstruments {
    final seen = <String>{};
    final result = <HeldInstrument>[];
    for (final lot in state.lots) {
      if (seen.contains(lot.instrumentID)) continue;
      seen.add(lot.instrumentID);
      final instrument = InstrumentCatalog.instrument(lot.instrumentID);
      if (instrument == null) continue;
      final valuation = valuationFor(instrument, state.baseCurrency);
      if (valuation == null) continue;
      result.add(HeldInstrument(
        instrument: instrument,
        valuation: valuation,
        lotCount: lotsFor(instrument).length,
      ));
    }
    result.sort((a, b) => b.valuation.value.amount.compareTo(a.valuation.value.amount));
    return result;
  }

  WatchCard? firstCard(Instrument instrument) {
    for (final card in state.cards) {
      if (card.instrumentID == instrument.id) return card;
    }
    return null;
  }

  double? totalQuantity(Instrument instrument, PriceUnit unit) {
    final lots = lotsFor(instrument);
    if (lots.isEmpty) return null;
    double canonical = 0;
    for (final lot in lots) {
      canonical += lot.quantity * lot.unit.multiplier;
    }
    return canonical / unit.multiplier;
  }

  double? averageCost(Instrument instrument, String currency, PriceUnit unit) {
    final valuation = valuationFor(instrument, currency);
    final avgUSD = valuation?.averageUnitCostUSD;
    if (avgUSD == null) return null;
    final converter = PriceConverter(rates: state.rates, currencyCode: currency, unit: unit);
    return converter.money(avgUSD).amount;
  }

  Future<void> saveLot(HoldingLot lot) async {
    final lots = await holdingsStore.upsert(lot);
    emit(state.copyWith(lots: lots));
    unawaited(_markDataChanged());
  }

  Future<void> deleteLot(HoldingLot lot) async {
    final lots = await holdingsStore.delete(lot.id);
    emit(state.copyWith(lots: lots));
    unawaited(_markDataChanged());
  }

  // ---------------------------------------------------------------------
  // Price alerts
  // ---------------------------------------------------------------------

  List<PriceAlert> alertsFor(String cardID) => state.alerts.where((a) => a.cardID == cardID).toList();

  Future<void> saveAlert(PriceAlert alert) async {
    final alerts = await alertsStore.upsert(alert);
    emit(state.copyWith(alerts: alerts));
    unawaited(_markDataChanged());
  }

  Future<void> deleteAlert(PriceAlert alert) async {
    final alerts = await alertsStore.delete(alert.id);
    emit(state.copyWith(alerts: alerts));
    unawaited(_markDataChanged());
  }

  Future<void> setAlertEnabled(PriceAlert alert, bool enabled) async {
    if (alert.enabled == enabled) return;
    await saveAlert(alert.copyWith(enabled: enabled));
  }

  /// The alert's per-device runtime state (last fired time, armed) — read
  /// straight from [alertRuntimeStore] since it's deliberately not part of
  /// [AppState]/[PriceAlert] (never synced, see `alert_runtime_state.dart`).
  Future<AlertRuntimeState> runtimeStateFor(String alertId) async {
    final all = await alertRuntimeStore.loadAll();
    return alertRuntimeStore.stateFor(all, alertId);
  }

  Future<void> setDeliverAlertsOnThisDevice(bool value) async {
    if (value == state.deliverAlertsOnThisDevice) return;
    await preferences.setDeliverAlertsOnThisDevice(value);
    emit(state.copyWith(deliverAlertsOnThisDevice: value));
  }

  /// Requests OS notification permission (Android 13+, iOS/macOS) and
  /// refreshes [AppState.notificationsEnabled] from the result, so the
  /// Alerts/Settings screens' "Notifications are off" banner updates
  /// immediately rather than waiting for the next unrelated rebuild.
  Future<bool> requestNotificationPermission() async {
    final granted = await notificationService.requestPermission();
    await refreshNotificationStatus();
    return granted;
  }

  Future<void> refreshNotificationStatus() async {
    final enabled = await notificationService.isEnabled();
    if (enabled != state.notificationsEnabled) {
      emit(state.copyWith(notificationsEnabled: enabled));
    }
  }

  // ---------------------------------------------------------------------
  // Backup & restore (spec Phase 6)
  // ---------------------------------------------------------------------

  /// Applies an already-decoded, already-decrypted [payload] to every store
  /// in [mode] via [BackupService.import], then reloads every store and
  /// preference back into [AppState] — so the app reflects the restored
  /// data immediately rather than requiring a restart. Called only after
  /// `ImportPreviewScreen` has a fully validated [BackupPayload] in hand
  /// (see `BackupCodec.decodePayload`), so nothing here can partially apply
  /// a corrupt/mistyped file.
  Future<void> restoreFromBackup(BackupPayload payload, {required BackupImportMode mode}) async {
    await backupService.import(payload, mode: mode);
    await _reloadAllStores();
    await _refreshBackupReminder();
  }

  /// Re-reads every synced collection and syncable preference from disk and
  /// re-emits them into [AppState] — used after a restore (and safe to call
  /// any time local storage might have changed out from under the in-memory
  /// state).
  Future<void> _reloadAllStores() async {
    final customs = await customInstrumentStore.load();
    InstrumentCatalog.reloadCustom(customs.map((c) => c.instrument).toList());

    final cards = await watchlistStore.load();
    final lots = await holdingsStore.load();
    final alerts = await alertsStore.load();
    final baseCurrency = await preferences.baseCurrency;
    final appLanguage = await preferences.appLanguage;
    final appearance = await preferences.appearance;
    final preferredChartRange = preferences.preferredChartRange;
    final widgetRefreshInterval = await preferences.widgetRefreshInterval;

    final seriesByID = <String, QuoteSeries>{...state.seriesByID};
    for (final instrument in _trackedInstrumentsFor(cards, lots)) {
      if (seriesByID.containsKey(instrument.id)) continue;
      seriesByID[instrument.id] = await repository.cachedSeries(instrument);
    }

    emit(state.copyWith(
      cards: cards,
      lots: lots,
      alerts: alerts,
      baseCurrency: baseCurrency,
      appLanguage: appLanguage,
      appearance: appearance,
      preferredChartRange: preferredChartRange,
      widgetRefreshInterval: widgetRefreshInterval,
      seriesByID: seriesByID,
    ));

    unawaited(refreshAll());
    unawaited(BackgroundRefresh.register(interval: widgetRefreshInterval.timeInterval));
  }

  // ---------------------------------------------------------------------
  // Portfolio history (watchlist hero chart)
  // ---------------------------------------------------------------------

  /// Memoization cache for [portfolioHistory], keyed on the exact set of
  /// inputs that can change its output. [PortfolioHistory.build] walks every
  /// tracked lot's full quote/FX series, which is too expensive to redo on
  /// every `build()` (e.g. every scrub-driven rebuild of the hero chart) —
  /// so this cubit computes it once per distinct (range, lots, seriesByID,
  /// fxHistory, baseCurrency) tuple and reuses the result until one of those
  /// actually changes. [AppState] fields are immutable/structurally-equal
  /// (`Equatable`/unmodifiable lists), so identity/equality checks here are
  /// cheap and correct.
  ChartRange? _historyCacheRange;
  List<HoldingLot>? _historyCacheLots;
  Map<String, QuoteSeries>? _historyCacheSeries;
  FXHistory? _historyCacheFxHistory;
  String? _historyCacheBaseCurrency;
  DateTime? _historyCacheDay;
  List<PortfolioHistoryPoint>? _historyCacheResult;

  /// Day-by-day portfolio value/cost for [range], computed fresh from lots
  /// and quote/FX history (never snapshotted — see `portfolio_history.dart`).
  /// Cheap to call repeatedly: results are memoized until lots, prices, FX
  /// history or the base currency actually change, or a new calendar day
  /// starts (so "All"/"1Y" etc. extend to include today).
  List<PortfolioHistoryPoint> portfolioHistory(ChartRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_historyCacheRange == range &&
        identical(_historyCacheLots, state.lots) &&
        identical(_historyCacheSeries, state.seriesByID) &&
        identical(_historyCacheFxHistory, state.fxHistory) &&
        _historyCacheBaseCurrency == state.baseCurrency &&
        _historyCacheDay == today) {
      return _historyCacheResult!;
    }

    final result = PortfolioHistory.build(
      lots: state.lots,
      seriesByID: state.seriesByID,
      rates: state.rates,
      fxHistory: state.fxHistory,
      baseCurrency: state.baseCurrency,
      range: range,
      now: now,
    );

    _historyCacheRange = range;
    _historyCacheLots = state.lots;
    _historyCacheSeries = state.seriesByID;
    _historyCacheFxHistory = state.fxHistory;
    _historyCacheBaseCurrency = state.baseCurrency;
    _historyCacheDay = today;
    _historyCacheResult = result;
    return result;
  }

  /// Change in GAIN (value − cost), not value, over [range] — so adding a
  /// new lot mid-range is never shown as if it were profit. Null when there
  /// isn't at least one point on or before the range's start (e.g. the
  /// range predates every lot, or the portfolio is empty).
  PortfolioRangeChange? portfolioChange(ChartRange range) {
    final points = portfolioHistory(range);
    if (points.isEmpty) return null;
    final first = points.first;
    final last = points.last;
    final gainDelta = last.gain - first.gain;
    final valueDelta = last.value - first.value;
    final denominator = first.cost != 0 ? first.cost : first.value;
    final fraction = denominator != 0 ? gainDelta / denominator : 0.0;
    return PortfolioRangeChange(
      gainDelta: gainDelta,
      valueDelta: valueDelta,
      percentValue: fraction,
      isUp: gainDelta >= 0,
      latestValue: last.value,
    );
  }

  // ---------------------------------------------------------------------
  // Home-screen widgets (Android Glance + iOS/macOS WidgetKit)
  // ---------------------------------------------------------------------

  /// Every state change that could move a widget-visible number (a price
  /// tick, an FX rate refresh, a watchlist or holdings edit) republishes the
  /// widget data contract — see [HomeWidgetService] for the payload shape
  /// and the "first card stands in for the configured instrument"
  /// limitation. This is the single choke point for that fan-out so no
  /// individual mutator method needs to remember to call it.
  @override
  void onChange(Change<AppState> change) {
    super.onChange(change);
    final next = change.nextState;
    if (!next.initialized) return;
    final prev = change.currentState;
    final widgetRelevant = prev.seriesByID != next.seriesByID ||
        prev.rates != next.rates ||
        prev.fxHistory != next.fxHistory ||
        prev.cards != next.cards ||
        prev.lots != next.lots ||
        prev.baseCurrency != next.baseCurrency ||
        prev.hideBalances != next.hideBalances;
    if (widgetRelevant) {
      unawaited(HomeWidgetService.publish(next));
    }
  }
}
