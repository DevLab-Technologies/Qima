import 'package:equatable/equatable.dart';

import 'chart_range.dart';
import 'fx_history.dart';
import 'holding.dart';
import 'money.dart';
import 'quote.dart';

/// A single day's portfolio value/cost sample, both expressed in the base
/// currency.
class PortfolioHistoryPoint extends Equatable {
  final DateTime date;
  final double value;
  final double cost;

  const PortfolioHistoryPoint({required this.date, required this.value, required this.cost});

  double get gain => value - cost;

  @override
  List<Object?> get props => [date, value, cost];
}

/// A range-scoped headline for the portfolio hero chart. [gainDelta] is the
/// change in GAIN (value minus cost) over the range — not the change in
/// value — so buying more of a holding partway through the window is never
/// shown as if it were profit (spec §v2-A). [valueDelta] and [latestValue]
/// are still exposed for the value line/label the hero card also shows.
class PortfolioRangeChange extends Equatable {
  final double gainDelta;
  final double valueDelta;
  final double percentValue;
  final bool isUp;
  final double latestValue;

  const PortfolioRangeChange({
    required this.gainDelta,
    required this.valueDelta,
    required this.percentValue,
    required this.isUp,
    required this.latestValue,
  });

  @override
  List<Object?> get props => [gainDelta, valueDelta, percentValue, isUp, latestValue];
}

/// Computed (never snapshotted) day-by-day portfolio value across a range.
///
/// For each day `d`, `value(d)` sums, over every lot dated on or before `d`,
/// `quantity * unit.multiplier * instrument's last known USD price on/before
/// d * base-currency FX rate on d`. `cost(d)` follows the same
/// lots-dated-on-or-before-`d` rule but reuses [HoldingValuation.aggregate]'s
/// exact (live-FX, not historical) currency conversion, so a day's cost
/// figure always matches what the Holdings screen would show if you looked
/// at it that day with today's rates.
///
/// The walk is a single ascending pass per instrument/currency (a cursor,
/// like [PriceConverter.points]), not a lookup-per-day, so this stays cheap
/// even for a multi-year "All" range with a large history.
class PortfolioHistory {
  PortfolioHistory._();

