import 'package:equatable/equatable.dart';

import 'chart_range.dart';
import 'display_point.dart';
import 'fx_history.dart';
import 'holding_transaction.dart';
import 'ledger.dart';
import 'money.dart';
import 'portfolio_history.dart';
import 'quote.dart';

/// What moved the portfolio over a range, as facts a sentence is built from
/// (v4 phase 3). Every figure here comes from [PortfolioHistory]; the
/// sentence around them is a template, or a model's rephrasing that may not
/// add a number of its own.
class PeriodSummary extends Equatable {
  final ChartRange range;

  /// Change in gain over the range, in the base currency (see
  /// [PortfolioRangeChange.gainDelta]: buying more is never a gain).
  final double gainDelta;
  final double percent;

  /// The holding whose gain changed most either way, or null when nothing
  /// moved.
  final String? topMoverID;
  final double topMoverDelta;

  /// Buys and sells dated within the range.
  final int transactionCount;

  const PeriodSummary({
    required this.range,
    required this.gainDelta,
    required this.percent,
    this.topMoverID,
    this.topMoverDelta = 0,
    this.transactionCount = 0,
  });

  bool get isUp => gainDelta >= 0;

  /// Null when nothing was held during [range].
  static PeriodSummary? build({
    required Ledger ledger,
    required List<HoldingTransaction> transactions,
    required Map<String, QuoteSeries> seriesByID,
    required FXRates rates,
    required FXHistory fxHistory,
    required String baseCurrency,
    required DateTime now,
    ChartRange range = ChartRange.month1,
  }) {
    List<PortfolioHistoryPoint> history(Ledger l) => PortfolioHistory.build(
          ledger: l,
          seriesByID: seriesByID,
          rates: rates,
          fxHistory: fxHistory,
          baseCurrency: baseCurrency,
          range: range,
          now: now,
        );

    final change = PortfolioRangeChange.from(history(ledger), range);
    if (change == null) return null;

    String? topID;
    var topDelta = 0.0;
    for (final entry in ledger.positions.entries) {
      final delta = PortfolioRangeChange.from(history(Ledger({entry.key: entry.value})), range)?.gainDelta ?? 0;
      if (delta.abs() > topDelta.abs()) {
        topID = entry.key;
        topDelta = delta;
      }
    }

    final start = range.startDate(now);
    final count = start == null ? transactions.length : transactions.where((t) => !t.date.isBefore(start)).length;

    return PeriodSummary(
      range: range,
      gainDelta: change.gainDelta,
      percent: change.percentValue,
      topMoverID: topID,
      topMoverDelta: topDelta,
      transactionCount: count,
    );
  }

  @override
  List<Object?> get props => [range, gainDelta, percent, topMoverID, topMoverDelta, transactionCount];
}

/// A chart's shape as facts for a screen reader: where it started and
/// ended, and its high and low with their dates.
class ChartFacts extends Equatable {
  final DisplayPoint first;
  final DisplayPoint last;
  final DisplayPoint high;
  final DisplayPoint low;

  const ChartFacts({required this.first, required this.last, required this.high, required this.low});

  double get percent => first.value == 0 ? 0 : (last.value - first.value) / first.value;

  /// Null for fewer than two points, which draw nothing.
  static ChartFacts? of(List<DisplayPoint> points) {
    if (points.length < 2) return null;
    var high = points.first;
    var low = points.first;
    for (final p in points) {
      if (p.value > high.value) high = p;
      if (p.value < low.value) low = p;
    }
    return ChartFacts(first: points.first, last: points.last, high: high, low: low);
  }

  @override
  List<Object?> get props => [first, last, high, low];
}
