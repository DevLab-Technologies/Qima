import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chart_range.dart';
import '../models/instrument_catalog.dart';
import '../models/watch_card.dart';
import 'cloud_kv_store.dart';

enum WidgetRefreshInterval {
  fifteenMinutes(15),
  thirtyMinutes(30),
  oneHour(60),
  threeHours(180),
  sixHours(360);

  final int rawValue;
  const WidgetRefreshInterval(this.rawValue);

  Duration get timeInterval => Duration(minutes: rawValue);

  static const WidgetRefreshInterval defaultValue = WidgetRefreshInterval.fifteenMinutes;

  String get labelKey {
    switch (this) {
      case WidgetRefreshInterval.fifteenMinutes:
        return 'refresh.15m';
      case WidgetRefreshInterval.thirtyMinutes:
        return 'refresh.30m';
      case WidgetRefreshInterval.oneHour:
        return 'refresh.1h';
      case WidgetRefreshInterval.threeHours:
        return 'refresh.3h';
      case WidgetRefreshInterval.sixHours:
        return 'refresh.6h';
    }
  }

  static WidgetRefreshInterval fromRawValue(int value) {
    return WidgetRefreshInterval.values.firstWhere((v) => v.rawValue == value, orElse: () => defaultValue);
  }
}

enum AppLanguage {
  system,
  en,
  ar,
  es,
  fr;

  String? get localeIdentifier => this == AppLanguage.system ? null : name;

  String get nativeName {
    switch (this) {
      case AppLanguage.system:
        return '';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.ar:
        return 'العربية';
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.fr:
        return 'Français';
    }
  }

  static AppLanguage fromRawValue(String value) {
    return AppLanguage.values.firstWhere((v) => v.name == value, orElse: () => AppLanguage.system);
  }
}

/// How long the app may sit in the background before [LockGate] re-locks it
/// on return, once app lock is enabled (spec Phase 4 "App lock · Lock
/// after"). `immediately` re-locks on every backgrounding, with no grace at
/// all.
enum LockGrace {
  immediately(0),
  oneMinute(1),
  fiveMinutes(5),
  fifteenMinutes(15);

  final int minutes;
  const LockGrace(this.minutes);

  Duration get duration => Duration(minutes: minutes);

  static const LockGrace defaultValue = LockGrace.oneMinute;

  String get labelKey {
    switch (this) {
      case LockGrace.immediately:
        return 'lockGrace.immediately';
      case LockGrace.oneMinute:
        return 'lockGrace.1m';
      case LockGrace.fiveMinutes:
        return 'lockGrace.5m';
      case LockGrace.fifteenMinutes:
        return 'lockGrace.15m';
    }
  }

  static LockGrace fromRawValue(int value) {
    return LockGrace.values.firstWhere((v) => v.minutes == value, orElse: () => defaultValue);
  }
}

/// Light/dark override, independent of [AppLanguage]. Mirrors the "Appearance"
/// setting added in Phase 1 (spec Figma "Settings · v2").
enum Appearance {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    switch (this) {
      case Appearance.system:
        return ThemeMode.system;
      case Appearance.light:
        return ThemeMode.light;
      case Appearance.dark:
        return ThemeMode.dark;
    }
  }

  static Appearance fromRawValue(String value) {
    return Appearance.values.firstWhere((v) => v.name == value, orElse: () => Appearance.system);
  }
}

/// User settings, mirrored between a (pluggable) cloud KV store — source of
/// truth for cross-device sync — and local `SharedPreferences` as a fast
/// local cache. Mirrors `Preferences.swift` (spec §2.14).
class Preferences {
  static const String _baseCurrencyKey = 'baseCurrency';
  static const String _widgetRefreshIntervalKey = 'widgetRefreshInterval';
  static const String _appLanguageKey = 'appLanguage';
  static const String _appearanceKey = 'appearance';
  static const String _preferredChartRangeKey = 'preferredChartRange';
  static const String _preferredPortfolioRangeKey = 'preferredPortfolioRange';
  static const String _hideBalancesKey = 'hideBalances';
  static const String _appLockEnabledKey = 'appLockEnabled';
  static const String _lockGraceKey = 'lockGrace';
  static const String _deliverAlertsOnThisDeviceKey = 'deliverAlertsOnThisDevice';
  static const String _lastAlertEvaluationAtKey = 'lastAlertEvaluationAt';
  static const String _iCloudSyncEnabledKey = 'iCloudSyncEnabled';
  static const String _legacyWatchcardsKey = 'pref.watchcards';
  static const String _legacyWatchlistKey = 'pref.watchlist';

  final CloudKVStore cloud;
  final SharedPreferences local;

  Preferences({required this.cloud, required this.local});

