import 'package:flutter/material.dart';

import 'design_system.dart';
import 'qima_colors.dart';

/// Builds the app's [ThemeData] for a given [brightness], moved out of
/// `main.dart` so `MaterialApp.theme`/`darkTheme` can both come from here
/// (spec Phase 1). Dark keeps every value the app shipped with when it was
/// dark-only; light is the new Figma "Qima DS" light palette.
///
/// This is the one place the app's font is decided ([DS.fontFamilyFor]
/// [locale]). Component themes whose label styles replace the ambient text
/// style rather than merging with it (chips, navigation labels) build them
/// from [text] so they carry the same family.
ThemeData buildTheme(Brightness brightness, {Locale? locale}) {
  final colors = brightness == Brightness.dark ? QimaColors.dark : QimaColors.light;
  final fontFamily = locale == null ? null : DS.fontFamilyFor(locale);
  TextStyle text({Color? color, double? fontSize, FontWeight? fontWeight}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: DS.fontFamilyFallback,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      );

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.bg0,
    fontFamily: fontFamily,
    fontFamilyFallback: DS.fontFamilyFallback,
    extensions: [colors],
    // Seeded from the brand gold, but surfaces are pinned to the DS
    // palette so menus, dialogs and pickers match the cool-grey cards
    // instead of the warm tones the seed would generate.
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.brand,
      brightness: brightness,
    ).copyWith(
      primary: colors.brandText,
      onPrimary: colors.onBrand,
      surface: colors.bg1,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      surfaceContainerLowest: colors.bg0,
      surfaceContainerLow: colors.surfaceBottom,
      surfaceContainer: colors.overlay,
      surfaceContainerHigh: colors.overlay,
      surfaceContainerHighest: colors.tileTop,
      outline: colors.hairlineStrong,
      outlineVariant: colors.hairline,
      error: colors.down,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      foregroundColor: colors.textPrimary,
    ),
    textTheme: (brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
          fontFamily: fontFamily,
          bodyColor: colors.textPrimary,
          displayColor: colors.textPrimary,
        ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.textPrimary,
        foregroundColor: colors.bg0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DS.radiusPill)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colors.brandText),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.brand : colors.textSecondary,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.onBrand : colors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.brand : colors.tileTop,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.tileTop,
      selectedColor: colors.brand,
      side: BorderSide(color: colors.hairline),
      labelStyle: text(color: colors.textSecondary),
      secondaryLabelStyle: text(color: colors.onBrand),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: DS.segmentedButtonStyle(colors, colors.brand),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.bg1,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colors.brand,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? colors.onBrand : colors.textTertiary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text(
          color: states.contains(WidgetState.selected) ? colors.textPrimary : colors.textTertiary,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.bg1,
      indicatorColor: colors.brand,
      selectedIconTheme: IconThemeData(color: colors.onBrand),
      unselectedIconTheme: IconThemeData(color: colors.textTertiary),
      selectedLabelTextStyle: text(color: colors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: text(color: colors.textTertiary, fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}
