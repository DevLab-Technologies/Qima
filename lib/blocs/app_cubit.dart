import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/asset.dart';
import '../models/custom_instrument.dart';
import '../models/holding.dart';
import '../models/instrument_catalog.dart';
import '../models/instrument_presentation.dart';
import '../models/quote.dart';
import '../models/watch_card.dart';
import '../models/chart_range.dart';
import '../services/custom_instrument_store.dart';
import '../services/holdings_store.dart';
import '../services/preferences.dart';
import '../services/home_widget_service.dart';
import '../services/price_converter.dart';
import '../services/price_repository.dart';
import '../services/watchlist_store.dart';
import 'app_state.dart';

/// Central state container mirroring `AppModel.swift` (spec §4.1). Wires the
/// [PriceRepository] and the persisted stores to a single [AppState] the UI
/// observes via `flutter_bloc`.
class AppCubit extends Cubit<AppState> {
  final PriceRepository repository;
  final WatchlistStore watchlistStore;
  final HoldingsStore holdingsStore;
  final CustomInstrumentStore customInstrumentStore;
  late Preferences preferences;

  AppCubit({
    PriceRepository? repository,
    WatchlistStore? watchlistStore,
    HoldingsStore? holdingsStore,
    CustomInstrumentStore? customInstrumentStore,
  })  : repository = repository ?? PriceRepository(),
        watchlistStore = watchlistStore ?? WatchlistStore(),
        holdingsStore = holdingsStore ?? HoldingsStore(),
        customInstrumentStore = customInstrumentStore ?? CustomInstrumentStore(),
        super(AppState());

  // ---------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------

  Future<void> init() async {
    preferences = await Preferences.create();

    final customs = await customInstrumentStore.load();
    InstrumentCatalog.reloadCustom(customs.map((c) => c.instrument).toList());

    final baseCurrency = await preferences.baseCurrency;
    final widgetRefreshInterval = await preferences.widgetRefreshInterval;
    final appLanguage = await preferences.appLanguage;
    final preferredChartRange = preferences.preferredChartRange;

    final seedCards = await preferences.seedWatchcards();
    final cards = await _loadCardsSeeding(watchlistStore, seedCards);

    final lots = await holdingsStore.load();
    final rates = await repository.cachedRates();
    final fxHistory = await repository.cachedFXHistory();

    final seriesByID = <String, QuoteSeries>{};
    for (final instrument in _watchInstrumentsFor(cards)) {
      seriesByID[instrument.id] = await repository.cachedSeries(instrument);
    }

    emit(state.copyWith(
      initialized: true,
      baseCurrency: baseCurrency,
      widgetRefreshInterval: widgetRefreshInterval,
      appLanguage: appLanguage,
      preferredChartRange: preferredChartRange,
      cards: cards,
      lots: lots,
      rates: rates,
      fxHistory: fxHistory,
      seriesByID: seriesByID,
    ));

    startSync();
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
    final instruments = watchInstruments;
    if (!silent) emit(state.copyWith(phase: RefreshPhase.refreshing, clearError: true));
    try {
      final updated = await repository.refreshAll(instruments);
      final rates = await repository.cachedRates();
      final merged = {...state.seriesByID, ...updated};
      if (updated.isEmpty && instruments.isNotEmpty) {
        emit(state.copyWith(
          phase: RefreshPhase.failed,
          errorMessage: 'error.refreshFailed',
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
      }
    } catch (e) {
      emit(state.copyWith(phase: RefreshPhase.failed, errorMessage: e.toString()));
    }
    // Fire-and-forget: history is larger and shouldn't block live prices.
    unawaited(backfillHistoryIfNeeded());
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
      final updated = await repository.backfillInstruments(watchInstruments, fxHistory);
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
      emit(state.copyWith(
        phase: RefreshPhase.idle,
        clearError: true,
        rates: rates,
        seriesByID: {...state.seriesByID, instrument.id: series},
        lastRefresh: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(phase: RefreshPhase.failed, errorMessage: e.toString()));
    }
  }

  // ---------------------------------------------------------------------
  // Watchlist mutations
  // ---------------------------------------------------------------------

  Future<void> addCard(WatchCard card) async {
    if (state.cards.any((c) => c.isSameCombo(card))) return;
    final isNewInstrument = card.instrument != null && !state.seriesByID.containsKey(card.instrumentID);
    final cards = await watchlistStore.upsert(card);
    emit(state.copyWith(cards: cards));

    if (isNewInstrument) {
      final instrument = card.instrument!;
      final cached = await repository.cachedSeries(instrument);
      emit(state.copyWith(seriesByID: {...state.seriesByID, instrument.id: cached}));
      unawaited(refresh(instrument));
      unawaited(backfillHistoryIfNeeded());
    }
  }

  Future<void> updateCard(WatchCard card) async {
    final cards = await watchlistStore.upsert(card);
    emit(state.copyWith(cards: cards));
  }

  Future<void> removeCard(String id) async {
    final cards = await watchlistStore.delete(id);
    emit(state.copyWith(cards: cards));
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

  Future<void> setPreferredChartRange(ChartRange value) async {
    if (value.isExtended || value == state.preferredChartRange) return;
    await preferences.setPreferredChartRange(value);
    emit(state.copyWith(preferredChartRange: value));
  }

  Future<void> setWidgetRefreshInterval(WidgetRefreshInterval value) async {
    if (value == state.widgetRefreshInterval) return;
    await preferences.setWidgetRefreshInterval(value);
    emit(state.copyWith(widgetRefreshInterval: value));
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
  }

  Future<void> deleteLot(HoldingLot lot) async {
    final lots = await holdingsStore.delete(lot.id);
    emit(state.copyWith(lots: lots));
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
        prev.baseCurrency != next.baseCurrency;
    if (widgetRelevant) {
      unawaited(HomeWidgetService.publish(next));
    }
  }
}
