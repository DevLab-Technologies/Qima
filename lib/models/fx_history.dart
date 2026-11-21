import 'package:equatable/equatable.dart';

import 'money.dart';

/// A single historical FX sample: `perUSD` units of the currency per 1 USD.
class FXHistoryPoint extends Equatable {
  final DateTime date;
  final double perUSD;

  const FXHistoryPoint({required this.date, required this.perUSD});

  Map<String, dynamic> toJson() => {
        'date': date.toUtc().toIso8601String(),
        'perUSD': perUSD,
      };

  factory FXHistoryPoint.fromJson(Map<String, dynamic> json) => FXHistoryPoint(
        date: DateTime.parse(json['date'] as String),
        perUSD: (json['perUSD'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [date, perUSD];
}

DateTime _utcStartOfDay(DateTime date) {
  final u = date.toUtc();
  return DateTime.utc(u.year, u.month, u.day);
}

/// Historical FX rate series, keyed by currency code. USD is implicit
/// (always 1) and never stored.
class FXHistory extends Equatable {
  final Map<String, List<FXHistoryPoint>> series;

  const FXHistory({required this.series});

  static const FXHistory empty = FXHistory(series: {});

  /// Resolves the rate for [code] at [date]. Dates before the earliest
  /// sample fall back to the earliest sample (never null, never
  /// extrapolated). No history at all for the code returns null.
  double? rate(String code, DateTime date) {
    if (code == 'USD') return 1;
    final points = series[code];
    if (points == null || points.isEmpty) return null;
    double? chosen;
    for (final point in points) {
      if (!point.date.isAfter(date)) {
        chosen = point.perUSD;
      } else {
        break;
      }
    }
    return chosen ?? points.first.perUSD;
  }

  List<FXHistoryPoint> points(String code) => series[code] ?? const [];

  DateTime? latestDate(String code) {
    final points = series[code];
    if (points == null || points.isEmpty) return null;
    return points.last.date;
  }

  /// All sample dates across every currency, sorted ascending.
  List<DateTime> allDates() {
    final dates = <DateTime>{};
    for (final points in series.values) {
      for (final p in points) {
        dates.add(p.date);
      }
    }
    final list = dates.toList()..sort();
    return list;
  }

  FXHistory set(String code, List<FXHistoryPoint> newPoints) {
    final sorted = List<FXHistoryPoint>.of(newPoints)..sort((a, b) => a.date.compareTo(b.date));
    return FXHistory(series: {...series, code: sorted});
  }

  /// Merges [newPoints] into the existing series for [code], bucketing by
  /// UTC calendar day (not device timezone). New points win ties for the
  /// same day; existing points from days absent in the new data are kept.
  FXHistory merge(String code, List<FXHistoryPoint> newPoints) {
    final byDay = <DateTime, FXHistoryPoint>{};
    for (final p in series[code] ?? const <FXHistoryPoint>[]) {
      byDay[_utcStartOfDay(p.date)] = p;
    }
    for (final p in newPoints) {
      byDay[_utcStartOfDay(p.date)] = p;
    }
    final merged = byDay.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    return FXHistory(series: {...series, code: merged});
  }

  /// A daily close that jumps more than this from both neighbours, in the
  /// same direction, while they agree with each other, is a bad tick. A
  /// trend or a real step (a devaluation) never looks like that: the days
  /// on one side follow it.
  static const double spikeTolerance = 0.01;

  /// A series whose newest close and recent closes both sit this far from
  /// the live rate is from a feed that has gone wrong, so none of it is used.
  static const double liveTolerance = 0.02;

  /// This history with bad samples left out, checked against [live]: one-day
  /// spikes are dropped from every series, and a series whose recent closes
  /// disagree with the live rate is dropped whole (charts then show live
  /// prices only, never a made-up path). The stored history is untouched, so
  /// it comes back once the feed is right again.
  FXHistory checkedAgainst(FXRates live) {
    final out = <String, List<FXHistoryPoint>>{};
    series.forEach((code, points) {
      final kept = withoutSpikes(points);
      if (kept.isEmpty) return;
      final rate = live.rate(code), usd = live.rate('USD');
      if (rate != null && usd != null && usd > 0) {
        final perUSD = rate / usd;
        bool off(double v) => (v - perUSD).abs() / perUSD > liveTolerance;
        // Wrong only when both the newest close and the recent closes as a
        // whole disagree: a fast real move passes on the newest close, and
        // one bad last tick passes on the median and is trimmed below.
        final recent = [for (final p in kept.skip(kept.length > 5 ? kept.length - 5 : 0)) p.perUSD]..sort();
        if (off(kept.last.perUSD) && off(recent[recent.length ~/ 2])) return;
        while (kept.isNotEmpty && off(kept.last.perUSD)) {
          kept.removeLast();
        }
        if (kept.isEmpty) return;
      }
      out[code] = kept;
    });
    return FXHistory(series: out);
  }

  /// [points] without one-day spikes (see [spikeTolerance]). The first and
  /// last closes have one neighbour and are kept; the live check covers the
  /// newest one.
  static List<FXHistoryPoint> withoutSpikes(List<FXHistoryPoint> points) {
    if (points.length < 3) return List.of(points);
    double gap(double a, double b) => (a - b).abs() / b;
    bool spike(double before, double v, double after) =>
        before > 0 &&
        after > 0 &&
        gap(v, before) > spikeTolerance &&
        gap(v, after) > spikeTolerance &&
        (v > before) == (v > after) &&
        gap(after, before) <= spikeTolerance;
    return [
      for (var i = 0; i < points.length; i++)
        if (i == 0 || i == points.length - 1 || !spike(points[i - 1].perUSD, points[i].perUSD, points[i + 1].perUSD)) points[i],
    ];
  }

  Map<String, dynamic> toJson() => {
        'series': series.map((k, v) => MapEntry(k, v.map((p) => p.toJson()).toList())),
      };

  factory FXHistory.fromJson(Map<String, dynamic> json) {
    final raw = json['series'] as Map<String, dynamic>? ?? {};
    return FXHistory(
      series: raw.map(
        (k, v) => MapEntry(
          k,
          (v as List<dynamic>).map((e) => FXHistoryPoint.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [series];
}
