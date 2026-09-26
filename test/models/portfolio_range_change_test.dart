import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/portfolio_history.dart';

void main() {
  PortfolioHistoryPoint p(int day, double value, double cost) =>
      PortfolioHistoryPoint(date: DateTime(2026, 1, day), value: value, cost: cost);

  test('"All" is total gain over total cost, however lots were spread over time', () {
    // A small first lot, then most of the money later: the old first-day-cost
    // denominator turned this into -1670%.
    final points = [p(1, 130, 130), p(2, 130, 130), p(10, 20968.38, 23139.85)];
    final change = PortfolioRangeChange.from(points, ChartRange.all)!;

    expect(change.gainDelta, closeTo(20968.38 - 23139.85, 1e-6));
    expect(change.percentValue, closeTo((20968.38 - 23139.85) / 23139.85, 1e-9));
    expect(change.isUp, isFalse);
  });

  test('a bounded range with no purchases is the plain value return', () {
    final points = [p(1, 1000, 800), p(30, 1100, 800)];
    final change = PortfolioRangeChange.from(points, ChartRange.month1)!;

    expect(change.gainDelta, 100);
    expect(change.percentValue, closeTo(0.10, 1e-9));
  });

  test('money added during a range counts as invested, not as gain', () {
    // 1000 at the start, 500 more bought mid-range, worth 1650 at the end.
    final points = [p(1, 1000, 800), p(15, 1520, 1300), p(30, 1650, 1300)];
    final change = PortfolioRangeChange.from(points, ChartRange.month1)!;

    expect(change.gainDelta, closeTo(150, 1e-9));
    expect(change.percentValue, closeTo(150 / 1500, 1e-9));
  });

  test('no points means no change', () {
    expect(PortfolioRangeChange.from(const [], ChartRange.all), isNull);
  });
}
