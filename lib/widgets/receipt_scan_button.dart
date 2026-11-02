import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../services/dictation_service.dart';
import '../services/text_recognition_service.dart';
import '../theme/qima_colors.dart';

/// Scan a receipt into the Add field (v4 phase 7): take or pick a photo,
/// read its text on the device, and put it in the field as if typed, where
/// the typed-capture flow reads it. Hidden where on-device text
/// recognition isn't available.
class ReceiptScanButton extends StatefulWidget {
  final ValueChanged<String> onText;

  /// Picks the photo; replaced in tests.
  final Future<String?> Function(BuildContext context)? pickImage;

  const ReceiptScanButton({super.key, required this.onText, this.pickImage});

  @override
  State<ReceiptScanButton> createState() => _ReceiptScanButtonState();
}

class _ReceiptScanButtonState extends State<ReceiptScanButton> {
  bool _available = false;
  bool _reading = false;

  TextRecognitionService get _service => context.read<AppCubit>().textRecognition;

  @override
  void initState() {
    super.initState();
    _service.isAvailable().then((value) {
      if (mounted) setState(() => _available = value);
    });
  }

  Future<String?> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final l10n = AppLocalizations.of(context)!;
    final source = picker.supportsImageSource(ImageSource.camera)
        ? await showModalBottomSheet<ImageSource>(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: Text(l10n.receiptTakePhoto),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: Text(l10n.receiptChoosePhoto),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          )
        : ImageSource.gallery;
    if (source == null) return null;
    final file = await picker.pickImage(source: source);
    return file?.path;
  }

  Future<void> _scan() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final language = dictationLocaleTag(Localizations.localeOf(context));
    final path = await (widget.pickImage ?? _pick)(context);
    if (path == null || !mounted) return;
    setState(() => _reading = true);
    final lines = await _service.recognize(path, [language, 'en-US']);
    if (!mounted) return;
    setState(() => _reading = false);
    final text = lines == null ? '' : receiptText(lines);
    if (text.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(persist: false, content: Text(l10n.receiptNoText)));
      return;
    }
    widget.onText(text);
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    if (_reading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return IconButton(
      icon: Icon(Icons.document_scanner_outlined, color: colors.textSecondary),
      tooltip: l10n.receiptScan,
      onPressed: _scan,
    );
  }
}
