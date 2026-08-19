import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding.dart';
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
  });
}
