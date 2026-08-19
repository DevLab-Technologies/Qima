import 'package:equatable/equatable.dart';

import 'asset.dart';
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

  const HoldingLot({
    required this.id,
    required this.instrumentID,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.costCurrency,
    required this.date,
  });

  double get totalCost => quantity * unitCost;

  HoldingLot copyWith({
    String? id,
    String? instrumentID,
    double? quantity,
    PriceUnit? unit,
    double? unitCost,
    String? costCurrency,
    DateTime? date,
  }) {
    return HoldingLot(
      id: id ?? this.id,
      instrumentID: instrumentID ?? this.instrumentID,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      costCurrency: costCurrency ?? this.costCurrency,
      date: date ?? this.date,
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
      };

  factory HoldingLot.fromJson(Map<String, dynamic> json) => HoldingLot(
        id: json['id'] as String,
        instrumentID: json['instrumentID'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: PriceUnit.values.byName(json['unit'] as String),
        unitCost: (json['unitCost'] as num).toDouble(),
        costCurrency: json['costCurrency'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  @override
  List<Object?> get props => [id, instrumentID, quantity, unit, unitCost, costCurrency, date];
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
      final currentValueUSD = lot.quantity * usd * lot.unit.multiplier;
      final costUSD = lot.totalCost / costToUSD;
      valueDisplay += currentValueUSD * toDisplay;
      costDisplay += costUSD * toDisplay;
      costUSDTotal += costUSD;
      canonicalQty += lot.quantity * lot.unit.multiplier;
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
