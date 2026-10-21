import '../models/holding_transaction.dart';
import 'cloud_kv_store.dart';
import 'holdings_store.dart';
import 'synced_store.dart';

/// The holdings ledger (v3), synced like every other collection under
/// `transactions.records`.
///
/// Holdings used to be a list of lots (`holdings.records`). That store is
/// kept read-mostly as the migration source: every live lot becomes a buy
/// with the lot's own id and timestamps, on every load. That makes the
/// migration idempotent across devices, and it picks up lots that a device
/// still on 2.x adds later. Edits made to a lot on such a device after it
/// was migrated don't carry over — the ledger row is the record from then
/// on.
class TransactionsStore {
  static const String cloudKey = 'transactions.records';

  final SyncedStore<HoldingTransaction> _store;
  final HoldingsStore legacyLots;

  TransactionsStore({required this.legacyLots, CloudKVStore? cloud})
      : _store = SyncedStore<HoldingTransaction>(
          filePath: 'transactions.records.json',
          cloudKey: cloudKey,
          itemFromJson: HoldingTransaction.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: () => const [],
        );

  /// Migrates any not-yet-seen lots, then returns the ledger.
  Future<List<HoldingTransaction>> load() async {
    await migrateLegacyLots();
    return _store.load();
  }

  /// Returns how many lots became transactions this time.
  Future<int> migrateLegacyLots() async {
    final lots = await legacyLots.exportRecords();
    return _store.insertMissing([
      for (final r in lots)
        if (!r.deleted)
          Record<HoldingTransaction>(
            item: HoldingTransaction.fromLot(r.item),
            order: r.order,
            updatedAt: r.updatedAt,
          ),
    ]);
  }

  Future<List<HoldingTransaction>> upsert(HoldingTransaction transaction) => _store.upsert(transaction);

  /// Deleting a migrated buy also deletes its source lot, so the migration
  /// can never bring it back (and a device still on 2.x stops showing it).
  Future<List<HoldingTransaction>> delete(String id) async {
    await legacyLots.delete(id);
    return _store.delete(id);
  }

  Future<List<HoldingTransaction>?> adoptCloudChanges() async {
    await migrateLegacyLots();
    return _store.adoptCloudChanges();
  }

  /// Raw records (metadata + tombstones), for backup export.
  Future<List<Record<HoldingTransaction>>> exportRecords() => _store.exportRecords();

  /// Restores a previously exported record set — see
  /// `SyncedStore.importRecords` for merge/replace semantics.
  Future<List<HoldingTransaction>> importRecords(List<Record<HoldingTransaction>> records,
          {required bool replace, DateTime? now}) =>
      _store.importRecords(records, replace: replace, now: now);
}
