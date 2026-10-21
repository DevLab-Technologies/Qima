import 'package:equatable/equatable.dart';

import 'chart_range.dart';
import 'fx_history.dart';
import 'ledger.dart';
import 'money.dart';
import 'quote.dart';

/// A single day's portfolio sample, all in the base currency.
class PortfolioHistoryPoint extends Equatable {
  final DateTime date;
  final double value;

  /// Cost basis of what was held that day.
  final double cost;

  /// Gain or loss realised by sells and fees up to that day. Part of the
  /// gain, so selling at a profit never reads as a drop.
  final double realised;

  const PortfolioHistoryPoint({required this.date, required this.value, required this.cost, this.realised = 0});

  double get gain => value - cost + realised;

  @override
  List<Object?> get props => [date, value, cost, realised];
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

  /// The change over [points] (a [PortfolioHistory.build] series for
  /// [range]); null when there are none.
  ///
  /// The percent is the gain change over the money at work in the range:
  /// the value held at its start plus what was invested during it (a simple
  /// Dietz return). "All" starts from before the first purchase, so it
  /// reads as total gain over total cost. Dividing by the first day's cost
  /// alone, as before, blew up whenever more was bought later (a $130 first
  /// lot followed by $23,000 more read as -1670%).
  static PortfolioRangeChange? from(List<PortfolioHistoryPoint> points, ChartRange range) {
    if (points.isEmpty) return null;
    final last = points.last;
    final start = range == ChartRange.all
        ? PortfolioHistoryPoint(date: points.first.date, value: 0, cost: 0)
        : points.first;
    final gainDelta = last.gain - start.gain;
    final invested = start.value + (last.cost - start.cost);
    return PortfolioRangeChange(
      gainDelta: gainDelta,
      valueDelta: last.value - points.first.value,
      percentValue: invested > 0 ? gainDelta / invested : 0,
      isUp: gainDelta >= 0,
      latestValue: last.value,
    );
  }

  @override
  List<Object?> get props => [gainDelta, valueDelta, percentValue, isUp, latestValue];
}

/// Computed (never snapshotted) day-by-day portfolio value across a range.
///
/// For each day `d` and each instrument, the ledger's position as it stood at
/// the end of `d` (see [InstrumentPosition.stateAt]) is valued at the
/// instrument's last known USD price on or before `d` and the base
/// currency's FX rate on `d`. A sale therefore lowers the value from its
/// date on, and what it realised moves into [PortfolioHistoryPoint.realised]
/// so the gain line stays continuous. Cost and realised amounts use today's
/// rates — the same rule as [HoldingValuation.aggregate] — so a day's cost
/// matches what the holdings screen would show for it today.
///
/// The walk is one ascending pass per instrument (cursors over quotes and
/// ledger states), not a lookup per day, so a multi-year "All" stays cheap.
class PortfolioHistory {
  PortfolioHistory._();

  /// Builds the series for [range]. [seriesByID] may lack an instrument; it
  /// then contributes cost but no value until a price exists. [now] is the
  /// last day plotted.
  static List<PortfolioHistoryPoint> build({
    required Ledger ledger,
    required Map<String, QuoteSeries> seriesByID,
    required FXRates rates,
    required FXHistory fxHistory,
    required String baseCurrency,
    required ChartRange range,
    required DateTime now,
  }) {
    final firstDate = ledger.firstDate;
    if (firstDate == null) return const [];

    final today = _dayStart(now);
    final startDate = range == ChartRange.all ? _dayStart(firstDate) : _dayStart(range.startDate(now) ?? today);
    if (startDate.isAfter(today)) return const [];

    final positions = ledger.positions.values.where((p) => p.timeline.isNotEmpty).toList();
    final quoteCursors = [for (final p in positions) _QuoteCursor(seriesByID[p.instrumentID]?.quotes ?? const [])];
    final stateIndex = List<int>.filled(positions.length, -1);
    final baseFxCursor = _FxCursor(fxHistory.points(baseCurrency));

    // Each ledger state's cost and realised amounts in the base currency,
    // converted once (live rates don't change across the walk).
    final converted = <PositionState, (double, double)>{};
    (double, double) inBase(PositionState state) => converted.putIfAbsent(
          state,
          () => (state.basis.inCurrency(baseCurrency, rates).amount, state.realised.inCurrency(baseCurrency, rates).amount),
        );

    final points = <PortfolioHistoryPoint>[];
    var cursor = startDate;
    while (!cursor.isAfter(today)) {
      // The last microsecond of the day (not the next midnight, which would
      // also swallow a sample stamped at the very start of the next day).
      final endOfDay = DateTime(cursor.year, cursor.month, cursor.day + 1).subtract(const Duration(microseconds: 1));
      final fxRate = baseCurrency == 'USD' ? 1.0 : (baseFxCursor.rateOnOrBefore(endOfDay) ?? rates.rate(baseCurrency) ?? 1);

      double valueUSD = 0;
      double cost = 0;
      double realised = 0;
      for (var i = 0; i < positions.length; i++) {
        final timeline = positions[i].timeline;
        while (stateIndex[i] + 1 < timeline.length && !timeline[stateIndex[i] + 1].date.isAfter(endOfDay)) {
          stateIndex[i] += 1;
        }
        final price = quoteCursors[i].priceOnOrBefore(endOfDay);
        if (stateIndex[i] < 0) continue;
        final state = timeline[stateIndex[i]];
        final (stateCost, stateRealised) = inBase(state);
        cost += stateCost;
        realised += stateRealised;
        // No price known yet on/before this day: the holding still carries
        // its cost, but no value until a price becomes available.
        if (price != null) valueUSD += state.fineOunces * price;
      }

      points.add(PortfolioHistoryPoint(date: cursor, value: valueUSD * fxRate, cost: cost, realised: realised));
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
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
