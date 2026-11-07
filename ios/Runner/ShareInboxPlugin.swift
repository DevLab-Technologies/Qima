import Flutter
import UIKit

/// Where Share › Qima leaves files (`ImportInbox` in the app group), for
/// `ShareInbox` (Dart), which reads and clears it.
final class ShareInboxPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.devlabtechnologies.qima/share_inbox", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(ShareInboxPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "inboxPath" else { return result(FlutterMethodNotImplemented) }
    guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.devlabtechnologies.qima") else {
      return result(nil)
    }
    let inbox = container.appendingPathComponent("ImportInbox", isDirectory: true)
    try? FileManager.default.createDirectory(at: inbox, withIntermediateDirectories: true)
    result(inbox.path)
  }
}
