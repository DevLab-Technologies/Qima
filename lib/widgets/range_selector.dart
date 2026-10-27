import 'package:flutter/material.dart';

import '../models/chart_range.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';

/// The chart range chips under a price chart.
///
/// With [fill], every range gets an equal share of the row and long labels
/// shrink to fit, so a short list (the portfolio hero's five ranges) never
/// runs off the card edge in any language. Without it the row scrolls and
/// fades out at both ends, so it is obvious there is more to swipe to, and
/// the selected range is scrolled into view.
class RangeSelector extends StatelessWidget {
  final List<ChartRange> ranges;
  final ChartRange selected;
  final ValueChanged<ChartRange> onSelected;
  final Color accent;
  final bool fill;

  const RangeSelector({
    super.key,
    required this.ranges,
    required this.selected,
    required this.onSelected,
    required this.accent,
    this.fill = false,
  });

  static const double _height = 36;
  static const double _fadeWidth = 24;

  @override
  Widget build(BuildContext context) {
    if (fill) {
      return SizedBox(
        height: _height,
        child: Row(
          children: [
            for (final range in ranges)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _RangePill(
                    label: displayLabel(context, range.labelKey),
                    selected: range == selected,
                    accent: accent,
                    onTap: () => onSelected(range),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      height: _height,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          final stop = (_fadeWidth / bounds.width).clamp(0.0, 0.5);
          return LinearGradient(
            colors: const [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
            stops: [0, stop, 1 - stop, 1],
          ).createShader(bounds);
        },
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: DS.spaceXS),
          children: [
            for (final range in ranges)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _RangePill(
                  key: range == selected ? const ValueKey('selected-range') : null,
                  label: displayLabel(context, range.labelKey),
                  selected: range == selected,
                  accent: accent,
                  minWidth: 44,
                  onTap: () => onSelected(range),
                  revealWhenSelected: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RangePill extends StatefulWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final double? minWidth;
  final bool revealWhenSelected;

  const _RangePill({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.minWidth,
    this.revealWhenSelected = false,
  });

  @override
  State<_RangePill> createState() => _RangePillState();
}

class _RangePillState extends State<_RangePill> {
  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(covariant _RangePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) _reveal();
  }

  /// Keeps the selected range on screen in a scrolling row, e.g. "All"
  /// chosen on a previous visit and now past the trailing edge.
  void _reveal() {
    if (!widget.revealWhenSelected || !widget.selected) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(context, alignment: 0.5, duration: const Duration(milliseconds: 200));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? DS.selectedTint(colors, widget.accent) : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: widget.minWidth ?? 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM),
              child: Center(
                widthFactor: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected ? colors.textPrimary : colors.textSecondary,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
