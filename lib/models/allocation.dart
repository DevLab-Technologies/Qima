import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'asset_group.dart';
import 'fx_history.dart';
import 'holding.dart';
import 'ledger.dart';
import 'metal_breakdown.dart';
import 'money.dart';
import 'quote.dart';

/// One slice of an allocation breakdown: its value in the base currency and
/// its share of the breakdown's total.
class AllocationShare<K> extends Equatable {
  final K key;
  final Money value;
  final double fraction;

  const AllocationShare({required this.key, required this.value, required this.fraction});

  @override
  List<Object?> get props => [key, value, fraction];
}

/// A metal held in one form: gold at one karat, or a white metal (which
/// has no karat). "Gold 21K" and "Gold 24K" are separate forms.
class MetalForm extends Equatable {
  final Instrument instrument;

  /// Only for gold; 24K for fine gold, including troy-ounce lots.
  final GoldKarat? karat;

  const MetalForm(this.instrument, this.karat);

  @override
  List<Object?> get props => [instrument.id, karat];
}

/// Where each [AssetGroup]'s share stood at the start of a period and where
/// it stands now.
class DriftRow extends Equatable {
  final AssetGroup group;
  final double from;
  final double to;

  const DriftRow({required this.group, required this.from, required this.to});

  /// Change in share, in percentage points, rounded the way the screen shows
  /// it — so "12% → 12%" never reads as a move.
  int get pointsChange => (to * 100).round() - (from * 100).round();

  @override
  List<Object?> get props => [group, from, to];
}

/// Result of [Allocation.drift].
sealed class DriftResult extends Equatable {
  const DriftResult();
}

/// Drift since [since], one row per group held at either end.
class DriftReady extends DriftResult {
  final DateTime since;
  final List<DriftRow> rows;

  const DriftReady({required this.since, required this.rows});

  @override
  List<Object?> get props => [since, rows];
}

/// Fewer than [Allocation.minimumHistoryDays] days since the first holding: the
/// drift appears on [availableOn]. No curve is invented in the meantime.
class DriftPending extends DriftResult {
  final DateTime availableOn;

  const DriftPending(this.availableOn);

  @override
  List<Object?> get props => [availableOn];
}

/// Something held at the start of the period has no stored price that far
/// back, so the starting split can't be known.
class DriftNoPriceHistory extends DriftResult {
  const DriftNoPriceHistory();

  @override
  List<Object?> get props => [];
}

/// Pure allocation maths over held lots. Everything is valued with the same
/// rules as `HoldingValuation.aggregate`, so the shares here always add up
/// to the portfolio total shown above them.
class Allocation {
  Allocation._();

  /// Drift needs this many days of history before it means anything.
  static const int minimumHistoryDays = 14;

  /// Today's split by [AssetGroup], largest first. Groups with nothing
  /// priced are left out.
  static List<AllocationShare<AssetGroup>> byGroup(List<HeldInstrument> held, String baseCurrency) {
    final values = <AssetGroup, double>{};
    for (final h in held) {
      final group = AssetGroup.of(h.instrument.assetClass);
      values[group] = (values[group] ?? 0) + h.valuation.value.amount;
    }
    return _shares(values, baseCurrency);
  }

  /// Today's metals split by metal and karat, largest first. Each lot is
  /// valued on its own fine content, so 100 g of 21K and 100 g of 24K are
  /// two forms with different values.
  static List<AllocationShare<MetalForm>> metalsByForm({
    required List<HoldingLot> lots,
    required FXRates rates,
    required String baseCurrency,
    required double? Function(String instrumentID) latestUSD,
    required Instrument? Function(String instrumentID) resolve,
  }) {
    final values = <MetalForm, double>{};
    for (final lot in lots) {
      final instrument = resolve(lot.instrumentID);
      if (instrument == null || instrument.assetClass != AssetClass.metal) continue;
      final valuation = HoldingValuation.aggregate(
        lots: [lot],
        rates: rates,
        displayCurrency: baseCurrency,
        latestUSD: latestUSD,
      );
      if (valuation == null) continue;
      final karat = instrument.supportedKarats.isEmpty ? null : (lot.karat ?? GoldKarat.k24);
      final form = MetalForm(instrument, karat);
      values[form] = (values[form] ?? 0) + valuation.value.amount;
    }
    return _shares(values, baseCurrency);
  }

