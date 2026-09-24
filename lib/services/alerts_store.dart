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
}
