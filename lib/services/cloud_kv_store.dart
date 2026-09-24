/// Why a key-value store's external-change notification fired — mirrors
/// `NSUbiquitousKeyValueStoreChangeReasonKey`'s possible values (see
/// `CloudKVPlugin.swift`). Values other than the four modeled below collapse
/// to [unknown] rather than throwing, so a future/unrecognized OS reason
/// code never crashes the listener.
enum CloudKVChangeReason {
  /// A change arrived from another device/process — the normal "something
  /// else wrote a value" case.
  serverChange,

  /// The very first sync after iCloud KVS finished downloading this app's
  /// existing cloud data (e.g. right after enabling sync or a fresh
  /// install). Treated the same as [serverChange] by callers.
  initialSyncChange,

  /// A write was dropped because the store exceeded its size/key-count
  /// quota. No data was written; the caller should surface a "storage full"
  /// status rather than retry the write as if it were a transient failure.
  quotaViolationChange,

  /// The signed-in iCloud account changed (switched or signed out) since
  /// the last sync. Existing keys may now belong to a different account's
  /// data, so callers should re-check [CloudKVStore.accountStatus] rather
  /// than trust cached values.
  accountChange,

  unknown;

  static CloudKVChangeReason fromWireValue(String value) {
    return CloudKVChangeReason.values.firstWhere((r) => r.name == value, orElse: () => CloudKVChangeReason.unknown);
  }
}

/// A single external-change event: which keys changed (empty means "unknown
/// keys, reload everything" — iCloud sometimes omits the key list) and why.
class CloudKVChangeEvent {
  final List<String> keys;
  final CloudKVChangeReason reason;

  const CloudKVChangeEvent({required this.keys, required this.reason});
}

/// Abstraction over a cloud key-value store (e.g. iCloud KVS via a platform
/// channel on iOS/macOS). [LocalOnlyCloudKVStore] is a no-op fallback used
/// wherever real cloud sync isn't available or hasn't been enabled;
/// [IcloudKVStore] (`icloud_kv_store.dart`) is the real platform-channel
/// implementation. [SwitchableCloudKVStore] picks between them at runtime so
/// stores built on top of [CloudKVStore] never need to be reconstructed when
/// sync is toggled on/off.
abstract class CloudKVStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> synchronize();

  /// Whether an iCloud account is currently available on this device. Always
  /// `false` for a local-only backend.
  Future<bool> accountStatus();

  /// A stream of external-change notifications (cloud value changed outside
  /// this process, quota was exceeded, or the account changed).
  Stream<CloudKVChangeEvent> get didChangeExternally;
}

/// No-op cloud store: every read returns null (never has data), writes are
/// discarded, and no external-change events ever fire. Used as the backend
/// on platforms without iCloud KVS (Android, Windows, Linux, Web, and macOS
/// until its entitlement is added — see `WATCHOS_SETUP.md`/Phase 7 report)
/// and whenever the user has iCloud sync turned off.
class LocalOnlyCloudKVStore implements CloudKVStore {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<void> setString(String key, String value) async {}

  @override
  Future<void> synchronize() async {}

  @override
  Future<bool> accountStatus() async => false;

  @override
  Stream<CloudKVChangeEvent> get didChangeExternally => const Stream.empty();
}
