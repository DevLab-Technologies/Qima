import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/quote.dart';

void main() {
  group('QuoteSeries.appending per-minute dedup (spec §8.5 / TC-Q4)', () {
    test('two quotes 30 seconds apart in the same minute collapse, newest wins', () {
      var series = QuoteSeries.empty('metal.XAU');
      final base = DateTime(2024, 1, 1, 12, 30, 0);
      series = series.appending(Quote(instrumentID: 'metal.XAU', timestamp: base, canonicalUSD: 100));
      series = series.appending(
        Quote(instrumentID: 'metal.XAU', timestamp: base.add(const Duration(seconds: 30)), canonicalUSD: 101),
      );
      expect(series.quotes.length, 1);
      expect(series.quotes.single.canonicalUSD, 101);
    });

    test('quotes in different minutes are both kept', () {
      var series = QuoteSeries.empty('metal.XAU');
      final base = DateTime(2024, 1, 1, 12, 30, 0);
      series = series.appending(Quote(instrumentID: 'metal.XAU', timestamp: base, canonicalUSD: 100));
      series = series.appending(
        Quote(instrumentID: 'metal.XAU', timestamp: base.add(const Duration(minutes: 1)), canonicalUSD: 101),
      );
      expect(series.quotes.length, 2);
    });
  });

  group('QuoteSeries.appending daily collapse (long-history survival)', () {
    test('minute-resolution samples older than 2 days collapse to one per day as new quotes arrive', () {
      // Simulate 3 days of one-minute-resolution foreground refreshes.
      var series = QuoteSeries.empty('metal.XAU');
      final start = DateTime(2024, 1, 1, 0, 0, 0);
      var t = start;
      for (var i = 0; i < 3 * 24 * 60; i++) {
        series = series.appending(Quote(instrumentID: 'metal.XAU', timestamp: t, canonicalUSD: 100 + i.toDouble()));
        t = t.add(const Duration(minutes: 1));
      }
      // The most recent 2 days stay at one-minute resolution; everything
      // before that collapses to (at most) one point per calendar day.
      final now = series.quotes.last.timestamp;
      final intradayCutoff = now.subtract(const Duration(days: 2));
      final old = series.quotes.where((q) => q.timestamp.isBefore(intradayCutoff)).toList();
      final recent = series.quotes.where((q) => !q.timestamp.isBefore(intradayCutoff)).toList();
      expect(old.length, lessThanOrEqualTo(2)); // at most the leading partial + one full day.
      expect(recent.length, greaterThan(60)); // still minute-resolution.
    });

    test('a 5Y-old quote survives many days of intermittent one-minute foreground refreshes', () {
      // Simulates the actual failure mode the spec describes: the app is
      // opened in the foreground for a while (60s refresh cadence) on each
      // of many separate days, well within the 2000-sample cap for any one
      // day, but enough elapsed real time that pre-fix behaviour (a flat
      // recency cap with no collapsing) would have pushed 5-year-old daily
      // history out entirely.
      var series = QuoteSeries(
        instrumentID: 'metal.XAU',
        quotes: [Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2019, 1, 1), canonicalUSD: 50)],
      );
      var day = DateTime(2024, 1, 1);
      for (var d = 0; d < 200; d++) {
        // 30 minutes of one-minute-resolution refreshes per day.
        var t = day;
        for (var m = 0; m < 30; m++) {
          series = series.appending(Quote(instrumentID: 'metal.XAU', timestamp: t, canonicalUSD: 100 + m.toDouble()));
          t = t.add(const Duration(minutes: 1));
        }
        day = day.add(const Duration(days: 1));
      }
      expect(series.quotes.length, lessThanOrEqualTo(2000));
      expect(series.quotes.any((q) => q.timestamp.year == 2019), isTrue);
    });

    test('a same-day tie keeps the newer sample (greater timestamp wins)', () {
      final now = DateTime(2024, 6, 10);
      final day = DateTime(2024, 1, 1);
      var series = QuoteSeries(
        instrumentID: 'metal.XAU',
        quotes: [Quote(instrumentID: 'metal.XAU', timestamp: day.add(const Duration(hours: 1)), canonicalUSD: 100)],
      );
      series = series.appending(
        Quote(instrumentID: 'metal.XAU', timestamp: day.add(const Duration(hours: 20)), canonicalUSD: 110),
        now: now,
      );
      final dayQuotes = series.quotes.where((q) => q.timestamp.year == 2024 && q.timestamp.month == 1 && q.timestamp.day == 1);
      expect(dayQuotes.length, 1);
      expect(dayQuotes.single.canonicalUSD, 110);
    });

    test('an empty series collapses to just the new quote', () {
      final series = QuoteSeries.empty('metal.XAU').appending(
        Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2024, 1, 1), canonicalUSD: 42),
      );
      expect(series.quotes.length, 1);
      expect(series.quotes.single.canonicalUSD, 42);
    });
  });

  group('QuoteSeries.merging backfill keying (spec §8.5 / TC-Q6)', () {
    test('samples within 2 days of now key per-minute; ties keep greatest timestamp', () {
      final now = DateTime(2024, 6, 1, 12, 0, 0);
      final minute = DateTime(2024, 6, 1, 10, 15, 0);
      final existing = QuoteSeries(
        instrumentID: 'metal.XAU',
        quotes: [Quote(instrumentID: 'metal.XAU', timestamp: minute, canonicalUSD: 100)],
      );
      final merged = existing.merging(
        [Quote(instrumentID: 'metal.XAU', timestamp: minute.add(const Duration(seconds: 10)), canonicalUSD: 105)],
        now,
      );
      expect(merged.quotes.length, 1);
      expect(merged.quotes.single.canonicalUSD, 105);
    });

    test('samples older than 2 days collapse to one per calendar day', () {
      final now = DateTime(2024, 6, 10);
      final day = DateTime(2024, 1, 1);
      final existing = QuoteSeries(
        instrumentID: 'metal.XAU',
        quotes: [
          Quote(instrumentID: 'metal.XAU', timestamp: day.add(const Duration(hours: 1)), canonicalUSD: 100),
        ],
      );
      final merged = existing.merging(
        [Quote(instrumentID: 'metal.XAU', timestamp: day.add(const Duration(hours: 20)), canonicalUSD: 110)],
        now,
      );
      expect(merged.quotes.length, 1);
      expect(merged.quotes.single.canonicalUSD, 110);
    });
  });
}
