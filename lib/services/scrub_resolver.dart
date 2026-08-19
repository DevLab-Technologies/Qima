import '../models/display_point.dart';

/// Resolves a dragged/scrubbed date to the nearest chart vertex. The leading
/// edge of the plotted window is exact; the trailing edge tolerates 15% of
/// the total span past the last sample (matching the chart's 24pt trailing
/// axis padding). Spec §3.3 / TC-SR1..SR9.
class ScrubResolver {
  ScrubResolver._();

  static const double trailingSlack = 0.15;

  static DisplayPoint? sample(DateTime date, List<DisplayPoint> points) {
    if (points.isEmpty) return null;
    final first = points.first.date;
    final last = points.last.date;
    final spanMicros = last.difference(first).inMicroseconds;
    final slackMicros = (spanMicros * trailingSlack).round();
    final upperBound = last.add(Duration(microseconds: slackMicros));

    if (date.isBefore(first)) return null;
    if (date.isAfter(upperBound)) return null;

    DisplayPoint closest = points.first;
    Duration bestDelta = date.difference(closest.date).abs();
    for (final point in points) {
      final delta = date.difference(point.date).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        closest = point;
      }
    }
    return closest;
  }
}

/// Axis granularity derived from a series' total span, with tick formatting
/// hints. Thresholds are exact day-count boundaries measured in seconds
/// (86,400s/day) to avoid calendar-month drift (spec §3.3 / §8.11).
enum AxisGranularity {
  time,
  dayMonth,
  month,
  monthYear,
  year;

  static const int _secondsPerDay = 86400;

  static AxisGranularity forSpan(Duration span) {
    final days = span.inSeconds / _secondsPerDay;
    if (days < 2) return AxisGranularity.time;
    if (days < 120) return AxisGranularity.dayMonth;
    if (days < 400) return AxisGranularity.month;
    if (days < 730) return AxisGranularity.monthYear;
    return AxisGranularity.year;
  }

  int get tickCount {
    switch (this) {
      case AxisGranularity.time:
        return 4;
      case AxisGranularity.dayMonth:
        return 4;
      case AxisGranularity.month:
        return 4;
      case AxisGranularity.monthYear:
        return 3;
      case AxisGranularity.year:
        return 4;
    }
  }
}
