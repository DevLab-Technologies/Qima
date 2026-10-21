import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/holding_totals.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/ledger.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';

void main() {
  const gold = 'metal.XAU';
  const grams = PriceUnit.gram;
  final usdOnly = FXRates(base: 'USD', rates: const {'USD': 1, 'SAR': 4}, updatedAt: DateTime(2026));

  HoldingTransaction tx(
    String id,
    TransactionKind kind,
    double quantity,
    double price,
    DateTime date, {
    double fee = 0,
    GoldKarat? karat,
    String currency = 'USD',
    String instrument = gold,
    PriceUnit unit = grams,
  }) =>
      HoldingTransaction(
        id: id,
        instrumentID: instrument,
        kind: kind,
        quantity: quantity,
        unit: unit,
        karat: karat,
        unitPrice: price,
        fee: fee,
        currency: currency,
        date: date,
      );

  double fineGrams(InstrumentPosition p) => p.fineOunces / grams.multiplier;
  double basisUsd(InstrumentPosition p) => p.timeline.last.basis.inCurrency('USD', usdOnly).amount;
  double realisedUsd(InstrumentPosition p) => p.realised.inCurrency('USD', usdOnly).amount;

  group('weighted average', () {
    // The Figma ledger: two buys, a sell with a commission.
    final rows = [
      tx('b1', TransactionKind.buy, 100, 71.20, DateTime(2026, 3, 12)),
      tx('b2', TransactionKind.buy, 62, 78.40, DateTime(2026, 6, 4)),
      tx('s1', TransactionKind.sell, 20, 83.60, DateTime(2026, 8, 18), fee: 18),
    ];

    test('a sell releases its share of the average cost and realises the rest', () {
      final p = Ledger.derive(rows)[gold]!;
      const totalCost = 7120 + 4860.80;
      const average = totalCost / 162;
      expect(fineGrams(p), closeTo(142, 1e-9));
      expect(basisUsd(p), closeTo(average * 142, 1e-6));
      expect(p.disposals['s1']!.basisReleased.inCurrency('USD', usdOnly).amount, closeTo(average * 20, 1e-6));
      expect(realisedUsd(p), closeTo(1672 - 18 - average * 20, 1e-6));
    });

    test('the average cost of what remains is unchanged by a sell', () {
      final p = Ledger.derive(rows)[gold]!;
      final before = (7120 + 4860.80) / 162;
      final avg = HoldingTotals.averageCost(
        lots: p.openLots,
        refUnit: grams,
        displayCurrency: 'USD',
        rates: usdOnly,
      )!;
      expect(avg.amount, closeTo(before, 1e-9));
    });

    test('open lots keep their own date, unit and cost, scaled down', () {
      final lots = Ledger.derive(rows)[gold]!.openLots;
      expect(lots.map((l) => l.id), ['b1', 'b2']);
      expect(lots[0].quantity, closeTo(100 * 142 / 162, 1e-9));
      expect(lots[0].unitCost, 71.20);
      expect(lots[0].date, DateTime(2026, 3, 12));
    });

    test('a buy commission is part of the cost', () {
      final p = Ledger.derive([tx('b', TransactionKind.buy, 10, 100, DateTime(2026), fee: 5)])[gold]!;
      expect(basisUsd(p), closeTo(1005, 1e-9));
      expect(p.openLots.single.unitCost, closeTo(100.5, 1e-9));
    });
  });

  test('selling everything closes the position and keeps the realised gain', () {
    final p = Ledger.derive([
      tx('b', TransactionKind.buy, 10, 100, DateTime(2026, 1, 1)),
      tx('s', TransactionKind.sell, 10, 120, DateTime(2026, 2, 1)),
    ])[gold]!;
    expect(p.openLots, isEmpty);
    expect(p.fineOunces, 0);
    expect(realisedUsd(p), closeTo(200, 1e-9));
    expect(p.overdrawn, isEmpty);
  });

  test('a full sale survives unit-conversion noise without leaving dust', () {
    final p = Ledger.derive([
      tx('b', TransactionKind.buy, 1, 3000, DateTime(2026, 1, 1), unit: PriceUnit.troyOunce),
      tx('s', TransactionKind.sell, PriceUnit.gramsPerTroyOunce, 100, DateTime(2026, 2, 1)),
    ])[gold]!;
    expect(p.openLots, isEmpty);
    expect(p.overdrawn, isEmpty);
  });

  test('karats mix by fine content', () {
    // 100 g of 21K holds 87.5 g fine; selling 20 g of 24K takes 20/87.5.
    final p = Ledger.derive([
      tx('b', TransactionKind.buy, 100, 80, DateTime(2026, 1, 1), karat: GoldKarat.k21),
      tx('s', TransactionKind.sell, 20, 100, DateTime(2026, 2, 1)),
    ])[gold]!;
    expect(fineGrams(p), closeTo(67.5, 1e-9));
    expect(p.disposals['s']!.basisReleased.inCurrency('USD', usdOnly).amount, closeTo(8000 * 20 / 87.5, 1e-6));
    expect(p.openLots.single.karat, GoldKarat.k21);
    expect(p.openLots.single.quantity, closeTo(100 * 67.5 / 87.5, 1e-9));
  });

  test('a transfer in with no cost lowers the average; a transfer out realises nothing', () {
    final p = Ledger.derive([
      tx('b', TransactionKind.buy, 10, 100, DateTime(2026, 1, 1)),
      tx('ti', TransactionKind.transferIn, 10, 0, DateTime(2026, 1, 2)),
      tx('to', TransactionKind.transferOut, 5, 0, DateTime(2026, 1, 3)),
    ])[gold]!;
    expect(fineGrams(p), closeTo(15, 1e-9));
    expect(basisUsd(p), closeTo(750, 1e-9), reason: 'a quarter of 1000 left with the transfer');
    expect(p.realised.isZero, isTrue);
    expect(p.disposals['to']!.realised.isZero, isTrue);
  });

  test('a standalone fee is a realised loss and leaves quantity alone', () {
    final p = Ledger.derive([
      tx('b', TransactionKind.buy, 10, 100, DateTime(2026, 1, 1)),
      tx('f', TransactionKind.fee, 0, 0, DateTime(2026, 1, 5), fee: 12),
    ])[gold]!;
    expect(fineGrams(p), closeTo(10, 1e-9));
    expect(realisedUsd(p), closeTo(-12, 1e-9));
    expect(basisUsd(p), closeTo(1000, 1e-9));
  });

  test('costs in several currencies stay apart until display', () {
    final p = Ledger.derive([
      tx('b1', TransactionKind.buy, 10, 100, DateTime(2026, 1, 1)), // $1,000
      tx('b2', TransactionKind.buy, 10, 400, DateTime(2026, 1, 2), currency: 'SAR'), // 4,000 SAR = $1,000
      tx('s', TransactionKind.sell, 10, 150, DateTime(2026, 1, 3)),
    ])[gold]!;
    final released = p.disposals['s']!.basisReleased;
    expect(released.byCurrency['USD'], closeTo(500, 1e-9));
    expect(released.byCurrency['SAR'], closeTo(2000, 1e-9));
    expect(realisedUsd(p), closeTo(1500 - 1000, 1e-9));
  });

  group('order and conflicts', () {
    test('same-day buy comes before same-day sell, whatever the ids', () {
      final day = DateTime(2026, 5, 5);
      final p = Ledger.derive([
        tx('a-sell', TransactionKind.sell, 5, 10, day),
        tx('z-buy', TransactionKind.buy, 5, 8, day),
      ])[gold]!;
      expect(p.overdrawn, isEmpty);
      expect(realisedUsd(p), closeTo(10, 1e-9));
    });

    test('a same-day sell sees a buy saved later that day', () {
      // A migrated lot carries the time it was saved; the editor dates rows
      // at midnight.
      final p = Ledger.derive([
        tx('buy', TransactionKind.buy, 10, 100, DateTime(2026, 10, 21, 17, 0)),
        tx('sell', TransactionKind.sell, 4, 120, DateTime(2026, 10, 21)),
      ])[gold]!;
      expect(p.overdrawn, isEmpty);
      expect(fineGrams(p), closeTo(6, 1e-9));
      // The timeline stays in time order, so asking about that evening sees
      // the sale.
      expect(p.timeline.map((s) => s.date), [DateTime(2026, 10, 21, 17), DateTime(2026, 10, 21, 17)]);
      expect(p.fineOuncesOn(DateTime(2026, 10, 21, 23)) / grams.multiplier, closeTo(6, 1e-9));
    });

    test('a sell of more than is held is flagged and applied as everything', () {
      final p = Ledger.derive([
        tx('b', TransactionKind.buy, 10, 100, DateTime(2026, 1, 1)),
        tx('s', TransactionKind.sell, 15, 120, DateTime(2026, 2, 1)),
      ])[gold]!;
      expect(p.overdrawn, {'s'});
      expect(p.openLots, isEmpty);
      expect(p.fineOunces, 0);
    });

    test('a sell before any buy is flagged and changes nothing', () {
      final p = Ledger.derive([
        tx('s', TransactionKind.sell, 1, 120, DateTime(2026, 1, 1)),
        tx('b', TransactionKind.buy, 10, 100, DateTime(2026, 2, 1)),
      ])[gold]!;
      expect(p.overdrawn, {'s'});
      expect(fineGrams(p), closeTo(10, 1e-9));
    });

    test('instruments are independent', () {
      final ledger = Ledger.derive([
        tx('b', TransactionKind.buy, 10, 100, DateTime(2026, 1, 1)),
        tx('c', TransactionKind.buy, 1, 50000, DateTime(2026, 1, 1), instrument: 'crypto.BTC', unit: PriceUnit.each),
      ]);
      expect(ledger.positions.keys, unorderedEquals([gold, 'crypto.BTC']));
      expect(ledger.openLots, hasLength(2));
    });
  });

  test('the timeline answers how much was held on a day', () {
    final p = Ledger.derive([
      tx('b', TransactionKind.buy, 10, 100, DateTime(2026, 1, 1)),
      tx('s', TransactionKind.sell, 4, 120, DateTime(2026, 3, 1)),
    ])[gold]!;
    double on(DateTime d) => p.fineOuncesOn(d) / grams.multiplier;
    expect(on(DateTime(2025, 12, 31)), 0);
    expect(on(DateTime(2026, 2, 1)), closeTo(10, 1e-9));
    expect(on(DateTime(2026, 3, 1, 12)), closeTo(6, 1e-9));
    expect(p.timeline, hasLength(2));
  });

  group('HoldingTransaction', () {
    test('a migrated lot becomes a buy with the same id and values', () {
      final lot = HoldingLot(
        id: 'lot-1',
        instrumentID: gold,
        quantity: 100,
        unit: grams,
        unitCost: 70,
        costCurrency: 'SAR',
        date: DateTime(2025, 4, 1),
        karat: GoldKarat.k21,
      );
      final t = HoldingTransaction.fromLot(lot);
      expect(t.id, 'lot-1');
      expect(t.kind, TransactionKind.buy);
      expect(t.fineOunces, closeTo(lot.fineOunces, 1e-12));
      expect(t.totalCost, lot.totalCost);
      final p = Ledger.derive([t])[gold]!;
      expect(p.openLots.single, lot);
    });

    test('JSON round-trips, with optional fields omitted when empty', () {
      final t = tx('s', TransactionKind.sell, 20, 83.6, DateTime(2026, 8, 18), fee: 18, karat: GoldKarat.k22)
          .copyWith(note: 'Sold at the souk');
      expect(HoldingTransaction.fromJson(t.toJson()), t);
      final plain = tx('b', TransactionKind.buy, 1, 1, DateTime(2026)).toJson();
      expect(plain.containsKey('fee'), isFalse);
      expect(plain.containsKey('note'), isFalse);
      expect(plain.containsKey('karat'), isFalse);
    });

    test('an unknown kind from a newer version reads as a buy rather than crashing', () {
      final json = tx('x', TransactionKind.buy, 1, 1, DateTime(2026)).toJson()..['kind'] = 'stakingReward';
      expect(HoldingTransaction.fromJson(json).kind, TransactionKind.buy);
    });
  });
}
