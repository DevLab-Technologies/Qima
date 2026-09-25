import Flutter
import UIKit

/// Opens Qima's page in the Settings app for `SystemSettings` (Dart) — the
/// notification settings directly on iOS 16+, the app's settings before that.
final class SystemSettingsPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.devlabtechnologies.qima/system_settings",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(SystemSettingsPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "openNotificationSettings" else {
      result(FlutterMethodNotImplemented)
      return
    }
    let link: String
    if #available(iOS 16.0, *) {
      link = UIApplication.openNotificationSettingsURLString
    } else {
      link = UIApplication.openSettingsURLString
    }
    guard let url = URL(string: link) else {
      result(nil)
      return
    }
    UIApplication.shared.open(url) { _ in result(nil) }
  }
}
