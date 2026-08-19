# Qima

**Qima** (Arabic: *قيمة*, "value") is a precious-metals-first portfolio tracker
for phones, tablets, desktop and the web. It follows spot prices for gold,
silver, platinum and palladium alongside crypto, equities, indices and
currencies — valued in whatever currency and unit you actually think in, from
troy ounces to grams to 21-karat gold per gram.

One Flutter codebase across iOS, Android, macOS, Windows, Linux, Web and Wear
OS, built on a shared domain layer that every screen and platform surface
reads from.

[![License: MIT](https://img.shields.io/badge/License-MIT-informational.svg)](LICENSE)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web%20%7C%20Wear%20OS-lightgrey.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg)

---

## Features

**Watchlist** — track any mix of metals, crypto, equities, indices and fiat
pairs. The same instrument can appear more than once with a different display
currency or unit, so gold in USD per ounce and gold in EGP per gram sit side by
side as separate cards.

**Real units, real currencies** — every quote is stored canonically in USD per
troy ounce (or per unit) and converted at display time. Metals convert to
grams and kilograms; gold additionally breaks down by 24K/22K/21K/18K purity,
the way Gulf and Middle-East jewellery markets quote it. Fiat instruments are
quoted against your display currency, which makes cross-pairs like EUR shown in
JPY fall out for free.

**Custom tickers** — add any stock, ETF or index ticker not already in the
built-in catalog, validated live against the price provider before it's saved.

**Holdings and P/L** — record lots with a quantity, unit, purchase price and
currency. Qima aggregates them into canonical quantity, cost basis,
weighted-average unit cost, and unrealised gain, converted into your base
currency.

**Charts** — 1D through 5Y plus YTD and all-time, with scrubbing, range-aware
axis labels, and change figures scoped to the visible window. Non-USD charts use
*historical* FX at each point, so a chart in EGP shows real movement rather than
today's rate applied to yesterday's prices.

**Home-screen widgets** — a configurable price widget and a whole-portfolio
value widget on Android; see [Known limitations](#known-limitations) for iOS
and macOS.

**Wear OS** — a read-only companion watchlist, running off the same shared
engine, packaged in the same app.

**Localised** — English, Arabic, Spanish and French, with full right-to-left
layout for Arabic and an in-app language override.

**Private by design** — no accounts, no analytics, no tracking. All data is
stored locally on-device. See [Privacy](#privacy).

---

## Requirements

| | |
|---|---|
| Flutter | Latest stable channel |
| Platform toolchains | Xcode (iOS/macOS), Android SDK, or nothing extra for Web |

---

## Getting started

```bash
flutter pub get
flutter run
```

Pick a device/target with `flutter run -d <device>` (e.g. `macos`, `chrome`,
an iOS simulator id, or a connected Android device).

---

## Running the tests

```bash
flutter analyze
flutter test
```

71 tests cover the money math, unit conversion, FX handling (current and
historical), quote-series analytics, chart sampling, scrubbing and holdings
valuation — everywhere a silent arithmetic error would misreport someone's
wealth.

---

## Project layout

```
lib/
  models/      Instruments, money, quotes, holdings, chart ranges
  services/    Providers, repository, persistence, sync engine
  theme/       Design system, chart view
  blocs/       App-wide state (flutter_bloc)
  screens/     Watchlist, detail, holdings, settings, add-instrument
  l10n/        ARB translations (en · ar · es · fr)
  widgets/     Shared widget building blocks
android/       Android app + Jetpack Glance home-screen widgets
ios/ macos/    Native platform shells
windows/ linux/web/  Native platform shells
test/          Unit tests for the domain layer
```

---

## Architecture

Data flows one way, and every surface reads the same path:

```
Providers  ->  PriceRepository  ->  Stores (local storage)  ->  AppCubit  ->  Screens
                                                                 WatchCards -> Widgets
```

**`QuoteProvider`** is the seam for pricing. Routing is by asset class alone, so
adding a source means adding one type; swapping Yahoo for a licensed feed is a
single-file change.

- `GoldAPIProvider` — metals and crypto spot (`api.gold-api.com`)
- `YahooQuoteProvider` / `YahooHistoryProvider` — equities, indices and
  historical series (`query1.finance.yahoo.com`)
- `ExchangeRateAPIProvider` — FX rates for 160+ currencies (`open.er-api.com`)
- `FiatQuoteProvider` — prices fiat instruments off the live FX table

**`PriceRepository`** owns the wiring: routing, FX, history backfill and widget
reloads, so refresh behaviour is identical everywhere it's used.

**Persistence** is local JSON storage on native platforms (via
`path_provider`) and `shared_preferences`-backed storage on Web. User-owned
collections (watchlist, holdings, custom tickers) go through `SyncedStore`,
a last-write-wins-per-item merge engine with soft-delete tombstones — the
plumbing multi-device sync needs, currently wired to a local-only backend (see
[Known limitations](#known-limitations)).

**`InstrumentCatalog`** is data, not code paths. Adding an instrument is one
line; the watchlist, add-flow, detail screen and widget configuration are all
driven off that list.

**Canonical pricing** is the invariant worth knowing before changing anything:
everything is stored in USD, per troy ounce for metals and per unit otherwise.
Currency, unit and karat are presentation concerns applied by `PriceConverter`
at the last moment — which is why the same series can be re-rendered in any
currency without refetching.

---

## Data sources

Qima uses free, keyless public endpoints — there is no API key to configure and
nothing to sign up for.

> **Note:** Yahoo Finance's chart endpoint is *unofficial* (the public API was
> retired). It is a good fit for personal use, but it carries no stability or
> terms-of-service guarantee. Swap in a licensed feed before distributing
> commercially. The `QuoteProvider` protocol keeps that a single-file change.

Prices are indicative and may be delayed or wrong. Qima is a tracking tool, not
financial advice.

---

## Known limitations

This is an active rewrite of a native Swift app into a single cross-platform
Flutter codebase. A few things are intentionally incomplete rather than faked:

- **Web + Yahoo Finance**: browsers enforce CORS, and Yahoo's chart endpoint
  doesn't send permissive CORS headers. On Web, stock/index prices and all
  historical charts sourced from Yahoo (which includes metal and crypto
  *history*, not their live spot price) can't be fetched directly from the
  browser. Metals/crypto spot prices and live FX rates work fine there —
  `gold-api.com` and `open.er-api.com` both send `Access-Control-Allow-Origin:
  *`. This isn't fixable without introducing a backend, which is out of scope.
- **iOS/macOS home-screen widgets**: WidgetKit extensions require native Xcode
  target creation (provisioning, App Groups) that can't be safely scripted
  blind. See `WIDGETS_IOS_SETUP.md` for the exact steps to finish wiring it.
- **watchOS**: a true Apple Watch app needs native Swift (Flutter has no
  watchOS target). See `WATCHOS_SETUP.md` for how to point the original app's
  watch companion at this project's data contract.
- **Multi-device sync**: the `SyncedStore` merge engine is fully implemented
  and tested, but currently backed by local-only storage. Wiring a real
  iCloud/cloud key-value backend behind the same interface is the remaining
  step for cross-device sync.

---

## Privacy

Qima has no accounts, no analytics and no tracking SDKs. Holdings and
watchlist data are stored locally on your device. The only network traffic is
anonymous HTTPS price and FX requests to the endpoints listed above; no user
data is attached to them.

---

## Contributing

Issues and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md)
for the workflow.

## License

[MIT](LICENSE) © DevLab Technologies
