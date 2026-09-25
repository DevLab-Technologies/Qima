import '../blocs/app_state.dart';
import '../models/asset.dart';
import '../models/chart_range.dart';
import '../models/currency_style.dart';
import '../models/holding.dart';
import '../models/instrument_catalog.dart';
import '../models/quote.dart';

/// The data contract the iOS WidgetKit extension reads (key [storageKey] in
/// the shared App Group defaults).
///
/// Every widget instance is configured on its own (asset, unit, karat,
/// currency, chart range), so the snapshot carries everything needed to
/// price ANY of those combinations natively rather than one precomputed
/// answer: canonical-USD price series per instrument and range, live FX
/// rates, and daily FX history. The extension applies the same conversion
/// rules PriceConverter and PortfolioHistory use:
///
/// - a price point is `usd * fx(currency, at the point's time) * unit
///   multiplier * karat purity`, where `fx` is USD → 1, else the most
///   recent history sample at or before the time (the earliest sample for
///   older times), else the live rate when the currency has no history;
/// - portfolio value follows the same rule; portfolio cost is always at the
///   live rate (never historical), as on the Holdings screen.
///
/// Instrument windows are the exact quotes [ChartRange.filter] would keep,
/// thinned evenly by index to at most [maxPoints] while always keeping the
/// first and last sample, so a widget's change figure matches the app's.
class WidgetSnapshot {
  WidgetSnapshot._();

  static const storageKey = 'widget_snapshot';
  static const schemaVersion = 1;
  static const maxPoints = 48;

  /// Ranges a widget can be set to, keyed by the id the extension uses.
  static const Map<String, ChartRange> ranges = {
    '1D': ChartRange.day1,
    '1W': ChartRange.week1,
    '1M': ChartRange.month1,
    '3M': ChartRange.month3,
    '1Y': ChartRange.year1,
    'ALL': ChartRange.all,
  };

  static Map<String, dynamic> build(AppState state, {required DateTime now}) {
    final instrumentIDs = <String>{
      ...state.cards.map((c) => c.instrumentID),
      ...state.lots.map((l) => l.instrumentID),
    };
    final instruments = <Map<String, dynamic>>[];
    for (final id in instrumentIDs) {
      final instrument = InstrumentCatalog.instrument(id);
      if (instrument == null) continue;
      instruments.add(_instrument(instrument, state.seriesByID[id] ?? QuoteSeries.empty(id), now));
    }

    final currencies = <String, dynamic>{};
    for (final code in state.rates.availableCurrencies) {
      final rate = state.rates.rate(code);
      if (rate == null) continue;
      final style = CurrencyStyle.of(code);
      // The real symbol, not the fallback: the iOS extension bundles the
      // Riyal font, so it can draw the new Saudi Riyal sign.
      currencies[code] = {
        'rate': rate,
        'symbol': style.symbol,
        'suffix': style.position == SymbolPosition.suffix,
      };
    }

    final fxHistory = <String, dynamic>{};
    for (final entry in state.fxHistory.series.entries) {
      if (entry.value.isEmpty) continue;
      fxHistory[entry.key] = [
        for (final p in entry.value) [p.date.millisecondsSinceEpoch, p.perUSD],
      ];
    }

    return {
      'version': schemaVersion,
      'updatedAt': now.millisecondsSinceEpoch,
      'lastRefresh': state.lastRefresh?.millisecondsSinceEpoch,
      'hideBalances': state.hideBalances,
      'baseCurrency': state.baseCurrency,
      'currencies': currencies,
      'fxHistory': fxHistory,
      'cards': [
        for (final card in state.cards)
          if (InstrumentCatalog.instrument(card.instrumentID) != null)
            {
              'id': card.id,
              'instrumentID': card.instrumentID,
              'currency': card.currency,
              'unit': card.unit.name,
              'karat': card.karat?.rawValue,
            },
      ],
      'instruments': instruments,
      'portfolio': _portfolio(state, now),
    };
  }

  static Map<String, dynamic> _instrument(Instrument instrument, QuoteSeries series, DateTime now) {
    return {
      'id': instrument.id,
      'symbol': instrument.symbol,
      // Built-ins carry a localization key the extension resolves from its
      // own strings; custom tickers store their literal name here.
      'nameKey': instrument.nameKey,
      'assetClass': instrument.assetClass.name,
      'units': instrument.supportedUnits.map((u) => u.name).toList(),
      'karats': instrument.supportedKarats.map((k) => k.rawValue).toList(),
      'latest': series.latest?.canonicalUSD,
      'latestAt': series.latest?.timestamp.millisecondsSinceEpoch,
      'series': {
        for (final entry in ranges.entries) entry.key: _window(series.quotes, entry.value, now),
      },
    };
  }

