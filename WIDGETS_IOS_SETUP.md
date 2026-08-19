# Finishing the iOS/macOS home-screen widgets

Android's Price and Portfolio widgets are fully implemented (Jetpack Glance,
see `android/app/src/main/kotlin/com/devlabtechnologies/qima/widget/`) and
build cleanly today. iOS/macOS need a WidgetKit extension, which is a native
Xcode target — something a Flutter CLI/agent can't safely scaffold blind
(it needs Xcode's own target-creation flow, an App Group entitlement, and a
provisioning profile tied to a real Apple Developer team). This doc is the
checklist to finish it by hand.

## What's already done (Flutter side)

`lib/services/home_widget_service.dart` writes two JSON blobs via the
`home_widget` package after every successful refresh:

| Key | Written when | Shape |
|---|---|---|
| `price_widget_data` | always | `{available, symbol, currency, price, compactPrice, unitSuffix, karatLabel, changePercent, isUp, hasChange, sparkline: [double], accentColor: int (ARGB32), updatedAtMillis}` or `{available: false}` |
| `portfolio_widget_data` | always | `{available, currency, value, cost, gain, percent, isUp, updatedAtMillis}` or `{available: false}` |

Today every placed widget instance shows the same thing: the price widget
mirrors the *first* watchlist card, the portfolio widget mirrors the base
currency. Per-instance configuration (picking an instrument/currency/unit/
range per widget, per spec §5.1) is a later enhancement — see "Next steps"
below.

`HomeWidget.updateWidget(...)` is called with `iOSName: 'PriceWidget'` /
`'PortfolioWidget'` after each write — these must match the WidgetKit kind
strings you create below.

## Steps in Xcode

1. **Add an App Group.** In `ios/Runner.xcworkspace` (and separately for
   `macos/Runner.xcworkspace`), select the Runner target → Signing &
   Capabilities → `+ Capability` → App Groups → add
   `group.com.devlabtechnologies.qima` (matches the bundle id already used
   by `pubspec.yaml`'s `com.devlabtechnologies` org). Repeat for the widget
   extension target once it exists (step 2) — both must share the same
   group id, since that's how `home_widget` hands data from the Flutter
   process to the extension process.
2. **File → New → Target → Widget Extension**, name it `QimaWidget`, uncheck
   "Include Configuration Intent" for a first pass (add it back for
   per-instance config later). Do this once for iOS, once for macOS (or a
   multiplatform target if your Xcode version supports it).
3. In the generated `QimaWidget.swift`, define two `Widget`s with `kind:
   "PriceWidget"` and `kind: "PortfolioWidget"` respectively (a
   `WidgetBundle` hosts both from one extension). Read data via
   `UserDefaults(suiteName: "group.com.devlabtechnologies.qima")`, keys
   `price_widget_data` / `portfolio_widget_data` (the `home_widget` plugin
   writes JSON strings under these exact keys in the shared group's
   defaults) — `JSONSerialization` the string back into a dictionary and
   render it. Reference `qima_spec.md` §5.1/§5.2 (or the original Swift
   app's `Widget/` target at `/Users/elkhayyat/Dev/Qima/Widget/` if still
   present) for layout fidelity — small/medium sizes at minimum.
4. Add the App Group's container URL entitlement to both the widget
   extension's and the Runner target's entitlements files (mirrors
   `com.apple.security.application-groups` — same pattern the original
   Swift app used in `AppGroup.swift`).
5. Build & run once with the widget target selected as the scheme to catch
   entitlement/provisioning errors before wiring it back into the main
   Runner scheme's build.
6. Long-press the iOS/macOS home screen or Notification Center → add the
   Qima widget → confirm it shows live data after the app has run at least
   once (the extension only reads what the app last wrote — it never
   fetches network data itself, matching the original app's `reloadsWidgets:
   false` design so the extension never triggers its own refresh cycle).

## Next steps (not required to ship a first working widget)

- Per-instance configuration: add `AppIntentConfiguration` (iOS 17+/macOS
  14+, matching this app's deployment target) with an `InstrumentEntity`
  picker, mirroring spec §5.3. Requires the Flutter side to key its writes
  by widget id instead of a single shared blob — a real (if contained)
  follow-up change to `home_widget_service.dart`.
- Widget refresh interval (`Preferences.widgetRefreshInterval`) currently
  only affects how *often the Flutter app itself* re-publishes; the
  WidgetKit `TimelineProvider`'s own `.after(...)` reload policy should be
  set from the same value once the extension exists.
