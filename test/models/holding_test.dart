import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/holding_totals.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';

void main() {
  final rates = FXRates(base: 'USD', rates: const {'EUR': 0.5}, updatedAt: DateTime(2024));

  group('HoldingValuation.aggregate (spec §1.5 / §8.6)', () {
    test('empty lot list returns null (TC-V6)', () {
      final result = HoldingValuation.aggregate(
        lots: const [],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => 100,
      );
      expect(result, isNull);
    });

    test('all-unpriced lots return null (TC-V6)', () {
      final lot = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 1900,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final result = HoldingValuation.aggregate(
        lots: [lot],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => null,
      );
      expect(result, isNull);
    });

    test('unpriced lots are silently skipped, priced ones still aggregate (TC-V5)', () {
      final priced = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 1900,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final unpriced = HoldingLot(
        id: '2',
        instrumentID: 'stock.UNKNOWN',
        quantity: 1,
        unit: PriceUnit.each,
        unitCost: 100,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final result = HoldingValuation.aggregate(
        lots: [priced, unpriced],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (id) => id == 'metal.XAU' ? 2000.0 : null,
      );
      expect(result, isNotNull);
      expect(result!.value.amount, closeTo(2000, 1e-9));
      expect(result.cost.amount, closeTo(1900, 1e-9));
    });

    test('cost currency != display currency converts through USD as pivot (TC-V3)', () {
      // Lot cost in EUR (0.5 EUR per USD => 2 USD per EUR), displayed in USD.
      final lot = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 950, // EUR
        costCurrency: 'EUR',
        date: DateTime(2024),
      );
      final result = HoldingValuation.aggregate(
        lots: [lot],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => 2000,
      );
      // costUSD = totalCost / rate(EUR) = 950 / 0.5 = 1900
      expect(result!.cost.amount, closeTo(1900, 1e-9));
      expect(result.value.amount, closeTo(2000, 1e-9));
    });

    test('gram-denominated lots aggregate into canonical troy-ounce quantity (TC-V4)', () {
      final lot = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 31.1034768, // exactly 1 troy ounce in grams
        unit: PriceUnit.gram,
        unitCost: 60,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final result = HoldingValuation.aggregate(
        lots: [lot],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => 2000, // per troy ounce
      );
      // canonicalQty = 31.1034768 * (1/31.1034768) = 1 troy ounce
      // averageUnitCostUSD = costUSDTotal / canonicalQty = totalCost / 1
      expect(result!.averageUnitCostUSD, closeTo(lot.totalCost, 1e-6));
    });

    test('a 21K gold lot values at 0.875x a 24K lot of the same quantity (bug fix)', () {
      final k24 = HoldingLot(
        id: '24k',
        instrumentID: 'metal.XAU',
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final k21 = HoldingLot(
        id: '21k',
        instrumentID: 'metal.XAU',
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
        karat: GoldKarat.k21,
      );
      final result24 = HoldingValuation.aggregate(
        lots: [k24],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => 2000,
      );
      final result21 = HoldingValuation.aggregate(
        lots: [k21],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => 2000,
      );
      expect(result21!.value.amount, closeTo(result24!.value.amount * GoldKarat.k21.purity, 1e-6));
      expect(result21.value.amount, closeTo(result24.value.amount * 0.875, 1e-6));
      // Cost is what was actually paid — purity never touches it.
      expect(result21.cost.amount, closeTo(result24.cost.amount, 1e-9));
    });

    test('a null karat values identically to an explicit 24K karat (back-compat)', () {
      final implicit = HoldingLot(
        id: 'implicit',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final explicit = implicit.copyWith(id: 'explicit', karat: GoldKarat.k24);
      final resultImplicit = HoldingValuation.aggregate(
        lots: [implicit],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => 2000,
      );
      final resultExplicit = HoldingValuation.aggregate(
        lots: [explicit],
        rates: rates,
        displayCurrency: 'USD',
        latestUSD: (_) => 2000,
      );
      expect(resultImplicit!.value.amount, closeTo(resultExplicit!.value.amount, 1e-9));
    });
  });

  group('HoldingLot karat JSON (back-compat)', () {
    test('a lot without a stored karat decodes to null (old records)', () {
      final json = {
        'id': 'lot',
        'instrumentID': 'metal.XAU',
        'quantity': 1,
        'unit': 'gram',
        'unitCost': 50,
        'costCurrency': 'USD',
        'date': DateTime(2024).toUtc().toIso8601String(),
      };
      final lot = HoldingLot.fromJson(json);
      expect(lot.karat, isNull);
      expect(lot.purity, 1);
    });

    test('toJson omits the karat field when null', () {
      final lot = HoldingLot(
        id: 'lot',
        instrumentID: 'metal.XAU',
        quantity: 1,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      expect(lot.toJson().containsKey('karat'), isFalse);
    });

    test('round trip preserves a non-null karat', () {
      final lot = HoldingLot(
        id: 'lot',
        instrumentID: 'metal.XAU',
        quantity: 1,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
        karat: GoldKarat.k18,
      );
      final restored = HoldingLot.fromJson(lot.toJson());
      expect(restored.karat, GoldKarat.k18);
      expect(restored, lot);
    });

    test('copyWith clearKarat resets to null', () {
      final lot = HoldingLot(
        id: 'lot',
        instrumentID: 'metal.XAU',
        quantity: 1,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
        karat: GoldKarat.k18,
      );
      final cleared = lot.copyWith(clearKarat: true);
      expect(cleared.karat, isNull);
    });
  });

  group('HoldingTotals (spec: totals & average cost)', () {
    final rates2 = FXRates(base: 'USD', rates: const {'EUR': 0.5}, updatedAt: DateTime(2024));

    test('totalHeld is 0 for an empty lot list', () {
      expect(HoldingTotals.totalHeld(lots: const [], refUnit: PriceUnit.gram), 0);
    });

    test('totalHeld sums a single lot with no karat at its own unit', () {
      final lot = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 50,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final held = HoldingTotals.totalHeld(lots: [lot], refUnit: PriceUnit.gram);
      expect(held, closeTo(50, 1e-9));
    });

    test('totalHeld across mixed units converts to a common reference unit', () {
      final gramLot = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 31.1034768, // exactly 1 troy ounce
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final ozLot = HoldingLot(
        id: '2',
        instrumentID: 'metal.XAU',
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 2000,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final held = HoldingTotals.totalHeld(lots: [gramLot, ozLot], refUnit: PriceUnit.troyOunce);
      expect(held, closeTo(2, 1e-6));
    });

    test('totalHeld across mixed karats counts by fine content, shown at the reference karat', () {
      final k24 = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final k21 = HoldingLot(
        id: '2',
        instrumentID: 'metal.XAU',
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
        karat: GoldKarat.k21,
      );
      // Fine content: 100g (24K) + 87.5g fine-equivalent (21K) = 187.5g fine.
      // Re-expressed at 21K purity: 187.5 / 0.875 = 214.285... g of 21K gold.
      final held = HoldingTotals.totalHeld(lots: [k24, k21], refUnit: PriceUnit.gram, refKarat: GoldKarat.k21);
      expect(held, closeTo(187.5 / GoldKarat.k21.purity, 1e-6));
    });

    test('isMixed is false for a single lot and for lots sharing unit+karat', () {
      final a = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
        karat: GoldKarat.k21,
      );
      final b = a.copyWith(id: '2', quantity: 20);
      expect(HoldingTotals.isMixed([a]), isFalse);
      expect(HoldingTotals.isMixed([a, b]), isFalse);
    });

    test('isMixed is true when karats differ', () {
      final a = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
        karat: GoldKarat.k21,
      );
      final b = a.copyWith(id: '2', karat: GoldKarat.k18);
      expect(HoldingTotals.isMixed([a, b]), isTrue);
    });

    test('isMixedKarat is true only when karats specifically differ, not just units', () {
      final a = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final differentUnit = a.copyWith(id: '2', unit: PriceUnit.troyOunce);
      final differentKarat = a.copyWith(id: '3', karat: GoldKarat.k21);
      expect(HoldingTotals.isMixedKarat([a, differentUnit]), isFalse);
      expect(HoldingTotals.isMixedKarat([a, differentKarat]), isTrue);
    });

    test('isMixed is true when units differ', () {
      final a = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final b = a.copyWith(id: '2', unit: PriceUnit.troyOunce);
      expect(HoldingTotals.isMixed([a, b]), isTrue);
    });

    test('averageCost is null for an empty lot list', () {
      expect(
        HoldingTotals.averageCost(lots: const [], refUnit: PriceUnit.gram, displayCurrency: 'USD', rates: rates2),
        isNull,
      );
    });

    test('averageCost for a single lot equals its own unit cost (same currency, no karat)', () {
      final lot = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 55,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final avg = HoldingTotals.averageCost(lots: [lot], refUnit: PriceUnit.gram, displayCurrency: 'USD', rates: rates2);
      expect(avg!.amount, closeTo(55, 1e-9));
    });

    test('averageCost blends mixed cost currencies via the live FX rate, like HoldingValuation', () {
      // EUR rate 0.5 => 2 USD per EUR.
      final usdLot = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 50, // USD
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final eurLot = HoldingLot(
        id: '2',
        instrumentID: 'metal.XAU',
        quantity: 10,
        unit: PriceUnit.gram,
        unitCost: 25, // EUR => 50 USD equivalent per gram
        costCurrency: 'EUR',
        date: DateTime(2024),
      );
      final avg =
          HoldingTotals.averageCost(lots: [usdLot, eurLot], refUnit: PriceUnit.gram, displayCurrency: 'USD', rates: rates2);
      // total cost USD = 500 (usd lot) + (250/0.5=500) = 1000, over 20g => 50/g
      expect(avg!.amount, closeTo(50, 1e-6));
    });

    test('averageCost divides by the karat-adjusted total, not the raw quantity sum', () {
      final k24 = HoldingLot(
        id: '1',
        instrumentID: 'metal.XAU',
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 40,
        costCurrency: 'USD',
        date: DateTime(2024),
      );
      final k21 = HoldingLot(
        id: '2',
        instrumentID: 'metal.XAU',
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 40,
        costCurrency: 'USD',
        date: DateTime(2024),
        karat: GoldKarat.k21,
      );
      final avgAt21 = HoldingTotals.averageCost(
        lots: [k24, k21],
        refUnit: PriceUnit.gram,
        refKarat: GoldKarat.k21,
        displayCurrency: 'USD',
        rates: rates2,
      );
      final held = HoldingTotals.totalHeld(lots: [k24, k21], refUnit: PriceUnit.gram, refKarat: GoldKarat.k21);
      final totalCostUSD = 100 * 40 + 100 * 40;
      expect(avgAt21!.amount, closeTo(totalCostUSD / held, 1e-6));
    });
  });

  test('HoldingLot JSON round trip keeps the calendar day the user picked', () {
    // A date picked at local midnight is stored as a UTC instant; east of UTC
    // that instant falls on the previous day, which must not leak into display.
    final picked = DateTime(2025, 1, 8);
    final lot = HoldingLot(
      id: 'lot',
      instrumentID: 'metal.XAU',
      quantity: 1,
      unit: PriceUnit.gram,
      unitCost: 100,
      costCurrency: 'USD',
      date: picked,
    );
    final restored = HoldingLot.fromJson(lot.toJson());
    expect(restored.date.isUtc, isFalse);
    expect([restored.date.year, restored.date.month, restored.date.day], [2025, 1, 8]);
    expect(restored.date, picked);
  });
}
