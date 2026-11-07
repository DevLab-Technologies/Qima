import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One thing pasted: a statement file, a table, text such as a bank
/// message, or a screenshot.
typedef PastedFile = ({String? name, String extension, Uint8List bytes});

/// What is on the clipboard, imported like a picked file: a statement or
/// receipt copied in Files or Mail, a copied bank message, or a screenshot
/// copied from the screenshot editor.
///
/// iOS refuses a paste the app starts from code, so the content comes
/// through the system Paste button ([button]): tapping it is the person's
/// own paste. Only iOS has it for now; elsewhere [available] is false and
/// the option doesn't show.
class PastedFiles {
  const PastedFiles._();

  static const channel = MethodChannel('com.devlabtechnologies.qima/share_inbox');

  /// Where the Paste button sends what was pasted ("pasted": a list of
  /// `{name?, ext, bytes}`).
  static const pastes = MethodChannel('com.devlabtechnologies.qima/paste');

  static const _buttonView = 'com.devlabtechnologies.qima/paste_button';

  /// Whether the clipboard holds something the import reads. Asking shows
  /// no prompt.
  static Future<bool> available() async {
    try {
      return await channel.invokeMethod<bool>('hasPastedFile') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('PastedFiles: $e');
      return false;
    }
  }

  /// Calls [onPaste] with what is pasted through [button], until
  /// [stopListening].
  static void listen(void Function(List<PastedFile> files) onPaste) {
    pastes.setMethodCallHandler((call) async {
      if (call.method != 'pasted' || call.arguments is! List) return;
      final files = [
        for (final item in call.arguments as List)
          if (item is Map && item['bytes'] is Uint8List && item['ext'] is String)
            (name: item['name'] as String?, extension: item['ext'] as String, bytes: item['bytes'] as Uint8List),
      ];
      if (files.isNotEmpty) onPaste(files);
    });
  }

  static void stopListening() => pastes.setMethodCallHandler(null);

  /// The system Paste button in the app's [background] and [foreground];
  /// nothing where there is none.
  static Widget button({required Color background, required Color foreground}) => defaultTargetPlatform == TargetPlatform.iOS
      ? SizedBox(
          width: 112,
          height: 40,
          child: UiKitView(
            // A new view when the colours change (light and dark).
            key: ValueKey((background, foreground)),
            viewType: _buttonView,
            creationParams: {'background': background.toARGB32(), 'foreground': foreground.toARGB32()},
            creationParamsCodec: const StandardMessageCodec(),
          ),
        )
      : const SizedBox.shrink();
}
