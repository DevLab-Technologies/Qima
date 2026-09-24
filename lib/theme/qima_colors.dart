import 'package:flutter/material.dart';

/// Theme-dependent design-system tokens, ported from `DesignSystem.swift`
/// (spec §3.1) and Figma "Qima DS". [dark] keeps every value the app shipped
/// with when it was dark-only; [light] is the Phase 1 light palette.
///
/// Theme-independent tokens (radii, spacing, type sizes) stay on `DS` in
/// `design_system.dart`; everything that differs between light and dark
/// lives here, reached via `context.colors`.
@immutable
class QimaColors extends ThemeExtension<QimaColors> {
  final Color bg0;
  final Color bg1;
  final Color surfaceTop;
  final Color surfaceBottom;
  final Color tileTop;
  final Color tileBottom;

  /// Menus, dialogs and sheets floating above cards.
  final Color overlay;
  final Color hairline;
  final Color hairlineStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color up;
  final Color down;

  /// Brand accent (gold): FILLS ONLY — chips, switches, radio rings,
  /// selected segments. Never used as text; use [brandText] for that.
  final Color brand;

  /// Gold text/glyphs on a surface: text buttons, links, highlights,
  /// focused labels. Distinct from [brand] so gold text keeps ≥ 4.5:1
  /// contrast in light mode, where a fill-strength gold would not.
  final Color brandText;

  /// Text/icons drawn on top of a [brand] fill (replaces the old
  /// `bg0-on-brand` convention now that bg0 differs between themes).
  final Color onBrand;

  final Color shadow;
  final Color scrim;

  final Color accentGold;
  final Color accentSilver;
  final Color accentPlatinum;
  final Color accentCrypto;
  final Color accentFiat;
  final Color accentStock;
  final Color accentIndex;

  const QimaColors({
    required this.bg0,
    required this.bg1,
    required this.surfaceTop,
    required this.surfaceBottom,
    required this.tileTop,
    required this.tileBottom,
    required this.overlay,
    required this.hairline,
    required this.hairlineStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.up,
    required this.down,
    required this.brand,
    required this.brandText,
    required this.onBrand,
    required this.shadow,
    required this.scrim,
    required this.accentGold,
    required this.accentSilver,
    required this.accentPlatinum,
    required this.accentCrypto,
    required this.accentFiat,
    required this.accentStock,
    required this.accentIndex,
  });

  /// Today's (and Phase 0's) values, unchanged — `design_system_contrast_test.dart`
  /// covered these before Phase 1 and continues to.
  static const QimaColors dark = QimaColors(
    bg0: Color(0xFF08090C),
    bg1: Color(0xFF0F1116),
    surfaceTop: Color(0xFF1F2229),
    surfaceBottom: Color(0xFF191B21),
    tileTop: Color(0xFF2B2F39),
    tileBottom: Color(0xFF22252D),
    overlay: Color(0xFF262A33),
    hairline: Color.fromRGBO(255, 255, 255, 0.10),
    hairlineStrong: Color.fromRGBO(255, 255, 255, 0.18),
    textPrimary: Colors.white,
    textSecondary: Color.fromRGBO(255, 255, 255, 0.60),
    textTertiary: Color.fromRGBO(255, 255, 255, 0.52),
    up: Color(0xFF30D158),
    down: Color(0xFFFF6B61),
    brand: Color(0xFFE6BA4D),
    brandText: Color(0xFFE6BA4D),
    onBrand: Color(0xFF08090C),
    shadow: Color.fromRGBO(0, 0, 0, 0.45),
    scrim: Color.fromRGBO(0, 0, 0, 0.55),
    accentGold: Color(0xFFE6BA4D),
    accentSilver: Color.fromRGBO(199, 199, 199, 0.78),
    accentPlatinum: Color(0xFFA9C4DD),
    accentCrypto: Color(0xFFF28C33),
    accentFiat: Color(0xFF3FB8C9),
    accentStock: Color(0xFF6B8CEB),
    accentIndex: Color(0xFF9975E0),
  );

