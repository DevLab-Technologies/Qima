import 'package:equatable/equatable.dart';

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
