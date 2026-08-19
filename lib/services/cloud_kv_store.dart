/// Abstraction over a cloud key-value store (e.g. iCloud KVS via a platform
/// channel on iOS/macOS). For this pass only a local-only no-op
/// implementation is provided; a later pass can swap in a real
/// platform-channel implementation behind this same interface without
/// touching [SyncedStore].
abstract class CloudKVStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> synchronize();

  /// A stream of external-change notifications (cloud value changed outside
  /// this process), keyed by the key that changed.
  Stream<String> get didChangeExternally;
}

/// No-op cloud store: every read returns null (never has data), writes are
/// discarded, and no external-change events ever fire. This makes
/// [SyncedStore] behave as a local-only store for this pass.
class LocalOnlyCloudKVStore implements CloudKVStore {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<void> setString(String key, String value) async {}

  @override
  Future<void> synchronize() async {}

  @override
  Stream<String> get didChangeExternally => const Stream.empty();
}
