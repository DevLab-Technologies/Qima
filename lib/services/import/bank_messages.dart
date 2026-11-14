import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// How bank text messages reach Qima on this device.
enum BankMessagesWay {
  /// Android: Qima reads new money messages itself once allowed.
  readSms,

  /// iOS: a Shortcuts automation sends each message to Qima's "Add a bank
  /// message" action; apps can't read messages themselves.
  shortcutsAutomation,

  /// Nowhere else.
  none,
}

/// Whether Qima reads new bank messages, and whether it may.
typedef BankMessagesStatus = ({bool granted, bool enabled});

/// Bank text messages into the import inbox, where the person checks each
/// one in review like a shared file. On Android Qima reads them on its own
/// once allowed: as they arrive, and on each open for any it missed. Messages without a figure and a
/// currency or banking word, and one-time codes, are never kept
/// (`BankSms.kt`); one with no transaction is dropped after reading.
class BankMessages {
  const BankMessages._();

  @visibleForTesting
  static const sms = MethodChannel('com.devlabtechnologies.qima/sms');
  static const _inbox = MethodChannel('com.devlabtechnologies.qima/share_inbox');

  static BankMessagesWay get way => kIsWeb
      ? BankMessagesWay.none
      : switch (defaultTargetPlatform) {
          TargetPlatform.android => BankMessagesWay.readSms,
          TargetPlatform.iOS => BankMessagesWay.shortcutsAutomation,
          _ => BankMessagesWay.none,
        };

  static Future<BankMessagesStatus> status() => _call('status');

  /// Asks for the SMS permission where needed, then reads new messages.
  static Future<BankMessagesStatus> enable() => _call('enable');

  static Future<BankMessagesStatus> disable() => _call('disable');

  /// Money messages from the last [days] days into the inbox; how many.
  static Future<int> importRecent({int days = 60}) async {
    try {
      return await sms.invokeMethod<int>('importRecent', {'days': days}) ?? 0;
    } on MissingPluginException {
      return 0;
    } on PlatformException catch (e) {
      debugPrint('BankMessages: $e');
      return 0;
    }
  }

  /// Messages that came since Qima last looked and weren't kept as they
  /// arrived (Android); how many. Called each time Qima opens.
  static Future<int> catchUp() async {
    if (way != BankMessagesWay.readSms) return 0;
    try {
      return await sms.invokeMethod<int>('catchUp') ?? 0;
    } on MissingPluginException {
      return 0;
    } on PlatformException catch (e) {
      debugPrint('BankMessages: $e');
      return 0;
    }
  }

  /// Takes down the "Bank messages to check" notification (Android).
  static Future<void> clearNotification() => _quiet('clearNotification');

  /// The notification's words in the app's language (Android).
  static Future<void> setNotificationText({required String title, required String body}) =>
      _quiet('setNotificationText', {'title': title, 'body': body});

  /// Calls [onOpen] when the person taps the "Bank messages to check"
  /// notification, including the tap that launched Qima.
  static Future<void> listenForOpen(void Function() onOpen) async {
    if (way != BankMessagesWay.readSms) return;
    sms.setMethodCallHandler((call) async {
      if (call.method != 'openReview') return null;
      onOpen();
      return true;
    });
    try {
      if (await sms.invokeMethod<bool>('takeOpenReview') == true) onOpen();
    } on MissingPluginException {
      // Not on this platform.
    } on PlatformException catch (e) {
      debugPrint('BankMessages: $e');
    }
  }

  static Future<void> _quiet(String method, [Object? arguments]) async {
    if (way != BankMessagesWay.readSms) return;
    try {
      await sms.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // Not on this platform.
    } on PlatformException catch (e) {
      debugPrint('BankMessages: $e');
    }
  }

  /// The Shortcuts app, to set up the automation (iOS).
  static Future<void> openShortcuts() async {
    try {
      await _inbox.invokeMethod<void>('openShortcuts');
    } on MissingPluginException {
      // Nothing to open here.
    } on PlatformException catch (e) {
      debugPrint('BankMessages: $e');
    }
  }

  static Future<BankMessagesStatus> _call(String method) async {
    try {
      final m = await sms.invokeMapMethod<String, Object?>(method) ?? const {};
      return (granted: m['granted'] == true, enabled: m['enabled'] == true);
    } on MissingPluginException {
      return (granted: false, enabled: false);
    } on PlatformException catch (e) {
      debugPrint('BankMessages: $e');
      return (granted: false, enabled: false);
    }
  }
}
