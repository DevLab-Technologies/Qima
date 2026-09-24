import FlutterMacOS
import Foundation

/// macOS counterpart of `ios/Runner/CloudKVPlugin.swift` — same
/// `MethodChannel`/`EventChannel` contract over `NSUbiquitousKeyValueStore`.
///
/// NOTE: the macOS `Runner` target does not yet declare the
/// `com.apple.developer.ubiquity-kvstore-identifier` entitlement (see
/// `macos/Runner/DebugProfile.entitlements` / `Release.entitlements` and the
/// Phase 7 report for the exact line to add later plus the signing/minimum
/// OS-version decisions that are still pending). Without that entitlement,
/// `NSUbiquitousKeyValueStore` silently behaves as an empty, non-syncing
/// store and `FileManager.ubiquityIdentityToken` still reflects the signed
/// -in iCloud account, so `accountStatus` alone is not a reliable signal
/// that sync is actually wired up on macOS yet — this plugin is registered
/// so the channel exists, but `SwitchableCloudKVStore` only routes to it
/// once the entitlement is added. Until then the Dart side stays on
/// `LocalOnlyCloudKVStore` on macOS, which is what keeps macOS working
/// local-only per the Phase 7 spec.
final class CloudKVPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let store = NSUbiquitousKeyValueStore.default
  private var eventSink: FlutterEventSink?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CloudKVPlugin()

    let methodChannel = FlutterMethodChannel(
      name: "qima/cloud_kv",
      binaryMessenger: registrar.messenger
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: "qima/cloud_kv/changes",
      binaryMessenger: registrar.messenger
    )
    eventChannel.setStreamHandler(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
      result(store.synchronize())

    case "accountStatus":
      result(FileManager.default.ubiquityIdentityToken != nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(storeDidChangeExternally(_:)),
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: store
    )
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
