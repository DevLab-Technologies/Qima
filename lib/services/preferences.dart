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

/// User settings, mirrored between a (pluggable) cloud KV store — source of
/// truth for cross-device sync — and local `SharedPreferences` as a fast
/// local cache. Mirrors `Preferences.swift` (spec §2.14).
class Preferences {
  static const String _baseCurrencyKey = 'baseCurrency';
  static const String _widgetRefreshIntervalKey = 'widgetRefreshInterval';
  static const String _appLanguageKey = 'appLanguage';
  static const String _preferredChartRangeKey = 'preferredChartRange';
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
