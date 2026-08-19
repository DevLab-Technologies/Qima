import '../models/display_point.dart';

/// Downsamples a point series for chart rendering while preserving local
/// min/max extremes per bucket, so a single-sample spike is never smoothed
/// away. Mirrors `ChartSampling.thinned` exactly (spec §3.3 / TC-S1..S9).
class ChartSampling {
  ChartSampling._();

  static List<DisplayPoint> thinned(List<DisplayPoint> points, int limit) {
    if (limit < 2 || points.length <= limit) return points;

    final last = points.length - 1;
    // Integer division truncates: at limit 2 or 3 there are zero buckets,
    // so the result is just the first+last point (TC-S7).
    final buckets = (limit - 2) ~/ 2;
    final span = last - 1;

    final sampled = <DisplayPoint>[points[0]];

    for (var bucket = 0; bucket < buckets; bucket++) {
      final start = 1 + (bucket * span) ~/ buckets;
      final end = 1 + ((bucket + 1) * span) ~/ buckets;
      if (start >= end) continue;

      var lo = start;
      var hi = start;
      for (var i = start; i < end; i++) {
        if (points[i].value < points[lo].value) lo = i;
        if (points[i].value > points[hi].value) hi = i;
      }

      final first = lo < hi ? lo : hi;
      final second = lo < hi ? hi : lo;
      sampled.add(points[first]);
      if (second != first) sampled.add(points[second]);
    }

    sampled.add(points[last]);
    return sampled;
  }
}
