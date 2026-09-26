import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/instrument_search.dart';

// A tiny English/Arabic display-name map standing in for `displayLabel`,
// since the model takes a resolver instead of a BuildContext.
const _names = {
  'metal.XAU': 'Gold',
  'metal.XAG': 'Silver',
  'crypto.BTC': 'Bitcoin',
  'stock.AAPL': 'Apple',
  'index.GSPC': 'S&P 500',
  'fx.USD': 'US Dollar',
};

const _arabicNames = {
  'metal.XAU': 'الذهب',
  'fx.USD': 'الدولار الأمريكي',
};

String _englishName(Instrument i) => _names[i.id] ?? i.symbol;
String _arabicName(Instrument i) => _arabicNames[i.id] ?? _englishName(i);

void main() {
  final catalog = InstrumentCatalog.builtIn;

  test('matches by name, case-insensitive', () {
    final groups = InstrumentSearch.search(catalog, 'gold', displayName: _englishName);
    final ids = groups.expand((g) => g.matches).map((m) => m.instrument.id);
    expect(ids, contains('metal.XAU'));
  });

  test('matches by symbol', () {
    final groups = InstrumentSearch.search(catalog, 'aapl', displayName: _englishName);
    final ids = groups.expand((g) => g.matches).map((m) => m.instrument.id);
    expect(ids, contains('stock.AAPL'));
  });

  test('is case-insensitive on mixed-case queries', () {
    final groups = InstrumentSearch.search(catalog, 'BiTcOiN', displayName: _englishName);
    final ids = groups.expand((g) => g.matches).map((m) => m.instrument.id);
    expect(ids, contains('crypto.BTC'));
  });

  test('is diacritic-insensitive on Latin names', () {
    final instruments = [
      const Instrument(id: 'stock.CAFE', symbol: 'CAFE', assetClass: AssetClass.stock, nameKey: 'Café Co'),
    ];
    final groups = InstrumentSearch.search(instruments, 'cafe', displayName: (i) => i.nameKey);
    expect(groups.expand((g) => g.matches).map((m) => m.instrument.id), contains('stock.CAFE'));
  });

  test('matches Arabic names regardless of tashkeel', () {
    final instruments = [InstrumentCatalog.metals.first];
    // "الذَّهَب" (with tashkeel) vs a plain query "الذهب".
    final groups = InstrumentSearch.search(
      instruments,
      'الذهب',
      displayName: (i) => i.id == 'metal.XAU' ? 'الذَّهَب' : _arabicName(i),
    );
    expect(groups.expand((g) => g.matches).map((m) => m.instrument.id), contains('metal.XAU'));
  });

  test('folds Arabic alef/hamza and teh marbuta variants', () {
    final instruments = [InstrumentCatalog.fiat.firstWhere((i) => i.id == 'fx.USD')];
    // Display name uses "أ" (alef with hamza above); query uses bare "ا".
    final groups = InstrumentSearch.search(instruments, 'الدولار', displayName: _arabicName);
    expect(groups.expand((g) => g.matches).map((m) => m.instrument.id), contains('fx.USD'));
  });

  test('reports the matched range against the original (non-normalized) string', () {
    final groups = InstrumentSearch.search(catalog, 'old', displayName: _englishName);
    final match = groups.expand((g) => g.matches).firstWhere((m) => m.instrument.id == 'metal.XAU');
    expect(match.nameRanges, [const MatchRange(1, 4)]); // "G[old]"
  });

  test('reports a match range for the symbol separately from the name', () {
    final groups = InstrumentSearch.search(catalog, 'aapl', displayName: _englishName);
    final match = groups.expand((g) => g.matches).firstWhere((m) => m.instrument.id == 'stock.AAPL');
    expect(match.symbolRanges, [const MatchRange(0, 4)]);
    expect(match.nameRanges, isEmpty);
  });

  test('groups results by asset class in catalog order', () {
    final groups = InstrumentSearch.search(catalog, 'o', displayName: _englishName);
    // AssetClass.values order: metal, crypto, stock, indices, fiat.
    final order = groups.map((g) => g.assetClass).toList();
    final expectedOrder = AssetClass.values.where(order.contains).toList();
    expect(order, expectedOrder);
  });

  test('an empty or whitespace query returns no groups', () {
    expect(InstrumentSearch.search(catalog, '', displayName: _englishName), isEmpty);
    expect(InstrumentSearch.search(catalog, '   ', displayName: _englishName), isEmpty);
  });

  test('no matches returns no groups', () {
    expect(InstrumentSearch.search(catalog, 'zzzznotfound', displayName: _englishName), isEmpty);
  });

  test('includes custom instruments passed in alongside built-ins', () {
    final custom = InstrumentCatalog.builtIn.first.copyWith(id: 'stock.MYCO', symbol: 'MYCO', nameKey: 'My Custom Co');
    final groups = InstrumentSearch.search([...catalog, custom], 'myco', displayName: (i) => i.nameKey);
    expect(groups.expand((g) => g.matches).map((m) => m.instrument.id), contains('stock.MYCO'));
  });
}
