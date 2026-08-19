import 'package:equatable/equatable.dart';

import '../models/fx_history.dart';
import '../models/holding.dart';
import '../models/money.dart';
import '../models/quote.dart';
import '../models/watch_card.dart';
import '../models/chart_range.dart';
import '../services/preferences.dart';

enum RefreshPhase { idle, refreshing, failed }

/// The app's single source of truth. Mirrors `AppModel.swift` (spec §4.1).
class AppState extends Equatable {
  final bool initialized;
  final Map<String, QuoteSeries> seriesByID;
  final FXRates rates;
  final FXHistory fxHistory;
  final RefreshPhase phase;
  final String? errorMessage;
  final List<HoldingLot> lots;
  final List<WatchCard> cards;
  final String baseCurrency;
  final WidgetRefreshInterval widgetRefreshInterval;
  final AppLanguage appLanguage;
  final ChartRange preferredChartRange;
  final DateTime? lastRefresh;
  final bool isBackfilling;
  final bool isLoadingHistory;

  AppState({
    this.initialized = false,
    Map<String, QuoteSeries>? seriesByID,
    FXRates? rates,
    this.fxHistory = FXHistory.empty,
    this.phase = RefreshPhase.idle,
    this.errorMessage,
    this.lots = const [],
    this.cards = const [],
    this.baseCurrency = 'USD',
    this.widgetRefreshInterval = WidgetRefreshInterval.defaultValue,
    this.appLanguage = AppLanguage.system,
    this.preferredChartRange = ChartRange.fallbackDefault,
    this.lastRefresh,
    this.isBackfilling = false,
    this.isLoadingHistory = false,
  })  : seriesByID = seriesByID ?? const {},
        rates = rates ?? FXRates.usdIdentity;

  AppState copyWith({
    bool? initialized,
    Map<String, QuoteSeries>? seriesByID,
    FXRates? rates,
    FXHistory? fxHistory,
    RefreshPhase? phase,
    String? errorMessage,
    bool clearError = false,
    List<HoldingLot>? lots,
    List<WatchCard>? cards,
    String? baseCurrency,
    WidgetRefreshInterval? widgetRefreshInterval,
    AppLanguage? appLanguage,
    ChartRange? preferredChartRange,
    DateTime? lastRefresh,
    bool? isBackfilling,
    bool? isLoadingHistory,
  }) {
    return AppState(
      initialized: initialized ?? this.initialized,
      seriesByID: seriesByID ?? this.seriesByID,
      rates: rates ?? this.rates,
      fxHistory: fxHistory ?? this.fxHistory,
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lots: lots ?? this.lots,
      cards: cards ?? this.cards,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      widgetRefreshInterval: widgetRefreshInterval ?? this.widgetRefreshInterval,
      appLanguage: appLanguage ?? this.appLanguage,
      preferredChartRange: preferredChartRange ?? this.preferredChartRange,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      isBackfilling: isBackfilling ?? this.isBackfilling,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }

  @override
  List<Object?> get props => [
        initialized,
        seriesByID,
        rates,
        fxHistory,
        phase,
        errorMessage,
        lots,
        cards,
        baseCurrency,
        widgetRefreshInterval,
        appLanguage,
        preferredChartRange,
        lastRefresh,
        isBackfilling,
        isLoadingHistory,
      ];
}
