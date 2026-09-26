import '../models/price_alert.dart';
import 'cloud_kv_store.dart';
import 'synced_store.dart';

/// Thin wrapper over [SyncedStore] for price alert definitions. Mirrors
/// `HoldingsStore` — no legacy migration needed for a from-scratch install.
class AlertsStore {
  final SyncedStore<PriceAlert> _store;

  AlertsStore({CloudKVStore? cloud})
      : _store = SyncedStore<PriceAlert>(
          filePath: 'alerts.records.json',
          cloudKey: 'alerts.records',
          itemFromJson: PriceAlert.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: () => const [],
        );

  Future<List<PriceAlert>> load() => _store.load();

  Future<List<PriceAlert>> upsert(PriceAlert alert) => _store.upsert(alert);

  Future<List<PriceAlert>> delete(String id) => _store.delete(id);

  Future<List<PriceAlert>?> adoptCloudChanges() => _store.adoptCloudChanges();

  /// Raw records (metadata + tombstones), for backup export (spec Phase 6).
  Future<List<Record<PriceAlert>>> exportRecords() => _store.exportRecords();

  /// Restores a previously-exported record set — see
  /// `SyncedStore.importRecords` for the merge/replace semantics.
  Future<List<PriceAlert>> importRecords(List<Record<PriceAlert>> records, {required bool replace, DateTime? now}) =>
      _store.importRecords(records, replace: replace, now: now);
}
