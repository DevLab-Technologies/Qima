import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android-only `FLAG_SECURE` toggle (spec Phase 4 "App lock"): prevents
/// screenshots and blanks the recents/app-switcher thumbnail whenever app
/// lock or hide-balances is on, so a portfolio amount is never captured to
/// disk or shown in a system surface outside the app itself. A no-op
/// everywhere except Android — iOS/macOS get the same protection for free
/// via [LockGate]'s privacy cover, which the OS's own snapshot mechanism
/// captures instead of the real content.
class SecureScreen {
  SecureScreen._();

  static const _channel = MethodChannel('com.devlabtechnologies.qima/privacy');

  static bool? _lastValue;

  /// Best-effort: failures (channel unavailable in tests, non-Android
  /// platforms without the handler, etc.) are swallowed rather than
  /// surfaced, since this is a defense-in-depth side effect, not a
  /// correctness-critical one.
  static Future<void> setSecure(bool secure) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (_lastValue == secure) return;
    _lastValue = secure;
    try {
      await _channel.invokeMethod<void>('setSecure', {'secure': secure});
    } catch (e, st) {
      debugPrint('SecureScreen: setSecure($secure) failed: $e\n$st');
    }
  }
}
