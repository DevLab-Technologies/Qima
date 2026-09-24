import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    // `CloudKVPlugin` lives directly in this target (it's not a pub
    // package), so `RegisterGeneratedPlugins` never picks it up — it has to
    // be registered by hand, same as any other app-target-local plugin.
    CloudKVPlugin.register(with: flutterViewController.registrar(forPlugin: "CloudKVPlugin"))

    super.awakeFromNib()
  }
}
