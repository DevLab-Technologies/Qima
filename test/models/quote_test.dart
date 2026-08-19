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
