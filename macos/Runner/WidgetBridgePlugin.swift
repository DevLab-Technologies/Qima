import FlutterMacOS
import Foundation
import WidgetKit

/// Hands the widget snapshot (`WidgetSnapshot` in Dart) to the macOS widget
/// extension. iOS does this through the `home_widget` plugin, which has no
/// macOS implementation, so the Mac app writes the same key to the shared
/// App Group itself and asks WidgetKit to redraw.
final class WidgetBridgePlugin: NSObject, FlutterPlugin {
  /// Must match the App Group in the Runner and QimaWidget entitlements.
  private static let appGroup = "ZS3A435WC2.com.devlabtechnologies.qima"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.devlabtechnologies.qima/widgets",
      binaryMessenger: registrar.messenger
    )
    registrar.addMethodCallDelegate(WidgetBridgePlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "saveSnapshot":
      guard let args = call.arguments as? [String: Any],
            let key = args["key"] as? String,
            let json = args["json"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      UserDefaults(suiteName: WidgetBridgePlugin.appGroup)?.set(json, forKey: key)
      if #available(macOS 11.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      result(nil)
    case "groupContainerPath":
      // Where "Let AI apps read Qima" keeps its copy (`AiApps` in Dart): the
      // sandboxed qima-mcp helper shares this group, not Qima's container.
      result(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetBridgePlugin.appGroup)?.path)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
