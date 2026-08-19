import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/display_point.dart';
import 'package:qima/services/scrub_resolver.dart';

void main() {
  final first = DateTime(2024, 1, 1);
  final last = DateTime(2024, 1, 11); // 10-day span
  final points = [
    DisplayPoint(date: first, value: 1),
    DisplayPoint(date: DateTime(2024, 1, 6), value: 2),
    DisplayPoint(date: last, value: 3),
  ];

  group('ScrubResolver.sample asymmetric slack (spec §8.10 / TC-SR6/7/8)', () {
    test('leading edge is exact: 1ms before first sample resolves to null (TC-SR6)', () {
      final justBefore = first.subtract(const Duration(milliseconds: 1));
      expect(ScrubResolver.sample(justBefore, points), isNull);
    });

    test('date exactly at first sample resolves', () {
      expect(ScrubResolver.sample(first, points), points.first);
    });

    test('trailing edge tolerates 15% of span past the last sample (TC-SR7)', () {
      // span = 10 days; 15% slack = 1.5 days
      final withinSlack = last.add(const Duration(hours: 20));
      expect(ScrubResolver.sample(withinSlack, points), points.last);

      final beyondSlack = last.add(const Duration(days: 2));
      expect(ScrubResolver.sample(beyondSlack, points), isNull);
    });

    test('single-point window has zero span and zero slack in either direction (TC-SR8)', () {
      final single = [DisplayPoint(date: first, value: 1)];
      expect(ScrubResolver.sample(first, single), single.first);
      expect(ScrubResolver.sample(first.add(const Duration(milliseconds: 1)), single), isNull);
      expect(ScrubResolver.sample(first.subtract(const Duration(milliseconds: 1)), single), isNull);
    });

    test('empty points returns null', () {
      expect(ScrubResolver.sample(first, const []), isNull);
    });

    test('resolves to the nearest vertex', () {
      final near = DateTime(2024, 1, 5);
      expect(ScrubResolver.sample(near, points), points[1]);
    });
  });

  group('AxisGranularity thresholds (spec §8.11)', () {
    test('span < 2 days -> time', () {
      expect(AxisGranularity.forSpan(const Duration(hours: 47)), AxisGranularity.time);
    });
    test('span < 120 days -> dayMonth', () {
      expect(AxisGranularity.forSpan(const Duration(days: 2)), AxisGranularity.dayMonth);
      expect(AxisGranularity.forSpan(const Duration(days: 119)), AxisGranularity.dayMonth);
    });
    test('span < 400 days -> month', () {
      expect(AxisGranularity.forSpan(const Duration(days: 120)), AxisGranularity.month);
      expect(AxisGranularity.forSpan(const Duration(days: 399)), AxisGranularity.month);
    });
    test('span < 730 days -> monthYear', () {
      expect(AxisGranularity.forSpan(const Duration(days: 400)), AxisGranularity.monthYear);
      expect(AxisGranularity.forSpan(const Duration(days: 729)), AxisGranularity.monthYear);
    });
    test('span >= 730 days -> year', () {
      expect(AxisGranularity.forSpan(const Duration(days: 730)), AxisGranularity.year);
    });
  });
}
