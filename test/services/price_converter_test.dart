import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/services/price_converter.dart';

/// Naive/independent per-point lookup, used as the reference implementation
/// against which the forward-cursor walk in [PriceConverter.points] must be
/// provably identical (spec §8.3 / TC-P6/TC-P10).
double _naiveRate(FXHistory history, String code, DateTime date) {
  final points = history.points(code);
  if (points.isEmpty) return double.nan;
  double? chosen;
  for (final p in points) {
    if (!p.date.isAfter(date)) {
      chosen = p.perUSD;
    }
  }
  return chosen ?? points.first.perUSD;
}

void main() {
  final rates = FXRates(base: 'USD', rates: const {'EUR': 0.9}, updatedAt: DateTime(2024));
  final history = FXHistory(series: {
    'EUR': [
      FXHistoryPoint(date: DateTime(2024, 1, 10), perUSD: 0.88),
      FXHistoryPoint(date: DateTime(2024, 2, 10), perUSD: 0.90),
      FXHistoryPoint(date: DateTime(2024, 3, 10), perUSD: 0.92),
    ],
  });

  final quotes = QuoteSeries(
    instrumentID: 'metal.XAU',
    quotes: [
      Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2024, 1, 1), canonicalUSD: 2000), // before earliest
      Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2024, 1, 10), canonicalUSD: 2010), // exact match
      Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2024, 1, 20), canonicalUSD: 2020), // between samples
      Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2024, 2, 15), canonicalUSD: 2030), // between samples
      Quote(instrumentID: 'metal.XAU', timestamp: DateTime(2024, 4, 1), canonicalUSD: 2040), // after last
    ],
  );

  group('PriceConverter.points forward-cursor walk (TC-P3/P6/P10)', () {
    test('matches naive independent per-point lookup exactly', () {
      final converter = PriceConverter(rates: rates, currencyCode: 'EUR', unit: PriceUnit.troyOunce, history: history);
      final result = converter.points(quotes);

      for (var i = 0; i < quotes.quotes.length; i++) {
        final quote = quotes.quotes[i];
        final expectedRate = _naiveRate(history, 'EUR', quote.timestamp);
        final expectedValue = quote.canonicalUSD * expectedRate * PriceUnit.troyOunce.multiplier;
        expect(result[i].value, closeTo(expectedValue, 1e-9));
      }
    });

    test('USD currency uses flat unit*purity multiplier (no history walk)', () {
      final converter = PriceConverter(rates: rates, currencyCode: 'USD', unit: PriceUnit.gram, history: history);
      final result = converter.points(quotes);
      for (var i = 0; i < quotes.quotes.length; i++) {
        expect(result[i].value, closeTo(quotes.quotes[i].canonicalUSD * PriceUnit.gram.multiplier, 1e-9));
      }
    });

    test('no history samples for currency falls back to flat live factor', () {
      final converter = PriceConverter(rates: rates, currencyCode: 'EUR', unit: PriceUnit.troyOunce);
      final result = converter.points(quotes);
      for (var i = 0; i < quotes.quotes.length; i++) {
        expect(result[i].value, closeTo(quotes.quotes[i].canonicalUSD * 0.9, 1e-9));
      }
    });
  });

  group('Karat scaling composes multiplicatively on BOTH code paths (TC-P11/P12)', () {
    test('flat (no-history) path', () {
      final unscaled = PriceConverter(rates: rates, currencyCode: 'USD', unit: PriceUnit.gram);
      final k18 = PriceConverter(rates: rates, currencyCode: 'USD', unit: PriceUnit.gram, karat: GoldKarat.k18);
      final quote = quotes.quotes.first;
      final unscaledValue = unscaled.points(QuoteSeries(instrumentID: 'x', quotes: [quote]))[0].value;
      final k18Value = k18.points(QuoteSeries(instrumentID: 'x', quotes: [quote]))[0].value;
      expect(k18Value, closeTo(unscaledValue * (18 / 24), 1e-9));
    });

    test('historical FX-walk path', () {
      final unscaled = PriceConverter(rates: rates, currencyCode: 'EUR', unit: PriceUnit.gram, history: history);
      final k18 = PriceConverter(
        rates: rates,
        currencyCode: 'EUR',
        unit: PriceUnit.gram,
        karat: GoldKarat.k18,
        history: history,
      );
      final unscaledValue = unscaled.points(quotes);
      final k18Value = k18.points(quotes);
      for (var i = 0; i < quotes.quotes.length; i++) {
        expect(k18Value[i].value, closeTo(unscaledValue[i].value * (18 / 24), 1e-9));
      }
    });
  });

  test('PriceUnit.kilogram is exactly 1000x gram (TC-U2)', () {
    expect(PriceUnit.kilogram.multiplier, PriceUnit.gram.multiplier * 1000);
  });
}
