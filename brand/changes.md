# Changes from the current app

What the guidelines change compared with the code on `v3.1/design-polish`, why, and which files would need to change. No app code has been changed. Values to copy are in `tokens.json` and `flutter/qima_tokens.dart`.

Kept as is (and why): the dark palette, surfaces and trend colours (they pass contrast and were tuned in v3.1); the spacing scale (about 400 uses, tuned on device); the radii 14, 22 and 100; tabular figures; the Arabic small-text boost and no-tracking rule; the tint-selected chips from v3.1; the platform font for Latin in the app; Material Icons; the contrast test.

## 1. Colour

| # | Change | Why | Files |
|---|---|---|---|
| 1.1 | `textSecondary` dark 60% to 68%, light 70% to 76% | Secondary and tertiary were too close to tell apart (5.89 vs 4.81 on a tile in dark) | `lib/theme/qima_colors.dart` |
| 1.2 | Add `brandIndicator` (dark `#E6BA4D`, light `#A87B14`) | A gold that reaches 3:1 for UI marks in light mode | `qima_colors.dart`, `app_theme.dart` (Material switch track, focus) |
| 1.3 | Light `accentGold` `#A87B14` (unchanged value), now defined as equal to `brandIndicator` | One fewer gold to manage | `qima_colors.dart` |
| 1.4 | Light accents: silver `#8A8D93` to `#7A7D83`, platinum `#6F93B8` to `#5A7FA5`, crypto `#E0761A` to `#C2620F`, fiat `#1597A8` to `#10808F` | Were 2.79 to 3.14:1 on tiles; now at least 3.55:1 | `qima_colors.dart` |
| 1.5 | Add `success`, `warning`, `error`, `info` tokens | No semantic roles existed; warnings had no colour | `qima_colors.dart`; use in `alerts_screen.dart` (notifications off), `backup_screen.dart` (reminder card, unprotected warning), `export_backup_sheet.dart`, `zakat_settings_screen.dart` |
| 1.6 | Selected chips and range pills get a 1.5 px `brandIndicator` border | The wash alone is a weak state cue in light mode | `lib/theme/design_system.dart` (`DSChoiceChip`), `lib/widgets/range_selector.dart` (`_RangePill`) |
| 1.7 | Chart scrub ring uses `surfaceTop` instead of `Colors.white` | Raw white bypasses the theme | `lib/theme/price_chart.dart:389` |
| 1.8 | Website colours match the app: `--up #3DBE6E`, `--down #FF6B61`, text on gold `#08090C`; drop hover `#F0C863` or derive it | Two greens and reds across surfaces | `site/style.css` |

## 2. Typography

| # | Change | Why | Files |
|---|---|---|---|
| 2.1 | Ten named steps (`display` to `micro`) replace 17 ad hoc sizes | One scale to design and review against | Add to `lib/theme/design_system.dart` |
| 2.2 | Size 10 to `micro` 11 | Below comfortable reading size | `help_sheet.dart`, `price_chart.dart`, `stat_pill.dart` |
| 2.3 | 18 and 20 to `title2` 17 or `title1` 22, by role | Off-scale | 18: `export_backup_sheet.dart`, `watchlist_screen.dart`, `add_instrument_screen.dart`, `share_asset_sheet.dart`, `alert_editor_sheet.dart`. 20: `holdings_screen.dart`, `onboarding_illustrations.dart`, `help_sheet.dart`, `watch_watchlist_screen.dart` |
| 2.4 | 24, 26, 28, 32 to `title1` 22 or `hero` 30, by role | Off-scale | 24: `onboarding_tour_screen.dart`. 26: `onboarding_illustrations.dart`. 28: `holdings_screen.dart`. 32: `zakat_screen.dart` |
| 2.5 | Arabic line heights per the scale; Arabic boost extended from overlines to `caption` and `micro` | Almarai needs more leading; small Arabic reads small | `design_system.dart` (`DS.overline` and new steps) |
| 2.6 | Marketing uses Almarai for Latin as well as Arabic | One family across store art in both scripts | `tool/store_assets.py`, `tool/mac_store_media.sh`, `site/style.css` (add `@font-face`) |

## 3. Layout, components, motion