  static Future<Preferences> create({CloudKVStore? cloud}) async {
    final prefs = await SharedPreferences.getInstance();
    return Preferences(cloud: cloud ?? LocalOnlyCloudKVStore(), local: prefs);
  }

  Future<String> get baseCurrency async {
    final cloudValue = await cloud.getString(_baseCurrencyKey);
    if (cloudValue != null) {
      await local.setString(_baseCurrencyKey, cloudValue);
      return cloudValue;
    }
    return local.getString(_baseCurrencyKey) ?? 'USD';
  }

  Future<void> setBaseCurrency(String value) async {
    await local.setString(_baseCurrencyKey, value);
    await cloud.setString(_baseCurrencyKey, value);
    await cloud.synchronize();
  }

  Future<WidgetRefreshInterval> get widgetRefreshInterval async {
    final cloudValue = await cloud.getString(_widgetRefreshIntervalKey);
    if (cloudValue != null) {
      await local.setInt(_widgetRefreshIntervalKey, int.parse(cloudValue));
      return WidgetRefreshInterval.fromRawValue(int.parse(cloudValue));
    }
    final localValue = local.getInt(_widgetRefreshIntervalKey);
    return localValue == null ? WidgetRefreshInterval.defaultValue : WidgetRefreshInterval.fromRawValue(localValue);
  }

  Future<void> setWidgetRefreshInterval(WidgetRefreshInterval value) async {
    await local.setInt(_widgetRefreshIntervalKey, value.rawValue);
    await cloud.setString(_widgetRefreshIntervalKey, value.rawValue.toString());
    await cloud.synchronize();
  }

  Future<AppLanguage> get appLanguage async {
    final cloudValue = await cloud.getString(_appLanguageKey);
    if (cloudValue != null) {
      await local.setString(_appLanguageKey, cloudValue);
      return AppLanguage.fromRawValue(cloudValue);
    }
    final localValue = local.getString(_appLanguageKey);
    return localValue == null ? AppLanguage.system : AppLanguage.fromRawValue(localValue);
  }

  Future<void> setAppLanguage(AppLanguage value) async {
    await local.setString(_appLanguageKey, value.name);
    await cloud.setString(_appLanguageKey, value.name);
    await cloud.synchronize();
  }

  Future<Appearance> get appearance async {
    final cloudValue = await cloud.getString(_appearanceKey);
    if (cloudValue != null) {
      await local.setString(_appearanceKey, cloudValue);
      return Appearance.fromRawValue(cloudValue);
    }
    final localValue = local.getString(_appearanceKey);
    return localValue == null ? Appearance.system : Appearance.fromRawValue(localValue);
  }

  Future<void> setAppearance(Appearance value) async {
    await local.setString(_appearanceKey, value.name);
    await cloud.setString(_appearanceKey, value.name);
    await cloud.synchronize();
  }

  /// Local-only, NOT synced to iCloud. Extended ranges (5Y/all) are
  /// coerced back to [ChartRange.fallbackDefault] on read — extended
  /// windows are viewing-only, never persisted as default.
  ChartRange get preferredChartRange {
    final raw = local.getString(_preferredChartRangeKey);
    if (raw == null) return ChartRange.fallbackDefault;
    final range = ChartRange.values.firstWhere((r) => r.name == raw, orElse: () => ChartRange.fallbackDefault);
    return range.isExtended ? ChartRange.fallbackDefault : range;
  }

  Future<void> setPreferredChartRange(ChartRange value) async {
    final coerced = value.isExtended ? ChartRange.fallbackDefault : value;
    await local.setString(_preferredChartRangeKey, coerced.name);
  }

  /// Local-only, like [preferredChartRange]. Restricted to
  /// [ChartRange.portfolioSelectable] — anything else read back (a stale
  /// value from a future app version, say) falls back to
  /// [ChartRange.portfolioDefault] rather than being trusted blindly.
  ChartRange get preferredPortfolioRange {
    final raw = local.getString(_preferredPortfolioRangeKey);
    if (raw == null) return ChartRange.portfolioDefault;
    final range = ChartRange.values.firstWhere((r) => r.name == raw, orElse: () => ChartRange.portfolioDefault);
    return ChartRange.portfolioSelectable.contains(range) ? range : ChartRange.portfolioDefault;
  }

  Future<void> setPreferredPortfolioRange(ChartRange value) async {
    if (!ChartRange.portfolioSelectable.contains(value)) return;
    await local.setString(_preferredPortfolioRangeKey, value.name);
  }

  /// Local-only, NOT synced — hiding balances is a per-device, in-the-moment
  /// privacy choice (e.g. "don't show this over someone's shoulder right
  /// now"), not something that should silently reveal or hide amounts on a
  /// second device.
  bool get hideBalances => local.getBool(_hideBalancesKey) ?? false;

