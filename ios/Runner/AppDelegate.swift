import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // BGTaskScheduler requires every launch handler to be (re-)registered
    // before this method returns, or a cold relaunch the OS uses to deliver
    // a previously-scheduled background task crashes with "All launch
    // handlers must be registered before application finishes launching".
    //
    // Under this app's UIScene/implicit-engine setup (see
    // `didInitializeImplicitFlutterEngine` below), `GeneratedPluginRegistrant`
    // — and therefore `WorkmanagerPlugin`'s own application-delegate hook
    // that normally does this automatically — doesn't run until AFTER
    // `didFinishLaunchingWithOptions` returns (Flutter defers plugin
    // registration to `scene:willConnectToSession:` under UIScene). That is
    // too late for BGTaskScheduler, so this calls the plugin's public,
    // early-registration entry point directly instead, exactly as Flutter's
    // own UIScene migration guide recommends for plugins with a
    // must-run-before-launch-completes API. See the Phase 5 implementation
    // report for the full chain of reasoning.
    WorkmanagerPlugin.registerLaunchHandlers()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // `CloudKVPlugin` lives directly in this target (it's not a pub
    // package), so `GeneratedPluginRegistrant` never picks it up — it has to
    // be registered by hand, same as any other app-target-local plugin.
    CloudKVPlugin.register(with: engineBridge.pluginRegistry.registrar(forPlugin: "CloudKVPlugin")!)
  }
}
