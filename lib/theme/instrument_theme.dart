import 'package:flutter/material.dart';

import '../models/asset.dart';
import 'qima_colors.dart';

/// Per-asset-class accent colors, ported from `Theme.swift` (spec §3.2).
/// Each stop set keeps its dark-mode gradient shape (used for the hero-card
/// wash/border), but the single flat [accentColor] — used as fills, chip
/// selections and chart lines — comes from [QimaColors]'s per-asset-class
/// accent tokens so it stays correct in light mode.
class InstrumentTheme {
  InstrumentTheme._();

  static List<Color> _stops(Instrument? instrument) {
    if (instrument == null) {
      return const [
        Color.fromRGBO(158, 189, 250, 1),
        Color.fromRGBO(107, 140, 235, 1),
        Color.fromRGBO(66, 92, 189, 1),
      ];
    }
    switch (instrument.assetClass) {
      case AssetClass.metal:
        if (instrument.symbol == 'XAG') {
          return const [
            Color.fromRGBO(242, 242, 242, 0.95),
            Color.fromRGBO(199, 199, 199, 0.78),
            Color.fromRGBO(140, 140, 140, 0.55),
          ];
        }
        // Platinum-group metals get a cool blue cast so they read apart
        // from silver's neutral grey.
        if (instrument.symbol == 'XPT' || instrument.symbol == 'XPD') {
          return const [
            Color.fromRGBO(214, 230, 245, 1),
            Color.fromRGBO(169, 196, 221, 1),
            Color.fromRGBO(98, 128, 158, 1),
          ];
        }
        // Gold (default metal, e.g. XAU).
        return const [
          Color.fromRGBO(250, 222, 140, 1),
          Color.fromRGBO(230, 186, 77, 1),
          Color.fromRGBO(184, 135, 33, 1),
        ];
      case AssetClass.crypto:
        return const [
          Color.fromRGBO(252, 194, 92, 1),
          Color.fromRGBO(242, 140, 51, 1),
          Color.fromRGBO(199, 92, 26, 1),
        ];
      // Cyan rather than teal, so currencies don't read as the "up" green.
      case AssetClass.fiat:
        return const [
          Color.fromRGBO(140, 220, 232, 1),
          Color.fromRGBO(63, 184, 201, 1),
          Color.fromRGBO(30, 122, 140, 1),
        ];
      case AssetClass.stock:
        return const [
          Color.fromRGBO(158, 189, 250, 1),
          Color.fromRGBO(107, 140, 235, 1),
          Color.fromRGBO(66, 92, 189, 1),
        ];
      case AssetClass.indices:
        return const [
          Color.fromRGBO(199, 168, 245, 1),
          Color.fromRGBO(153, 117, 224, 1),
          Color.fromRGBO(102, 71, 173, 1),
        ];
    }
  }

  static LinearGradient accentGradient(Instrument? instrument) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _stops(instrument),
    );
  }

  /// Flat accent used for fills, selected chips/segments and chart lines.
  /// Metal instruments without a specific asset-class accent (gold, and the
  /// silver/platinum-group split above) fall back to the gradient's middle
  /// stop, matching pre-Phase-1 behaviour; other asset classes use
  /// [QimaColors]'s theme-aware accent so light mode reads correctly.
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
}
