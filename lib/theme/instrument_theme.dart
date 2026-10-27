import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../models/asset_group.dart';
import 'qima_colors.dart';

/// Per-asset-class accent colors, ported from `Theme.swift` (spec §3.2).
/// [accentColor] — used for icon washes, fills, chip selections and chart
/// lines — comes from [QimaColors]'s per-asset-class accent tokens so it
/// stays correct in light mode.
class InstrumentTheme {
  InstrumentTheme._();

  /// The soft circle behind an instrument glyph.
  static Color iconWash(Color accent, {required bool dark}) => accent.withValues(alpha: dark ? 0.22 : 0.12);

  /// The glyph drawn on [iconWash] over [surface]: the accent itself, or in
  /// light mode darkened only as far as it takes to reach 3:1 on the wash,
  /// so gold stays gold and only orange, silver and teal deepen slightly.
  static Color iconGlyph(Color accent, Color surface, {required bool dark}) {
    if (dark) return accent;
    final wash = Color.alphaBlend(iconWash(accent, dark: false), surface);
    var hsl = HSLColor.fromColor(accent);
    while (_contrast(hsl.toColor(), wash) < 3.0 && hsl.lightness > 0) {
      hsl = hsl.withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0));
    }
    return hsl.toColor();
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
  }

  /// Flat accent used for icon washes, fills, selected chips and chart
  /// lines. Silver and the platinum group get their own metal accents;
  /// every other metal uses gold.
  static Color accentColor(Instrument? instrument, QimaColors colors) {
    if (instrument == null) return colors.accentStock;
    switch (instrument.assetClass) {
      case AssetClass.metal:
        if (instrument.symbol == 'XAG') return colors.accentSilver;
        if (instrument.symbol == 'XPT' || instrument.symbol == 'XPD') return colors.accentPlatinum;
        return colors.accentGold;
      case AssetClass.crypto:
        return colors.accentCrypto;
      case AssetClass.fiat:
        return colors.accentFiat;
      case AssetClass.stock:
        return colors.accentStock;
      case AssetClass.indices:
        return colors.accentIndex;
    }
  }

  /// The accent for a whole [AssetGroup] in allocation breakdowns: the
  /// accent of the group's most typical instrument.
  static Color groupColor(AssetGroup group, QimaColors colors) {
    switch (group) {
      case AssetGroup.metals:
        return colors.accentGold;
      case AssetGroup.crypto:
        return colors.accentCrypto;
      case AssetGroup.equities:
        return colors.accentStock;
      case AssetGroup.cash:
        return colors.accentFiat;
    }
  }
}
