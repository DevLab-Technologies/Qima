import FlutterMacOS
import Foundation
import Security

/// macOS counterpart of `ios/Runner/CloudKVPlugin.swift` — same
/// `MethodChannel`/`EventChannel` contract over `NSUbiquitousKeyValueStore`,
/// and the same store: `AppStore.entitlements` declares the iOS app's
/// `com.apple.developer.ubiquity-kvstore-identifier`, so a Mac and an iPhone
/// on one iCloud account see each other's data.
///
/// Only App Store / TestFlight builds carry that entitlement (the signing
/// lane switches to `AppStore.entitlements`, which needs the Mac App Store
/// profile). Debug builds and the direct-download zip are signed without
/// it, and there
/// `NSUbiquitousKeyValueStore` silently acts as an empty, non-syncing store
/// while `ubiquityIdentityToken` still reports the signed-in account. So
/// `accountStatus` also checks the running process's own entitlement, and
/// the Dart side stays local-only when it is missing.
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
      result(CloudKVPlugin.hasKeyValueStoreEntitlement && FileManager.default.ubiquityIdentityToken != nil)

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

  /// Whether this build was signed with the iCloud key-value store
  /// entitlement (see the type comment).
  private static let hasKeyValueStoreEntitlement: Bool = {
    guard let task = SecTaskCreateFromSelf(nil) else { return false }
    let value = SecTaskCopyValueForEntitlement(
      task, "com.apple.developer.ubiquity-kvstore-identifier" as CFString, nil
    )
    return value != nil
  }()

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
