import 'package:flutter/services.dart';

import 'cloud_kv_store.dart';

/// Real iCloud key-value storage backend, over the platform channels
/// `CloudKVPlugin.swift` (iOS) / `CloudKVPlugin.swift` (macOS, registered
/// but see that file's note on why it stays inert until its entitlement is
/// added) exposes: a `MethodChannel` for reads/writes/status and an
/// `EventChannel` for `NSUbiquitousKeyValueStore`'s external-change
/// notification.
///
/// The event channel is subscribed to lazily on first access to
/// [didChangeExternally] and the subscription is shared (a broadcast
/// stream) so multiple listeners don't open multiple native event streams;
/// [dispose] tears it down so nothing keeps delivering events (or keeps this
/// object alive) after the owner is done with it.
class IcloudKVStore implements CloudKVStore {
  static const MethodChannel _methodChannel = MethodChannel('qima/cloud_kv');
  static const EventChannel _eventChannel = EventChannel('qima/cloud_kv/changes');

  Stream<CloudKVChangeEvent>? _changes;

  @override
  Future<String?> getString(String key) async {
    final result = await _methodChannel.invokeMethod<String>('getString', {'key': key});
    return result;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _methodChannel.invokeMethod<void>('setString', {'key': key, 'value': value});
  }

  @override
  Future<void> synchronize() async {
    await _methodChannel.invokeMethod<void>('synchronize');
  }

  @override
  Future<bool> accountStatus() async {
    final result = await _methodChannel.invokeMethod<bool>('accountStatus');
    return result ?? false;
  }

  @override
  Stream<CloudKVChangeEvent> get didChangeExternally {
    return _changes ??= _eventChannel.receiveBroadcastStream().map(_toChangeEvent).asBroadcastStream();
  }

  CloudKVChangeEvent _toChangeEvent(dynamic raw) {
    final map = Map<Object?, Object?>.from(raw as Map);
    final keys = (map['keys'] as List<dynamic>? ?? const []).cast<String>();
    final reasonRaw = map['reason'] as String? ?? 'unknown';
    return CloudKVChangeEvent(keys: keys, reason: CloudKVChangeReason.fromWireValue(reasonRaw));
  }

  /// Drops the cached event stream so a subsequent [didChangeExternally]
  /// access opens a fresh native subscription. There's no live native
  /// resource to explicitly cancel here beyond letting Dart-side listeners
  /// unsubscribe (Flutter's `EventChannel` tears down the native side once
  /// its last Dart listener cancels), but this is provided so callers that
  /// hold this store for a long time (e.g. across a sync toggle) have an
  /// explicit place to release it rather than relying on GC.
  void dispose() {
    _changes = null;
  }
}
