import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/display_point.dart';
import 'package:qima/services/chart_sampling.dart';

List<DisplayPoint> _points(int count) => List.generate(
      count,
      (i) => DisplayPoint(date: DateTime(2024, 1, 1).add(Duration(days: i)), value: i.toDouble()),
    );

void main() {
  group('ChartSampling.thinned (spec §8.9 / TC-S1..S9)', () {
    test('pass-through when already small enough', () {
      final points = _points(10);
      expect(ChartSampling.thinned(points, 20), points);
    });

    test('empty input returns empty output', () {
      expect(ChartSampling.thinned(const [], 10), isEmpty);
    });

    test('limit <= 1 returns input unchanged', () {
      final points = _points(20);
      expect(ChartSampling.thinned(points, 1), points);
      expect(ChartSampling.thinned(points, 0), points);
    });

    test('zero-bucket edge case at limit 2 and 3 returns just first+last (TC-S7)', () {
      final points = _points(50);
      final result2 = ChartSampling.thinned(points, 2);
      expect(result2, [points.first, points.last]);
      final result3 = ChartSampling.thinned(points, 3);
      expect(result3, [points.first, points.last]);
    });

    test('output count never exceeds limit', () {
      final points = _points(500);
      for (final limit in [2, 3, 4, 10, 50, 251]) {
        expect(ChartSampling.thinned(points, limit).length, lessThanOrEqualTo(limit));
      }
    });

    test('first and last points always survive', () {
      final points = _points(300);
      final result = ChartSampling.thinned(points, 50);
      expect(result.first, points.first);
      expect(result.last, points.last);
    });

    test('output stays ascending by date with no duplicate dates', () {
      final points = _points(300);
      final result = ChartSampling.thinned(points, 50);
      for (var i = 1; i < result.length; i++) {
        expect(result[i].date.isAfter(result[i - 1].date), isTrue);
      }
    });

    test('a single-sample spike within a bucket survives (local min/max preserved)', () {
      final points = [
        for (var i = 0; i < 20; i++) DisplayPoint(date: DateTime(2024, 1, 1).add(Duration(days: i)), value: 10),
      ];
      // Inject one spike in the middle.
      final spiked = List<DisplayPoint>.from(points);
      spiked[10] = DisplayPoint(date: spiked[10].date, value: 999);
      final result = ChartSampling.thinned(spiked, 8);
      expect(result.any((p) => p.value == 999), isTrue);
    });
  });
}
