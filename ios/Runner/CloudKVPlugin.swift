import Flutter
import Foundation

/// Bridges `NSUbiquitousKeyValueStore` (iCloud key-value storage) to Dart via
/// a `MethodChannel` ("qima/cloud_kv") for reads/writes and an
/// `EventChannel` ("qima/cloud_kv/changes") for external-change
/// notifications. See `lib/services/icloud_kv_store.dart` for the Dart side
/// and `SyncedStore`/`Preferences` for how the two are merged.
///
/// KVS limits (documented, not enforced by the OS at write time — a write
/// past them is silently dropped and `didChangeExternallyNotification` fires
/// with `NSUbiquitousKeyValueStoreQuotaViolationChange` instead): 1 MB total
/// store size, 1 MB per value, 1024 keys. This plugin surfaces the quota
/// violation reason to Dart rather than trying to pre-validate sizes itself,
/// since the true limit is enforced by the OS/iCloud daemon, not by this
/// process.
final class CloudKVPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let store = NSUbiquitousKeyValueStore.default
  private var eventSink: FlutterEventSink?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CloudKVPlugin()

    let methodChannel = FlutterMethodChannel(
      name: "qima/cloud_kv",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: "qima/cloud_kv/changes",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(instance)
  }

  // MARK: - FlutterPlugin (method channel)

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // NSUbiquitousKeyValueStore's own API is thread-safe and may be called
    // from any thread per Apple's docs, but the method channel itself
    // dispatches `handle` on the main thread already (Flutter's default),
    // so no extra hop is needed here.
    switch call.method {
    case "getString":
      guard let args = call.arguments as? [String: Any], let key = args["key"] as? String else {
        result(FlutterError(code: "bad_args", message: "getString requires a 'key' string", details: nil))
        return
      }
      result(store.string(forKey: key))

    case "setString":
      guard let args = call.arguments as? [String: Any],
            let key = args["key"] as? String,
            let value = args["value"] as? String else {
        result(FlutterError(code: "bad_args", message: "setString requires 'key' and 'value' strings", details: nil))
        return
      }
      store.set(value, forKey: key)
      result(nil)

    case "synchronize":
      // Explicit synchronize() is documented as rarely necessary (the store
      // auto-syncs periodically), but calling it after a write gives the
      // best chance of a prompt round-trip when the app is about to
      // background or the user just toggled sync on.
      result(store.synchronize())

    case "accountStatus":
      // `FileManager.ubiquityIdentityToken` is the standard non-CloudKit way
      // to check "is an iCloud account currently signed in on this device"
      // without touching CloudKit at all — nil means signed out (or iCloud
      // Drive/the app's iCloud capability unavailable).
      result(FileManager.default.ubiquityIdentityToken != nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - FlutterStreamHandler (event channel)

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(storeDidChangeExternally(_:)),
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: store
    )
    // Kick off an initial sync so a change made while the app was closed
    // surfaces as soon as something starts listening.
    store.synchronize()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(
      self,
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: store
    )
    eventSink = nil
    return nil
  }

  /// `NSUbiquitousKeyValueStore.didChangeExternallyNotification` always
  /// fires on the main thread/main run loop per Apple's docs, but this is
  /// pinned onto the main queue explicitly anyway so a future change to
  /// that guarantee (or a test that posts the notification off-thread)
  /// can't send a Flutter event from a background thread, which is unsafe.
  @objc private func storeDidChangeExternally(_ notification: Notification) {
    guard let sink = eventSink else { return }
    let userInfo = notification.userInfo
    let changedKeys = (userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]) ?? []
    let reasonCode = (userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? NSNumber)?.intValue
    let reason = CloudKVPlugin.reasonName(for: reasonCode)

    let payload: [String: Any] = [
      "keys": changedKeys,
      "reason": reason,
    ]

    if Thread.isMainThread {
      sink(payload)
    } else {
      DispatchQueue.main.async {
        sink(payload)
      }
    }
  }

  private static func reasonName(for code: Int?) -> String {
    switch code {
    case NSUbiquitousKeyValueStoreServerChange:
      return "serverChange"
    case NSUbiquitousKeyValueStoreInitialSyncChange:
      return "initialSyncChange"
    case NSUbiquitousKeyValueStoreQuotaViolationChange:
      return "quotaViolationChange"
    case NSUbiquitousKeyValueStoreAccountChange:
      return "accountChange"
    default:
      return "unknown"
    }
  }
}
