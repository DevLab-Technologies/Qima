import 'dart:async';

import 'cloud_kv_store.dart';
import 'icloud_kv_store.dart';

/// Forwards to either a real [IcloudKVStore] or [LocalOnlyCloudKVStore]
/// depending on [enabled], without ever changing identity — every
/// `SyncedStore`/`Preferences` instance is constructed once against a single
/// [SwitchableCloudKVStore], so turning iCloud sync on/off in Settings never
/// requires rebuilding any store, and in-flight reads mid-toggle still
/// resolve against a consistent backend rather than a half-swapped one.
///
/// [enabled] starts `false` (local-only) until [AppCubit] explicitly turns it
/// on after reading the user's `iCloudSyncEnabled` preference — this class
/// itself has no opinion on defaults.
class SwitchableCloudKVStore implements CloudKVStore {
  final IcloudKVStore _icloud;
  final LocalOnlyCloudKVStore _local = LocalOnlyCloudKVStore();
  bool _enabled = false;

  final StreamController<CloudKVChangeEvent> _changesController = StreamController<CloudKVChangeEvent>.broadcast();
  StreamSubscription<CloudKVChangeEvent>? _icloudSubscription;

  SwitchableCloudKVStore({IcloudKVStore? icloud}) : _icloud = icloud ?? IcloudKVStore();

  bool get enabled => _enabled;

  CloudKVStore get _active => _enabled ? _icloud : _local;

  /// Switches the active backend. Turning ON subscribes to the real iCloud
  /// change stream (so external-change events start flowing); turning OFF
  /// unsubscribes so no more events arrive from a backend the app is no
  /// longer treating as authoritative — callers that already merged local
  /// data into the cloud before disabling don't need to worry about a event
  /// arriving after the fact and re-triggering a reload from a store nothing
  /// reads anymore.
  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (value) {
      _icloudSubscription ??= _icloud.didChangeExternally.listen(
        _changesController.add,
        onError: _changesController.addError,
      );
    } else {
      unawaited(_icloudSubscription?.cancel());
      _icloudSubscription = null;
    }
  }

  @override
  Future<String?> getString(String key) => _active.getString(key);

  @override
  Future<void> setString(String key, String value) => _active.setString(key, value);

  @override
  Future<void> synchronize() => _active.synchronize();

  @override
  Future<bool> accountStatus() => _icloud.accountStatus();

  @override
  Stream<CloudKVChangeEvent> get didChangeExternally => _changesController.stream;

  /// Releases the underlying event subscription and closes the forwarded
  /// stream — call once when the owner (normally a single app-lifetime
  /// [AppCubit]) is done with this store, so no native event channel
  /// listener outlives it.
  Future<void> dispose() async {
    await _icloudSubscription?.cancel();
    _icloudSubscription = null;
    await _changesController.close();
    _icloud.dispose();
  }
}