  /// How each group's share moved since 1 January — or since the first
  /// holding, if that's later. In the first two weeks of a year the period
  /// reaches back to the previous 1 January instead, so the card doesn't
  /// go blank every January.
  ///
  /// The starting split values what the ledger held at the end of that day
  /// at that day's stored prices and FX, like the portfolio history chart.
  static DriftResult? drift({
    required Ledger ledger,
    required List<HeldInstrument> heldNow,
    required Map<String, QuoteSeries> seriesByID,
    required FXHistory fxHistory,
    required FXRates rates,
    required String baseCurrency,
    required Instrument? Function(String instrumentID) resolve,
    required DateTime now,
  }) {
    final firstDate = ledger.firstDate;
    if (firstDate == null || heldNow.isEmpty) return null;
    final today = _day(now);
    final firstHolding = _day(firstDate);

    // Calendar-day arithmetic throughout: adding a Duration of days drifts
    // by an hour across a daylight-saving change.
    var yearStart = DateTime(today.year, 1, 1);
    if (today.isBefore(_plusDays(yearStart, minimumHistoryDays))) yearStart = DateTime(today.year - 1, 1, 1);
    final since = firstHolding.isAfter(yearStart) ? firstHolding : yearStart;

    final availableOn = _plusDays(since, minimumHistoryDays);
    if (today.isBefore(availableOn)) return DriftPending(availableOn);

    final endOfDay = _plusDays(since, 1).subtract(const Duration(microseconds: 1));
    final fx = baseCurrency == 'USD' ? 1.0 : (fxHistory.rate(baseCurrency, endOfDay) ?? rates.rate(baseCurrency) ?? 1);
    final then = <AssetGroup, double>{};
    for (final position in ledger.positions.values) {
      final held = position.fineOuncesOn(endOfDay);
      if (held <= 0) continue;
      final instrument = resolve(position.instrumentID);
      if (instrument == null) continue;
      final price = _priceOnOrBefore(seriesByID[position.instrumentID], endOfDay);
      if (price == null) return const DriftNoPriceHistory();
      final group = AssetGroup.of(instrument.assetClass);
      then[group] = (then[group] ?? 0) + held * price * fx;
    }

    final thenShares = {for (final s in _shares(then, baseCurrency)) s.key: s.fraction};
    final nowShares = {for (final s in byGroup(heldNow, baseCurrency)) s.key: s.fraction};
    final rows = [
      for (final group in AssetGroup.values)
        if (thenShares.containsKey(group) || nowShares.containsKey(group))
          DriftRow(group: group, from: thenShares[group] ?? 0, to: nowShares[group] ?? 0),
    ]..sort((a, b) => b.to.compareTo(a.to));
    return DriftReady(since: since, rows: rows);
  }

  static List<AllocationShare<K>> _shares<K>(Map<K, double> values, String baseCurrency) {
    final total = values.values.fold<double>(0, (sum, v) => sum + v);
    if (total <= 0) return const [];
    final shares = [
      for (final entry in values.entries)
        if (entry.value > 0)
          AllocationShare<K>(key: entry.key, value: Money(entry.value, baseCurrency), fraction: entry.value / total),
    ]..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    return shares;
  }

  static double? _priceOnOrBefore(QuoteSeries? series, DateTime instant) {
    if (series == null) return null;
    double? price;
    for (final quote in series.quotes) {
      if (quote.timestamp.isAfter(instant)) break;
      price = quote.canonicalUSD;
    }
    return price;
  }

  static DateTime _plusDays(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);

  static DateTime _day(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
