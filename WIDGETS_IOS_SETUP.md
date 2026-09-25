# Home-screen widgets

## iOS (WidgetKit)

The `QimaWidgetExtension` target (`ios/QimaWidget/`, iOS 17+) ships two
widgets, each configured per placed instance with an App Intent:

| Widget | Sizes | Settings |
|---|---|---|
| Price (`PriceWidget`) | small, medium, lock-screen inline / circular / rectangular | asset (a watchlist card or another priced instrument), unit, karat, currency, chart range |
| Portfolio (`PortfolioWidget`) | small, medium, large, lock-screen rectangular | currency, chart range |

"Automatic" unit, karat and currency follow the picked watchlist card (or the
base currency for an instrument without a card).

### Data flow

The extension never fetches anything. After every widget-relevant state
change and every background refresh the app writes one JSON snapshot
(`lib/services/widget_snapshot.dart`) to the App Group
`group.com.devlabtechnologies.qima` under `widget_snapshot`, then reloads the
`PriceWidget` / `PortfolioWidget` timelines
(`lib/services/home_widget_service.dart`). The snapshot holds canonical-USD
series per instrument and range, live FX rates and FX history; the extension
(`ios/QimaWidget/Snapshot.swift`) applies the app's own conversion rules, so
any unit/karat/currency combination prices exactly as it does in the app.

Bump `WidgetSnapshot.schemaVersion` and `Snapshot.supportedVersion` together
whenever the shape changes.

### Strings

`ios/QimaWidget/<lang>.lproj/Localizable.strings` is generated: asset, unit,
karat and range names come from the app's ARB files, widget-only phrases
from `tool/widget_strings.json`. Regenerate after changing either:

```sh
python3 tool/generate_widget_strings.py
```

### Signing

Bundle ID `com.devlabtechnologies.qima.widget`, App Group as above. Release
builds sign it with the `IOS_WIDGET_PROVISION_PROFILE_BASE64` profile (see
`docs/store-release.md`).

## Android (Glance)

`android/app/src/main/kotlin/com/devlabtechnologies/qima/widget/` has a price
widget (the first watchlist card) and a portfolio widget (base currency),
fed by the precomputed `price_widget_data` / `portfolio_widget_data` blobs.
They have no per-widget settings yet.

## macOS

`QimaWidgetExtension` in `macos/Runner.xcodeproj` (macOS 14+) compiles the
same Swift sources, strings and fonts as iOS (the `Shared` group points at
`ios/QimaWidget`), with the small, medium and large families. `home_widget`
has no macOS implementation, so the Mac runner's `WidgetBridgePlugin`
writes the snapshot to the team-prefixed App Group
`ZS3A435WC2.com.devlabtechnologies.qima` and reloads the timelines. The App
Group (like iCloud) is only in `AppStore.entitlements`, so Mac widgets work
in App Store / TestFlight builds, not in the direct-download zip.
