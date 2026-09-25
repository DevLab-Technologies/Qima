import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Opens the operating system's settings for this app. Implemented natively
/// in each runner (`SystemSettingsPlugin` on iOS/macOS, `MainActivity` on
/// Android); platforms without an implementation do nothing.
class SystemSettings {
  SystemSettings._();

  static const _channel = MethodChannel('com.devlabtechnologies.qima/system_settings');

  /// Qima's notification settings page, or its general settings page where
  /// the OS has no direct link to the notification one.
  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod<void>('openNotificationSettings');
    } on MissingPluginException {
      // Windows, Linux and web have no per-app notification settings page.
    } on PlatformException catch (e) {
      debugPrint('SystemSettings: openNotificationSettings failed: $e');
    }
  }
}
