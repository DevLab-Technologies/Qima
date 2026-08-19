import 'package:shared_preferences/shared_preferences.dart';

import '../models/asset.dart';
import '../models/fx_history.dart';
import '../models/metal_breakdown.dart';
import '../models/money.dart';
import '../models/quote.dart';
import 'fx_history_store.dart';
import 'fx_rate_store.dart';
import 'price_converter.dart';
import 'quote_history_store.dart';
import 'quote_provider.dart';

/// Central orchestrator wiring quote providers to persistence. Mirrors
/// `PriceRepository.swift` (spec §2.2).
class PriceRepository {
  static const int backfillMinSpanDays = 60;
  static const Duration fxTailMaxAge = Duration(hours: 12);
  static const Duration fxRetryBackoff = Duration(minutes: 10);
  static const Duration fxFullPullInterval = Duration(hours: 12);

  static const Map<String, String> metalHistorySymbols = {
    'XAU': 'GC=F',
    'XAG': 'SI=F',
    'XPT': 'PL=F',
    'XPD': 'PA=F',
  };

  final GoldAPIProvider metalCryptoProvider;
  final YahooHistoryProvider historyProvider;
  final ExchangeRateAPIProvider fxProvider;
  final FXRateStore fxRateStore;
  final FXHistoryStore fxHistoryStore;
  final QuoteHistoryStore quoteHistoryStore;
  final Future<SharedPreferences> Function() prefsProvider;

  /// Must be false when this repository runs inside a widget extension —
  /// avoids a crash reloading widget timelines from within the extension
  /// itself. There is no widget extension in this Flutter port yet, so this
  /// is currently unused beyond preserving the flag's meaning.
  final bool reloadsWidgets;

  PriceRepository({
    GoldAPIProvider? metalCryptoProvider,
    YahooHistoryProvider? historyProvider,
    ExchangeRateAPIProvider? fxProvider,
    FXRateStore? fxRateStore,
    FXHistoryStore? fxHistoryStore,
    QuoteHistoryStore? quoteHistoryStore,
    Future<SharedPreferences> Function()? prefsProvider,
    this.reloadsWidgets = true,
  })  : metalCryptoProvider = metalCryptoProvider ?? GoldAPIProvider(),
        historyProvider = historyProvider ?? YahooHistoryProvider(),
        fxProvider = fxProvider ?? ExchangeRateAPIProvider(),
        fxRateStore = fxRateStore ?? FXRateStore(),
        fxHistoryStore = fxHistoryStore ?? FXHistoryStore(),
        quoteHistoryStore = quoteHistoryStore ?? QuoteHistoryStore(),
        prefsProvider = prefsProvider ?? SharedPreferences.getInstance;

  /// Routes an instrument to the provider responsible for its asset class.
  QuoteProvider provider(Instrument instrument, FXRates rates) {
    switch (instrument.assetClass) {
      case AssetClass.fiat:
        return FiatQuoteProvider(rates);
      case AssetClass.stock:
      case AssetClass.indices:
        return YahooQuoteProvider(rates);
      case AssetClass.metal:
      case AssetClass.crypto:
        return metalCryptoProvider;
    }
  }

  // ---- Reads (no network) ----

  Future<QuoteSeries> cachedSeries(Instrument instrument) => quoteHistoryStore.load(instrument.id);

  Future<FXRates> cachedRates() async => (await fxRateStore.load()) ?? FXRates.usdIdentity;

  Future<FXHistory> cachedFXHistory() => fxHistoryStore.load();

  Future<PriceConverter> converter({
    required String currency,
    required PriceUnit unit,
    GoldKarat? karat,
  }) async {
    final rates = await cachedRates();
    final history = await cachedFXHistory();
    return PriceConverter(rates: rates, currencyCode: currency, unit: unit, karat: karat, history: history);
  }

  // ---- Rates ----

  Future<FXRates> refreshRatesIfNeeded({DateTime? now}) async {
    final cached = await fxRateStore.load();
    if (cached != null && !fxRateStore.isStale(cached, now: now)) {
      return cached;
    }
    try {
      final fresh = await fxProvider.latestRates();
      await fxRateStore.save(fresh);
      return fresh;
    } catch (_) {
      return cached ?? FXRates.usdIdentity;
    }
  }

