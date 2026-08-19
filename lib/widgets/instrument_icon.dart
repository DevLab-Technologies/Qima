import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../theme/instrument_theme.dart';

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

/// Accent-gradient-tinted instrument icon, used in the watchlist row, detail
/// header, and add-instrument list.
class InstrumentIcon extends StatelessWidget {
  final Instrument? instrument;
  final double size;

  const InstrumentIcon({super.key, this.instrument, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final gradient = InstrumentTheme.accentGradient(instrument);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
      child: Icon(
        _materialIcon(instrument?.systemImage ?? 'dollarsign.circle.fill'),
        color: Colors.black.withValues(alpha: 0.65),
        size: size * 0.55,
      ),
    );
  }
}