  /// Builds the series for [range]. [lots] need not be sorted. [seriesByID]
  /// must contain an entry (possibly empty) for every instrument referenced
  /// by a lot; a missing entry means that lot is skipped for every day (no
  /// price to value it at). [now] is the last day plotted.
  static List<PortfolioHistoryPoint> build({
    required List<HoldingLot> lots,
    required Map<String, QuoteSeries> seriesByID,
    required FXRates rates,
    required FXHistory fxHistory,
    required String baseCurrency,
    required ChartRange range,
    required DateTime now,
  }) {
    if (lots.isEmpty) return const [];

    final today = _dayStart(now);
    final startDate = range == ChartRange.all
        ? _dayStart(lots.map((l) => l.date).reduce((a, b) => a.isBefore(b) ? a : b))
        : _dayStart(range.startDate(now) ?? today);
    if (startDate.isAfter(today)) return const [];

    // One ascending-quote cursor per instrument referenced by a lot, plus a
    // running "last known USD price on/before day d" for each.
    final lotsByInstrument = <String, List<HoldingLot>>{};
    for (final lot in lots) {
      (lotsByInstrument[lot.instrumentID] ??= []).add(lot);
    }
    for (final list in lotsByInstrument.values) {
      list.sort((a, b) => a.date.compareTo(b.date));
    }

    final quoteCursors = <String, _QuoteCursor>{
      for (final id in lotsByInstrument.keys) id: _QuoteCursor(seriesByID[id]?.quotes ?? const []),
    };

    // One ascending FX cursor for the base currency (identical rule to
    // FXHistory.rate, walked forward instead of re-scanned per day).
    final baseFxCursor = _FxCursor(fxHistory.points(baseCurrency));

    // Cost uses HoldingValuation's rule: live rate only, never historical —
    // so it's identical for every day and can be precomputed per lot once.
    final liveCostToDisplay = <String, double>{};
    double liveCostFor(HoldingLot lot) {
      final cached = liveCostToDisplay[lot.id];
      if (cached != null) return cached;
      final costToUSD = rates.rate(lot.costCurrency) ?? 1;
      final toDisplay = rates.rate(baseCurrency) ?? 1;
      final costUSD = lot.totalCost / costToUSD;
      final value = costUSD * toDisplay;
      liveCostToDisplay[lot.id] = value;
      return value;
    }

    final points = <PortfolioHistoryPoint>[];
    var cursor = startDate;
    // Lots are re-partitioned "included as of day d" via each per-instrument
    // list's own position — advanced alongside the day loop rather than
    // re-filtered per day, so a long lot history stays O(days + lots).
    final includedUpTo = <String, int>{for (final id in lotsByInstrument.keys) id: 0};

    while (!cursor.isAfter(today)) {
      // Query instant is the last microsecond of calendar day [cursor] (NOT
      // the next midnight, which would also swallow a sample timestamped at
      // the very start of day d+1) so a lot dated, or a quote/FX sample
      // timestamped, anytime during day [cursor] itself is included in that
      // day's point — not just samples exactly at local midnight.
      final endOfDay = cursor.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
      final fxRate = baseCurrency == 'USD' ? 1.0 : (baseFxCursor.rateOnOrBefore(endOfDay) ?? rates.rate(baseCurrency) ?? 1);

      double valueUSD = 0;
      double costDisplay = 0;

      for (final entry in lotsByInstrument.entries) {
        final instrumentID = entry.key;
        final instrumentLots = entry.value;
        final quoteCursor = quoteCursors[instrumentID]!;
        final priceUSD = quoteCursor.priceOnOrBefore(endOfDay);

        var includedCount = includedUpTo[instrumentID]!;
        while (includedCount < instrumentLots.length && instrumentLots[includedCount].date.isBefore(endOfDay)) {
          includedCount += 1;
        }
        includedUpTo[instrumentID] = includedCount;

        if (priceUSD == null) {
          // No price known yet on/before this day: every lot of this
          // instrument contributes 0 value (but still its live cost) until
          // a price becomes available.
          for (var i = 0; i < includedCount; i++) {
            costDisplay += liveCostFor(instrumentLots[i]);
          }
          continue;
        }

        for (var i = 0; i < includedCount; i++) {
          final lot = instrumentLots[i];
          valueUSD += lot.quantity * lot.unit.multiplier * priceUSD;
          costDisplay += liveCostFor(lot);
        }
      }

      points.add(PortfolioHistoryPoint(date: cursor, value: valueUSD * fxRate, cost: costDisplay));
      cursor = cursor.add(const Duration(days: 1));
    }

    return points;
  }

  static DateTime _dayStart(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

/// Walks a single instrument's ascending quote series, returning the most
/// recent canonical-USD price at or before a monotonically non-decreasing
/// sequence of query dates (mirrors [PriceConverter.points]'s cursor).
class _QuoteCursor {
  final List<Quote> quotes;
  int _index = 0;
  double? _last;

  _QuoteCursor(this.quotes);

  double? priceOnOrBefore(DateTime date) {
    while (_index < quotes.length && !quotes[_index].timestamp.isAfter(date)) {
      _last = quotes[_index].canonicalUSD;
      _index += 1;
    }
    return _last;
  }
}

/// Walks an ascending FX history series the same way [FXHistory.rate] would
/// resolve it (fallback to the earliest sample, then hold the latest sample
/// flat), but as a forward cursor instead of a per-call linear scan.
class _FxCursor {
  final List<FXHistoryPoint> points;
  int _index = 0;
  double? _last;

  _FxCursor(this.points);

  double? rateOnOrBefore(DateTime date) {
    while (_index < points.length && !points[_index].date.isAfter(date)) {
      _last = points[_index].perUSD;
      _index += 1;
    }
    if (_last != null) return _last;
    return points.isEmpty ? null : points.first.perUSD;
  }
}
