import 'asset.dart';
import 'watch_card.dart';

/// One-tap orders the watchlist's Edit order menu can apply. Each writes a
/// new manual order (the user can keep dragging from there); none is a
/// live sort that keeps re-shuffling as prices move.
enum WatchlistSort {
  /// A to Z by the name shown in the row.
  name,

  /// Best performer first, by the same change the row shows; cards with
  /// no change yet go last.
  change,

  /// Grouped by asset class (metals, crypto, stocks, indices, currencies),
  /// keeping the current order inside each group.
  assetClass,
}

/// [cards] reordered by [sort]. Stable: cards that compare equal keep their
/// current relative order, so sorting twice never shuffles ties.
List<WatchCard> sortWatchCards(
  List<WatchCard> cards,
  WatchlistSort sort, {
  required String Function(WatchCard) nameOf,
  required double? Function(WatchCard) changeOf,
  required AssetClass Function(WatchCard) assetClassOf,
}) {
  int compare(WatchCard a, WatchCard b) {
    switch (sort) {
      case WatchlistSort.name:
        return nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase());
      case WatchlistSort.change:
        final ca = changeOf(a);
        final cb = changeOf(b);
        if (ca == null || cb == null) return (ca == null ? 1 : 0) - (cb == null ? 1 : 0);
        return cb.compareTo(ca);
      case WatchlistSort.assetClass:
        return assetClassOf(a).index.compareTo(assetClassOf(b).index);
    }
  }

  final indexed = [for (var i = 0; i < cards.length; i++) (i, cards[i])];
  indexed.sort((a, b) {
    final result = compare(a.$2, b.$2);
    return result != 0 ? result : a.$1.compareTo(b.$1);
  });
  return [for (final entry in indexed) entry.$2];
}
