import 'dart:ui';

import 'package:flutter/material.dart';

/// Design-system tokens ported from `DesignSystem.swift` (spec §3.1). The app
/// is dark-mode-only.
class DS {
  DS._();

  // ---- Palette ----
  static const Color bg0 = Color(0xFF08090C);
  static const Color bg1 = Color(0xFF0F1116);
  static const Color surfaceTop = Color(0xFF1C1F27);
  static const Color surfaceBottom = Color(0xFF14161C);
  static const Color tileTop = Color(0xFF23262F);
  static const Color tileBottom = Color(0xFF191B22);
  static const Color hairline = Color.fromRGBO(255, 255, 255, 0.08);
  static const Color hairlineStrong = Color.fromRGBO(255, 255, 255, 0.16);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color.fromRGBO(255, 255, 255, 0.60);
  static const Color textTertiary = Color.fromRGBO(255, 255, 255, 0.38);
  static const Color up = Color(0xFF30D158);
  static const Color down = Color(0xFFFF453A);

  // ---- Radius ----
  static const double radiusTile = 14;
  static const double radiusCard = 22;
  static const double radiusPill = 100;

  // ---- Spacing ----
  static const double spaceXS = 6;
  static const double spaceSM = 10;
  static const double spaceMD = 16;
  static const double spaceLG = 20;
  static const double spaceXL = 28;

  static Color trendColor(bool isUp) => isUp ? up : down;

  static const LinearGradient cardFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceTop, surfaceBottom],
  );

  static const LinearGradient tileFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [tileTop, tileBottom],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bg1, bg0],
  );

  /// `.dsCard` — flat surface card.
  static BoxDecoration card({double cornerRadius = radiusCard}) {
    return BoxDecoration(
      gradient: cardFill,
      borderRadius: BorderRadius.circular(cornerRadius),
      border: Border.all(color: hairline, width: 1),
      boxShadow: const [
        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.45), blurRadius: 18, offset: Offset(0, 10)),
      ],
    );
  }

  /// `.dsTile` — inset tile, no shadow.
  static BoxDecoration tile({double cornerRadius = radiusTile}) {
    return BoxDecoration(
      gradient: tileFill,
      borderRadius: BorderRadius.circular(cornerRadius),
      border: Border.all(color: hairline, width: 1),
    );
  }

  /// `.dsHeroCard` — surface card plus an accent radial wash and a gradient
  /// border, with a colored glow shadow in addition to the base drop shadow.
  static BoxDecoration heroCard(Color accent, {double cornerRadius = radiusCard}) {
    return BoxDecoration(
      gradient: cardFill,
      borderRadius: BorderRadius.circular(cornerRadius),
      boxShadow: [
        BoxShadow(color: accent.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 12)),
        const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.45), blurRadius: 18, offset: Offset(0, 10)),
      ],
    );
  }

  /// Border gradient used atop [heroCard] (draw via a `Container` foreground
  /// decoration or a bordered overlay, since `BoxDecoration` can't combine a
  /// gradient border with a gradient fill in one pass).
  static Gradient heroBorderGradient(Color accent) {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [accent.withValues(alpha: 0.55), hairline],
    );
  }

  static RadialGradient heroAccentWash(Color accent) {
    return RadialGradient(
      center: Alignment.topRight,
      radius: 1.2,
      colors: [accent.withValues(alpha: 0.32), accent.withValues(alpha: 0.0)],
    );
  }

  /// Style for a [SegmentedButton] whose selected segment should be tinted
  /// with [accent] instead of Material 3's auto-generated (and, for a gold
  /// seed color, often blue/purple-looking) `secondaryContainer`. Pass the
  /// current instrument's accent (`InstrumentTheme.accentColor`) wherever an
  /// instrument is in scope, or [textPrimary] as a neutral default when it
  /// isn't (spec §3.1/§3.2).
  static ButtonStyle segmentedButtonStyle(Color accent) {
    return SegmentedButton.styleFrom(
      backgroundColor: tileTop,
      foregroundColor: textSecondary,
      selectedBackgroundColor: accent,
      selectedForegroundColor: bg0,
      side: const BorderSide(color: hairline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
    );
  }
}

/// A [ChoiceChip] pre-styled to pull its selected fill from [accent] (an
/// instrument accent, or a neutral default) rather than Material 3's
/// auto-generated secondary color, matching [DS.segmentedButtonStyle]'s
/// intent for the chip widget family (spec §3.1/§3.2).
class DSChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color accent;

  const DSChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.accent = DS.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: DS.tileTop,
      selectedColor: accent,
      side: const BorderSide(color: DS.hairline),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: selected ? DS.bg0 : DS.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

/// Full-bleed screen background: a vertical gradient plus a soft blurred
/// glow ellipse near the top, matching `DS.screenBackground`.
class ScreenBackground extends StatelessWidget {
  final Widget child;

  const ScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: DS.backgroundGradient)),
        Positioned(
          top: -180 - 180,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 520,
                height: 360,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(255, 255, 255, 0.08),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A card surface built with [DS.card].
class DSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double cornerRadius;

  const DSCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DS.spaceMD),
    this.cornerRadius = DS.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: DS.card(cornerRadius: cornerRadius),
      child: child,
    );
  }
}

/// A tile surface built with [DS.tile].
class DSTile extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double cornerRadius;

  const DSTile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DS.spaceSM),
    this.cornerRadius = DS.radiusTile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: DS.tile(cornerRadius: cornerRadius),
      child: child,
    );
  }
}

/// A hero card surface built with [DS.heroCard] plus its accent wash and
/// gradient border, matching `.dsHeroCard`.
class DSHeroCard extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final double cornerRadius;

  const DSHeroCard({
    super.key,
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.all(DS.spaceLG),
    this.cornerRadius = DS.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(cornerRadius);
    return Container(
      decoration: DS.heroCard(accent, cornerRadius: cornerRadius),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(gradient: DS.heroAccentWash(accent))),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: GradientBoxBorder(gradient: DS.heroBorderGradient(accent), width: 1),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// A [BoxBorder] painted with a gradient, since [Border.all] only accepts a
/// flat color.
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({required this.gradient, this.width = 1});

  @override
  BorderSide get top => BorderSide.none;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  bool get isUniform => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  BoxBorder scale(double t) => GradientBoxBorder(gradient: gradient, width: width * t);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final inset = rect.deflate(width / 2);
    if (shape == BoxShape.circle) {
      canvas.drawCircle(inset.center, inset.shortestSide / 2, paint);
    } else if (borderRadius != null) {
      canvas.drawRRect(borderRadius.toRRect(inset), paint);
    } else {
      canvas.drawRect(inset, paint);
    }
  }
}
