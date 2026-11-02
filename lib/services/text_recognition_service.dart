import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads the text in a photo on the device (v4 phase 7, receipt scan).
/// Implemented with Apple's Vision in the iOS and macOS runners
/// (`TextRecognitionPlugin`). Android's only on-device route is ML Kit,
/// which brings Google's usage logging, so Android, web, Windows and Linux
/// report unavailable and the scan button stays hidden.
abstract class TextRecognitionService {
  Future<bool> isAvailable();

  /// The image's lines, top to bottom, recognized in [languageTags] first;
  /// null when it couldn't be read.
  Future<List<String>?> recognize(String imagePath, List<String> languageTags);
}

class NoTextRecognition implements TextRecognitionService {
  const NoTextRecognition();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<List<String>?> recognize(String imagePath, List<String> languageTags) async => null;
}

class PlatformTextRecognition implements TextRecognitionService {
  const PlatformTextRecognition();

  static const _channel = MethodChannel('com.devlabtechnologies.qima/text_recognition');

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('TextRecognition: isAvailable failed: $e');
      return false;
    }
  }

  @override
  Future<List<String>?> recognize(String imagePath, List<String> languageTags) async {
    try {
      return await _channel.invokeListMethod<String>('recognize', {'path': imagePath, 'languages': languageTags});
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('TextRecognition: recognize failed: $e');
      return null;
    }
  }
}

/// A receipt's lines as one line of text for the Add field: blank lines
/// dropped, the rest joined with " · " so each stays a separate phrase for
/// the parser.
String receiptText(List<String> lines) => lines.map((l) => l.trim()).where((l) => l.isNotEmpty).join(' · ');
