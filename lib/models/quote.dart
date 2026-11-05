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

  /// How far back samples keep their minute; older ones collapse to one a
  /// calendar day.
  static const Duration intradayWindow = Duration(days: 2);

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
  /// device-local calendar minute (newest wins). Samples older than 2 days
  /// are first collapsed to one point per calendar day (the same approach
  /// [merging] uses for backfilled history) so that a long-running foreground
  /// refresh — which only ever calls this method — can't slowly evict years
  /// of daily history by filling [limit] with recent one-minute samples.
  /// Keeps at most [limit] most-recent samples after collapsing.
  QuoteSeries appending(Quote quote, {int limit = 2000, DateTime? now}) {
    final effectiveNow = now ?? quote.timestamp;
    final intradayCutoff = effectiveNow.subtract(intradayWindow);
    String keyFor(Quote q) => q.timestamp.isBefore(intradayCutoff) ? _dayKey(q.timestamp) : _minuteKey(q.timestamp);

    // Same collision rule as [merging]: the sample with the greatest
    // timestamp wins any bucket collision, and on a tie the new one does.
    final byKey = <String, Quote>{};
    for (final q in [...quotes, quote]) {
      final key = keyFor(q);
      final existing = byKey[key];
      if (existing == null || !q.timestamp.isBefore(existing.timestamp)) {
        byKey[key] = q;
      }
    }
    final merged = byKey.values.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final trimmed = merged.length > limit ? merged.sublist(merged.length - limit) : merged;
    return QuoteSeries(instrumentID: instrumentID, quotes: trimmed);
  }

  /// Backfill merge: samples within 2 days of [now] are keyed per-minute;
  /// older samples collapse to one per calendar day. The greater timestamp
  /// wins a collision, and on a tie the new sample does, so a re-fetched
  /// bar replaces the copy stored while it was still forming.
  ///
  /// With [replacing], every existing sample inside that span is dropped
  /// first: the new samples are the whole record of it, so samples from
  /// another source never interleave with them.
  QuoteSeries merging(
    List<Quote> newQuotes,
    DateTime now, {
    int limit = 2000,
    ({DateTime from, DateTime to})? replacing,
  }) {
    final intradayCutoff = now.subtract(intradayWindow);
    String keyFor(Quote q) => q.timestamp.isBefore(intradayCutoff) ? _dayKey(q.timestamp) : _minuteKey(q.timestamp);
    bool replaced(Quote q) =>
        replacing != null && !q.timestamp.isBefore(replacing.from) && !q.timestamp.isAfter(replacing.to);

    final byKey = <String, Quote>{};
    for (final q in [...quotes.where((q) => !replaced(q)), ...newQuotes]) {
      final key = keyFor(q);
      final existing = byKey[key];
      if (existing == null || !q.timestamp.isBefore(existing.timestamp)) {
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
