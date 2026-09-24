import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/theme/qima_colors.dart';

/// WCAG 2.1 contrast ratio, compositing a translucent [fg] over [bg] first.
double _contrast(Color fg, Color bg) {
  final a = Color.alphaBlend(fg, bg).computeLuminance();
  final b = bg.computeLuminance();
  final (hi, lo) = a > b ? (a, b) : (b, a);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const palettes = {'dark': QimaColors.dark, 'light': QimaColors.light};

  for (final paletteEntry in palettes.entries) {
    final paletteName = paletteEntry.key;
    final colors = paletteEntry.value;

    // Text can sit on any of these; tileTop is the lightest surface in dark
    // mode (surfaceTop/overlay are lightest in light mode), so covering all
    // of them is the binding constraint for each palette.
    final surfaces = {
      'bg0': colors.bg0,
      'bg1': colors.bg1,
      'surfaceTop': colors.surfaceTop,
      'surfaceBottom': colors.surfaceBottom,
      'tileTop': colors.tileTop,
      'tileBottom': colors.tileBottom,
      'overlay': colors.overlay,
    };
    final texts = {
      'textPrimary': colors.textPrimary,
      'textSecondary': colors.textSecondary,
      'textTertiary': colors.textTertiary,
      'up': colors.up,
      'down': colors.down,
      'brandText': colors.brandText,
    };

    for (final surface in surfaces.entries) {
      for (final text in texts.entries) {
        test('[$paletteName] ${text.key} on ${surface.key} meets WCAG AA (4.5:1)', () {
          expect(_contrast(text.value, surface.value), greaterThanOrEqualTo(4.5));
        });
      }
    }

    test('[$paletteName] change pills: trend text on its own 15% tint meets 4.5:1', () {
      for (final trend in [colors.up, colors.down]) {
        final pill = Color.alphaBlend(trend.withValues(alpha: 0.15), colors.surfaceTop);
        expect(_contrast(trend, pill), greaterThanOrEqualTo(4.5));
      }
    });

    test('[$paletteName] onBrand on brand meets 4.5:1', () {
      expect(_contrast(colors.onBrand, colors.brand), greaterThanOrEqualTo(4.5));
    });

    // brand/accent fills (chips, switches, radio rings, selected segments,
    // hero-card glows/instrument icon gradients) only need to be visually
    // distinguishable from the card surface they actually render on
    // (WCAG's 3:1 "non-text contrast" minimum), not text-level 4.5:1 —
    // brand is FILLS ONLY per spec; brandText covers the text/glyph case
    // above. surfaceTop is where these fills are drawn (DSHeroCard,
    // InstrumentIcon, DSChoiceChip's own tileTop background already
    // guarantees the chip-on-chip case separately via its own hairline).
    final fills = {
      'brand': colors.brand,
      'accentGold': colors.accentGold,
      'accentSilver': colors.accentSilver,
      'accentPlatinum': colors.accentPlatinum,
      'accentCrypto': colors.accentCrypto,
      'accentFiat': colors.accentFiat,
      'accentStock': colors.accentStock,
      'accentIndex': colors.accentIndex,
    };
    for (final fill in fills.entries) {
      test('[$paletteName] ${fill.key} fill on surfaceTop meets non-text contrast (3:1)', () {
        expect(_contrast(fill.value, colors.surfaceTop), greaterThanOrEqualTo(3.0));
      });
    }
  }
}
