import '../models/holding.dart';
import 'cloud_kv_store.dart';
import 'synced_store.dart';

/// Thin wrapper over [SyncedStore] for holding lots. No legacy migration is
/// needed for a from-scratch install, so it seeds empty.
class HoldingsStore {
  final SyncedStore<HoldingLot> _store;

  HoldingsStore({CloudKVStore? cloud})
      : _store = SyncedStore<HoldingLot>(
          filePath: 'holdings.records.json',
          cloudKey: 'holdings.records',
          itemFromJson: HoldingLot.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: () => const [],
        );

  Future<List<HoldingLot>> load() => _store.load();

  Future<List<HoldingLot>> upsert(HoldingLot lot) => _store.upsert(lot);

  Future<List<HoldingLot>> delete(String id) => _store.delete(id);

  Future<List<HoldingLot>?> adoptCloudChanges() => _store.adoptCloudChanges();

  /// Raw records (metadata + tombstones), for backup export (spec Phase 6).
  Future<List<Record<HoldingLot>>> exportRecords() => _store.exportRecords();

  /// Restores a previously-exported record set — see
  /// `SyncedStore.importRecords` for the merge/replace semantics.
  Future<List<HoldingLot>> importRecords(List<Record<HoldingLot>> records, {required bool replace, DateTime? now}) =>
      _store.importRecords(records, replace: replace, now: now);
}
