import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../theme/instrument_theme.dart';
import '../theme/qima_colors.dart';

IconData _materialIcon(String systemImage) {
  switch (systemImage) {
    case 'circle.hexagongrid.fill':
      return Icons.hexagon;
    case 'bitcoinsign.circle.fill':
      return Icons.currency_bitcoin;
    case 'chart.line.uptrend.xyaxis':
      return Icons.show_chart;
    case 'chart.bar.xaxis':
      return Icons.bar_chart;
    case 'dollarsign.circle.fill':
      return Icons.attach_money;
    default:
      return Icons.circle;
  }
}

/// Instrument icon used in the watchlist row, detail header, and
/// add-instrument list: a soft wash of the instrument's accent with the
/// glyph in that accent.
class InstrumentIcon extends StatelessWidget {
  final Instrument? instrument;
  final double size;

  const InstrumentIcon({super.key, this.instrument, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = InstrumentTheme.accentColor(instrument, colors);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: InstrumentTheme.iconWash(accent, dark: dark), shape: BoxShape.circle),
      // Pinned LTR: some glyphs (the stocks trend line) mirror under RTL,
      // which would read as a downtrend in Arabic.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Icon(
          _materialIcon(instrument?.systemImage ?? 'dollarsign.circle.fill'),
          color: InstrumentTheme.iconGlyph(accent, colors.surfaceTop, dark: dark),
          size: size * 0.55,
        ),
      ),
    );
  }
}
