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
  static const double space2XS = 4;
  static const double spaceXS = 6;
  static const double spaceSM = 10;
  static const double spaceMD = 16;
  static const double spaceLG = 20;
  static const double spaceXL = 28;

  // ---- Typography ----
  /// Big headline figures: the asset price on the detail screen, and the
  /// portfolio/zakat totals on hero cards.
  static const double figureDisplay = 40;
  static const double figureHero = 30;

  /// Arabic glyphs read smaller than Latin ones at the same point size, so
  /// small Arabic labels (overlines, captions) get this many points more.
  static const double arabicSmallTextBoost = 1.5;

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

  /// Small caption style for section headers and metric labels. Latin
  /// overlines are letter-spaced; Arabic gets no letter spacing (it would
  /// break the joins between letters) and [arabicSmallTextBoost] more points,
  /// since Arabic glyphs read smaller at the same size.
  static TextStyle overline(
    BuildContext context, {
    required Color color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final arabic = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    return TextStyle(
      color: color,
      fontSize: arabic ? fontSize + arabicSmallTextBoost : fontSize,
      fontWeight: fontWeight,
      letterSpacing: arabic ? 0 : 0.5,
    );
  }

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
        BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 3)),
      ],
    );
  }

  /// `.dsTile` — a flat inset tile with no border or shadow, so a tile
  /// inside a card reads as a quiet grouping rather than a second card.
  static BoxDecoration tile(QimaColors colors, {double cornerRadius = radiusTile}) {
    return BoxDecoration(
      color: colors.tileTop,
      borderRadius: BorderRadius.circular(cornerRadius),
    );
  }

  /// `.dsHeroCard` — surface card plus an accent radial wash and a gradient
  /// border, with a colored glow shadow in addition to the base drop shadow.
  static BoxDecoration heroCard(QimaColors colors, Color accent, {double cornerRadius = radiusCard}) {
    return BoxDecoration(
      gradient: cardFill(colors),
      borderRadius: BorderRadius.circular(cornerRadius),
      boxShadow: [
        BoxShadow(color: accent.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 6)),
        BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 3)),
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
      colors: [accent.withValues(alpha: 0.30), colors.hairline],
    );
  }

  static RadialGradient heroAccentWash(Color accent) {
    return RadialGradient(
      center: Alignment.topRight,
      radius: 1.2,
      colors: [accent.withValues(alpha: 0.20), accent.withValues(alpha: 0.0)],
    );
  }

  /// Style for every [SegmentedButton]: a sliding-control look — a grey
  /// track with the selected segment raised as a [QimaColors.segmentThumb]
  /// — instead of Material 3's outlined segments with a solid fill. The
  /// border is drawn in the track's own color, so it reads as the gap that
  /// insets the thumb rather than as an outline. Callers pass
  /// `showSelectedIcon: false`; the thumb already marks the selection.
  static ButtonStyle segmentedButtonStyle(QimaColors colors) {
    return SegmentedButton.styleFrom(
      backgroundColor: colors.tileTop,
      foregroundColor: colors.textSecondary,
      selectedBackgroundColor: colors.segmentThumb,
      selectedForegroundColor: colors.textPrimary,
      side: BorderSide(color: colors.tileTop, width: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  /// Fill of a selected chip: a soft wash of the accent rather than a solid
  /// block, so solid gold stays reserved for the screen's main action.
  /// The dark palette (light text) needs a slightly stronger wash to read.
  static Color selectedTint(QimaColors colors, Color accent) =>
      accent.withValues(alpha: colors.textPrimary.computeLuminance() > 0.5 ? 0.24 : 0.18);
}

/// A borderless [ChoiceChip]: grey when idle, a soft [DS.selectedTint] of
/// [accent] (an instrument accent, or `context.colors.brand` by default)
/// with a bold label when selected, rather than a solid fill. The selected
/// label stays [QimaColors.textPrimary] so it keeps full contrast on the tint.
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
      selectedColor: DS.selectedTint(colors, resolvedAccent),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      // A chip's label style replaces the ambient text style instead of
      // merging with it, so start from the theme's to keep the app font.
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? colors.textPrimary : colors.textSecondary,
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
