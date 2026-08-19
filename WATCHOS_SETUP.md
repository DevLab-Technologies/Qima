# Finishing the watchOS companion

Per your decision earlier in this project, the watchOS companion stays a
**native Swift app**, not a Flutter one — Flutter has no watchOS target at
all, so this is the one platform in scope that can't be Dart. The good news:
the original Qima repo already has a complete, working, tiny watchOS app at
`/Users/elkhayyat/Dev/Qima/Watch/QimaWatchApp.swift`, and it needs almost no
changes — it's read-only, has no dependency on a paired phone app to
function (it fetches its own prices via its own `PriceRepository`), and
already reuses the exact same `Shared/Models`/`Shared/Services` Swift
domain layer that the rest of the original app used. This doc is the
checklist to embed it as a companion of the Flutter iOS app, in place of the
original native Swift phone app it used to pair with.

## Why this needs Xcode, not a script

Apple requires a watchOS app to be bundled *inside* its paired iOS host
app's Xcode project as a companion target — it can't be an independently
distributed app that happens to talk to a different bundle id. Since
`ios/Runner.xcodeproj` (the Flutter app's iOS project) is a different
Xcode project from the original `/Users/elkhayyat/Dev/Qima/Qima.xcodeproj`,
the watch target has to be re-created inside `Runner.xcodeproj` — this is
inherently a GUI target-creation + provisioning-profile task, the same
category of work as the iOS/macOS WidgetKit extension in
`WIDGETS_IOS_SETUP.md`.

## Steps

1. **Copy the domain layer.** Add a new group to `ios/Runner.xcodeproj`
   (e.g. `WatchShared`) and copy in the Swift files from
   `/Users/elkhayyat/Dev/Qima/Shared/Models/` and
   `/Users/elkhayyat/Dev/Qima/Shared/Services/` (plus `Shared/Theme/` for
   `DS`/`Theme` used by `WatchRow`) — these are unmodified, already-tested
   Swift files with zero Flutter dependency; they only need to compile into
   the new watch target. This is the same domain logic the Dart layer in
   this repo (`lib/models/`, `lib/services/`) was independently ported
   from, so the watch app's math (money formatting, conversions, karat
   scaling, etc.) already matches the phone app's — no re-verification
   needed there.
2. **File → New → Target → Watch App** in `ios/Runner.xcworkspace`, name it
   `QimaWatch`. Replace its generated `ContentView`/`App` files with
   `/Users/elkhayyat/Dev/Qima/Watch/QimaWatchApp.swift` (copy, don't move —
   keep the original repo intact), add the `WatchShared` group's files to
   the new target's compile sources, and copy
   `Watch/Assets.xcassets/AppIcon.appiconset/` into the new target's asset
   catalog.
3. **App Group.** Add the same `group.com.devlabtechnologies.qima` App
   Group capability to the `QimaWatch` target that you set up for the
   widget extension in `WIDGETS_IOS_SETUP.md` — `AppGroup.swift` (part of
   the copied `Shared/Services/`) reads/writes through this container, and
   it must be the *same* group id the Flutter iOS app's widget/App Group
   setup uses so both can eventually share cached price data.
4. **iCloud key-value storage capability** — add it to both the `Runner`
   and `QimaWatch` targets (Signing & Capabilities → `+ Capability` →
   iCloud → check "Key-value storage"). This is what lets the watch app's
   `WatchlistStore` see the same watchlist as the phone app once sync is
   wired (next section) — note ad-hoc/development signing without a real
   Apple Development identity silently strips this entitlement, per the
   original README's warning.
5. Build & run the `QimaWatch` scheme on a watchOS simulator/device paired
   with the Runner app to confirm it boots, shows its own watchlist (empty
   until synced or seeded), and fetches live prices independently.

## The sync gap (important — read before assuming this "just works")

The watch app's `WatchlistStore` is a `SyncedStore` reading from
`NSUbiquitousKeyValueStore` (iCloud) + a local app-group JSON file — real
iCloud sync, exactly as the original app had it. **This Flutter rewrite's
own sync layer (`lib/services/synced_store.dart`) is currently stubbed as
local-only** (`LocalOnlyCloudKVStore`, a no-op — this was an explicit,
documented decision earlier in the project: iCloud sync via platform
channel on iOS/macOS was scoped as a *follow-up*, not part of the initial
domain-layer pass). Until that follow-up lands:

- The watchOS companion will run standalone (it fetches its own live
  prices independently, so it's never *broken* — it just won't show
  whatever watchlist the Flutter phone app has, and any watchlist you build
  on the watch itself won't reach the phone).
- To make the two apps' watchlists actually converge, the Flutter iOS app
  needs a platform channel that reads/writes the exact same iCloud KVS +
  app-group file `SyncedStore` uses (`watchcards.records.json` /
  `holdings.records.json`, see `qima_spec.md` §2.10) — that channel is the
  real remaining piece of work, not anything on the watch side, which
  already speaks this format natively.

## What's out of scope here

Nothing on the watch app needs to change to support this — it was already
written to be a thin, independent, glanceable consumer of the shared
engine. The only "new" work is Xcode target plumbing (steps 1–5) and,
eventually, the iCloud sync bridge described above.