| # | Change | Why | Files |
|---|---|---|---|
| 3.1 | Add `space3XS` 2 and `radiusXS` 6; move the stray 7 to 6 | Name the values already in use | `design_system.dart`; `asset_share_card.dart:158` (7), `holdings_screen.dart:398`, `csv_import_screen.dart:505` |
| 3.2 | Motion tokens and `easeOutCubic`; onboarding 280 to 300 ms; range reveal 200 to 250 ms | One set of durations, matching the website's easing | `onboarding_tour_screen.dart:47`, `home_shell.dart:99`, `range_selector.dart:134` |
| 3.3 | Respect reduced motion | No handling today | Same three call sites, via `QimaMotion.movement` |
| 3.4 | Focus ring on every focusable control | Keyboard use on iPad, Mac, Windows, web | `app_theme.dart` (button, chip, input themes) |
| 3.5 | Touch targets at least 44 pt / 48 dp | Range pills render about 32 tall | `range_selector.dart`, `asset_class_filter.dart` |
| 3.6 | Icons: outlined at rest, filled only when selected or on | 113 filled and 62 outlined mixed today | All screens using `Icons.*`; start with app bar actions in `watchlist_screen.dart`, `instrument_detail_screen.dart` |
| 3.7 | Labels and tooltips on every icon-only button | Only 12 semantics labels or tooltips in the app | `watchlist_screen.dart`, `instrument_detail_screen.dart`, `portfolio_detail_screen.dart`, `holdings_screen.dart` |

## 4. Name

| # | Change | Why | Files |
|---|---|---|---|
| 4.1 | Arabic home-screen label قيمة | Owner answer 6 | iOS: add `ios/Runner/ar.lproj/InfoPlist.strings` with `CFBundleDisplayName`; Android: `android/app/src/main/res/values-ar/strings.xml` and point `android:label` at `@string/app_name`; macOS: `macos/Runner/ar.lproj/InfoPlist.strings` |
| 4.2 | Arabic in-app title stays قيمة; Latin "Qima" stays inside Arabic sentences | The rule in guidelines section 2; already how `app_ar.arb` is written | None |
| 4.3 | Keep the name out of all-caps overlines | Would render QIMA | Check any `toUpperCase()` on strings containing the name |

## 5. Copy

| # | Change | Files |
|---|---|---|
| 5.1 | The eleven rewrites in guidelines section 8 | `lib/l10n/app_en.arb`, then `app_ar.arb`, `app_es.arb`, `app_fr.arb` with native review; regenerate `app_localizations*.dart`. `addCustomTickerError` gains a `{symbol}` placeholder: `custom_ticker_screen.dart` |
| 5.2 | Website: hero copy, remove "tolas", hold widget line, fix "deleted when you uninstall", outlined wordmark in header | `site/index.html` |
| 5.3 | Store descriptions list zakat, allocation, alerts, app lock and backup; subtitle and promo text per section 10 | `ios/fastlane/metadata/*/description.txt`, `subtitle.txt`, `promotional_text.txt`; `android/fastlane/metadata/android/*/full_description.txt` |
| 5.4 | README: remove or qualify Wear OS (pending answer 15); refresh the test count | `README.md` |

## 6. Assets

| # | Change | Why | Files |
|---|---|---|---|
| 6.1 | **Not doing.** Owner answer 22: keep the current app icon. Kept for reference: refined app icon (no arrowhead, level end node) | Arrow implies gains | Would replace `assets/icon/app_icon.png` with `brand/assets/icon/png/qima-app-icon-1024.png`; run `python3 tool/macos_icon.py` then `dart run flutter_launcher_icons`; add `adaptive_icon_monochrome` in `pubspec.yaml`; add iOS 18 dark and tinted appearances to `ios/Runner/Assets.xcassets/AppIcon.appiconset` |
| 6.2 | Delete the duplicate `icon-master-1024.png` in the repo root | Byte-identical to `assets/icon/app_icon.png` | repo root |
| 6.3 | Website logo and favicons from the new exports | Re-typed logo today | `site/img/logo.png`, `favicon-32.png`, `apple-touch-icon.png`, `og.png` |
| 6.4 | Regenerate store screenshots after v3.1 and these changes; captions per section 10 | Current set predates v3.1 (solid-gold chips, Eastern digits) | `integration_test/store_screenshots_test.dart`, `tool/store_screenshots.sh`, `tool/store_assets.py` |
| 6.5 | Play feature graphic with the lockup | | `android/fastlane/metadata/android/*/images/featureGraphic.png` |
