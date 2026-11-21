# watchOS

Qima has no Apple Watch app. Flutter has no watchOS target, so one would have
to be a native Swift app added to the iOS project. This note records what that
would take; none of it is built.

(Wear OS is different: the Android app adapts to a watch-sized screen and
shows a read-only watchlist. See `lib/screens/watch_watchlist_screen.dart`.)

## Why it needs Xcode

Apple requires a watchOS app to be bundled inside its paired iOS app's Xcode
project as a companion target. It would be a new target in
`ios/Runner.xcodeproj`, with its own App ID and provisioning profile, set up
the same way as the WidgetKit extension (see
[WIDGETS_IOS_SETUP.md](WIDGETS_IOS_SETUP.md)).

## What a watch app would need

1. **A Watch App target** in `ios/Runner.xcworkspace` (File › New › Target ›
   Watch App), written in SwiftUI.
2. **The App Group.** Add `group.com.devlabtechnologies.qima` to the new
   target. The iOS app already writes a widget snapshot there
   (`lib/services/widget_snapshot.dart`): prices, series, live FX rates and FX
   history in canonical USD. The widget extension under `ios/QimaWidget/`
   shows how to read and format it in Swift.
3. **A way to get data onto the watch.** An App Group is not shared between a
   phone and a watch, so the watch needs one of:
   - WatchConnectivity, with the iOS app sending the snapshot when it changes;
   - iCloud key-value storage, which the iOS app already uses for sync when
     the person turns it on (`ios/Runner/CloudKVPlugin.swift`);
   - fetching prices itself from the endpoints listed in the README.
4. **Signing.** A new App ID, the App Group and (if used) the iCloud
   capability on the watch target, and a provisioning profile for the release
   pipeline (`docs/store-release.md`).

## Rules to keep

- Money arithmetic on the watch must match the app: quotes are stored in USD,
  per troy ounce for metals, and converted for display at the last moment.
- A watch app is read-only unless it writes through the same book as the
  phone; it must not keep a second copy of balances.
