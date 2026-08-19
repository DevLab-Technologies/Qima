import 'display_point.dart';

/// Selectable time windows for a price chart.
enum ChartRange {
  day1,
  day3,
  day7,
  month1,
  month3,
  month6,
  ytd,
  year1,
  year5,
  all;

  String get labelKey {
    switch (this) {
      case ChartRange.day1:
        return 'range.1D';
      case ChartRange.day3:
        return 'range.3D';
      case ChartRange.day7:
        return 'range.7D';
      case ChartRange.month1:
        return 'range.1M';
      case ChartRange.month3:
        return 'range.3M';
      case ChartRange.month6:
        return 'range.6M';
      case ChartRange.ytd:
        return 'range.ytd';
      case ChartRange.year1:
        return 'range.1Y';
      case ChartRange.year5:
        return 'range.5Y';
      case ChartRange.all:
        return 'range.all';
    }
  }

  /// Ranges cheap enough to offer by default (<= 1 year).
  static const List<ChartRange> defaultSelectable = [
    ChartRange.day1,
    ChartRange.day3,
    ChartRange.day7,
    ChartRange.month1,
    ChartRange.month3,
    ChartRange.month6,
    ChartRange.ytd,
    ChartRange.year1,
  ];

  /// Ranges only shown after an explicit user action ("load history").
  static const List<ChartRange> extended = [ChartRange.year5, ChartRange.all];

  bool get isExtended => extended.contains(this);

  static const ChartRange fallbackDefault = ChartRange.month3;

  /// Start date for this range relative to [now], or null for "all" (no
  /// filtering).
  DateTime? startDate(DateTime now) {
    switch (this) {
      case ChartRange.day1:
        return now.subtract(const Duration(days: 1));
      case ChartRange.day3:
        return now.subtract(const Duration(days: 3));
      case ChartRange.day7:
        return now.subtract(const Duration(days: 7));
      case ChartRange.month1:
        return _subtractMonths(now, 1);
      case ChartRange.month3:
        return _subtractMonths(now, 3);
      case ChartRange.month6:
        return _subtractMonths(now, 6);
      case ChartRange.ytd:
        return DateTime(now.year);
      case ChartRange.year1:
        return _subtractMonths(now, 12);
      case ChartRange.year5:
        return _subtractMonths(now, 60);
      case ChartRange.all:
        return null;
    }
  }

  static DateTime _subtractMonths(DateTime date, int months) {
    var year = date.year;
    var month = date.month - months;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    final daysInTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  List<DisplayPoint> filter(List<DisplayPoint> points, DateTime now) {
    final start = startDate(now);
    if (start == null) return points;
    return points.where((p) => !p.date.isBefore(start)).toList();
  }

  /// Ranges that are actually usable given the data in [points] — a range
  /// chip is only offered if the series reaches back that far. Always
  /// returns at least one entry.
  static List<ChartRange> available(List<DisplayPoint> points, DateTime now, {bool includeExtended = false}) {
    final pool = includeExtended ? ChartRange.values : ChartRange.defaultSelectable;
    if (points.length < 2) {
      return includeExtended ? const [ChartRange.all] : [pool.first];
    }
    final earliest = points.map((p) => p.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final dated = pool.where((range) {
      if (range == ChartRange.all) return false;
      final start = range.startDate(now);
      if (start == null) return false;
      return !earliest.isAfter(start);
    }).toList();
    final result = includeExtended ? [...dated, ChartRange.all] : dated;
    return result.isEmpty ? [pool.first] : result;
  }
}
