import '../models/alert_runtime_state.dart';
import 'local_file_store.dart';
import 'mutex.dart';

/// Local-only (never synced) persistence for [AlertRuntimeState], one JSON
/// file (`alerts.state.json`) keyed by alert id (spec Phase 5). Writes go
/// through [LocalFileStore.writeJson], which is atomic (temp file + rename —
/// see `local_file_store_io.dart`), so a foreground refresh and a background
/// task writing at the same moment can never corrupt the file; the later
/// rename simply wins.
///
/// [_mutex] only serializes calls made from within this same isolate (the
/// foreground app OR a single background task run, never both at once since
/// they're separate isolates/processes) — it prevents two concurrent
/// `updateOne` calls on this isolate from doing a lost-update
/// read-modify-write race against each other, which matters because
/// `AlertEvaluator` can evaluate several alerts for the same refresh
/// concurrently.
class AlertRuntimeStore {
  static const _path = 'alerts.state.json';
  final Mutex _mutex = Mutex();

  Future<Map<String, AlertRuntimeState>> _readAll() async {
    final json = await LocalFileStore.readJson(_path);
    if (json == null) return {};
    final raw = json['states'] as List<dynamic>? ?? [];
    final result = <String, AlertRuntimeState>{};
    for (final entry in raw) {
      try {
        final state = AlertRuntimeState.fromJson(entry as Map<String, dynamic>);
        result[state.alertID] = state;
      } catch (_) {
        // Tolerate a corrupt individual entry rather than losing the whole file.
      }
    }
    return result;
  }

  Future<void> _writeAll(Map<String, AlertRuntimeState> states) {
    return LocalFileStore.writeJson(_path, {'states': states.values.map((s) => s.toJson()).toList()});
  }

  Future<Map<String, AlertRuntimeState>> loadAll() => _readAll();

  AlertRuntimeState stateFor(Map<String, AlertRuntimeState> all, String alertID) {
    return all[alertID] ?? AlertRuntimeState(alertID: alertID);
  }

  /// Reads-modifies-writes the state for a single alert id under this
  /// isolate's mutex, so concurrent evaluations within the same refresh pass
  /// can't clobber each other.
  Future<AlertRuntimeState> updateOne(String alertID, AlertRuntimeState Function(AlertRuntimeState current) update) {
    return _mutex.synchronized(() async {
      final all = await _readAll();
      final current = stateFor(all, alertID);
      final updated = update(current);
      all[alertID] = updated;
      await _writeAll(all);
      return updated;
    });
  }

  /// Removes runtime state for alert ids no longer present (their [PriceAlert]
  /// was deleted) — keeps the file from growing unboundedly across the
  /// lifetime of the install.
  Future<void> pruneMissing(Set<String> liveAlertIDs) {
    return _mutex.synchronized(() async {
      final all = await _readAll();
      final pruned = {
        for (final entry in all.entries)
          if (liveAlertIDs.contains(entry.key)) entry.key: entry.value,
      };
      if (pruned.length != all.length) {
        await _writeAll(pruned);
      }
    });
  }
}
