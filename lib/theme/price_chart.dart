import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../models/display_point.dart';
import '../models/money.dart';
import '../services/chart_sampling.dart';
import '../services/scrub_resolver.dart';
import 'design_system.dart';

// Re-exported so callers only need to import price_chart.dart for the
// granularity/resolver types used alongside the chart.
export '../services/scrub_resolver.dart' show AxisGranularity, ScrubResolver;

/// Maximum points actually drawn — the full series is first thinned via
/// [ChartSampling.thinned] (spec §3.3).
const int maxDrawnPoints = 250;

/// Price chart matching `PriceChartView.swift` (spec §3.3): an area+line
/// mark with a smooth (Catmull-Rom-equivalent) curve, optional axes, and
/// optional drag-to-scrub interaction.
class PriceChartView extends StatefulWidget {
  final List<DisplayPoint> points;
  final bool isTrendingUp;
  final Color accent;
  final bool showsAxes;
  final double lineWidth;
  final bool isInteractive;
  final String? currencyCode;

  const PriceChartView({
    super.key,
    required this.points,
    required this.isTrendingUp,
    required this.accent,
    this.showsAxes = true,
    this.lineWidth = 2.5,
    this.isInteractive = false,
    this.currencyCode,
  });

  @override
  State<PriceChartView> createState() => _PriceChartViewState();
}

class _PriceChartViewState extends State<PriceChartView> {
  DisplayPoint? _scrubbed;

  @override
  void didUpdateWidget(covariant PriceChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _scrubbed = null;
    }
  }

  void _handleScrub(Offset localPosition, Size size, List<DisplayPoint> fullPoints) {
    if (fullPoints.length < 2) return;
    final first = fullPoints.first.date;
    final last = fullPoints.last.date;
    final span = last.difference(first).inMicroseconds;
    if (span <= 0) return;
    final leftPad = 0.0;
    final rightPad = widget.showsAxes ? 24.0 : 0.0;
    final plotWidth = size.width - leftPad - rightPad;
    if (plotWidth <= 0) return;
    final fraction = ((localPosition.dx - leftPad) / plotWidth).clamp(0.0, 1.4);
    final micros = (span * fraction).round();
    final date = first.add(Duration(microseconds: micros));
    final sample = ScrubResolver.sample(date, fullPoints);
    setState(() => _scrubbed = sample);
  }

  void _endScrub() => setState(() => _scrubbed = null);

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    final drawn = ChartSampling.thinned(points, maxDrawnPoints);
    final lo = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final hi = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final pad = (hi - lo) * 0.15 > hi * 0.002 ? (hi - lo) * 0.15 : hi * 0.002;
    final domainLo = lo - pad;
    final domainHi = hi + pad;

    final span = points.last.date.difference(points.first.date);
    final granularity = AxisGranularity.forSpan(span);

    Widget chart = LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: widget.isInteractive
              ? (details) => _handleScrub(details.localPosition, size, points)
              : null,
          onHorizontalDragUpdate: widget.isInteractive
              ? (details) => _handleScrub(details.localPosition, size, points)
              : null,
          onHorizontalDragEnd: widget.isInteractive ? (_) => _endScrub() : null,
          onHorizontalDragCancel: widget.isInteractive ? _endScrub : null,
          onTapDown: widget.isInteractive
              ? (details) => _handleScrub(details.localPosition, size, points)
              : null,
          child: CustomPaint(
            size: size,
            painter: _PriceChartPainter(
              drawnPoints: drawn,
              domainLo: domainLo,
              domainHi: domainHi,
              color: widget.isTrendingUp ? DS.up : DS.down,
              showsAxes: widget.showsAxes,
              lineWidth: widget.lineWidth,
              granularity: granularity,
              scrubbed: _scrubbed,
              rangeStart: points.first.date,
              rangeEnd: points.last.date,
            ),
          ),
        );
      },
    );

    if (_scrubbed != null) {
      chart = Stack(
        children: [
          Positioned.fill(child: chart),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: _Callout(
                point: _scrubbed!,
                color: widget.isTrendingUp ? DS.up : DS.down,
                granularity: granularity,
                currencyCode: widget.currencyCode,
              ),
            ),
          ),
        ],
      );
    }

    return chart;
  }
}

class _Callout extends StatelessWidget {
  final DisplayPoint point;
  final Color color;
  final AxisGranularity granularity;
  final String? currencyCode;

