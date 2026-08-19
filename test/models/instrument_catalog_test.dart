import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/instrument_catalog.dart';

void main() {
  test('instruments(ids:) drops unresolvable ids while preserving order (TC-I4)', () {
    final result = InstrumentCatalog.instruments(['metal.XAU', 'bogus.ID', 'crypto.BTC', 'metal.XAG']);
    expect(result.map((i) => i.id).toList(), ['metal.XAU', 'crypto.BTC', 'metal.XAG']);
  });

  test('instruments(ids:) never throws on all-unresolvable input', () {
    expect(() => InstrumentCatalog.instruments(['nope', 'also.nope']), returnsNormally);
    expect(InstrumentCatalog.instruments(['nope']), isEmpty);
  });

  test('built-ins win on id clash with custom instruments', () {
    InstrumentCatalog.reloadCustom([
      InstrumentCatalog.metals.first.copyWith(nameKey: 'hijacked'),
    ]);
    addTearDown(() => InstrumentCatalog.reloadCustom(const []));
    final resolved = InstrumentCatalog.instrument('metal.XAU');
    expect(resolved!.nameKey, 'asset.gold');
  });
}
