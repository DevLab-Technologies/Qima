import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/models/watchlist_sort.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/watchlist_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_watchlist_order_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;
  final btc = InstrumentCatalog.instrument('crypto.BTC')!;

  Future<AppCubit> seededCubit() async {
    final store = WatchlistStore();
    for (final card in [
      WatchCard(id: 'gold', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce),
      WatchCard(id: 'btc', instrumentID: btc.id, currency: 'USD', unit: PriceUnit.each),
      WatchCard(id: 'silver', instrumentID: silver.id, currency: 'USD', unit: PriceUnit.troyOunce),
    ]) {
      await store.upsert(card);
    }
    final cubit = AppCubit(watchlistStore: store);
    final now = DateTime.now();
    QuoteSeries series(String id, double from, double to) => QuoteSeries(instrumentID: id, quotes: [
          Quote(instrumentID: id, timestamp: now.subtract(const Duration(days: 30)), canonicalUSD: from),
          Quote(instrumentID: id, timestamp: now, canonicalUSD: to),
        ]);
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      cards: await store.load(),
      seriesByID: {
        gold.id: series(gold.id, 100, 101), // +1%
        btc.id: series(btc.id, 100, 120), // +20%
        silver.id: series(silver.id, 100, 90), // -10%
      },
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
    ));
    return cubit;
  }

  test('sortWatchlist by change orders best performer first and saves the order', () async {
    final cubit = await seededCubit();

    await cubit.sortWatchlist(WatchlistSort.change, nameOf: (c) => c.id);

    expect(cubit.state.cards.map((c) => c.id), ['btc', 'gold', 'silver']);
    expect((await WatchlistStore().load()).map((c) => c.id), ['btc', 'gold', 'silver']);
  });

  test('sortWatchlist by name uses the given names', () async {
    final cubit = await seededCubit();

    await cubit.sortWatchlist(WatchlistSort.name, nameOf: (c) => {'gold': 'Z', 'btc': 'M', 'silver': 'A'}[c.id]!);

    expect(cubit.state.cards.map((c) => c.id), ['silver', 'btc', 'gold']);
  });

  test('a drag after a sort keeps adjusting the saved order', () async {
    final cubit = await seededCubit();
    await cubit.sortWatchlist(WatchlistSort.assetClass, nameOf: (c) => c.id);
    expect(cubit.state.cards.map((c) => c.id), ['gold', 'silver', 'btc']);

    await cubit.move(2, 0);

    expect((await WatchlistStore().load()).map((c) => c.id), ['btc', 'gold', 'silver']);
  });
}
