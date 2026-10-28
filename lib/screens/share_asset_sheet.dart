import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart' show getSaveLocation;
import 'package:flutter/foundation.dart' show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/chart_range.dart';
import '../models/share_format.dart';
import '../models/watch_card.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/asset_share_card.dart';

/// The site the shared image and caption point people to.
const String qimaSiteLabel = 'qima.devlabtechnologies.com';
const String qimaSiteUrl = 'https://qima.devlabtechnologies.com/';

/// The text that goes with a shared asset image: price and change, then
/// where it came from.
String assetShareCaption(AppLocalizations l10n, AssetShareData data) {
  // Isolated left-to-right so "$4,041.10" doesn't come out as "4,041.10$"
  // inside Arabic text (the change is already isolated by signedFigure).
  final price = '\u2066${data.price}\u2069';
  final headline = data.changeLabel == null
      ? l10n.shareCaption(data.name, price)
      : l10n.shareCaptionWithChange(data.name, price, data.changeLabel!, data.rangeLabel);
  return '$headline\n${l10n.shareCaptionFooter(qimaSiteUrl)}';
}

/// "Share" sheet for one watchlist asset: pick where it's going (which sets
/// the image shape), see the image and caption, then share both through
/// the system share sheet. The caption is also copied, since Instagram
/// and Facebook drop text that comes with an image.
class ShareAssetSheet extends StatefulWidget {
  final WatchCard card;
  final ChartRange range;

  const ShareAssetSheet({super.key, required this.card, required this.range});

  static Future<void> show(BuildContext context, {required WatchCard card, required ChartRange range}) {
    final colors = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DS.radiusCard)),
      ),
      builder: (_) => ShareAssetSheet(card: card, range: range),
    );
  }

  @override
  State<ShareAssetSheet> createState() => _ShareAssetSheetState();
}

class _ShareAssetSheetState extends State<ShareAssetSheet> {
  final _captureKey = GlobalKey();
  final _shareButtonKey = GlobalKey();
  ShareDestination _destination = ShareDestination.whatsappMessage;
  bool _working = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The card's logo must be decoded before the first capture.
    precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
  }

  AssetShareData _data(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final presentation = cubit.presentation(widget.card);
    final now = DateTime.now();
    final change = presentation.change(widget.range, now);
    final unit = presentation.unitSuffix;
    final locale = Localizations.localeOf(context).toString();
    return AssetShareData(
      instrument: presentation.instrument,
      name: displayLabel(context, presentation.instrument.nameKey),
      detailLine: '${presentation.symbol} · ${presentation.displayCurrency}'
          '${unit != null ? ' / ${displayLabel(context, unit)}' : ''}',
      price: presentation.latestPrice,
      changeLabel: change == null
          ? null
          : signedFigure('${(change.percentValue * 100).toStringAsFixed(2)}%', isUp: change.isUp),
      isUp: change?.isUp ?? presentation.isTrendingUp,
      rangeLabel: displayLabel(context, widget.range.labelKey),
      dateLabel: DateFormat.yMMMd(locale).format(now),
      points: widget.range.filter(presentation.points, now),
    );
  }

  String _destinationLabel(AppLocalizations l10n, ShareDestination destination) => switch (destination) {
        ShareDestination.whatsappMessage => l10n.shareToWhatsappMessage,
        ShareDestination.whatsappStatus => l10n.shareToWhatsappStatus,
        ShareDestination.instagramPost => l10n.shareToInstagramPost,
        ShareDestination.instagramStory => l10n.shareToInstagramStory,
        ShareDestination.facebookPost => l10n.shareToFacebookPost,
        ShareDestination.facebookStory => l10n.shareToFacebookStory,
        ShareDestination.linkedinPost => l10n.shareToLinkedinPost,
      };

  Future<void> _share(BuildContext context, AssetShareData data) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final format = _destination.format;
    setState(() => _working = true);
    try {
      final boundary = _captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: format.widthPx / AssetShareCard.logicalSize(format).width);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      image.dispose();

      final caption = assetShareCaption(l10n, data);
      final filename = 'qima-${data.instrument.symbol.toLowerCase()}-${format.name}.png';
      final file = XFile.fromData(bytes, mimeType: 'image/png', name: filename);
      await Clipboard.setData(ClipboardData(text: caption));

      // share_plus can't hand files to other apps on Linux, so the image
      // is saved there instead (the caption is already on the clipboard).
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
        final location = await getSaveLocation(suggestedName: filename);
        if (location == null) return;
        await file.saveTo(location.path);
      } else {
        final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [file],
            fileNameOverrides: [filename],
            text: _destination.sendsCaption ? caption : null,
            sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
            downloadFallbackEnabled: kIsWeb,
          ),
        );
        if (result.status == ShareResultStatus.dismissed) return;
      }
      if (context.mounted) Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareCaptionCopied)));
    } catch (e, st) {
      debugPrint('ShareAssetSheet: share failed: $e\n$st');
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final data = _data(context);
    final format = _destination.format;
    final size = AssetShareCard.logicalSize(format);
    final screen = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceMD, DS.spaceMD, DS.spaceMD),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.shareTitle(data.name),
                style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: DS.spaceSM),
              Wrap(
                spacing: DS.spaceXS,
                runSpacing: DS.spaceXS,
                children: [
                  for (final destination in ShareDestination.values)
                    DSChoiceChip(
                      label: _destinationLabel(l10n, destination),
                      selected: destination == _destination,
                      onSelected: (_) => setState(() => _destination = destination),
                    ),
                ],
              ),
              const SizedBox(height: DS.spaceMD),
              // The preview is the image itself, scaled to fit: what's
              // captured is exactly what's shown.
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screen.height * 0.42, maxWidth: 420),
                  child: AspectRatio(
                    aspectRatio: format.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DS.radiusTile),
                      child: FittedBox(
                        child: RepaintBoundary(
                          key: _captureKey,
                          child: SizedBox.fromSize(
                            size: size,
                            child: AssetShareCard(data: data, format: format, siteLabel: qimaSiteLabel),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DS.space2XS),
              Text(
                '${format.ratioLabel} · ${format.widthPx}×${format.heightPx}',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: DS.spaceMD),
              DSCard(
                child: SelectableText(
                  assetShareCaption(l10n, data),
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: DS.spaceMD),
              FilledButton.icon(
                key: _shareButtonKey,
                onPressed: _working ? null : () => _share(context, data),
                icon: _working
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.adaptive.share),
                label: Text(l10n.shareAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
