import '../models/custom_instrument.dart';
import 'cloud_kv_store.dart';
import 'synced_store.dart';

/// Thin wrapper over [SyncedStore] for user-added tickers. No seed — a
/// fresh install starts empty.
class CustomInstrumentStore {
  final SyncedStore<CustomInstrument> _store;

  CustomInstrumentStore({CloudKVStore? cloud})
      : _store = SyncedStore<CustomInstrument>(
          filePath: 'custominstruments.records.json',
          cloudKey: 'custominstruments.records',
          itemFromJson: CustomInstrument.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
        );

  Future<List<CustomInstrument>> load() => _store.load();

  Future<List<CustomInstrument>> upsert(CustomInstrument instrument) => _store.upsert(instrument);

  Future<List<CustomInstrument>> delete(String id) => _store.delete(id);

  Future<List<CustomInstrument>?> adoptCloudChanges() => _store.adoptCloudChanges();
}
