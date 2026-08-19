import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'deterministic_uuid.dart';
import 'syncable.dart';

/// A user-added ticker not present in the built-in catalog.
///
/// Identity is derived ONLY from the (trimmed, uppercased) source symbol —
/// the display name has zero effect on identity (TC-C2), so two devices
/// creating the same ticker with different names still converge on the same
/// id.
class CustomInstrument extends Equatable implements Syncable {
  @override
  final String id;
  final String instrumentID;
  final String symbol;
  final String name;
  final String sourceSymbol;
  final AssetClass assetClass;

  CustomInstrument._({
    required this.id,
    required this.instrumentID,
    required this.symbol,
    required this.name,
    required this.sourceSymbol,
    required this.assetClass,
  });

  /// The two Yahoo-quote-routed asset classes a user is allowed to add a
  /// custom ticker for — metals/crypto/fiat aren't user-addable (spec §1.8,
  /// §4.2).
  static const _supportedClasses = {AssetClass.stock, AssetClass.indices};

  /// `instrumentID`/JSON prefix for each supported class, matching
  /// `InstrumentCatalog`'s `stock.<SOURCE>` / `index.<SOURCE>` conventions
  /// (spec §1.2) — note this deliberately differs from `AssetClass.indices`'s
  /// Dart identifier `name` ("indices"), which was renamed only to avoid
  /// colliding with `Enum.index`.
  static String _prefix(AssetClass assetClass) => assetClass == AssetClass.indices ? 'index' : 'stock';

  static AssetClass _classForPrefix(String prefix) => prefix == 'index' ? AssetClass.indices : AssetClass.stock;

  factory CustomInstrument({
    required String symbol,
    String? name,
    String? sourceSymbol,
    AssetClass assetClass = AssetClass.stock,
  }) {
    assert(
      _supportedClasses.contains(assetClass),
      'CustomInstrument only supports stock/indices asset classes',
    );
    final ticker = symbol.trim().toUpperCase();
    final source = (sourceSymbol ?? symbol).trim().toUpperCase();
    return CustomInstrument._(
      id: deterministicUuid('custominstrument.$source'),
      instrumentID: '${_prefix(assetClass)}.$source',
      symbol: ticker,
      name: (name ?? '').trim(),
      sourceSymbol: source,
      assetClass: assetClass,
    );
  }

  static String deterministicID(String source) => deterministicUuid('custominstrument.${source.trim().toUpperCase()}');

  /// Builds the [Instrument] representation. `nameKey` is used verbatim (not
  /// a localization lookup key) — falls back to the literal symbol when no
  /// display name was given (TC-C3).
  Instrument get instrument => Instrument(
        id: instrumentID,
        symbol: symbol,
        assetClass: assetClass,
        nameKey: name.isEmpty ? symbol : name,
        sourceSymbol: sourceSymbol,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'instrumentID': instrumentID,
        'symbol': symbol,
        'name': name,
        'sourceSymbol': sourceSymbol,
        'assetClass': _prefix(assetClass),
      };

  /// `assetClass` is optional for backward compatibility with persisted
  /// records (and existing tests) written before this field existed —
  /// absent/unrecognized values fall back to `stock`.
  factory CustomInstrument.fromJson(Map<String, dynamic> json) => CustomInstrument(
        symbol: json['symbol'] as String,
        name: json['name'] as String?,
        sourceSymbol: json['sourceSymbol'] as String,
        assetClass: _classForPrefix(json['assetClass'] as String? ?? 'stock'),
      );

  @override
  List<Object?> get props => [id, instrumentID, symbol, name, sourceSymbol, assetClass];
}
