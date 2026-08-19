import '../models/fx_history.dart';
import 'local_file_store.dart';
import 'mutex.dart';

/// `fx-history.json` persistence. All read-modify-write access is serialized
/// through [writer] (the Dart stand-in for the Swift `FXHistoryWriter`
/// actor), so a concurrent tail refresh and a user-triggered "load history"
/// can never race and clobber each other (spec §2.2/§2.9).
class FXHistoryStore {
  static const String _fileName = 'fx-history.json';
  final Mutex _mutex = Mutex();

  Future<FXHistory> load() async {
    final json = await LocalFileStore.readJson(_fileName);
    if (json == null) return FXHistory.empty;
    try {
      return FXHistory.fromJson(json);
    } catch (_) {
      return FXHistory.empty;
    }
  }

  Future<bool> save(FXHistory history) {
    return LocalFileStore.writeJson(_fileName, history.toJson());
  }

  /// Reads the freshest on-disk copy, applies [apply] to it, and persists
  /// the result only if it actually changed. Returns the merged history and
  /// whether the write was actually persisted.
  Future<(FXHistory, bool)> update(FXHistory Function(FXHistory current) apply) {
    return _mutex.synchronized(() async {
      final current = await load();
      final updated = apply(current);
      if (updated == current) return (updated, false);
      final persisted = await save(updated);
      return (updated, persisted);
    });
  }
}