  // ---- Live spot ----

  Future<double> probePrice(Instrument instrument) async {
    final rates = await cachedRates();
    return provider(instrument, rates).canonicalUSDPrice(instrument);
  }

  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async {
    final rates = await refreshRatesIfNeeded(now: now);
    final price = await provider(instrument, rates).canonicalUSDPrice(instrument);
    final quote = Quote(instrumentID: instrument.id, timestamp: now ?? DateTime.now(), canonicalUSD: price);
    final updated = await quoteHistoryStore.record(quote);
    _maybeReloadWidgets();
    return updated;
  }

  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async {
    final rates = await refreshRatesIfNeeded(now: now);
    final result = <String, QuoteSeries>{};
    for (final instrument in instruments) {
      try {
        final price = await provider(instrument, rates).canonicalUSDPrice(instrument);
        final quote = Quote(instrumentID: instrument.id, timestamp: now ?? DateTime.now(), canonicalUSD: price);
        result[instrument.id] = await quoteHistoryStore.record(quote);
      } catch (_) {
        // Tolerate individual failures; skip on error.
      }
    }
    if (result.isNotEmpty) _maybeReloadWidgets();
    return result;
  }

  void _maybeReloadWidgets() {
    if (!reloadsWidgets) return;
    // No widget extension in this Flutter port yet; hook point preserved.
  }

  // ---- FX history backfill ----

  bool _isDeep(List<FXHistoryPoint> points, DateTime cutoff) {
    if (points.isEmpty) return false;
    return points.first.date.isBefore(cutoff);
  }

  bool _isDeepQuotes(QuoteSeries series, DateTime cutoff) {
    final earliest = series.earliest;
    if (earliest == null) return false;
    return earliest.timestamp.isBefore(cutoff);
  }

