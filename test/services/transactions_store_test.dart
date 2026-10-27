import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/services/cloud_kv_store.dart';
import 'package:qima/services/holdings_store.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/transactions_store.dart';

/// In-memory cloud shared by two simulated devices.
class _FakeCloud implements CloudKVStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  Future<void> synchronize() async {}

  @override
  Future<bool> accountStatus() async => true;

  @override
  Stream<CloudKVChangeEvent> get didChangeExternally => const Stream.empty();
}

HoldingLot _lot(String id, {double quantity = 1}) => HoldingLot(
      id: id,
      instrumentID: 'metal.XAU',
      quantity: quantity,
      unit: PriceUnit.troyOunce,
      unitCost: 2000,
      costCurrency: 'USD',
      date: DateTime(2025, 1, 1),
    );

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qima_transactions_store_test');
    LocalFileStore.overrideDirectoryForTesting(dir);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('lots become buys with the same id on first load', () async {
    final lots = HoldingsStore();
    await lots.upsert(_lot('a', quantity: 2));
    await lots.upsert(_lot('b'));
    final store = TransactionsStore(legacyLots: lots);

    final loaded = await store.load();
    expect(loaded.map((t) => t.id), unorderedEquals(['a', 'b']));
    expect(loaded.every((t) => t.kind == TransactionKind.buy), isTrue);
    expect(loaded.firstWhere((t) => t.id == 'a').quantity, 2);
  });

  test('migration is idempotent and keeps edits made since', () async {
    final lots = HoldingsStore();
    await lots.upsert(_lot('a'));
    final store = TransactionsStore(legacyLots: lots);
    final first = (await store.load()).single;

    await store.upsert(first.copyWith(quantity: 5));
    expect(await store.migrateLegacyLots(), 0);
    expect((await store.load()).single.quantity, 5, reason: 'the ledger row wins once migrated');
  });

  test('a lot added later (by a device still on 2.x) is picked up', () async {
    final lots = HoldingsStore();
    final store = TransactionsStore(legacyLots: lots);
    expect(await store.load(), isEmpty);

    await lots.upsert(_lot('late'));
    expect(await store.migrateLegacyLots(), 1);
    expect((await store.load()).single.id, 'late');
  });

  test('deleting a migrated buy deletes its source lot, so it never comes back', () async {
    final lots = HoldingsStore();
    await lots.upsert(_lot('a'));
    final store = TransactionsStore(legacyLots: lots);
    final migrated = (await store.load()).single;

    await store.delete(migrated.id);
    expect(await store.load(), isEmpty);
    expect(await lots.load(), isEmpty);
    expect(await store.migrateLegacyLots(), 0);
  });

  test('a deleted lot is never migrated', () async {
    final lots = HoldingsStore();
    await lots.upsert(_lot('a'));
    await lots.delete('a');
    final store = TransactionsStore(legacyLots: lots);
    expect(await store.load(), isEmpty);
  });

  test('two devices migrating the same lot through the cloud converge on one row', () async {
    final cloud = _FakeCloud();
    // Device A migrates and syncs.
    final lotsA = HoldingsStore(cloud: cloud);
    await lotsA.upsert(_lot('a'));
    final storeA = TransactionsStore(legacyLots: lotsA, cloud: cloud);
    await storeA.load();

    // Device B (fresh local files, same cloud) migrates the same lot.
    final otherDir = await Directory.systemTemp.createTemp('qima_transactions_store_b');
    LocalFileStore.overrideDirectoryForTesting(otherDir);
    try {
      final storeB = TransactionsStore(legacyLots: HoldingsStore(cloud: cloud), cloud: cloud);
      final loaded = await storeB.load();
      expect(loaded.map((t) => t.id), ['a']);
    } finally {
      LocalFileStore.overrideDirectoryForTesting(dir);
      await otherDir.delete(recursive: true);
    }
  });

  test('a migrated row keeps the lot\'s own timestamp, so later ledger edits win sync', () async {
    final lots = HoldingsStore();
    await lots.upsert(_lot('a'));
    final lotStamp = (await lots.exportRecords()).single.updatedAt;
    final store = TransactionsStore(legacyLots: lots);
    await store.load();
    expect((await store.exportRecords()).single.updatedAt, lotStamp);
  });
}
