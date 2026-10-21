import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'holding.dart';
import 'metal_breakdown.dart';
import 'syncable.dart';

/// What a [HoldingTransaction] does to a position.
enum TransactionKind {
  /// Adds quantity at a cost.
  buy,

  /// Removes quantity for proceeds; realises a gain or loss.
  sell,

  /// Adds quantity moved in from elsewhere, carrying its original cost (or
  /// none, when [HoldingTransaction.unitPrice] is 0).
  transferIn,

  /// Removes quantity moved elsewhere. Its share of the cost basis leaves
  /// with it; nothing is realised.
  transferOut,

  /// A standalone charge (storage, custody, a wallet fee) on the holding,
  /// realised as a loss. Quantity is untouched.
  fee;

  bool get adds => this == buy || this == transferIn;
  bool get removes => this == sell || this == transferOut;
  bool get movesQuantity => this != fee;

  static TransactionKind fromName(String? name) =>
      TransactionKind.values.firstWhere((k) => k.name == name, orElse: () => TransactionKind.buy);
}

/// One row of a holding's ledger. Positions — quantity, cost basis, average
/// cost and realised gain — are never stored; they are derived from these
/// rows by `Ledger`, so editing or deleting any row re-derives everything
/// after it.
///
/// Synced and backed up like the lots it replaces (`transactions.records`).
class HoldingTransaction extends Equatable implements Syncable {
  @override
  final String id;
  final String instrumentID;
  final TransactionKind kind;

  /// In [unit]; 0 for a [TransactionKind.fee].
  final double quantity;
  final PriceUnit unit;

  /// Purity of physical gold bought or sold by weight, exactly as on a lot:
  /// null means fine (24K), and a troy-ounce row never carries one.
  final GoldKarat? karat;

  /// Per [unit], in [currency]: the cost of a buy, the price of a sell, the
  /// carried cost of a transfer in (0 when unknown). Unused (0) for a
  /// transfer out or a fee.
  final double unitPrice;

  /// Commission on a buy or sell, or the amount of a standalone fee, in
  /// [currency]. Never negative.
  final double fee;
  final String currency;
  final DateTime date;
  final String note;

  const HoldingTransaction({
    required this.id,
    required this.instrumentID,
    required this.kind,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.currency,
    required this.date,
    this.karat,
    this.fee = 0,
    this.note = '',
  });

  /// The row a pre-ledger lot becomes: a buy with the same id, so every
  /// device migrating the same lot produces the same record.
  factory HoldingTransaction.fromLot(HoldingLot lot) => HoldingTransaction(
        id: lot.id,
        instrumentID: lot.instrumentID,
        kind: TransactionKind.buy,
        quantity: lot.quantity,
        unit: lot.unit,
        karat: lot.karat,
        unitPrice: lot.unitCost,
        currency: lot.costCurrency,
        date: lot.date,
      );

  double get purity => karat?.purity ?? 1;

  /// Fine-metal (or, for non-metals, canonical) quantity — the same basis
  /// `HoldingLot.fineOunces` uses, so a sell of 20 g at 21K removes exactly
  /// what a buy of 20 g at 21K added.
  double get fineOunces => quantity * unit.multiplier * purity;

  double get gross => quantity * unitPrice;

  /// What a buy cost in total, including its commission.
  double get totalCost => gross + fee;

  /// What a sell brought in, after its commission.
  double get netProceeds => gross - fee;

  HoldingTransaction copyWith({
    TransactionKind? kind,
    double? quantity,
    PriceUnit? unit,
    GoldKarat? karat,
    bool clearKarat = false,
    double? unitPrice,
    double? fee,
    String? currency,
    DateTime? date,
    String? note,
  }) {
    return HoldingTransaction(
      id: id,
      instrumentID: instrumentID,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      karat: clearKarat ? null : (karat ?? this.karat),
      unitPrice: unitPrice ?? this.unitPrice,
      fee: fee ?? this.fee,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'instrumentID': instrumentID,
        'kind': kind.name,
        'quantity': quantity,
        'unit': unit.name,
        if (karat != null) 'karat': karat!.rawValue,
        'unitPrice': unitPrice,
        if (fee != 0) 'fee': fee,
        'currency': currency,
        'date': date.toUtc().toIso8601String(),
        if (note.isNotEmpty) 'note': note,
      };

  factory HoldingTransaction.fromJson(Map<String, dynamic> json) => HoldingTransaction(
        id: json['id'] as String,
        instrumentID: json['instrumentID'] as String,
        kind: TransactionKind.fromName(json['kind'] as String?),
        quantity: (json['quantity'] as num).toDouble(),
        unit: PriceUnit.values.byName(json['unit'] as String),
        karat: json['karat'] == null ? null : GoldKarat.fromRawValue(json['karat'] as int),
        unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
        fee: (json['fee'] as num? ?? 0).toDouble(),
        currency: json['currency'] as String,
        // Stored as a UTC instant, read back in local time so the calendar
        // day shown is the one the user picked.
        date: DateTime.parse(json['date'] as String).toLocal(),
        note: json['note'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, instrumentID, kind, quantity, unit, karat, unitPrice, fee, currency, date, note];
}
