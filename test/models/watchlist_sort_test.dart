import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/models/watchlist_sort.dart';

void main() {
  WatchCard card(String id) => WatchCard(id: id, instrumentID: id, currency: 'USD', unit: PriceUnit.each);

  // id -> (name, change, class)
  final facts = <String, (String, double?, AssetClass)>{
    'a': ('silver', 0.02, AssetClass.metal),
    'b': ('Bitcoin', -0.10, AssetClass.crypto),
    'c': ('Apple', null, AssetClass.stock),
    'd': ('gold', 0.05, AssetClass.metal),
    'e': ('Ether', 0.05, AssetClass.crypto),
  };
  final cards = [for (final id in facts.keys) card(id)];

  List<String> sorted(WatchlistSort sort) => sortWatchCards(
        cards,
        sort,
        nameOf: (c) => facts[c.id]!.$1,
        changeOf: (c) => facts[c.id]!.$2,
        assetClassOf: (c) => facts[c.id]!.$3,
      ).map((c) => c.id).toList();

  test('name sorts A to Z ignoring case', () {
    expect(sorted(WatchlistSort.name), ['c', 'b', 'e', 'd', 'a']);
  });

  test('change puts the best performer first, keeps ties in order, and cards without a change last', () {
    expect(sorted(WatchlistSort.change), ['d', 'e', 'a', 'b', 'c']);
  });

  test('asset class groups by class and keeps the current order inside each group', () {
    expect(sorted(WatchlistSort.assetClass), ['a', 'd', 'b', 'e', 'c']);
  });

  test('sorting leaves the input list untouched', () {
    sorted(WatchlistSort.name);
    expect(cards.map((c) => c.id), ['a', 'b', 'c', 'd', 'e']);
  });
}
