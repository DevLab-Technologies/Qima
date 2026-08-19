import 'dart:convert';
import 'dart:math';

import '../models/syncable.dart';
import 'cloud_kv_store.dart';
import 'local_file_store.dart';

/// A single synced record: the item plus merge metadata. [order] is
/// fractional so items can be inserted between two others without
/// renumbering the whole list. [deleted] is a soft-delete tombstone.
class Record<T extends Syncable> {
  final T item;
  final double order;
  final DateTime updatedAt;
  final bool deleted;

  const Record({required this.item, required this.order, required this.updatedAt, this.deleted = false});

  Record<T> copyWith({T? item, double? order, DateTime? updatedAt, bool? deleted}) {
    return Record<T>(
      item: item ?? this.item,
      order: order ?? this.order,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'order': order,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'deleted': deleted,
      };

  static Record<T> fromJson<T extends Syncable>(Map<String, dynamic> json, T Function(Map<String, dynamic>) itemFromJson) {
    return Record<T>(
      item: itemFromJson(json['item'] as Map<String, dynamic>),
      order: (json['order'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deleted: json['deleted'] as bool? ?? false,
    );
  }
}

/// Conflict-free per-item merge engine on top of a local JSON mirror and a
/// pluggable [CloudKVStore]. Mirrors `SyncedStore<Item: Syncable>.swift`
/// (spec §2.10): last-write-wins per item, tombstoned deletes pruned after
/// [tombstoneTTL].
class SyncedStore<T extends Syncable> {
  final String filePath;
  final String cloudKey;
  final CloudKVStore cloud;
  final T Function(Map<String, dynamic>) itemFromJson;
  final List<T> Function()? seed;

  static const Duration tombstoneTTL = Duration(days: 365);

  SyncedStore({
    required this.filePath,
    required this.cloudKey,
    required this.itemFromJson,
    required this.cloud,
    this.seed,
  });

  Map<String, Record<T>> keyed(List<Record<T>> records) {
    final byId = <String, Record<T>>{};
    for (final record in records) {
      final existing = byId[record.item.id];
      if (existing == null || !existing.updatedAt.isAfter(record.updatedAt)) {
        byId[record.item.id] = record;
      }
    }
    return byId;
  }

  List<Record<T>> merge(List<Record<T>> a, List<Record<T>> b) {
    final combined = keyed([...a, ...b]);
    return combined.values.toList();
  }

  List<Record<T>> prune(List<Record<T>> records, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return records
        .where((r) => !(r.deleted && current.difference(r.updatedAt) > tombstoneTTL))
        .toList();
  }

  Future<List<Record<T>>> _readLocal() async {
    final json = await LocalFileStore.readJson(filePath);
    if (json == null) return [];
    final raw = json['records'] as List<dynamic>? ?? [];
    return raw.map((e) => Record.fromJson<T>(e as Map<String, dynamic>, itemFromJson)).toList();
  }

  Future<void> _writeLocal(List<Record<T>> records) {
    return LocalFileStore.writeJson(filePath, {'records': records.map((r) => r.toJson()).toList()});
  }

  Future<List<Record<T>>> _readCloud() async {
    final raw = await cloud.getString(cloudKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Record.fromJson<T>(e as Map<String, dynamic>, itemFromJson)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeCloud(List<Record<T>> records) {
    return cloud.setString(cloudKey, jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  List<T> _liveSorted(List<Record<T>> records) {
    final live = records.where((r) => !r.deleted).toList()
      ..sort((a, b) {
        final byOrder = a.order.compareTo(b.order);
        if (byOrder != 0) return byOrder;
        return a.item.id.compareTo(b.item.id);
      });
    return live.map((r) => r.item).toList();
  }

  /// Loads the merged local+cloud state (seeding if both are empty),
  /// persists the merge result, and returns the live items in display
  /// order.
  Future<List<T>> load() async {
    final local = await _readLocal();
    final cloudRecords = await _readCloud();

    List<Record<T>> merged;
    if (local.isEmpty && cloudRecords.isEmpty && seed != null) {
      final seeded = seed!();
      final distantPast = DateTime.fromMillisecondsSinceEpoch(-8640000000000000, isUtc: true);
      merged = <Record<T>>[
        for (var i = 0; i < seeded.length; i++)
          Record<T>(item: seeded[i], order: i.toDouble(), updatedAt: distantPast),
      ];
    } else {
      merged = prune(merge(local, cloudRecords));
    }

    await _writeLocal(merged);
    final prunedCloud = prune(cloudRecords);
    if (!_sameRecordSet(prunedCloud, merged)) {
      await _writeCloud(merged);
    }

    return _liveSorted(merged);
  }

  bool _sameRecordSet(List<Record<T>> a, List<Record<T>> b) {
    if (a.length != b.length) return false;
    final byIdA = {for (final r in a) r.item.id: r};
    for (final r in b) {
      final other = byIdA[r.item.id];
      if (other == null) return false;
      if (other.deleted != r.deleted || other.order != r.order || other.updatedAt != r.updatedAt) return false;
    }
    return true;
  }

  Future<void> _commit(List<Record<T>> localRecords) async {
    final cloudRecords = await _readCloud();
    final merged = prune(merge(localRecords, cloudRecords));
    await _writeLocal(merged);
    await _writeCloud(merged);
  }

  Future<List<T>> upsert(T item) async {
    final local = await _readLocal();
    final now = DateTime.now();
    final existingIndex = local.indexWhere((r) => r.item.id == item.id);
    List<Record<T>> updatedLocal;
    if (existingIndex >= 0) {
      final existing = local[existingIndex];
      final updated = existing.copyWith(item: item, updatedAt: now, deleted: false);
      updatedLocal = List.of(local)..[existingIndex] = updated;
    } else {
      final maxOrder = local.isEmpty ? -1.0 : local.map((r) => r.order).reduce(max);
      updatedLocal = [...local, Record<T>(item: item, order: maxOrder + 1, updatedAt: now)];
    }
    await _commit(updatedLocal);
    return _liveSorted(await _readLocal());
  }

  Future<List<T>> delete(String id) async {
    final local = await _readLocal();
    final index = local.indexWhere((r) => r.item.id == id);
    if (index < 0) return _liveSorted(local);
    final now = DateTime.now();
    final updatedLocal = List<Record<T>>.of(local)..[index] = local[index].copyWith(deleted: true, updatedAt: now);
    await _commit(updatedLocal);
    return _liveSorted(await _readLocal());
  }

  /// Reassigns order for each id in [orderedIds]; only bumps `updatedAt` for
  /// items whose order actually changed.
  Future<List<T>> setOrder(List<String> orderedIds) async {
    final local = await _readLocal();
    final now = DateTime.now();
    final updatedLocal = List<Record<T>>.of(local);
    for (var i = 0; i < orderedIds.length; i++) {
      final index = updatedLocal.indexWhere((r) => r.item.id == orderedIds[i]);
      if (index < 0) continue;
      final record = updatedLocal[index];
      if (record.order != i.toDouble()) {
        updatedLocal[index] = record.copyWith(order: i.toDouble(), updatedAt: now);
      }
    }
    await _commit(updatedLocal);
    return _liveSorted(await _readLocal());
  }

  Future<void> startSync() => cloud.synchronize();

  /// Re-runs the merge+persist against fresh cloud data; returns null if the
  /// cloud has nothing stored for this key yet.
  Future<List<T>?> adoptCloudChanges() async {
    final raw = await cloud.getString(cloudKey);
    if (raw == null) return null;
    return load();
  }
}
