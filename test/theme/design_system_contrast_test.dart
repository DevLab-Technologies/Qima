import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/theme/design_system.dart';

/// WCAG 2.1 contrast ratio, compositing a translucent [fg] over [bg] first.
double _contrast(Color fg, Color bg) {
  final a = Color.alphaBlend(fg, bg).computeLuminance();
  final b = bg.computeLuminance();
  final (hi, lo) = a > b ? (a, b) : (b, a);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // Text can sit on any of these; tileTop is the lightest, so it is the
  // binding constraint.
  const surfaces = {
    'bg0': DS.bg0,
    'surfaceTop': DS.surfaceTop,
    'tileTop': DS.tileTop,
    'overlay': DS.overlay,
  };
  const texts = {
    'textPrimary': DS.textPrimary,
    'textSecondary': DS.textSecondary,
    'textTertiary': DS.textTertiary,
    'up': DS.up,
    'down': DS.down,
    'brand': DS.brand,
  };

  for (final surface in surfaces.entries) {
    for (final text in texts.entries) {
      test('${text.key} on ${surface.key} meets WCAG AA (4.5:1)', () {
        expect(_contrast(text.value, surface.value), greaterThanOrEqualTo(4.5));
      });
    }
  }

  test('change pills: trend text on its own 15% tint meets 4.5:1', () {
    for (final trend in [DS.up, DS.down]) {
      final pill = Color.alphaBlend(trend.withValues(alpha: 0.15), DS.surfaceTop);
      expect(_contrast(trend, pill), greaterThanOrEqualTo(4.5));
    }
  });

  test('selected chip/segment text (bg0) on brand meets 4.5:1', () {
    expect(_contrast(DS.bg0, DS.brand), greaterThanOrEqualTo(4.5));
  });
}
