import Cocoa
import FlutterMacOS

/// Opens Qima's entry in System Settings › Notifications for `SystemSettings`
/// (Dart).
final class SystemSettingsPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.devlabtechnologies.qima/system_settings",
      binaryMessenger: registrar.messenger
    )
    registrar.addMethodCallDelegate(SystemSettingsPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "openNotificationSettings" else {
      result(FlutterMethodNotImplemented)
      return
    }
    let bundleID = Bundle.main.bundleIdentifier ?? ""
    if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleID)") {
      NSWorkspace.shared.open(url)
    }
    result(nil)
  }
}
