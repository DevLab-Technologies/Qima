import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'metal_breakdown.dart';
import 'money.dart';
import 'syncable.dart';

/// A single purchase lot of an instrument.
class HoldingLot extends Equatable implements Syncable {
  @override
  final String id;
  final String instrumentID;
  final double quantity;
  final PriceUnit unit;
  final double unitCost;
  final String costCurrency;
  final DateTime date;

  /// Purity of the physical metal this lot represents, e.g. 21K jewelry
  /// bought and weighed at 21K rather than fine gold. `null` means fine
  /// metal (24K) — the historical default before karat-per-lot existed, so
  /// old records without a stored karat keep valuing exactly as before
  /// (no migration needed). Only ever meaningful for gold lots priced by
  /// weight (gram/kilogram); a troy-ounce lot is fine weight by convention
  /// and never carries a karat.
  final GoldKarat? karat;

  const HoldingLot({
    required this.id,
    required this.instrumentID,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.costCurrency,
    required this.date,
    this.karat,
  });

  double get totalCost => quantity * unitCost;

  /// This lot's purity as a fraction of fine metal (1.0 for 24K/non-gold).
  double get purity => karat?.purity ?? 1;

  /// Fine-metal content of this lot, expressed in troy ounces: quantity in
  /// the lot's own unit, converted to the canonical troy-ounce basis via
  /// [PriceUnit.multiplier] (same convention [PriceConverter.factor] and
  /// [HoldingValuation.aggregate] use), then scaled down by [purity] so a
  /// karat lot counts for only the fine metal it actually contains. This is
  /// a property of the LOT alone — it must never depend on the karat of
  /// whatever watch card or screen happens to be displaying it.
  double get fineOunces => quantity * unit.multiplier * purity;

  HoldingLot copyWith({
    String? id,
    String? instrumentID,
    double? quantity,
    PriceUnit? unit,
    double? unitCost,
    String? costCurrency,
    DateTime? date,
    GoldKarat? karat,
    bool clearKarat = false,
  }) {
    return HoldingLot(
      id: id ?? this.id,
      instrumentID: instrumentID ?? this.instrumentID,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      costCurrency: costCurrency ?? this.costCurrency,
      date: date ?? this.date,
      karat: clearKarat ? null : (karat ?? this.karat),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'instrumentID': instrumentID,
        'quantity': quantity,
        'unit': unit.name,
        'unitCost': unitCost,
        'costCurrency': costCurrency,
        'date': date.toUtc().toIso8601String(),
        if (karat != null) 'karat': karat!.rawValue,
      };

  factory HoldingLot.fromJson(Map<String, dynamic> json) => HoldingLot(
        id: json['id'] as String,
        instrumentID: json['instrumentID'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: PriceUnit.values.byName(json['unit'] as String),
        unitCost: (json['unitCost'] as num).toDouble(),
        costCurrency: json['costCurrency'] as String,
        // Stored as a UTC instant; converted back so the calendar day shown
        // matches the day the user picked in their own time zone.
        date: DateTime.parse(json['date'] as String).toLocal(),
        karat: json['karat'] == null ? null : GoldKarat.fromRawValue(json['karat'] as int),
      );

  @override
  List<Object?> get props => [id, instrumentID, quantity, unit, unitCost, costCurrency, date, karat];
}

/// Aggregated valuation across a group of lots, expressed in a display
/// currency.
class HoldingValuation extends Equatable {
  final Money value;
  final Money cost;
  final Money gain;
  final double gainFraction;
  final double? averageUnitCostUSD;

  const HoldingValuation({
    required this.value,
    required this.cost,
    required this.gain,
    required this.gainFraction,
    required this.averageUnitCostUSD,
  });

  bool get isUp => gain.amount >= 0;

  bool get hasCost => cost.amount > 0;

  /// Aggregates [lots] into a single valuation, per the exact algorithm in
  /// spec §1.5. Skips lots for instruments with no live price (TC-V5).
  /// Returns null if lots is empty or nothing could be valued (TC-V6).
  static HoldingValuation? aggregate({
    required List<HoldingLot> lots,
    required FXRates rates,
    required String displayCurrency,
    required double? Function(String instrumentID) latestUSD,
  }) {
    if (lots.isEmpty) return null;
    final toDisplay = rates.rate(displayCurrency) ?? 1;
    double valueDisplay = 0;
    double costDisplay = 0;
    double costUSDTotal = 0;
    double canonicalQty = 0;
    bool valued = false;

    for (final lot in lots) {
      final usd = latestUSD(lot.instrumentID);
      if (usd == null) continue;
      final costToUSD = rates.rate(lot.costCurrency) ?? 1;
      // Purity is applied exactly once, here, to the lot's fine-metal
      // content — never to the price itself and never a second time by a
      // caller. `lot.fineOunces` already folds in `lot.unit.multiplier`.
      final currentValueUSD = lot.fineOunces * usd;
      final costUSD = lot.totalCost / costToUSD;
      valueDisplay += currentValueUSD * toDisplay;
      costDisplay += costUSD * toDisplay;
      costUSDTotal += costUSD;
      canonicalQty += lot.fineOunces;
      valued = true;
    }

    if (!valued) return null;
    final gain = valueDisplay - costDisplay;
    final gainFraction = costDisplay != 0 ? gain / costDisplay : 0.0;
    final averageUnitCostUSD = canonicalQty != 0 ? costUSDTotal / canonicalQty : null;

    return HoldingValuation(
      value: Money(valueDisplay, displayCurrency),
      cost: Money(costDisplay, displayCurrency),
      gain: Money(gain, displayCurrency),
      gainFraction: gainFraction,
      averageUnitCostUSD: averageUnitCostUSD,
    );
  }

  @override
  List<Object?> get props => [value, cost, gain, gainFraction, averageUnitCostUSD];
}

/// One row in the portfolio breakdown: an instrument plus its aggregated
/// valuation across all of the user's lots for it.
class HeldInstrument extends Equatable {
  final Instrument instrument;
  final HoldingValuation valuation;
  final int lotCount;

  const HeldInstrument({required this.instrument, required this.valuation, required this.lotCount});

  String get id => instrument.id;

  @override
  List<Object?> get props => [instrument, valuation, lotCount];
}
