import 'asset.dart';

/// The four buckets people think of their wealth in — coarser than
/// [AssetClass]: stocks and indices are one "equities" group, and fiat
/// currency holdings are "cash". Used by the allocation breakdown and by
/// zakat's per-class switches, so both always agree on what a group holds.
///
/// The enum names are persisted (zakat settings), so renaming one is a
/// data migration.
enum AssetGroup {
  metals,
  crypto,
  equities,
  cash;

  static AssetGroup of(AssetClass assetClass) {
    switch (assetClass) {
      case AssetClass.metal:
        return AssetGroup.metals;
      case AssetClass.crypto:
        return AssetGroup.crypto;
      case AssetClass.stock:
      case AssetClass.indices:
        return AssetGroup.equities;
      case AssetClass.fiat:
        return AssetGroup.cash;
    }
  }

  static AssetGroup? fromName(String name) {
    for (final group in AssetGroup.values) {
      if (group.name == name) return group;
    }
    return null;
  }
}