  Future<void> setHideBalances(bool value) async {
    await local.setBool(_hideBalancesKey, value);
  }

  /// Local-only, like [hideBalances] — app lock is tied to this device's own
  /// biometric/passcode enrollment, so it can never be meaningfully synced.
  bool get appLockEnabled => local.getBool(_appLockEnabledKey) ?? false;

  Future<void> setAppLockEnabled(bool value) async {
    await local.setBool(_appLockEnabledKey, value);
  }

  LockGrace get lockGrace {
    final raw = local.getInt(_lockGraceKey);
    return raw == null ? LockGrace.defaultValue : LockGrace.fromRawValue(raw);
  }

  Future<void> setLockGrace(LockGrace value) async {
    await local.setInt(_lockGraceKey, value.minutes);
  }

  /// Local-only, NOT synced — like [hideBalances]/[appLockEnabled], whether
  /// THIS device should show alert notifications is a per-device choice (a
  /// tablet or a rarely-carried device may not need to buzz), not something
  /// that should silently enable/disable itself when another device changes
  /// it (spec Phase 5). Defaults to on for phones, off for macOS/desktop,
  /// where a background-refreshed notification is far less likely to be
  /// seen promptly and is more likely to be treated as noise.
  bool get deliverAlertsOnThisDeviceDefault {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  bool get deliverAlertsOnThisDevice =>
      local.getBool(_deliverAlertsOnThisDeviceKey) ?? deliverAlertsOnThisDeviceDefault;

  Future<void> setDeliverAlertsOnThisDevice(bool value) async {
    await local.setBool(_deliverAlertsOnThisDeviceKey, value);
  }

  /// Local-only, NOT synced — the last time [RefreshPipeline] evaluated
  /// alerts on THIS device, from any caller (foreground or the background
  /// task). Backed by `SharedPreferences` (a real file the OS shares between
  /// the running app process and a background isolate's separate process, on
  /// every platform that has a background isolate at all), rather than an
  /// in-memory field, specifically so `RefreshPipeline`'s overlap guard
  /// actually works ACROSS that process boundary — an in-memory-only guard
  /// would never see the foreground app's timestamp from inside a background
  /// isolate, since they never share a Dart VM (spec Phase 5 "Guard against
  /// double evaluation").
  DateTime? get lastAlertEvaluationAt {
    final raw = local.getString(_lastAlertEvaluationAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastAlertEvaluationAt(DateTime value) async {
    await local.setString(_lastAlertEvaluationAtKey, value.toUtc().toIso8601String());
  }

  /// Local-only, NOT synced through the cloud store itself — this is the
  /// on/off switch FOR cloud sync, so it can never be read from the thing it
  /// controls (spec Phase 7). Whether this device even offers the setting is
  /// a separate concern (`AppCubit`/`SettingsScreen` gate on platform +
  /// account availability); this getter just answers "did the user turn it
  /// on", defaulting to on so a first launch on a device with an iCloud
  /// account already signed in starts syncing without an extra step.
  bool get iCloudSyncEnabledDefault => platformSupportsICloud;

  bool get iCloudSyncEnabled => local.getBool(_iCloudSyncEnabledKey) ?? iCloudSyncEnabledDefault;

  Future<void> setICloudSyncEnabled(bool value) async {
    await local.setBool(_iCloudSyncEnabledKey, value);
  }

  /// Migration chain, simplified for a from-scratch app: (1) pre-sync
  /// `[WatchCard]` JSON, else (2) legacy ids-only watchlist mapped to
  /// seeded cards, else (3) `InstrumentCatalog.defaultWatchlist`.
  Future<List<WatchCard>> seedWatchcards() async {
    final legacyCards = local.getString(_legacyWatchcardsKey);
    if (legacyCards != null) {
      // Left as an extension point: a from-scratch Flutter install never
      // writes this legacy key, so there's nothing to decode here yet.
    }

    final legacyIds = local.getStringList(_legacyWatchlistKey);
    final base = await baseCurrency;
    if (legacyIds != null && legacyIds.isNotEmpty) {
      return _seedFromIds(legacyIds, base);
    }

    return _seedFromIds(InstrumentCatalog.defaultWatchlist, base);
  }

  List<WatchCard> _seedFromIds(List<String> ids, String baseCurrency) {
    final cards = <WatchCard>[];
    for (final id in ids) {
      final instrument = InstrumentCatalog.instrument(id);
      if (instrument == null) continue;
      final unit = instrument.quotation.defaultUnit;
      cards.add(WatchCard(
        id: WatchCard.seed(instrumentID: id, currency: baseCurrency, unit: unit),
        instrumentID: id,
        currency: baseCurrency,
        unit: unit,
      ));
    }
    return cards;
  }
}
