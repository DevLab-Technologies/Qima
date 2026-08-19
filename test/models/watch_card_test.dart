import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/watch_card.dart';

void main() {
  group('WatchCard duplicate/identity semantics (spec §8.13 / TC-W4)', () {
    test('isSameCombo compares the full tuple, not id', () {
      const a = WatchCard(id: 'aaaa', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce);
      const b = WatchCard(id: 'bbbb', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce);
      expect(a.id, isNot(b.id));
      expect(a.isSameCombo(b), isTrue);
    });

    test('different karats of the same instrument/currency/unit are NOT duplicates', () {
      const a = WatchCard(
        id: 'aaaa',
        instrumentID: 'metal.XAU',
        currency: 'USD',
        unit: PriceUnit.gram,
        karat: GoldKarat.k22,
      );
      const b = WatchCard(
        id: 'bbbb',
        instrumentID: 'metal.XAU',
        currency: 'USD',
        unit: PriceUnit.gram,
        karat: GoldKarat.k18,
      );
      expect(a.isSameCombo(b), isFalse);
    });

    test('different currency or unit also breaks the combo match', () {
      const usd = WatchCard(id: '1', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce);
      const eur = WatchCard(id: '2', instrumentID: 'metal.XAU', currency: 'EUR', unit: PriceUnit.troyOunce);
      const gram = WatchCard(id: '3', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.gram);
      expect(usd.isSameCombo(eur), isFalse);
      expect(usd.isSameCombo(gram), isFalse);
    });
  });

  test('WatchCard.seed is deterministic for the same instrumentID', () {
    final a = WatchCard.seed(instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce);
    final b = WatchCard.seed(instrumentID: 'metal.XAU', currency: 'EUR', unit: PriceUnit.gram);
    // Per spec, seed is derived only from instrumentID.
    expect(a, b);
    final c = WatchCard.seed(instrumentID: 'metal.XAG', currency: 'USD', unit: PriceUnit.troyOunce);
    expect(a, isNot(c));
    // Must look like a UUID (36 chars, hyphenated).
    expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$').hasMatch(a), isTrue);
  });
}
