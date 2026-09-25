import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Fired with the tapped notification's payload (a `WatchCard.id`) whenever a
/// notification is tapped — foreground, background, or the app is
/// cold-started by the tap. `main.dart` listens on this and drives
/// navigation once the app (and `LockGate`) are ready, so a locked app still
/// gates the deep link behind authentication rather than skipping straight to
/// the instrument (spec Phase 5 "notification-tap navigation ... Phase 4
/// LockGate must still gate it").
final StreamController<String> notificationTapPayloads = StreamController<String>.broadcast();

/// Top-level so it survives tree-shaking as the background isolate's
/// notification-tap entry point (required by `flutter_local_notifications`
/// for taps that wake a background isolate rather than the running app).
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null && payload.isNotEmpty) {
    notificationTapPayloads.add(payload);
  }
}

/// Thin wrapper over `flutter_local_notifications`: permission plumbing and
/// showing the one notification shape this app needs (spec Phase 5). No
/// scheduling — every notification is shown immediately, in direct response
/// to an alert firing during a refresh (foreground or background), so none
/// of the zonedSchedule/timezone machinery is needed.
class NotificationService {
  static const _channelId = 'price_alerts';
  static const _channelName = 'Price alerts';
  static const _channelDescription = 'Notifies you when a price alert you set is triggered.';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin}) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );
    // Like every other method here, never throws: app startup and the
    // background refresh both await this, and a notification setup failure
    // (e.g. a missing small icon) must only cost notifications, not leave
    // the app stuck on its loading screen.
    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            notificationTapPayloads.add(payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );
      _initialized = true;
    } catch (e, st) {
      debugPrint('NotificationService: initialize failed: $e\n$st');
    }
  }

  /// The payload (a `WatchCard.id`) of the notification that cold-launched
  /// the app, if any — checked once at startup so a tap that launches the
  /// app from scratch (not just resumes/backgrounds it) still deep-links.
  Future<String?> consumeLaunchPayload() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return details.notificationResponse?.payload;
    } catch (e, st) {
      debugPrint('NotificationService: getNotificationAppLaunchDetails failed: $e\n$st');
      return null;
    }
  }

  /// Requests permission to show notifications. Returns whether it's
  /// granted (or was already). Safe to call repeatedly — Android/iOS both
  /// no-op if already decided (Android may re-prompt only via OS settings
  /// once denied).
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? await isEnabled();
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
      final macos = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      if (macos != null) {
        final granted = await macos.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
      // No platform-specific implementation resolved (e.g. Linux, Web,
      // Windows, or a unit test with no plugin binding): treat as granted
      // rather than permanently blocking alerts on platforms with no
      // permission gate at all.
      return true;
    } catch (e, st) {
      debugPrint('NotificationService: requestPermission failed: $e\n$st');
      return false;
    }
  }

  /// Best-effort permission status query, used by the Alerts screen's
  /// "Notifications are off" banner. Returns true (rather than false) when
  /// the platform has no meaningful concept of it, so that banner doesn't
  /// show incorrectly on those platforms.
  Future<bool> isEnabled() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? true;
      }
      return true;
    } catch (e, st) {
      debugPrint('NotificationService: isEnabled check failed: $e\n$st');
      return true;
    }
  }

  /// Shows a single notification. [id] should be stable-but-distinct per
  /// alert (the caller passes a hash of the alert id) so a repeat alert
  /// firing again updates/replaces its own tray entry instead of stacking
  /// duplicates. [payload] is the `WatchCard.id` to navigate to on tap.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: darwinDetails, macOS: darwinDetails);
    try {
      await _plugin.show(id: id, title: title, body: body, notificationDetails: details, payload: payload);
    } catch (e, st) {
      // A notification failing to display must never crash a refresh —
      // it's a side effect of an otherwise-successful price update.
      debugPrint('NotificationService: show failed: $e\n$st');
    }
  }
}

/// Stable per-alert notification id: Android/iOS notification ids are 32-bit
/// ints, so this hashes the alert id down instead of using it directly.
///
/// Uses SHA-256 rather than [String.hashCode] deliberately — `hashCode` is
/// documented as NOT stable across isolates or separate program runs (only
/// within one running instance), which would break the "a repeat alert
/// firing again replaces its own tray entry instead of stacking duplicates"
/// behavior the moment the SAME alert fires once from the foreground app and
/// once from the background isolate (two completely separate Dart VM
/// instances), or even across two consecutive background task runs.
/// SHA-256 of the id's UTF-8 bytes is deterministic everywhere. Masked
/// positive (`& 0x7fffffff`) since some platforms choke on negative
/// notification ids.
int notificationIdFor(String alertId) {
  final digest = sha256.convert(utf8.encode(alertId));
  final firstFourBytes = digest.bytes.sublist(0, 4);
  final value = firstFourBytes.fold<int>(0, (acc, byte) => (acc << 8) | byte);
  return value & 0x7fffffff;
}
