import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/display_point.dart';

void main() {
  test('available() falls back to a single chip when fewer than 2 points exist', () {
    final now = DateTime(2024, 6, 1);
    expect(ChartRange.available(const [], now), [ChartRange.day1]);
    expect(
      ChartRange.available([DisplayPoint(date: now, value: 1)], now),
      [ChartRange.day1],
    );
  });

  test('available() only offers ranges the series actually reaches back to', () {
    final now = DateTime(2024, 6, 10);
    // Data only reaches 5 days back: day1/day3 fit (their start is within the
    // data), but day7 (needs 7 days of history) and month3 do not.
    final points = [
      DisplayPoint(date: now.subtract(const Duration(days: 5)), value: 1),
      DisplayPoint(date: now, value: 2),
    ];
    final available = ChartRange.available(points, now);
    expect(available.contains(ChartRange.day3), isTrue);
    expect(available.contains(ChartRange.day7), isFalse);
    expect(available.contains(ChartRange.month3), isFalse);
  });

  test('available(includeExtended: true) with degenerate data returns [.all]', () {
    final now = DateTime(2024, 6, 10);
    expect(ChartRange.available(const [], now, includeExtended: true), [ChartRange.all]);
  });

  test('kilogram gram-derived constant sanity: fallbackDefault is month3', () {
    expect(ChartRange.fallbackDefault, ChartRange.month3);
  });
}
