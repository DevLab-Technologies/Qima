import '../models/watch_card.dart';
import 'cloud_kv_store.dart';
import 'synced_store.dart';

/// Thin wrapper over [SyncedStore] for watchlist cards. Seeded via
/// `Preferences.seedWatchcards()`.
class WatchlistStore {
  final SyncedStore<WatchCard> _store;

  WatchlistStore({CloudKVStore? cloud, List<WatchCard> Function()? seed})
      : _store = SyncedStore<WatchCard>(
          filePath: 'watchcards.records.json',
          cloudKey: 'watchcards.records',
          itemFromJson: WatchCard.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: seed,
        );

  Future<List<WatchCard>> load() => _store.load();

  Future<List<WatchCard>> upsert(WatchCard card) => _store.upsert(card);

  Future<List<WatchCard>> delete(String id) => _store.delete(id);

  Future<List<WatchCard>> setOrder(List<String> orderedIds) => _store.setOrder(orderedIds);

  Future<List<WatchCard>?> adoptCloudChanges() => _store.adoptCloudChanges();
}
