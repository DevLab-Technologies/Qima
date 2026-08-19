import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/instrument_presentation.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/services/price_converter.dart';

void main() {
  final rates = FXRates(base: 'USD', rates: const {}, updatedAt: DateTime(2024));
  final instrument = InstrumentCatalog.instrument('metal.XAU')!;

  InstrumentPresentation presentationWith(List<Quote> quotes) {
    final series = QuoteSeries(instrumentID: instrument.id, quotes: quotes);
    final converter = PriceConverter(rates: rates, currencyCode: 'USD', unit: PriceUnit.troyOunce);
    return InstrumentPresentation(instrument: instrument, series: series, converter: converter);
  }

  group('RangeChange scoping (spec §8.12)', () {
    test('window with 0 points yields null, never a fabricated 0%', () {
      final presentation = presentationWith(const []);
      expect(presentation.change(ChartRange.day1, DateTime(2024, 6, 1)), isNull);
    });

    test('window with exactly 1 point yields null', () {
      final presentation = presentationWith([
        Quote(instrumentID: instrument.id, timestamp: DateTime(2024, 6, 1), canonicalUSD: 2000),
      ]);
      expect(presentation.change(ChartRange.day1, DateTime(2024, 6, 1, 12)), isNull);
    });

    test('window whose first value is exactly 0 yields null', () {
      final now = DateTime(2024, 6, 1, 12);
      final presentation = presentationWith([
        Quote(instrumentID: instrument.id, timestamp: now.subtract(const Duration(hours: 1)), canonicalUSD: 0),
        Quote(instrumentID: instrument.id, timestamp: now, canonicalUSD: 2000),
      ]);
      expect(presentation.change(ChartRange.day1, now), isNull);
    });

    test('a valid window computes a real absolute/percent change', () {
      final now = DateTime(2024, 6, 1, 12);
      final presentation = presentationWith([
        Quote(instrumentID: instrument.id, timestamp: now.subtract(const Duration(hours: 1)), canonicalUSD: 2000),
        Quote(instrumentID: instrument.id, timestamp: now, canonicalUSD: 2100),
      ]);
      final change = presentation.change(ChartRange.day1, now);
      expect(change, isNotNull);
      expect(change!.absoluteValue, closeTo(100, 1e-9));
      expect(change.percentValue, closeTo(0.05, 1e-9));
      expect(change.isUp, isTrue);
    });

    test('sparklineChange always matches the fallbackDefault window, never a wider one', () {
      final now = DateTime(2024, 6, 1, 12);
      final presentation = presentationWith([
        Quote(instrumentID: instrument.id, timestamp: now.subtract(const Duration(days: 400)), canonicalUSD: 1000),
        Quote(instrumentID: instrument.id, timestamp: now.subtract(const Duration(days: 10)), canonicalUSD: 1900),
        Quote(instrumentID: instrument.id, timestamp: now, canonicalUSD: 2000),
      ]);
      final sparkline = presentation.sparklineChange(now);
      final explicit = presentation.change(ChartRange.fallbackDefault, now);
      expect(sparkline?.percentValue, explicit?.percentValue);
      // Must NOT equal the whole-series (400-day) change.
      expect(sparkline!.percentValue, isNot(closeTo(1.0, 1e-9)));
    });
  });
}