  /// Figma "Qima DS" light palette.
  static const QimaColors light = QimaColors(
    bg0: Color(0xFFECEEF2),
    bg1: Color(0xFFF7F8FA),
    surfaceTop: Color(0xFFFFFFFF),
    surfaceBottom: Color(0xFFFAFAFC),
    tileTop: Color(0xFFF2F3F6),
    tileBottom: Color(0xFFEAECF0),
    overlay: Color(0xFFFFFFFF),
    hairline: Color.fromRGBO(0x11, 0x13, 0x18, 0.10),
    hairlineStrong: Color.fromRGBO(0x11, 0x13, 0x18, 0.18),
    textPrimary: Color(0xFF111318),
    textSecondary: Color.fromRGBO(0x11, 0x13, 0x18, 0.70),
    textTertiary: Color.fromRGBO(0x11, 0x13, 0x18, 0.60),
    up: Color(0xFF166B2E),
    down: Color(0xFFB42A26),
    brand: Color(0xFFA87B14),
    brandText: Color(0xFF8A6410),
    onBrand: Color(0xFF1A1406),
    shadow: Color.fromRGBO(0x1B, 0x22, 0x30, 0.08),
    scrim: Color.fromRGBO(0x11, 0x13, 0x18, 0.32),
    accentGold: Color(0xFFA87B14),
    accentSilver: Color(0xFF8A8D93),
    accentPlatinum: Color(0xFF6F93B8),
    accentCrypto: Color(0xFFE0761A),
    accentFiat: Color(0xFF1597A8),
    accentStock: Color(0xFF4A6FDB),
    accentIndex: Color(0xFF7447C9),
  );

  static Color trendColor(bool isUp, QimaColors colors) => isUp ? colors.up : colors.down;

  @override
  QimaColors copyWith({
    Color? bg0,
    Color? bg1,
    Color? surfaceTop,
    Color? surfaceBottom,
    Color? tileTop,
    Color? tileBottom,
    Color? overlay,
    Color? hairline,
    Color? hairlineStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? up,
    Color? down,
    Color? brand,
    Color? brandText,
    Color? onBrand,
    Color? shadow,
    Color? scrim,
    Color? accentGold,
    Color? accentSilver,
    Color? accentPlatinum,
    Color? accentCrypto,
    Color? accentFiat,
    Color? accentStock,
    Color? accentIndex,
  }) {
    return QimaColors(
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      surfaceTop: surfaceTop ?? this.surfaceTop,
      surfaceBottom: surfaceBottom ?? this.surfaceBottom,
      tileTop: tileTop ?? this.tileTop,
      tileBottom: tileBottom ?? this.tileBottom,
      overlay: overlay ?? this.overlay,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      up: up ?? this.up,
      down: down ?? this.down,
      brand: brand ?? this.brand,
      brandText: brandText ?? this.brandText,
      onBrand: onBrand ?? this.onBrand,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
      accentGold: accentGold ?? this.accentGold,
      accentSilver: accentSilver ?? this.accentSilver,
      accentPlatinum: accentPlatinum ?? this.accentPlatinum,
      accentCrypto: accentCrypto ?? this.accentCrypto,
      accentFiat: accentFiat ?? this.accentFiat,
      accentStock: accentStock ?? this.accentStock,
      accentIndex: accentIndex ?? this.accentIndex,
    );
  }

  @override
  QimaColors lerp(ThemeExtension<QimaColors>? other, double t) {
    if (other is! QimaColors) return this;
    return QimaColors(
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      surfaceTop: Color.lerp(surfaceTop, other.surfaceTop, t)!,
      surfaceBottom: Color.lerp(surfaceBottom, other.surfaceBottom, t)!,
      tileTop: Color.lerp(tileTop, other.tileTop, t)!,
      tileBottom: Color.lerp(tileBottom, other.tileBottom, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      up: Color.lerp(up, other.up, t)!,
      down: Color.lerp(down, other.down, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandText: Color.lerp(brandText, other.brandText, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      accentSilver: Color.lerp(accentSilver, other.accentSilver, t)!,
      accentPlatinum: Color.lerp(accentPlatinum, other.accentPlatinum, t)!,
      accentCrypto: Color.lerp(accentCrypto, other.accentCrypto, t)!,
      accentFiat: Color.lerp(accentFiat, other.accentFiat, t)!,
      accentStock: Color.lerp(accentStock, other.accentStock, t)!,
      accentIndex: Color.lerp(accentIndex, other.accentIndex, t)!,
    );
  }
}

/// `context.colors` — the theme-appropriate [QimaColors] palette. Falls back
/// to [QimaColors.dark] if the extension isn't registered (should never
/// happen once [buildTheme] wires it in), rather than crashing.
extension QimaColorsContext on BuildContext {
  QimaColors get colors => Theme.of(this).extension<QimaColors>() ?? QimaColors.dark;
}
