import 'package:equatable/equatable.dart';

/// A single canonical-USD price sample for an instrument.
class Quote extends Equatable {
  final String instrumentID;
  final DateTime timestamp;
  final double canonicalUSD;

  const Quote({required this.instrumentID, required this.timestamp, required this.canonicalUSD});

  Map<String, dynamic> toJson() => {
        'instrumentID': instrumentID,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'canonicalUSD': canonicalUSD,
      };

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        instrumentID: json['instrumentID'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        canonicalUSD: (json['canonicalUSD'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [instrumentID, timestamp, canonicalUSD];
}

String _minuteKey(DateTime t) {
  final local = t.toLocal();
  return 'm-${local.year}-${local.month}-${local.day}-${local.hour}-${local.minute}';
}

String _dayKey(DateTime t) {
  final local = t.toLocal();
  final startOfDay = DateTime(local.year, local.month, local.day);
  return 'd-${startOfDay.millisecondsSinceEpoch}';
}

/// Ordered (ascending by timestamp) history of quotes for one instrument.
class QuoteSeries extends Equatable {
  final String instrumentID;
  final List<Quote> quotes;

  QuoteSeries({required this.instrumentID, List<Quote>? quotes})
      : quotes = List.unmodifiable(_sorted(quotes ?? const []));

  static List<Quote> _sorted(List<Quote> quotes) {
    final copy = List<Quote>.of(quotes);
    copy.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return copy;
  }

  static QuoteSeries empty(String instrumentID) => QuoteSeries(instrumentID: instrumentID);

  bool get isEmpty => quotes.isEmpty;

  Quote? get latest => quotes.isEmpty ? null : quotes.last;

  Quote? get earliest => quotes.isEmpty ? null : quotes.first;

  double get absoluteChangeUSD {
    if (quotes.length < 2) return 0;
    return quotes.last.canonicalUSD - quotes.first.canonicalUSD;
  }

  double get percentChange {
    if (quotes.length < 2) return 0;
    final first = quotes.first.canonicalUSD;
    if (first == 0) return 0;
    return (quotes.last.canonicalUSD - first) / first;
  }

  bool get isTrendingUp => absoluteChangeUSD >= 0;

  /// Appends a live quote, de-duping any existing quote in the same
  /// device-local calendar minute (newest wins), keeping at most [limit]
  /// most-recent samples.
  QuoteSeries appending(Quote quote, {int limit = 2000}) {
    final key = _minuteKey(quote.timestamp);
    final merged = quotes.where((q) => _minuteKey(q.timestamp) != key).toList()..add(quote);
    merged.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final trimmed = merged.length > limit ? merged.sublist(merged.length - limit) : merged;
    return QuoteSeries(instrumentID: instrumentID, quotes: trimmed);
  }

  /// Backfill merge: samples within 2 days of [now] are keyed per-minute;
  /// older samples collapse to one per calendar day. Ties are broken by
  /// keeping the greater timestamp.
  QuoteSeries merging(List<Quote> newQuotes, DateTime now, {int limit = 2000}) {
    final intradayCutoff = now.subtract(const Duration(days: 2));
    String keyFor(Quote q) => q.timestamp.isBefore(intradayCutoff) ? _dayKey(q.timestamp) : _minuteKey(q.timestamp);

    // For each bucket key, the sample with the greatest timestamp wins any
    // collision (ties broken arbitrarily, per the spec's "greater or equal"
    // rule since the values are then identical for tie purposes).
    final byKey = <String, Quote>{};
    for (final q in [...quotes, ...newQuotes]) {
      final key = keyFor(q);
      final existing = byKey[key];
      if (existing == null || q.timestamp.isAfter(existing.timestamp)) {
        byKey[key] = q;
      }
    }
    final merged = byKey.values.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final trimmed = merged.length > limit ? merged.sublist(merged.length - limit) : merged;
    return QuoteSeries(instrumentID: instrumentID, quotes: trimmed);
  }

  Map<String, dynamic> toJson() => {
        'instrumentID': instrumentID,
        'quotes': quotes.map((q) => q.toJson()).toList(),
      };

  factory QuoteSeries.fromJson(Map<String, dynamic> json) => QuoteSeries(
        instrumentID: json['instrumentID'] as String,
        quotes: (json['quotes'] as List<dynamic>)
            .map((e) => Quote.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [instrumentID, quotes];
}
