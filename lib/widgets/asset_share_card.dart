import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/display_point.dart';
import '../models/share_format.dart';
import '../theme/app_theme.dart';
import '../theme/design_system.dart';
import '../theme/instrument_theme.dart';
import '../theme/price_chart.dart';
import '../theme/qima_colors.dart';
import 'instrument_icon.dart';

/// Everything the share card prints, already localized and formatted, so
/// the card is a pure layout and the caption reads from the same values.
class AssetShareData {
  final Instrument instrument;
  final String name;

  /// "XAU · USD / oz"
  final String detailLine;
  final String price;

  /// Signed "+5.26%", or null when the range has no change yet.
  final String? changeLabel;
  final bool isUp;

  /// "3 months"
  final String rangeLabel;

  /// "Oct 28, 2026"
  final String dateLabel;
  final List<DisplayPoint> points;

  const AssetShareData({
    required this.instrument,
    required this.name,
    required this.detailLine,
    required this.price,
    required this.changeLabel,
    required this.isUp,
    required this.rangeLabel,
    required this.dateLabel,
    required this.points,
  });
}

/// The shared-image template: the Qima mark and date, the asset, its price
/// and change over the chosen range, the chart, and the site. Always drawn
/// in the dark palette whatever the app's theme, so every shared image
/// looks like Qima. Lays out at a fixed logical size per [format]; the
/// caller scales it to the format's pixel size when capturing.
class AssetShareCard extends StatelessWidget {
  final AssetShareData data;
  final ShareFormat format;

  /// The site printed in the footer.
  final String siteLabel;

  const AssetShareCard({super.key, required this.data, required this.format, required this.siteLabel});

  /// Logical size the card lays out at; [ShareFormat.widthPx] divided by
  /// this width is the capture pixel ratio.
  static Size logicalSize(ShareFormat format) =>
      format == ShareFormat.landscape ? Size(600, 600 / format.aspectRatio) : Size(360, 360 / format.aspectRatio);

  @override
  Widget build(BuildContext context) {
    final size = logicalSize(format);
    return Theme(
      data: buildTheme(Brightness.dark, locale: Localizations.maybeLocaleOf(context)),
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final accent = InstrumentTheme.accentColor(data.instrument, colors);
          return SizedBox.fromSize(
            size: size,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: DS.backgroundGradient(colors)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: AlignmentDirectional.topEnd.resolve(Directionality.of(context)),
                          radius: 1.1,
                          colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(format == ShareFormat.story ? DS.spaceXL : DS.spaceLG),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: colors.textPrimary),
                      child: format == ShareFormat.landscape
                          ? _landscape(context, colors, accent)
                          : _vertical(context, colors, accent),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _vertical(BuildContext context, QimaColors colors, Color accent) {
    final story = format == ShareFormat.story;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _brandRow(context, colors),
        if (story) const Spacer(flex: 2) else const SizedBox(height: DS.spaceLG),
        _assetHeader(colors, iconSize: story ? 48 : 36, nameSize: story ? 22 : 17),
        SizedBox(height: story ? DS.spaceLG : DS.spaceSM),
        _priceBlock(colors, priceSize: story ? 40 : (format == ShareFormat.square ? 30 : 34)),
        SizedBox(height: story ? DS.spaceLG : DS.spaceSM),
        Expanded(flex: story ? 6 : 1, child: _chart(colors)),
        if (story) const Spacer(),
        const SizedBox(height: DS.spaceSM),
        _footer(colors),
      ],
    );
  }

  Widget _landscape(BuildContext context, QimaColors colors, Color accent) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _brandRow(context, colors, showDate: false),
              const Spacer(),
              _assetHeader(colors, iconSize: 36, nameSize: 18),
              const SizedBox(height: DS.spaceSM),
              _priceBlock(colors, priceSize: 32),
              const Spacer(),
              _footer(colors, showDate: true),
            ],
          ),
        ),
        const SizedBox(width: DS.spaceMD),
        Expanded(flex: 6, child: _chart(colors)),
      ],
    );
  }

  Widget _brandRow(BuildContext context, QimaColors colors, {bool showDate = true}) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.asset('assets/icon/app_icon.png', width: 26, height: 26),
        ),
        const SizedBox(width: DS.spaceXS),
        Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
        ),
        if (showDate) ...[
          const Spacer(),
          Text(data.dateLabel, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _assetHeader(QimaColors colors, {required double iconSize, required double nameSize}) {
    return Row(
      children: [
        InstrumentIcon(instrument: data.instrument, size: iconSize),
        const SizedBox(width: DS.spaceSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: nameSize, fontWeight: FontWeight.w700),
              ),
              Text(
                data.detailLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceBlock(QimaColors colors, {required double priceSize}) {
    final trend = QimaColors.trendColor(data.isUp, colors);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(data.price, style: TextStyle(fontSize: priceSize, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: DS.space2XS),
        Row(
          children: [
            if (data.changeLabel != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: 3),
                decoration: BoxDecoration(
                  color: trend.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DS.radiusPill),
                ),
                child: Text(
                  data.changeLabel!,
                  style: TextStyle(color: trend, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: DS.spaceXS),
            ],
            Flexible(
              child: Text(
                data.rangeLabel,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chart(QimaColors colors) {
    if (data.points.length < 2) return const SizedBox.shrink();
    return PriceChartView(
      points: data.points,
      isTrendingUp: data.isUp,
      accent: QimaColors.trendColor(data.isUp, colors),
      showsAxes: false,
      lineWidth: 3,
    );
  }

  /// The site; the landscape card, whose top row is too narrow for it,
  /// also carries the date here.
  Widget _footer(QimaColors colors, {bool showDate = false}) {
    return Text(
      showDate ? '${data.dateLabel} · $siteLabel' : siteLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}
