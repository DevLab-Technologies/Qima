import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether the mic can be offered for a language on this device.
enum DictationAvailability {
  /// On-device recognition is ready for the language.
  available,

  /// No on-device recognizer for the language (or none at all, as on web,
  /// Windows and Linux). The mic stays off: there is never a server
  /// fallback.
  unsupported,

  /// The user turned speech or microphone access off for Qima.
  denied,
}

/// One update from a running dictation.
sealed class DictationEvent {
  const DictationEvent();
}

/// What has been recognized so far; replaced by the next one.
class DictationPartial extends DictationEvent {
  final String text;
  const DictationPartial(this.text);
}

/// The final text. The session has ended.
class DictationFinal extends DictationEvent {
  final String text;
  const DictationFinal(this.text);
}

/// The session ended without a result. [denied] when a permission prompt
/// was refused.
class DictationFailed extends DictationEvent {
  final bool denied;
  const DictationFailed({this.denied = false});
}

/// Speech to text that never leaves the device (v4 phase 4). Implemented
/// natively in each runner (`DictationPlugin` on iOS and macOS,
/// `MainActivity` on Android), which requires on-device recognition and
/// reports a language as unsupported rather than falling back to a server.
abstract class DictationService {
  Future<DictationAvailability> availability(String localeTag);

  /// Starts listening in [localeTag]. The stream ends after a
  /// [DictationFinal] or [DictationFailed].
  Stream<DictationEvent> listen(String localeTag);

  /// Stops listening; the stream then delivers what was heard.
  Future<void> stop();
}

/// For platforms and tests without dictation.
class NoDictation implements DictationService {
  const NoDictation();

  @override
  Future<DictationAvailability> availability(String localeTag) async => DictationAvailability.unsupported;

  @override
  Stream<DictationEvent> listen(String localeTag) => const Stream.empty();

  @override
  Future<void> stop() async {}
}

class PlatformDictation implements DictationService {
  const PlatformDictation();

  static const _methods = MethodChannel('com.devlabtechnologies.qima/dictation');
  static const _events = EventChannel('com.devlabtechnologies.qima/dictation/events');

  @override
  Future<DictationAvailability> availability(String localeTag) async {
    if (kIsWeb) return DictationAvailability.unsupported;
    try {
      final value = await _methods.invokeMethod<String>('availability', {'locale': localeTag});
      return DictationAvailability.values.asNameMap()[value] ?? DictationAvailability.unsupported;
    } on MissingPluginException {
      return DictationAvailability.unsupported;
    } on PlatformException catch (e) {
      debugPrint('Dictation: availability failed: $e');
      return DictationAvailability.unsupported;
    }
  }

  @override
  Stream<DictationEvent> listen(String localeTag) {
    final controller = StreamController<DictationEvent>();
    StreamSubscription<dynamic>? subscription;
    controller.onListen = () {
      subscription = _events.receiveBroadcastStream({'locale': localeTag}).listen(
        (raw) {
          final event = Map<String, Object?>.from(raw as Map);
          final text = event['text'] as String? ?? '';
          switch (event['type']) {
            case 'partial':
              controller.add(DictationPartial(text));
            case 'final':
              controller.add(DictationFinal(text));
              controller.close();
            default:
              controller.add(DictationFailed(denied: event['code'] == 'denied'));
              controller.close();
          }
        },
        onError: (Object e) {
          debugPrint('Dictation: $e');
          controller.add(const DictationFailed());
          controller.close();
        },
        onDone: () {
          if (!controller.isClosed) controller.close();
        },
      );
    };
    controller.onCancel = () => subscription?.cancel();
    return controller.stream;
  }

  @override
  Future<void> stop() async {
    try {
      await _methods.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Nothing was listening.
    } on PlatformException catch (e) {
      debugPrint('Dictation: stop failed: $e');
    }
  }
}

/// The recognizer locale for the app's [language]: the device's own region
/// for that language when it has one ("ar-EG" on an Egyptian phone), else a
/// common default.
String dictationLocaleTag(Locale language) {
  for (final device in PlatformDispatcher.instance.locales) {
    if (device.languageCode == language.languageCode && device.countryCode != null) {
      return '${device.languageCode}-${device.countryCode}';
    }
  }
  const defaults = {'en': 'en-US', 'ar': 'ar-SA', 'es': 'es-ES', 'fr': 'fr-FR'};
  return defaults[language.languageCode] ?? language.toLanguageTag();
}
