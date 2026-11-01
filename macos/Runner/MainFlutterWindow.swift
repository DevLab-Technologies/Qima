import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    // `CloudKVPlugin`, `SystemSettingsPlugin`, `WidgetBridgePlugin`, `DictationPlugin` and `OnDeviceModelPlugin` live directly in this target (not pub
    // packages), so `RegisterGeneratedPlugins` never picks them up — they have to
    // be registered by hand, same as any other app-target-local plugin.
    CloudKVPlugin.register(with: flutterViewController.registrar(forPlugin: "CloudKVPlugin"))
    SystemSettingsPlugin.register(with: flutterViewController.registrar(forPlugin: "SystemSettingsPlugin"))
    WidgetBridgePlugin.register(with: flutterViewController.registrar(forPlugin: "WidgetBridgePlugin"))
    DictationPlugin.register(with: flutterViewController.registrar(forPlugin: "DictationPlugin"))
    OnDeviceModelPlugin.register(with: flutterViewController.registrar(forPlugin: "OnDeviceModelPlugin"))

    super.awakeFromNib()
  }
}
