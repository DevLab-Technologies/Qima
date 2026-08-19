import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/custom_instrument.dart';

void main() {
  group('CustomInstrument identity (spec §8.7)', () {
    test('symbol/source are trimmed and uppercased (TC-C1)', () {
      final instrument = CustomInstrument(symbol: '  voo ', sourceSymbol: ' voo ');
      expect(instrument.symbol, 'VOO');
      expect(instrument.sourceSymbol, 'VOO');
    });

    test('identity derives ONLY from source symbol, name has zero effect (TC-C2)', () {
      final a = CustomInstrument(symbol: 'voo', name: 'Vanguard S&P 500');
      final b = CustomInstrument(symbol: 'voo', name: 'Something Else Entirely');
      expect(a.id, b.id);
      expect(a.instrumentID, b.instrumentID);
    });

    test('different source symbols diverge in id', () {
      final a = CustomInstrument(symbol: 'VOO');
      final b = CustomInstrument(symbol: 'VTI');
      expect(a.id, isNot(b.id));
    });

    test('empty name falls back to symbol as nameKey (TC-C3)', () {
      final instrument = CustomInstrument(symbol: 'voo', name: '  ');
      expect(instrument.instrument.nameKey, 'VOO');
    });

    test('non-empty name is used verbatim as nameKey', () {
      final instrument = CustomInstrument(symbol: 'voo', name: 'Vanguard S&P 500');
      expect(instrument.instrument.nameKey, 'Vanguard S&P 500');
    });
  });

  group('CustomInstrument asset class (stock vs index/ETF)', () {
    test('defaults to stock when unspecified, for backward compatibility', () {
      final instrument = CustomInstrument(symbol: 'VOO');
      expect(instrument.assetClass, AssetClass.stock);
      expect(instrument.instrumentID, 'stock.VOO');
      expect(instrument.instrument.assetClass, AssetClass.stock);
    });

    test('explicit index construction uses the index prefix and asset class', () {
      final instrument = CustomInstrument(symbol: 'VOO', assetClass: AssetClass.indices);
      expect(instrument.assetClass, AssetClass.indices);
      expect(instrument.instrumentID, 'index.VOO');
      expect(instrument.instrument.assetClass, AssetClass.indices);
    });

    test('instrumentID prefix is correct for both classes with the same source symbol', () {
      final stock = CustomInstrument(symbol: 'qqq', assetClass: AssetClass.stock);
      final index = CustomInstrument(symbol: 'qqq', assetClass: AssetClass.indices);
      expect(stock.instrumentID, 'stock.QQQ');
      expect(index.instrumentID, 'index.QQQ');
      // Identity (`id`) is derived only from the source symbol (spec §1.8),
      // so it's unaffected by asset class even though `instrumentID` diverges.
      expect(stock.id, index.id);
    });

    test('fromJson defaults to stock when assetClass is absent (legacy records)', () {
      final json = {
        'id': 'ignored-recomputed',
        'instrumentID': 'stock.VOO',
        'symbol': 'VOO',
        'name': '',
        'sourceSymbol': 'VOO',
      };
      final instrument = CustomInstrument.fromJson(json);
      expect(instrument.assetClass, AssetClass.stock);
      expect(instrument.instrumentID, 'stock.VOO');
    });

    test('toJson/fromJson round-trips the index asset class', () {
      final original = CustomInstrument(symbol: 'VOO', assetClass: AssetClass.indices);
      final restored = CustomInstrument.fromJson(original.toJson());
      expect(restored.assetClass, AssetClass.indices);
      expect(restored.instrumentID, original.instrumentID);
      expect(restored.id, original.id);
    });
  });
}
