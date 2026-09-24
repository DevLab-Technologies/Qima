import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/holding.dart';
import '../theme/instrument_theme.dart';
import '../theme/qima_colors.dart';

/// One resolved slice of the portfolio allocation donut: a held instrument's
/// share of the total plus the exact color it's drawn in.
class AllocationSlice {
  final HeldInstrument holding;
  final double fraction;
  final Color color;

  const AllocationSlice({required this.holding, required this.fraction, required this.color});
}

/// Resolves one color per holding for [AllocationDonut]/the portfolio rows:
/// each holding's instrument accent (`InstrumentTheme.accentColor`), except
/// that when two or more holdings share an asset class (so they'd otherwise
/// paint identically, e.g. two custom stock tickers), every holding after
/// the first in that class is alternately lightened/darkened so slices stay
/// visually distinct (spec §v2-A "Portfolio").
List<AllocationSlice> resolveAllocation(List<HeldInstrument> holdings, QimaColors colors) {
  if (holdings.isEmpty) return const [];
  final total = holdings.fold<double>(0, (sum, h) => sum + h.valuation.value.amount.abs());

  final seenPerClass = <String, int>{};
  final slices = <AllocationSlice>[];
  for (final holding in holdings) {
    final classKey = holding.instrument.assetClass.name;
    final occurrence = seenPerClass[classKey] ?? 0;
    seenPerClass[classKey] = occurrence + 1;

    final base = InstrumentTheme.accentColor(holding.instrument, colors);
    final color = _shaded(base, occurrence);
    final fraction = total > 0 ? holding.valuation.value.amount.abs() / total : 0.0;
    slices.add(AllocationSlice(holding: holding, fraction: fraction, color: color));
  }
  return slices;
}

/// Alternates lighten/darken for successive same-class holdings: 1st extra
/// (occurrence 1) is lightened, 2nd (occurrence 2) darkened, 3rd lightened
/// again (stronger), and so on — always at least a perceptible step so
/// adjacent slices never look identical.
Color _shaded(Color base, int occurrence) {
  if (occurrence == 0) return base;
  final step = ((occurrence + 1) ~/ 2) * 0.16;
  final amount = step.clamp(0.0, 0.6);
  final hsl = HSLColor.fromColor(base);
  final lighten = occurrence.isOdd;
  final adjusted = lighten
      ? hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
      : hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return adjusted.toColor();
}

/// Portfolio allocation donut: one arc per holding, colored via
/// [resolveAllocation], with the total value centered inside the ring.
class AllocationDonut extends StatelessWidget {
  final List<AllocationSlice> slices;
  final String centerValue;
  final String centerLabel;
  final double size;
  final double strokeWidth;

  const AllocationDonut({
    super.key,
    required this.slices,
    required this.centerValue,
    required this.centerLabel,
    this.size = 140,
    this.strokeWidth = 18,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(slices: slices, strokeWidth: strokeWidth, trackColor: colors.hairline),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                centerLabel,
                style: TextStyle(color: colors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<AllocationSlice> slices;
  final double strokeWidth;
  final Color trackColor;

  _DonutPainter({required this.slices, required this.strokeWidth, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (slices.isEmpty) return;

    // Gap between slices reads as separation without a full stroke-cap gap
    // eating into small slices.
    const gapRadians = 0.02;
    var start = -math.pi / 2;
    for (final slice in slices) {
      if (slice.fraction <= 0) continue;
      final sweep = (slice.fraction * 2 * math.pi - gapRadians).clamp(0.0, 2 * math.pi);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = slice.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += slice.fraction * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.strokeWidth != strokeWidth || oldDelegate.trackColor != trackColor;
  }
}
