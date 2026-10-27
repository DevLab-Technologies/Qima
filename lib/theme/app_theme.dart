import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
///
/// Every text style uses tabular figures, so prices, balances and
/// percentages line up digit-for-digit down a list and don't jitter as
/// they refresh.
ThemeData buildTheme(Brightness brightness, {Locale? locale}) {
  final colors = brightness == Brightness.dark ? QimaColors.dark : QimaColors.light;
  final fontFamily = locale == null ? null : DS.fontFamilyFor(locale);
  TextStyle text({Color? color, double? fontSize, FontWeight? fontWeight}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: DS.fontFamilyFallback,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFeatures: _tabularFigures,
      );

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.bg0,
    fontFamily: fontFamily,
    fontFamilyFallback: DS.fontFamilyFallback,
    extensions: [colors],
    adaptations: [_CupertinoSwitchAdaptation(colors)],
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
      // When content scrolls under it, the bar is tinted with a neutral
      // rather than Material's default (the gold primary), which reads as
      // a warm brown band against the cool-grey screens.
      surfaceTintColor: colors.textPrimary,
      // App bars are transparent over the screen background, which would
      // otherwise make Flutter guess light status-bar icons — invisible on
      // the light palette.
      systemOverlayStyle: overlayStyleFor(brightness),
    ),
    textTheme: _withTabularFigures(
      (brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
            fontFamily: fontFamily,
            bodyColor: colors.textPrimary,
            displayColor: colors.textPrimary,
          ),
    ),
    // Gold is the one primary-action color: filled buttons are the screen's
    // main call to action; secondary actions are outlined or text buttons.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.brand,
        foregroundColor: colors.onBrand,
        disabledBackgroundColor: colors.tileTop,
        disabledForegroundColor: colors.textTertiary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: text(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DS.radiusPill)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.hairlineStrong),
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
    // Material switches (Android, desktop). Every `Switch`/`SwitchListTile`
    // is `.adaptive`, so on iOS/macOS [_CupertinoSwitchAdaptation] applies.
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
      selectedColor: DS.selectedTint(colors, colors.brand),
      side: BorderSide.none,
      labelStyle: text(color: colors.textSecondary),
      secondaryLabelStyle: text(color: colors.textPrimary),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: DS.segmentedButtonStyle(colors),
    ),
    // The selected tab is marked by a gold icon and label, not a filled
    // indicator pill.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.bg1,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? colors.brandText : colors.textTertiary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text(
          color: states.contains(WidgetState.selected) ? colors.brandText : colors.textTertiary,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.bg1,
      indicatorColor: Colors.transparent,
      selectedIconTheme: IconThemeData(color: colors.brandText),
      unselectedIconTheme: IconThemeData(color: colors.textTertiary),
      selectedLabelTextStyle: text(color: colors.brandText, fontSize: 12, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: text(color: colors.textTertiary, fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}

const List<FontFeature> _tabularFigures = [FontFeature.tabularFigures()];

TextTheme _withTabularFigures(TextTheme theme) {
  TextStyle? tabular(TextStyle? style) => style?.copyWith(fontFeatures: _tabularFigures);
  return theme.copyWith(
    displayLarge: tabular(theme.displayLarge),
    displayMedium: tabular(theme.displayMedium),
    displaySmall: tabular(theme.displaySmall),
    headlineLarge: tabular(theme.headlineLarge),
    headlineMedium: tabular(theme.headlineMedium),
    headlineSmall: tabular(theme.headlineSmall),
    titleLarge: tabular(theme.titleLarge),
    titleMedium: tabular(theme.titleMedium),
    titleSmall: tabular(theme.titleSmall),
    bodyLarge: tabular(theme.bodyLarge),
    bodyMedium: tabular(theme.bodyMedium),
    bodySmall: tabular(theme.bodySmall),
    labelLarge: tabular(theme.labelLarge),
    labelMedium: tabular(theme.labelMedium),
    labelSmall: tabular(theme.labelSmall),
  );
}

/// Status-bar icons that stay legible on the [brightness] palette: dark
/// icons on the light background, light icons on the dark one.
SystemUiOverlayStyle overlayStyleFor(Brightness brightness) =>
    brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

/// On iOS/macOS an adaptive switch draws as a native Cupertino switch (white
/// thumb, no outline) but keeps the brand gold for its "on" track instead of
/// iOS's default green. The "off" track stays the Cupertino default.
class _CupertinoSwitchAdaptation extends Adaptation<SwitchThemeData> {
  final QimaColors colors;

  const _CupertinoSwitchAdaptation(this.colors);

  @override
  SwitchThemeData adapt(ThemeData theme, SwitchThemeData defaultValue) {
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? colors.brand : null,
          ),
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return defaultValue;
    }
  }
}
