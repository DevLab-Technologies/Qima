import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'deterministic_uuid.dart';
import 'instrument_catalog.dart';
import 'metal_breakdown.dart';
import 'syncable.dart';

/// A single watchlist entry: an instrument shown at a particular
/// currency/unit/karat combination.
class WatchCard extends Equatable implements Syncable {
  @override
  final String id;
  final String instrumentID;
  final String currency;
  final PriceUnit unit;
  final GoldKarat? karat;

  const WatchCard({
    required this.id,
    required this.instrumentID,
    required this.currency,
    required this.unit,
    this.karat,
  });

  Instrument? get instrument => InstrumentCatalog.instrument(instrumentID);

  /// Identity for duplicate-suppression purposes is the FULL tuple, not
  /// [id] — a fresh random id is generated per add-flow instance, so two
  /// cards can differ only by id yet still represent "the same" watch item
  /// (TC-W4: different karats of the same instrument/currency/unit are NOT
  /// duplicates of each other).
  bool isSameCombo(WatchCard other) {
    return instrumentID == other.instrumentID &&
        currency == other.currency &&
        unit == other.unit &&
        karat == other.karat;
  }

  /// Deterministic id derived via SHA-256("watchcard.{instrumentID}"),
  /// truncated to the first 16 bytes. Reproduced bit-for-bit against the
  /// Swift original so independently-seeded devices converge on the same id.
  static String seed({
    required String instrumentID,
    required String currency,
    required PriceUnit unit,
  }) {
    return deterministicUuid('watchcard.$instrumentID');
  }

  WatchCard copyWith({
    String? id,
    String? instrumentID,
    String? currency,
    PriceUnit? unit,
    GoldKarat? karat,
    bool clearKarat = false,
  }) {
    return WatchCard(
      id: id ?? this.id,
      instrumentID: instrumentID ?? this.instrumentID,
      currency: currency ?? this.currency,
      unit: unit ?? this.unit,
      karat: clearKarat ? null : (karat ?? this.karat),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'instrumentID': instrumentID,
        'currency': currency,
        'unit': unit.name,
        'karat': karat?.rawValue,
      };

  factory WatchCard.fromJson(Map<String, dynamic> json) => WatchCard(
        id: json['id'] as String,
        instrumentID: json['instrumentID'] as String,
        currency: json['currency'] as String,
        unit: PriceUnit.values.byName(json['unit'] as String),
        karat: json['karat'] == null ? null : GoldKarat.fromRawValue(json['karat'] as int),
      );

  @override
  List<Object?> get props => [id, instrumentID, currency, unit, karat];
}
