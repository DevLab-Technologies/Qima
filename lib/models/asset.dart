import 'package:equatable/equatable.dart';

import 'metal_breakdown.dart';

/// Broad category an [Instrument] belongs to.
enum AssetClass {
  metal,
  crypto,
  stock,
  // Named `indices` (not `index`) to avoid colliding with the built-in
  // `Enum.index` instance getter.
  indices,
  fiat;

  /// The way prices are quoted for instruments of this class.
  Quotation get quotation {
    switch (this) {
      case AssetClass.metal:
        return Quotation.perTroyOunce;
      case AssetClass.crypto:
      case AssetClass.stock:
      case AssetClass.indices:
      case AssetClass.fiat:
        return Quotation.perUnit;
    }
  }

  /// Material icon standing in for the original SF Symbol.
  String get systemImage {
    switch (this) {
      case AssetClass.metal:
        return 'circle.hexagongrid.fill';
      case AssetClass.crypto:
        return 'bitcoinsign.circle.fill';
      case AssetClass.stock:
        return 'chart.line.uptrend.xyaxis';
      case AssetClass.indices:
        return 'chart.bar.xaxis';
      case AssetClass.fiat:
        return 'dollarsign.circle.fill';
    }
  }

  /// Localization key. Uses the spec's original `index` name (not the Dart
  /// identifier `indices`, which had to be renamed to avoid colliding with
  /// `Enum.index`).
  String get titleKey => 'assetClass.${this == AssetClass.indices ? 'index' : name}';
}

/// How an instrument's price is quoted.
enum Quotation {
  perTroyOunce,
  perUnit;

  List<PriceUnit> get displayUnits {
    switch (this) {
      case Quotation.perTroyOunce:
        return const [PriceUnit.troyOunce, PriceUnit.gram, PriceUnit.kilogram];
      case Quotation.perUnit:
        return const [PriceUnit.each];
    }
  }

  PriceUnit get defaultUnit => displayUnits.first;
}

/// Unit a price can be expressed in.
enum PriceUnit {
  troyOunce,
  gram,
  kilogram,
  each;

  /// Exact conversion constant, must match the Swift original bit-for-bit.
  static const double gramsPerTroyOunce = 31.1034768;

  /// Multiplier applied to a canonical per-troy-ounce (or per-unit) price to
  /// express it in this unit. Kilogram is derived from gram so the two stay
  /// exactly consistent (TC-U2): kilogram == 1000 * gram.
  double get multiplier {
    switch (this) {
      case PriceUnit.troyOunce:
      case PriceUnit.each:
        return 1;
      case PriceUnit.gram:
        return 1 / gramsPerTroyOunce;
      case PriceUnit.kilogram:
        return 1000 * (1 / gramsPerTroyOunce);
    }
  }

  String get labelKey => 'unit.$name';

  String? get abbreviationKey => this == PriceUnit.each ? null : 'unit.abbr.$name';
}

/// A single trackable financial instrument.
class Instrument extends Equatable {
  final String id;
  final String symbol;
  final AssetClass assetClass;
  final String nameKey;
  final String sourceSymbol;
  final List<GoldKarat> supportedKarats;

  const Instrument({
    required this.id,
    required this.symbol,
    required this.assetClass,
    required this.nameKey,
    String? sourceSymbol,
    this.supportedKarats = const [],
  }) : sourceSymbol = sourceSymbol ?? symbol;

  Quotation get quotation => assetClass.quotation;

  List<PriceUnit> get supportedUnits => quotation.displayUnits;

  String get systemImage => assetClass.systemImage;

  Instrument copyWith({
    String? id,
    String? symbol,
    AssetClass? assetClass,
    String? nameKey,
    String? sourceSymbol,
    List<GoldKarat>? supportedKarats,
  }) {
    return Instrument(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      assetClass: assetClass ?? this.assetClass,
      nameKey: nameKey ?? this.nameKey,
      sourceSymbol: sourceSymbol ?? this.sourceSymbol,
      supportedKarats: supportedKarats ?? this.supportedKarats,
    );
  }

  @override
  List<Object?> get props => [id, symbol, assetClass, nameKey, sourceSymbol, supportedKarats];
}