  static List<List<num>> _window(List<Quote> quotes, ChartRange range, DateTime now) {
    final start = range.startDate(now);
    final window = start == null ? quotes : quotes.where((q) => !q.timestamp.isBefore(start)).toList();
    return [
      for (final q in thin(window)) [q.timestamp.millisecondsSinceEpoch, q.canonicalUSD],
    ];
  }

  /// At most [maxPoints] items, evenly spaced by index, first and last kept.
  static List<T> thin<T>(List<T> items) {
    if (items.length <= maxPoints) return items;
    final step = (items.length - 1) / (maxPoints - 1);
    return [for (var i = 0; i < maxPoints; i++) items[(i * step).round()]];
  }

  static Map<String, dynamic> _portfolio(AppState state, DateTime now) {
    final lots = state.lots;
    if (lots.isEmpty) return {'available': false};

    double? latestUSD(String id) => state.seriesByID[id]?.latest?.canonicalUSD;
    double costUSD(HoldingLot lot) => lot.totalCost / (state.rates.rate(lot.costCurrency) ?? 1);

    var valued = false;
    final byInstrument = <String, List<double>>{};
    for (final lot in lots) {
      final usd = latestUSD(lot.instrumentID);
      if (usd == null) continue;
      valued = true;
      final row = byInstrument.putIfAbsent(lot.instrumentID, () => [0, 0]);
      row[0] += lot.fineOunces * usd;
      row[1] += costUSD(lot);
    }
    if (!valued) return {'available': false};

    final holdings = byInstrument.entries.toList()..sort((a, b) => b.value[0].compareTo(a.value[0]));
    final earliestLot = lots.map((l) => l.date).reduce((a, b) => a.isBefore(b) ? a : b);

    return {
      'available': true,
      'valueUSD': holdings.fold<double>(0, (sum, e) => sum + e.value[0]),
      'costUSD': holdings.fold<double>(0, (sum, e) => sum + e.value[1]),
      'holdings': [
        for (final e in holdings) {'instrumentID': e.key, 'valueUSD': e.value[0], 'costUSD': e.value[1]},
      ],
      'series': {
        for (final entry in ranges.entries) entry.key: _portfolioSeries(state, entry.value, earliestLot, now),
      },
    };
  }

  /// `[time, valueUSD, costUSD]` at [maxPoints] evenly spaced instants from
  /// the range start (the first lot's date for "All", so the first point
  /// already holds it) to [now]. A lot counts from its own date on; an
  /// instrument with no price yet at an instant adds cost but no value.
  static List<List<num>> _portfolioSeries(AppState state, ChartRange range, DateTime earliestLot, DateTime now) {
    final start = range.startDate(now) ?? earliestLot;
    if (!start.isBefore(now)) return const [];

    final span = now.difference(start).inMilliseconds;
    final times = [
      for (var i = 0; i < maxPoints; i++) start.add(Duration(milliseconds: (span * i / (maxPoints - 1)).round())),
    ];
    // One forward walk per instrument over the ascending sample times,
    // instead of rescanning every quote for every lot and instant.
    final pricesByInstrument = <String, List<double?>>{
      for (final id in state.lots.map((l) => l.instrumentID).toSet())
        id: _pricesAt(state.seriesByID[id]?.quotes ?? const [], times),
    };

    return [
      for (var i = 0; i < times.length; i++)
        () {
          double value = 0;
          double cost = 0;
          for (final lot in state.lots) {
            if (lot.date.isAfter(times[i])) continue;
            cost += lot.totalCost / (state.rates.rate(lot.costCurrency) ?? 1);
            final price = pricesByInstrument[lot.instrumentID]![i];
            if (price != null) value += lot.fineOunces * price;
          }
          return <num>[times[i].millisecondsSinceEpoch, value, cost];
        }(),
    ];
  }

  /// The last quote at or before each of [times] (ascending), or null.
  static List<double?> _pricesAt(List<Quote> quotes, List<DateTime> times) {
    var index = 0;
    double? last;
    return [
      for (final t in times)
        () {
          while (index < quotes.length && !quotes[index].timestamp.isAfter(t)) {
            last = quotes[index].canonicalUSD;
            index += 1;
          }
          return last;
        }(),
    ];
  }
}
