import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/allocation.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/asset_group.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/ledger.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';

void main() {
  final rates = FXRates(base: 'USD', rates: const {'USD': 1, 'SAR': 3.75}, updatedAt: DateTime(2026));
  const goldOz = 3110.34768; // $100/g
  final latest = <String, double>{'metal.XAU': goldOz, 'metal.XAG': 31.1034768, 'crypto.BTC': 50000, 'stock.AAPL': 200};

  HoldingLot lot(String id, double qty, {PriceUnit unit = PriceUnit.each, GoldKarat? karat, DateTime? date, String? lotId}) =>
      HoldingLot(
        id: lotId ?? '$id-$qty-${karat?.name}-${date?.toIso8601String()}',
        instrumentID: id,
        quantity: qty,
        unit: unit,
        unitCost: 1,
        costCurrency: 'USD',
        date: date ?? DateTime(2025, 6, 1),
        karat: karat,
      );

  List<HeldInstrument> held(List<HoldingLot> lots, {Map<String, double>? prices}) {
    final p = prices ?? latest;
    final byId = <String, List<HoldingLot>>{};
    for (final l in lots) {
      (byId[l.instrumentID] ??= []).add(l);
    }
    return [
      for (final e in byId.entries)
        if (HoldingValuation.aggregate(lots: e.value, rates: rates, displayCurrency: 'USD', latestUSD: (id) => p[id]) case final v?)
          HeldInstrument(instrument: InstrumentCatalog.instrument(e.key)!, valuation: v, transactionCount: e.value.length),
    ];
  }

  QuoteSeries series(String id, Map<DateTime, double> points) => QuoteSeries(
        instrumentID: id,
        quotes: [for (final e in points.entries) Quote(instrumentID: id, timestamp: e.key, canonicalUSD: e.value)],
      );

  group('byGroup', () {
    test('sums instruments into the four groups, largest first', () {
      final shares = Allocation.byGroup(
        held([lot('crypto.BTC', 1), lot('stock.AAPL', 100), lot('index.GSPC', 1), lot('metal.XAU', 100, unit: PriceUnit.gram)],
            prices: {...latest, 'index.GSPC': 5000}),
        'USD',
      );
      expect(shares.map((s) => s.key), [AssetGroup.crypto, AssetGroup.equities, AssetGroup.metals]);
      expect(shares[1].value.amount, closeTo(25000, 1e-6), reason: 'stocks and indices are one group');
      expect(shares.fold<double>(0, (sum, s) => sum + s.fraction), closeTo(1, 1e-9));
    });

    test('empty when nothing is held', () {
      expect(Allocation.byGroup(const [], 'USD'), isEmpty);
    });
  });

  group('metalsByForm', () {
    List<AllocationShare<MetalForm>> forms(List<HoldingLot> lots, {Map<String, double>? prices}) => Allocation.metalsByForm(
          lots: lots,
          rates: rates,
          baseCurrency: 'USD',
          latestUSD: (id) => (prices ?? latest)[id],
          resolve: InstrumentCatalog.instrument,
        );

    test('splits gold by karat and values each by its fine content', () {
      final shares = forms([
        lot('metal.XAU', 100, unit: PriceUnit.gram, karat: GoldKarat.k21),
        lot('metal.XAU', 50, unit: PriceUnit.gram),
        lot('metal.XAU', 1, unit: PriceUnit.troyOunce), // fine by convention
        lot('metal.XAG', 1000, unit: PriceUnit.gram),
      ]);
      final gold = InstrumentCatalog.instrument('metal.XAU')!;
      final byForm = {for (final s in shares) s.key: s.value.amount};
      expect(byForm[MetalForm(gold, GoldKarat.k21)], closeTo(8750, 1e-6));
      expect(byForm[MetalForm(gold, GoldKarat.k24)], closeTo(5000 + goldOz, 1e-6), reason: 'oz t gold joins 24K');
      expect(byForm[MetalForm(InstrumentCatalog.instrument('metal.XAG')!, null)], closeTo(1000, 1e-6));
      expect(shares.first.key, MetalForm(gold, GoldKarat.k21));
    });

    test('ignores non-metals and unpriced metals', () {
      final shares = forms([lot('crypto.BTC', 1), lot('metal.XPT', 1, unit: PriceUnit.troyOunce)]);
      expect(shares, isEmpty);
    });
  });

  group('drift', () {
    final gold = 'metal.XAU';
    final btc = 'crypto.BTC';

    DriftResult? drift(List<HoldingLot> lots, DateTime now, Map<String, QuoteSeries> history, {String base = 'USD', FXHistory fx = FXHistory.empty}) =>
        Allocation.drift(
          ledger: Ledger.derive(lots.map(HoldingTransaction.fromLot)),
          heldNow: held(lots),
          seriesByID: history,
          fxHistory: fx,
          rates: rates,
          baseCurrency: base,
          resolve: InstrumentCatalog.instrument,
          now: now,
        );

    test('compares 1 January with today', () {
      final lots = [lot(gold, 100, unit: PriceUnit.gram, date: DateTime(2025, 3, 1)), lot(btc, 1, date: DateTime(2025, 3, 1))];
      // On 1 Jan gold was $100/g ($10k) and BTC $10k: 50/50. Today gold is
      // $10k and BTC $50k: 1/6 vs 5/6.
      final history = {
        gold: series(gold, {DateTime(2025, 12, 31, 12): goldOz}),
        btc: series(btc, {DateTime(2025, 12, 30): 10000}),
      };
      final result = drift(lots, DateTime(2026, 10, 21), history) as DriftReady;
      expect(result.since, DateTime(2026, 1, 1));
      final rows = {for (final r in result.rows) r.group: r};
      expect(rows[AssetGroup.metals]!.from, closeTo(0.5, 1e-9));
      expect(rows[AssetGroup.metals]!.to, closeTo(10000 / 60000, 1e-9));
      expect(rows[AssetGroup.crypto]!.to, closeTo(50000 / 60000, 1e-9));
      expect(result.rows.first.group, AssetGroup.crypto, reason: 'largest share now comes first');
    });

    test('a group bought this year starts at 0%', () {
      final lots = [lot(gold, 100, unit: PriceUnit.gram, date: DateTime(2025, 3, 1)), lot(btc, 1, date: DateTime(2026, 5, 1))];
      final history = {gold: series(gold, {DateTime(2025, 12, 1): goldOz})};
      final result = drift(lots, DateTime(2026, 10, 21), history) as DriftReady;
      final crypto = result.rows.firstWhere((r) => r.group == AssetGroup.crypto);
      expect(crypto.from, 0);
      expect(result.rows.firstWhere((r) => r.group == AssetGroup.metals).from, 1);
    });

    test('a group sold off this year ends at 0% (shown, not dropped)', () {
      // Only gold now; BTC was held on 1 Jan in this scenario through a lot
      // the caller no longer has a price for today.
      final lots = [lot(gold, 100, unit: PriceUnit.gram, date: DateTime(2025, 3, 1)), lot(btc, 1, date: DateTime(2025, 3, 1))];
      final history = {
        gold: series(gold, {DateTime(2025, 12, 1): goldOz}),
        btc: series(btc, {DateTime(2025, 12, 1): 10000}),
      };
      final result = Allocation.drift(
        ledger: Ledger.derive(lots.map(HoldingTransaction.fromLot)),
        heldNow: held(lots, prices: {gold: goldOz}),
        seriesByID: history,
        fxHistory: FXHistory.empty,
        rates: rates,
        baseCurrency: 'USD',
        resolve: InstrumentCatalog.instrument,
        now: DateTime(2026, 10, 21),
      ) as DriftReady;
      expect(result.rows.firstWhere((r) => r.group == AssetGroup.crypto).to, 0);
    });

    test('starts from the first holding when that is after 1 January', () {
      final lots = [lot(gold, 1, unit: PriceUnit.troyOunce, date: DateTime(2026, 6, 10, 15))];
      final history = {gold: series(gold, {DateTime(2026, 6, 10, 9): goldOz})};
      final result = drift(lots, DateTime(2026, 10, 21), history) as DriftReady;
      expect(result.since, DateTime(2026, 6, 10));
    });

    test('is pending for the first 14 days of holdings', () {
      final lots = [lot(gold, 1, unit: PriceUnit.troyOunce, date: DateTime(2026, 10, 10))];
      expect(drift(lots, DateTime(2026, 10, 21), const {}), DriftPending(DateTime(2026, 10, 24)));
      // Day 14 itself is ready.
      final history = {gold: series(gold, {DateTime(2026, 10, 9): goldOz})};
      expect(drift(lots, DateTime(2026, 10, 24), history), isA<DriftReady>());
    });

    test('reaches back to last year in early January', () {
      final lots = [lot(gold, 1, unit: PriceUnit.troyOunce, date: DateTime(2024, 1, 1))];
      final history = {gold: series(gold, {DateTime(2024, 6, 1): goldOz})};
      expect((drift(lots, DateTime(2026, 1, 5), history) as DriftReady).since, DateTime(2025, 1, 1));
      expect((drift(lots, DateTime(2026, 1, 15), history) as DriftReady).since, DateTime(2026, 1, 1));
    });

    test('says so when a held asset has no price that far back', () {
      final lots = [lot(gold, 1, unit: PriceUnit.troyOunce, date: DateTime(2025, 3, 1))];
      final history = {gold: series(gold, {DateTime(2026, 2, 1): goldOz})};
      expect(drift(lots, DateTime(2026, 10, 21), history), const DriftNoPriceHistory());
    });

    test('uses that day\'s FX for the starting split', () {
      // A single group is 100% either way; the point is it values without
      // throwing and still reports the group.
      final lots = [lot(gold, 1, unit: PriceUnit.troyOunce, date: DateTime(2025, 3, 1))];
      final history = {gold: series(gold, {DateTime(2025, 12, 1): goldOz})};
      final fx = FXHistory(series: {
        'SAR': [FXHistoryPoint(date: DateTime(2025, 12, 1), perUSD: 3.7)],
      });
      final result = drift(lots, DateTime(2026, 10, 21), history, base: 'SAR', fx: fx) as DriftReady;
      expect(result.rows.single.from, 1);
    });

    test('null with nothing held', () {
      expect(drift(const [], DateTime(2026), const {}), isNull);
    });

    test('points change rounds like the screen', () {
      expect(const DriftRow(group: AssetGroup.metals, from: 0.121, to: 0.124).pointsChange, 0);
      expect(const DriftRow(group: AssetGroup.metals, from: 0.61, to: 0.65).pointsChange, 4);
      expect(const DriftRow(group: AssetGroup.crypto, from: 0.22, to: 0.18).pointsChange, -4);
    });
  });
}
