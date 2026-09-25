import 'dart:ui';

import 'package:flutter/material.dart';

import 'qima_colors.dart';

/// Theme-independent design-system tokens ported from `DesignSystem.swift`
/// (spec §3.1): radii, spacing and type sizes that don't change between
/// light and dark. Colors live on [QimaColors] (`context.colors`) instead —
/// see `qima_colors.dart` and `app_theme.dart`. Every text color keeps ≥
/// 4.5:1 contrast on the lightest surface it can sit on (`tileTop`);
/// `design_system_contrast_test.dart` enforces this for both palettes.
class DS {
  DS._();

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

  // ---- Typography ----
  /// Primary family when the app runs in Arabic; it ships matching Latin
  /// glyphs, so digits and tickers sit evenly with the Arabic around them.
  static const String arabicFontFamily = 'Almarai';

  /// The app's font family for [locale]: Almarai for Arabic, the platform
  /// font (null) otherwise. `buildTheme` is the only caller; everything
  /// else gets the family from the theme.
  static String? fontFamilyFor(Locale locale) => locale.languageCode == 'ar' ? arabicFontFamily : null;

  /// Consulted before the OS fallback chain in every locale: Arabic glyphs
  /// (currency symbols, Arabic names) render in Almarai rather than the system's
  /// basic Arabic face, and the Saudi Riyal sign always has a glyph.
  static const List<String> fontFamilyFallback = [arabicFontFamily, 'Riyal'];

  static LinearGradient cardFill(QimaColors colors) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.surfaceTop, colors.surfaceBottom],
      );

  static LinearGradient tileFill(QimaColors colors) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.tileTop, colors.tileBottom],
      );

  static LinearGradient backgroundGradient(QimaColors colors) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.bg1, colors.bg0],
      );

  /// `.dsCard` — flat surface card.
  static BoxDecoration card(QimaColors colors, {double cornerRadius = radiusCard}) {
    return BoxDecoration(
      gradient: cardFill(colors),
      borderRadius: BorderRadius.circular(cornerRadius),
      border: Border.all(color: colors.hairline, width: 1),
      boxShadow: [
        BoxShadow(color: colors.shadow, blurRadius: 18, offset: const Offset(0, 10)),
      ],
    );
  }

  /// `.dsTile` — inset tile, no shadow.
  static BoxDecoration tile(QimaColors colors, {double cornerRadius = radiusTile}) {
    return BoxDecoration(
      gradient: tileFill(colors),
      borderRadius: BorderRadius.circular(cornerRadius),
      border: Border.all(color: colors.hairline, width: 1),
    );
  }

  /// `.dsHeroCard` — surface card plus an accent radial wash and a gradient
  /// border, with a colored glow shadow in addition to the base drop shadow.
  static BoxDecoration heroCard(QimaColors colors, Color accent, {double cornerRadius = radiusCard}) {
    return BoxDecoration(
      gradient: cardFill(colors),
      borderRadius: BorderRadius.circular(cornerRadius),
      boxShadow: [
        BoxShadow(color: accent.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 12)),
        BoxShadow(color: colors.shadow, blurRadius: 18, offset: const Offset(0, 10)),
      ],
    );
  }

  /// Border gradient used atop [heroCard] (draw via a `Container` foreground
  /// decoration or a bordered overlay, since `BoxDecoration` can't combine a
  /// gradient border with a gradient fill in one pass).
  static Gradient heroBorderGradient(QimaColors colors, Color accent) {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [accent.withValues(alpha: 0.55), colors.hairline],
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
  /// instrument is in scope, or `colors.brand` when it isn't (spec §3.1/§3.2).
  /// The selected segment's fill is a brand-style accent, so its label uses
  /// [QimaColors.onBrand] rather than a fixed dark color.
  static ButtonStyle segmentedButtonStyle(QimaColors colors, Color accent) {
    return SegmentedButton.styleFrom(
      backgroundColor: colors.tileTop,
      foregroundColor: colors.textSecondary,
      selectedBackgroundColor: accent,
      selectedForegroundColor: colors.onBrand,
      side: BorderSide(color: colors.hairline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
    );
  }
}

/// A [ChoiceChip] pre-styled to pull its selected fill from [accent] (an
/// instrument accent, or `context.colors.brand` by default) rather than
/// Material 3's auto-generated secondary color, matching
/// [DS.segmentedButtonStyle]'s intent for the chip widget family (spec
/// §3.1/§3.2). The selected label uses [QimaColors.onBrand].
class DSChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color? accent;

  const DSChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedAccent = accent ?? colors.brand;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: colors.tileTop,
      selectedColor: resolvedAccent,
      side: BorderSide(color: colors.hairline),
      shape: const StadiumBorder(),
      // A chip's label style replaces the ambient text style instead of
      // merging with it, so start from the theme's to keep the app font.
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? colors.onBrand : colors.textSecondary,
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
    final colors = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: DS.backgroundGradient(colors))),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.textPrimary.withValues(alpha: 0.08),
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
      decoration: DS.card(context.colors, cornerRadius: cornerRadius),
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
      decoration: DS.tile(context.colors, cornerRadius: cornerRadius),
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
    final colors = context.colors;
    final radius = BorderRadius.circular(cornerRadius);
    return Container(
      decoration: DS.heroCard(colors, accent, cornerRadius: cornerRadius),
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
                  border: GradientBoxBorder(gradient: DS.heroBorderGradient(colors, accent), width: 1),
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
