import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/display_point.dart';
import 'package:qima/theme/price_chart.dart';

void main() {
  test('a point from a UTC timestamp is labeled in local time', () {
    final utc = DateTime.utc(2026, 11, 5, 16, 24);
    final point = DisplayPoint(date: utc, value: 1);
    expect(point.date.isUtc, isFalse);
    expect(point.date, utc.toLocal());
    expect(axisDateFormat(AxisGranularity.time).format(point.date), axisDateFormat(AxisGranularity.time).format(utc.toLocal()));
  });
}
