import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/portfolio_history.dart';
import 'package:qima/models/quote.dart';

void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;
  final usdRates = FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: DateTime(2024));

  QuoteSeries seriesOf(Instrument instrument, List<MapEntry<DateTime, double>> samples) {
    return QuoteSeries(
      instrumentID: instrument.id,
      quotes: [for (final s in samples) Quote(instrumentID: instrument.id, timestamp: s.key, canonicalUSD: s.value)],
    );
  }

  group('PortfolioHistory.build — day walk correctness', () {
    test('empty portfolio (no lots) returns an empty series', () {
      final points = PortfolioHistory.build(
        lots: const [],
        seriesByID: const {},
        rates: usdRates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.month1,
        now: DateTime(2024, 6, 10),
      );
      expect(points, isEmpty);
    });

    test('a lot added mid-range only contributes value from its date onward', () {
      final now = DateTime(2024, 6, 10);
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 2,
        unit: PriceUnit.troyOunce,
        unitCost: 1900,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 5),
      );
      final series = seriesOf(gold, [
        MapEntry(DateTime(2024, 6, 1), 1900),
        MapEntry(DateTime(2024, 6, 5), 2000),
        MapEntry(DateTime(2024, 6, 10), 2100),
      ]);

      final points = PortfolioHistory.build(
        lots: [lot],
        seriesByID: {gold.id: series},
        rates: usdRates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.month1,
        now: now,
      );

      final byDate = {for (final p in points) p.date: p};
      // Before the lot's date: zero value (and zero cost — nothing owned
      // yet), even though a price already existed.
      expect(byDate[DateTime(2024, 6, 3)]?.value, 0);
      expect(byDate[DateTime(2024, 6, 3)]?.cost, 0);
      // On/after the lot's date: valued at that day's last-known price.
      expect(byDate[DateTime(2024, 6, 5)]?.value, closeTo(2 * 2000, 1e-9));
      expect(byDate[DateTime(2024, 6, 10)]?.value, closeTo(2 * 2100, 1e-9));
      expect(byDate[DateTime(2024, 6, 10)]?.cost, closeTo(2 * 1900, 1e-9));
    });

    test('value uses the base-currency FX rate on each day (FX conversion)', () {
      final now = DateTime(2024, 6, 3);
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 1900,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 1),
      );
      final series = seriesOf(gold, [MapEntry(DateTime(2024, 6, 1), 2000)]);
      final fxHistory = FXHistory.empty.set('EUR', [
        FXHistoryPoint(date: DateTime(2024, 6, 1), perUSD: 0.90),
        FXHistoryPoint(date: DateTime(2024, 6, 2), perUSD: 0.92),
      ]);
      final rates = FXRates(base: 'USD', rates: const {'USD': 1, 'EUR': 0.95}, updatedAt: DateTime(2024));

      final points = PortfolioHistory.build(
        lots: [lot],
        seriesByID: {gold.id: series},
        rates: rates,
        fxHistory: fxHistory,
        baseCurrency: 'EUR',
        range: ChartRange.week1,
        now: now,
      );

      final byDate = {for (final p in points) p.date: p};
      // Day 1: uses the day-1 EUR sample (0.90), not the live rate (0.95).
      expect(byDate[DateTime(2024, 6, 1)]?.value, closeTo(2000 * 0.90, 1e-9));
      // Day 2 has its own FX sample.
      expect(byDate[DateTime(2024, 6, 2)]?.value, closeTo(2000 * 0.92, 1e-9));
      // Day 3 has no FX sample yet: holds the last known sample (day 2's).
      expect(byDate[DateTime(2024, 6, 3)]?.value, closeTo(2000 * 0.92, 1e-9));
    });

    test('a day before the instrument\'s first quote values that lot at zero, not a crash or extrapolation', () {
      final now = DateTime(2024, 6, 5);
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 1800,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 1),
      );
      // First quote for the instrument doesn't exist until day 4.
      final series = seriesOf(gold, [MapEntry(DateTime(2024, 6, 4), 2000)]);

      final points = PortfolioHistory.build(
        lots: [lot],
        seriesByID: {gold.id: series},
        rates: usdRates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.week1,
        now: now,
      );

      final byDate = {for (final p in points) p.date: p};
      expect(byDate[DateTime(2024, 6, 2)]?.value, 0);
      // Cost is still recognized even with no price yet (matches
      // HoldingValuation's "skip valuing, but the lot exists" behavior).
      expect(byDate[DateTime(2024, 6, 2)]?.cost, closeTo(1800, 1e-9));
      expect(byDate[DateTime(2024, 6, 4)]?.value, closeTo(2000, 1e-9));
    });

    test('multi-currency cost: each lot\'s own cost currency converts independently, at the live rate', () {
      final now = DateTime(2024, 6, 2);
      final lots = [
        HoldingLot(
          id: 'l1',
          instrumentID: gold.id,
          quantity: 1,
          unit: PriceUnit.troyOunce,
          unitCost: 1000,
          costCurrency: 'USD',
          date: DateTime(2024, 6, 1),
        ),
        HoldingLot(
          id: 'l2',
          instrumentID: silver.id,
          quantity: 1,
          unit: PriceUnit.troyOunce,
          unitCost: 900, // in EUR
          costCurrency: 'EUR',
          date: DateTime(2024, 6, 1),
        ),
      ];
      final rates = FXRates(base: 'USD', rates: const {'USD': 1, 'EUR': 0.9}, updatedAt: DateTime(2024));
      final series = {
        gold.id: seriesOf(gold, [MapEntry(DateTime(2024, 6, 1), 2000)]),
        silver.id: seriesOf(silver, [MapEntry(DateTime(2024, 6, 1), 25)]),
      };

      final points = PortfolioHistory.build(
        lots: lots,
        seriesByID: series,
        rates: rates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.week1,
        now: now,
      );

      final last = points.last;
      // USD lot: cost stays 1000. EUR lot: 900 EUR / 0.9 (EUR-per-USD) = 1000 USD.
      expect(last.cost, closeTo(2000, 1e-9));
    });

    test('"All" range starts at the earliest lot date, not an arbitrary fallback window', () {
      final now = DateTime(2024, 6, 10);
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 1500,
        costCurrency: 'USD',
        date: DateTime(2023, 1, 15),
      );
      final series = seriesOf(gold, [MapEntry(DateTime(2023, 1, 15), 1500), MapEntry(now, 2000)]);

      final points = PortfolioHistory.build(
        lots: [lot],
        seriesByID: {gold.id: series},
        rates: usdRates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.all,
        now: now,
      );

      expect(points.first.date, DateTime(2023, 1, 15));
      expect(points.last.date, DateTime(2024, 6, 10));
    });

    test('a lot dated in the future never produces a negative-length walk or a crash', () {
      final now = DateTime(2024, 6, 1);
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 1900,
        costCurrency: 'USD',
        date: DateTime(2025, 1, 1),
      );

      // "All" starts at the (future) lot date, which is after `now` — must
      // return an empty series rather than looping backwards or throwing.
      final all = PortfolioHistory.build(
        lots: [lot],
        seriesByID: {gold.id: seriesOf(gold, const [])},
        rates: usdRates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.all,
        now: now,
      );
      expect(all, isEmpty);

      // A bounded range that starts before `now`: every day is valued at
      // zero since the only lot isn't dated yet.
      final month = PortfolioHistory.build(
        lots: [lot],
        seriesByID: {gold.id: seriesOf(gold, const [])},
        rates: usdRates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.month1,
        now: now,
      );
      expect(month, isNotEmpty);
      expect(month.every((p) => p.value == 0 && p.cost == 0), isTrue);
    });
  });

  group('gain-change headline (spec: change in GAIN over the range, not value)', () {
    test('buying more mid-range is not shown as profit', () {
      final now = DateTime(2024, 6, 10);
      final lots = [
        HoldingLot(
          id: 'l1',
          instrumentID: gold.id,
          quantity: 1,
          unit: PriceUnit.troyOunce,
          unitCost: 2000,
          costCurrency: 'USD',
          date: DateTime(2024, 6, 1),
        ),
        // A second lot bought mid-range at the same price as the market —
        // this adds value and cost equally, so gain should NOT move even
        // though total value jumps.
        HoldingLot(
          id: 'l2',
          instrumentID: gold.id,
          quantity: 1,
          unit: PriceUnit.troyOunce,
          unitCost: 2000,
          costCurrency: 'USD',
          date: DateTime(2024, 6, 5),
        ),
      ];
      // Flat price the whole time: no real market movement.
      final series = seriesOf(gold, [MapEntry(DateTime(2024, 6, 1), 2000)]);

      final points = PortfolioHistory.build(
        lots: lots,
        seriesByID: {gold.id: series},
        rates: usdRates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        range: ChartRange.week1,
        now: now,
      );

      final first = points.first;
      final last = points.last;
      // Value roughly doubled (1 lot -> 2 lots), but gain is flat both ways.
      expect(last.value, greaterThan(first.value));
      expect(last.gain, closeTo(first.gain, 1e-9));
      expect(first.gain, closeTo(0, 1e-9));
    });
  });
}
