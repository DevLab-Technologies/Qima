import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/theme/instrument_theme.dart';
import 'package:qima/theme/qima_colors.dart';
import 'package:qima/widgets/allocation_donut.dart';

void main() {
  const colors = QimaColors.dark;

  HeldInstrument heldOf(Instrument instrument, double value, {int lotCount = 1}) {
    return HeldInstrument(
      instrument: instrument,
      lotCount: lotCount,
      valuation: HoldingValuation(
        value: Money(value, 'USD'),
        cost: Money(value, 'USD'),
        gain: const Money(0, 'USD'),
        gainFraction: 0,
        averageUnitCostUSD: null,
      ),
    );
  }

  group('resolveAllocation', () {
    test('fractions sum to 1 (percentages sum to 100)', () {
      final gold = InstrumentCatalog.instrument('metal.XAU')!;
      final silver = InstrumentCatalog.instrument('metal.XAG')!;
      final btc = InstrumentCatalog.instrument('crypto.BTC')!;
      final holdings = [heldOf(gold, 500), heldOf(silver, 300), heldOf(btc, 200)];

      final slices = resolveAllocation(holdings, colors);
      final total = slices.fold<double>(0, (sum, s) => sum + s.fraction);
      expect(total, closeTo(1.0, 1e-9));
      expect(slices[0].fraction, closeTo(0.5, 1e-9));
      expect(slices[1].fraction, closeTo(0.3, 1e-9));
      expect(slices[2].fraction, closeTo(0.2, 1e-9));
    });

    test('empty portfolio resolves to no slices', () {
      expect(resolveAllocation(const [], colors), isEmpty);
    });

    test('a single holding is the whole donut (fraction 1.0)', () {
      final gold = InstrumentCatalog.instrument('metal.XAU')!;
      final slices = resolveAllocation([heldOf(gold, 100)], colors);
      expect(slices.single.fraction, closeTo(1.0, 1e-9));
    });

    test('each holding gets its own instrument accent when asset classes differ', () {
      final gold = InstrumentCatalog.instrument('metal.XAU')!;
      final btc = InstrumentCatalog.instrument('crypto.BTC')!;
      final slices = resolveAllocation([heldOf(gold, 50), heldOf(btc, 50)], colors);
      expect(slices[0].color, InstrumentTheme.accentColor(gold, colors));
      expect(slices[1].color, InstrumentTheme.accentColor(btc, colors));
      expect(slices[0].color, isNot(slices[1].color));
    });

    test('holdings sharing an asset class get shaded so slices stay visually distinct', () {
      // Two custom/stock-class holdings would otherwise both resolve to
      // colors.accentStock — the second (and any later) must be shaded away
      // from the first so they don't paint identically.
      final aapl = InstrumentCatalog.instrument('stock.AAPL')!;
      final msft = InstrumentCatalog.instrument('stock.MSFT')!;
      final nvda = InstrumentCatalog.instrument('stock.NVDA')!;
      final slices = resolveAllocation([heldOf(aapl, 100), heldOf(msft, 100), heldOf(nvda, 100)], colors);

      final baseAccent = InstrumentTheme.accentColor(aapl, colors);
      expect(slices[0].color, baseAccent);
      expect(slices[1].color, isNot(baseAccent));
      expect(slices[2].color, isNot(baseAccent));
      // All three slices are pairwise distinct.
      final distinctColors = slices.map((s) => s.color).toSet();
      expect(distinctColors.length, 3);
    });
  });
}
