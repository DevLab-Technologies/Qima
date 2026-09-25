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

/// Status of the iCloud key-value sync backend, for the Settings "iCloud
/// sync" status line (spec Phase 7). [disabled] covers both "the user turned
/// it off" and "not offered on this platform/no iCloud account" — the UI
/// that decides whether to show the section at all is what distinguishes
/// those, this just reflects whether the switch is effectively on.
enum CloudSyncStatus {
  disabled,
  syncing,
  upToDate,

  /// No iCloud account is signed in on this device (`accountStatus()` was
  /// false, or an `accountChange` event fired and the recheck came back
  /// false).
  notSignedIn,

  /// The iCloud KVS quota (1 MB total, 1024 keys) was exceeded on a write —
  /// local data stays authoritative; the write is simply not reflected in
  /// the cloud until something is freed up (spec Phase 7 "Size guard").
  storageFull;
}

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

  /// Whether the Settings/Backup "Time for a backup" reminder card should
  /// show right now (spec Phase 6): reminder enabled, data changed since the
  /// last backup, and more than 30 days since the last backup (or never
  /// backed up). Recomputed from `BackupService.isReminderDue` — see
  /// `AppCubit._refreshBackupReminder`.
  final bool backupReminderDue;

  /// Whether the user has iCloud sync turned on (spec Phase 7) — mirrors
  /// `Preferences.iCloudSyncEnabled`, a local-only setting never itself
  /// synced through the store it controls.
  final bool iCloudSyncEnabled;

  /// Whether iCloud sync is offered on this device at all: iOS only, and
  /// (once checked) an iCloud account must be signed in. Starts `true`
  /// (platform-gated already by [iCloudSyncEnabled]'s default and by
  /// `SettingsScreen` only building the section on iOS) so the section
  /// doesn't flash away before the first `accountStatus()` check resolves;
  /// [AppCubit.init] corrects it promptly.
  final bool iCloudAccountAvailable;

  final CloudSyncStatus cloudSyncStatus;

  /// Last time a full sync round-trip (local+cloud merge) completed
  /// successfully, for the "Up to date · 14:32" status line.
  final DateTime? lastCloudSyncAt;

  /// Whether the first-launch onboarding tour should be presented before
  /// the home shell (spec "Onboarding tour"). Decided once in
  /// [AppCubit.init]: false once [Preferences.onboardingCompleted] is set,
  /// and also false for an existing (pre-onboarding) install that already
  /// has real user data — see [AppCubit.completeOnboarding] and
  /// `_hasExistingUserData`. Stays false until [initialized] to avoid
  /// flashing the tour on for a frame before init resolves.
  final bool shouldShowOnboarding;

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
    this.backupReminderDue = false,
    this.iCloudSyncEnabled = false,
    this.iCloudAccountAvailable = true,
    this.cloudSyncStatus = CloudSyncStatus.disabled,
    this.lastCloudSyncAt,
    this.shouldShowOnboarding = false,
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
    bool? backupReminderDue,
    bool? iCloudSyncEnabled,
    bool? iCloudAccountAvailable,
    CloudSyncStatus? cloudSyncStatus,
    DateTime? lastCloudSyncAt,
    bool clearLastCloudSyncAt = false,
    bool? shouldShowOnboarding,
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
      backupReminderDue: backupReminderDue ?? this.backupReminderDue,
      iCloudSyncEnabled: iCloudSyncEnabled ?? this.iCloudSyncEnabled,
      iCloudAccountAvailable: iCloudAccountAvailable ?? this.iCloudAccountAvailable,
      cloudSyncStatus: cloudSyncStatus ?? this.cloudSyncStatus,
      lastCloudSyncAt: clearLastCloudSyncAt ? null : (lastCloudSyncAt ?? this.lastCloudSyncAt),
      shouldShowOnboarding: shouldShowOnboarding ?? this.shouldShowOnboarding,
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
        backupReminderDue,
        iCloudSyncEnabled,
        iCloudAccountAvailable,
        cloudSyncStatus,
        lastCloudSyncAt,
        shouldShowOnboarding,
      ];
}