  const _Callout({
    required this.point,
    required this.color,
    required this.granularity,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = calloutDateFormat(granularity).format(point.date);
    final priceText = currencyCode != null
        ? Money(point.value, currencyCode!).formatted()
        : point.value.toStringAsFixed(2);
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: DS.spaceXS),
        padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: DS.spaceXS),
        decoration: BoxDecoration(
          gradient: DS.tileFill,
          borderRadius: BorderRadius.circular(DS.radiusTile),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateText, style: const TextStyle(color: DS.textTertiary, fontSize: 11)),
            Text(
              priceText,
              style: const TextStyle(color: DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tick-label formatter for a given axis granularity.
DateFormat axisDateFormat(AxisGranularity granularity) {
  switch (granularity) {
    case AxisGranularity.time:
      return DateFormat.Hm();
    case AxisGranularity.dayMonth:
      return DateFormat('MMM d');
    case AxisGranularity.month:
      return DateFormat('MMM');
    case AxisGranularity.monthYear:
      return DateFormat('MMM yy');
    case AxisGranularity.year:
      return DateFormat('y');
  }
}

/// Richer scrub-callout formatter.
DateFormat calloutDateFormat(AxisGranularity granularity) {
  if (granularity == AxisGranularity.time) return DateFormat('MMM d, HH:mm');
  return DateFormat('y MMM d');
}

class _PriceChartPainter extends CustomPainter {
  final List<DisplayPoint> drawnPoints;
  final double domainLo;
  final double domainHi;
  final Color color;
  final bool showsAxes;
  final double lineWidth;
  final AxisGranularity granularity;
  final DisplayPoint? scrubbed;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  _PriceChartPainter({
    required this.drawnPoints,
    required this.domainLo,
    required this.domainHi,
    required this.color,
    required this.showsAxes,
    required this.lineWidth,
    required this.granularity,
    required this.scrubbed,
    required this.rangeStart,
    required this.rangeEnd,
  });

  double _x(DateTime date, double plotWidth) {
    final span = rangeEnd.difference(rangeStart).inMicroseconds;
    if (span <= 0) return 0;
    final t = date.difference(rangeStart).inMicroseconds / span;
    return t * plotWidth;
  }

  double _y(double value, double height) {
    final range = domainHi - domainLo;
    if (range <= 0) return height / 2;
    final t = (value - domainLo) / range;
    return height - (t * height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (drawnPoints.length < 2) return;
    final axisLabelSpace = showsAxes ? 18.0 : 0.0;
    final plotHeight = size.height - axisLabelSpace;
    final rightPad = showsAxes ? 24.0 : 0.0;
    final plotWidth = size.width - rightPad;

    final coords = drawnPoints
        .map((p) => Offset(_x(p.date, plotWidth), _y(p.value, plotHeight)))
        .toList();

    final linePath = _smoothPath(coords);

    // Area fill: gradient top (color@35%) to bottom (transparent).
    final areaPath = Path.from(linePath)
      ..lineTo(coords.last.dx, plotHeight)
      ..lineTo(coords.first.dx, plotHeight)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, plotWidth, plotHeight));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawPath(linePath, linePaint);

    // X-axis tick labels.
    if (showsAxes) {
      final format = axisDateFormat(granularity);
      final tickCount = granularity.tickCount;
      for (var i = 0; i < tickCount; i++) {
        final t = tickCount == 1 ? 0.0 : i / (tickCount - 1);
        final micros = (rangeEnd.difference(rangeStart).inMicroseconds * t).round();
        final date = rangeStart.add(Duration(microseconds: micros));
        final label = format.format(date);
        final tp = TextPainter(
          text: TextSpan(text: label, style: const TextStyle(color: DS.textTertiary, fontSize: 10)),
          textDirection: TextDirection.ltr,
        )..layout();
        var dx = t * plotWidth - tp.width / 2;
        dx = dx.clamp(0.0, size.width - tp.width);
        tp.paint(canvas, Offset(dx, plotHeight + 4));
      }
    }

    // Scrub overlay: dashed vertical rule + point marker.
    if (scrubbed != null) {
      final sx = _x(scrubbed!.date, plotWidth);
      final sy = _y(scrubbed!.value, plotHeight);
      final dashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1;
      const dashHeight = 4.0;
      const dashGap = 3.0;
      var y = 0.0;
      while (y < plotHeight) {
        canvas.drawLine(Offset(sx, y), Offset(sx, (y + dashHeight).clamp(0, plotHeight)), dashPaint);
        y += dashHeight + dashGap;
      }
      canvas.drawCircle(Offset(sx, sy), 5, Paint()..color = color);
      canvas.drawCircle(
        Offset(sx, sy),
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  /// Builds a smooth path through [points] via cubic Bezier segments
  /// approximating Catmull-Rom interpolation (Swift Charts' `.catmullRom`).
  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
      return path;
    }
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final c1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final c2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _PriceChartPainter oldDelegate) {
    return oldDelegate.drawnPoints != drawnPoints ||
        oldDelegate.domainLo != domainLo ||
        oldDelegate.domainHi != domainHi ||
        oldDelegate.color != color ||
        oldDelegate.scrubbed != scrubbed;
  }
}
