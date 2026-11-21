import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// One side of a [SplitDonut]: its name, its size, the figure shown for
/// it, and its color.
class DonutPart {
  final String label;
  final double value;
  final String figure;
  final Color color;

  const DonutPart({required this.label, required this.value, required this.figure, required this.color});
}

/// A ring split between a few parts (owned and owed, lent and borrowed),
/// the net in the middle and each part's figure beside it.
class SplitDonut extends StatelessWidget {
  final List<DonutPart> parts;
  final String centerValue;
  final String centerLabel;
  final double size;

  const SplitDonut({super.key, required this.parts, required this.centerValue, required this.centerLabel, this.size = 112});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: Size.square(size), painter: _RingPainter(parts: parts, track: colors.hairline, stroke: size * 0.11)),
              Padding(
                padding: EdgeInsets.all(size * 0.17),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(centerValue, maxLines: 1, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    Text(centerLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textTertiary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DS.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final p in parts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
                    const SizedBox(width: DS.spaceXS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.label, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(p.figure, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<DonutPart> parts;
  final Color track;
  final double stroke;

  _RingPainter({required this.parts, required this.track, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    Paint pen(Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = c;
    canvas.drawArc(rect, 0, 2 * math.pi, false, pen(track));
    final total = parts.fold(0.0, (s, p) => s + p.value.abs());
    if (total <= 0) return;
    final shown = parts.where((p) => p.value != 0).length;
    final gap = shown > 1 ? 0.03 : 0.0;
    var start = -math.pi / 2;
    for (final p in parts) {
      final sweep = p.value.abs() / total * 2 * math.pi;
      if (sweep <= 0) continue;
      canvas.drawArc(rect, start + gap / 2, math.max(0, sweep - gap), false, pen(p.color));
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.parts != parts || old.track != track || old.stroke != stroke;
}
