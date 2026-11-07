import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// An image on the clipboard, such as a screenshot of a banking app copied
/// from the screenshot editor, to import like a picked photo.
///
/// iOS refuses a paste the app starts from code, so the image comes through
/// the system Paste button ([button]): tapping it is the person's own paste.
/// Only iOS has it for now; elsewhere [hasImage] is false and the option
/// doesn't show.
class PastedImage {
  const PastedImage._();

  static const channel = MethodChannel('com.devlabtechnologies.qima/share_inbox');

  /// Where the Paste button sends the image ("pasted", PNG bytes).
  static const pastes = MethodChannel('com.devlabtechnologies.qima/paste');

  static const _buttonView = 'com.devlabtechnologies.qima/paste_button';

  /// Whether the clipboard holds an image. Asking shows no prompt.
  static Future<bool> hasImage() async {
    try {
      return await channel.invokeMethod<bool>('hasPastedImage') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('PastedImage: $e');
      return false;
    }
  }

  /// Calls [onImage] with each image pasted through [button], until
  /// [stopListening].
  static void listen(void Function(Uint8List png) onImage) {
    pastes.setMethodCallHandler((call) async {
      if (call.method == 'pasted' && call.arguments is Uint8List) onImage(call.arguments as Uint8List);
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