  Future<DateTime?> _attemptedAt(SharedPreferences prefs, String key) async {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _stamp(SharedPreferences prefs, String key, DateTime now) async {
    await prefs.setString(key, now.toUtc().toIso8601String());
  }

  bool _dueSince(DateTime? last, Duration interval, DateTime now) {
    if (last == null) return true;
    return now.difference(last) > interval;
  }

  /// Backfills FX history for [currencies] (never "USD"). See spec §2.2 for
  /// the full throttling rules this reproduces exactly.
  Future<FXHistory> backfillFXHistory(List<String> currencies, {bool force = false, DateTime? now}) async {
    final effectiveNow = now ?? DateTime.now();
    final prefs = await prefsProvider();
    var history = await fxHistoryStore.load();
    final cutoff = effectiveNow.subtract(const Duration(days: backfillMinSpanDays));

    for (final code in currencies) {
      if (code == 'USD') continue;

      final attemptedKey = 'fxFetchAttemptedAt.$code';
      final tailKey = 'fxTailRefreshedAt.$code';
      final fullKey = 'fxFullPulledAt.$code';

      final lastAttempt = await _attemptedAt(prefs, attemptedKey);
      final retryDue = _dueSince(lastAttempt, fxRetryBackoff, effectiveNow);
      if (!force && !retryDue) continue;

      final deep = _isDeep(history.points(code), cutoff);
      final lastFullPull = await _attemptedAt(prefs, fullKey);
      final fullPullDue = _dueSince(lastFullPull, fxFullPullInterval, effectiveNow);
      final doFull = force || (!deep && fullPullDue);

      final lastTail = await _attemptedAt(prefs, tailKey);
      final latest = history.latestDate(code);
      final isFxTailStale = latest == null || effectiveNow.difference(latest) > fxTailMaxAge;
      final tailRefreshDue = _dueSince(lastTail, fxFullPullInterval, effectiveNow);
      final doTail = !doFull && isFxTailStale && tailRefreshDue;

      if (!doFull && !doTail) continue;

      // Every attempt (success or fail) stamps immediately.
      await _stamp(prefs, attemptedKey, effectiveNow);

      final bars = await historyProvider.bars(
        '$code=X',
        range: doFull ? '5y' : '1mo',
        interval: '1d',
      );
      if (bars.isEmpty) continue;

      final points = bars.map((b) => FXHistoryPoint(date: b.date, perUSD: b.close)).toList();

      final (merged, persisted) = await fxHistoryStore.update((current) {
        return doFull ? current.set(code, points) : current.merge(code, points);
      });
      history = merged;

      if (doTail) {
        await _stamp(prefs, tailKey, effectiveNow);
      }
      if (doFull && persisted) {
        await _stamp(prefs, fullKey, effectiveNow);
      }
    }

    return history;
  }

  String? _historySymbol(Instrument instrument) {
    switch (instrument.assetClass) {
      case AssetClass.stock:
      case AssetClass.indices:
        return instrument.sourceSymbol;
      case AssetClass.crypto:
        return '${instrument.symbol}-USD';
      case AssetClass.metal:
        return metalHistorySymbols[instrument.symbol];
      case AssetClass.fiat:
        return null;
    }
  }

  /// Derives fiat "quotes" directly from FX history (no network): a flat
  /// series of 1.0 for USD itself, else `1 / perUSD` for each sample.
  List<Quote> fiatQuotes(Instrument instrument, FXHistory history, List<DateTime> gridDates) {
    if (instrument.symbol == 'USD') {
      return gridDates.map((d) => Quote(instrumentID: instrument.id, timestamp: d, canonicalUSD: 1)).toList();
    }
    final points = history.points(instrument.symbol);
    return points
        .where((p) => p.perUSD != 0)
        .map((p) => Quote(instrumentID: instrument.id, timestamp: p.date, canonicalUSD: 1 / p.perUSD))
        .toList();
  }

  /// Backfills quote history for [instruments], per spec §2.2.
  Future<Map<String, QuoteSeries>> backfillInstruments(
    List<Instrument> instruments,
    FXHistory fxHistory, {
    bool force = false,
    DateTime? now,
  }) async {
    final effectiveNow = now ?? DateTime.now();
    final cutoff = effectiveNow.subtract(const Duration(days: backfillMinSpanDays));
    final rates = await cachedRates();
    final result = <String, QuoteSeries>{};

    for (final instrument in instruments) {
      final existing = await quoteHistoryStore.load(instrument.id);
      final deep = _isDeepQuotes(existing, cutoff);
      if (!force && deep) continue;

      List<Quote> newQuotes;
      if (instrument.assetClass == AssetClass.fiat) {
        newQuotes = fiatQuotes(instrument, fxHistory, fxHistory.allDates());
      } else {
        final symbol = _historySymbol(instrument);
        if (symbol == null) continue;
        final bars = await historyProvider.bars(symbol);
        newQuotes = [
          for (final bar in bars)
            Quote(
              instrumentID: instrument.id,
              timestamp: bar.date,
              canonicalUSD: () {
                try {
                  return usdFromPrice(bar.close, bar.currency, rates);
                } catch (_) {
                  return double.nan;
                }
              }(),
            ),
        ].where((q) => !q.canonicalUSD.isNaN).toList();
      }

      if (newQuotes.isEmpty) continue;
      final merged = existing.merging(newQuotes, effectiveNow);
      await quoteHistoryStore.save(merged);
      result[instrument.id] = merged;
    }

    if (result.isNotEmpty) _maybeReloadWidgets();
    return result;
  }

  /// Force-repulls FX history for [currency]/[baseCurrency] (+ the
  /// instrument's own symbol if it's fiat) and the single instrument's
  /// history — the "on-demand full reload" action, bypassing the deep-
  /// history throttle.
  Future<QuoteSeries> loadHistory(Instrument instrument, String currency, String baseCurrency, {DateTime? now}) async {
    final currencies = <String>{currency, baseCurrency};
    if (instrument.assetClass == AssetClass.fiat) currencies.add(instrument.symbol);

    final fxHistory = await backfillFXHistory(currencies.toList(), force: true, now: now);
    final result = await backfillInstruments([instrument], fxHistory, force: true, now: now);
    _maybeReloadWidgets();
    return result[instrument.id] ?? await quoteHistoryStore.load(instrument.id);
  }
}
