import 'package:equatable/equatable.dart';

import '../models/fx_history.dart';
import '../models/holding.dart';
import '../models/money.dart';
import '../models/price_alert.dart';
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

  /// Localization key (resolved with `displayLabel`), never raw exception text.
  final String? errorMessage;
  final List<HoldingLot> lots;
  final List<WatchCard> cards;
  final String baseCurrency;
  final WidgetRefreshInterval widgetRefreshInterval;
  final AppLanguage appLanguage;
  final Appearance appearance;
  final ChartRange preferredChartRange;
  final ChartRange preferredPortfolioRange;
  final DateTime? lastRefresh;
  final bool isBackfilling;
  final bool isLoadingHistory;

  /// Local-only privacy settings (spec Phase 4 "Hide balances + App lock") —
  /// never synced, see `Preferences`.
  final bool hideBalances;
  final bool appLockEnabled;
  final LockGrace lockGrace;

  /// Price alert definitions (spec Phase 5) — synced like [cards]/[lots].
  final List<PriceAlert> alerts;

  /// Local-only (never synced), like [hideBalances]/[appLockEnabled]: whether
  /// this device delivers alert notifications at all.
  final bool deliverAlertsOnThisDevice;

  /// Best-effort OS notification-permission status, refreshed whenever the
  /// Alerts/Settings screens check it — drives the "Notifications are off"
  /// banner. Defaults to true (no banner) until the first check resolves, so
  /// the banner doesn't flash on before settling.
  final bool notificationsEnabled;

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
    this.appearance = Appearance.system,
    this.preferredChartRange = ChartRange.fallbackDefault,
    this.preferredPortfolioRange = ChartRange.portfolioDefault,
    this.lastRefresh,
    this.isBackfilling = false,
    this.isLoadingHistory = false,
    this.hideBalances = false,
    this.appLockEnabled = false,
    this.lockGrace = LockGrace.defaultValue,
    this.alerts = const [],
    this.deliverAlertsOnThisDevice = true,
    this.notificationsEnabled = true,
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
    Appearance? appearance,
    ChartRange? preferredChartRange,
    ChartRange? preferredPortfolioRange,
    DateTime? lastRefresh,
    bool? isBackfilling,
    bool? isLoadingHistory,
    bool? hideBalances,
    bool? appLockEnabled,
    LockGrace? lockGrace,
    List<PriceAlert>? alerts,
    bool? deliverAlertsOnThisDevice,
    bool? notificationsEnabled,
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
      appearance: appearance ?? this.appearance,
      preferredChartRange: preferredChartRange ?? this.preferredChartRange,
      preferredPortfolioRange: preferredPortfolioRange ?? this.preferredPortfolioRange,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      isBackfilling: isBackfilling ?? this.isBackfilling,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      hideBalances: hideBalances ?? this.hideBalances,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      lockGrace: lockGrace ?? this.lockGrace,
      alerts: alerts ?? this.alerts,
      deliverAlertsOnThisDevice: deliverAlertsOnThisDevice ?? this.deliverAlertsOnThisDevice,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
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
        appearance,
        preferredChartRange,
        preferredPortfolioRange,
        lastRefresh,
        isBackfilling,
        isLoadingHistory,
        hideBalances,
        appLockEnabled,
        lockGrace,
        alerts,
        deliverAlertsOnThisDevice,
        notificationsEnabled,
      ];
}
