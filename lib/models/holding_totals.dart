import 'asset.dart';
import 'holding.dart';
import 'metal_breakdown.dart';
import 'money.dart';

/// Pure "total held" / "average cost" math for a group of lots, expressed at
/// a single reference unit/karat — e.g. the unit and karat of the watch card
/// the user opened Holdings from. Lives apart from [HoldingValuation] (which
/// aggregates into a display CURRENCY at the live FX rate) because these two
/// helpers aggregate into a display QUANTITY/unit-price instead; both read
/// the same underlying lots without either depending on the other.
///
/// Every lot's own karat is used to compute its fine-metal content exactly
/// once (via [HoldingLot.fineOunces]) — [refKarat] only controls how that
/// already-purity-adjusted total is re-expressed for display. A lot's value
/// never depends on the karat of the card/screen showing it.
class HoldingTotals {
  HoldingTotals._();

  /// Sum of every lot's fine-metal content (troy ounces), converted to
  /// [refUnit] at [refKarat]'s purity. For non-gold instruments [refKarat]
  /// is always null and this is just a canonical-unit quantity sum.
  ///
  /// Returns 0 for an empty list (callers decide whether 0 should be shown
  /// or treated as "nothing held").
  static double totalHeld({
    required List<HoldingLot> lots,
    required PriceUnit refUnit,
    GoldKarat? refKarat,
  }) {
    if (lots.isEmpty) return 0;
    final fineOuncesTotal = lots.fold<double>(0, (sum, lot) => sum + lot.fineOunces);
    final refPurity = refKarat?.purity ?? 1;
    // fineOuncesTotal is troy ounces of FINE metal; dividing by refPurity
    // re-expresses it as troy ounces of refKarat-purity metal, then
    // unit.multiplier converts troy ounces -> refUnit (both directions use
    // the same constant PriceConverter/HoldingValuation rely on, since
    // multiplier is its own inverse conversion factor: qty(unit) =
    // qty(oz) / unit.multiplier).
    final refKaratOunces = refPurity == 0 ? 0 : fineOuncesTotal / refPurity;
    return refKaratOunces / refUnit.multiplier;
  }

  /// True if every priced lot shares the same [HoldingLot.unit] and
  /// [HoldingLot.karat] — used to decide whether to show the "mixed
  /// karats/units" note next to the totals.
  static bool isMixed(List<HoldingLot> lots) {
    if (lots.length < 2) return false;
    final firstUnit = lots.first.unit;
    final firstKarat = lots.first.karat;
    return lots.any((l) => l.unit != firstUnit || l.karat != firstKarat);
  }

  /// True if the lots differ in [HoldingLot.karat] specifically (as opposed
  /// to only differing in unit) — used to pick between the "mixed karats
  /// counted by gold content" and the plainer "mixed units" note wording.
  static bool isMixedKarat(List<HoldingLot> lots) {
    if (lots.length < 2) return false;
    final firstKarat = lots.first.karat;
    return lots.any((l) => l.karat != firstKarat);
  }

  /// Average cost per [refUnit] at [refKarat]'s purity, in [displayCurrency],
  /// following the exact same live-FX cost-conversion rule
  /// [HoldingValuation.aggregate] uses (cost currency -> USD -> display
  /// currency at the LIVE rate, never historical). Returns null when there's
  /// nothing to average (empty lots, or zero total held).
  static Money? averageCost({
    required List<HoldingLot> lots,
    required PriceUnit refUnit,
    GoldKarat? refKarat,
    required String displayCurrency,
    required FXRates rates,
  }) {
    if (lots.isEmpty) return null;
    final held = totalHeld(lots: lots, refUnit: refUnit, refKarat: refKarat);
    if (held == 0) return null;

    final toDisplay = rates.rate(displayCurrency) ?? 1;
    double costUSDTotal = 0;
    for (final lot in lots) {
      final costToUSD = rates.rate(lot.costCurrency) ?? 1;
      costUSDTotal += lot.totalCost / costToUSD;
    }
    final costDisplay = costUSDTotal * toDisplay;
    return Money(costDisplay / held, displayCurrency);
  }
}
