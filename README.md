# Qima

**Qima** (Arabic: *قيمة*, "value") keeps everything you own and owe in one
balance sheet: cash and bank accounts, cards, loans, money lent and borrowed,
holdings in gold, silver, crypto and stocks, and assets you value yourself,
such as land or a car. It works out your net worth, your spending and your
zakat from the same book.

One Flutter codebase for iOS, Android, macOS, Windows, Linux, Web and Wear OS.
There are no accounts and no server: the book lives on your device.

[![License: MIT](https://img.shields.io/badge/License-MIT-informational.svg)](LICENSE)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web%20%7C%20Wear%20OS-lightgrey.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B.svg)

Website: [qima.money](https://qima.money/)

---

## Features

The app has three tabs: **Home**, **Money** and **Prices**.

**A double-entry book** — every transaction is a balanced entry between
accounts, so the balance sheet always adds up. Spend, income and transfers
share one "New transaction" page; accounts can be in any currency.

**Net worth** — a dated history of what you own and owe, with charts. Assets
you value by hand keep every valuation you enter; Qima never invents a value
between two of them.

**Budgets and planned payments** — monthly budgets by category, a single
"left to spend" figure, and bills or income that repeat weekly, monthly,
quarterly or yearly, with a reminder the day before.

**People** — money lent and borrowed is netted per person and currency, and a
bill can be split by amount, equally, by percent or by shares.

**Statement import** — bring in PDF statements (text or scanned), screenshots,
CSV and XLSX files, and bank text messages. Every import goes through a review
screen first; nothing is saved until you confirm it. Android can read bank SMS
with your permission; on iOS a Shortcuts automation hands messages to the app.

**Voice and receipts** — say a transaction or photograph a receipt. Both are
read on the device. See [Privacy](#privacy).

**Prices and holdings** — a watchlist of metals, crypto, equities, indices and
currency pairs, in the currency and unit you think in: troy ounces, grams,
kilograms, and gold by 24K/22K/21K/18K purity. Holdings track quantity, cost
basis and unrealised gain. Charts run from 1D to all-time and use *historical*
exchange rates at each point.

**Zakat** — worked out over the whole book, on a Hijri year, with a reminder
when it falls due.

**Alerts** — price alerts delivered as local notifications, checked by a
background refresh.

**Home-screen widgets** — configurable price and portfolio widgets on iOS,
macOS and Android, plus a watchlist widget on iOS and macOS. See
[WIDGETS_IOS_SETUP.md](WIDGETS_IOS_SETUP.md).

**Backup and restore** — one file with the whole book, optionally protected
with a password (AES-256-GCM, key derived with PBKDF2). Restore by merging or
replacing, with a before/after preview.

**App lock** — Face ID, fingerprint or the device passcode.

**AI apps on the desktop** — optionally let apps that speak the Model Context
Protocol read the book through a local, read-only helper. Off by default. See
[docs/ai-apps.md](docs/ai-apps.md).

**Localised** — English, Arabic, Spanish and French, with full right-to-left
layout for Arabic.

---

## Requirements

| | |
|---|---|
| Flutter | 3.41.6 (the version CI pins in `.github/workflows/ci.yml`) |
| iOS / macOS | Xcode |
| Android | Android SDK and a JDK |
| Windows / Linux | The Flutter desktop toolchain and CMake 3.28 or later |
| Web | Nothing extra |

The Windows and Linux builds download the llama.cpp sources at a pinned
version the first time they are configured, so the first build needs a network
connection.

---

## Getting started

```bash
flutter pub get
```

```bash
flutter run
```

Pick a target with `flutter run -d <device>` (for example `macos`, `chrome`,
an iOS simulator id or a connected Android device).

Debug builds need no signing setup, keys or accounts. Release signing and the
store pipelines are described in [docs/store-release.md](docs/store-release.md)
and only matter to maintainers.

---

## Running the tests

```bash
flutter analyze
```

```bash
flutter test
```

More than 1,100 tests cover the book and its arithmetic, currency and unit
conversion, statement and message reading, spoken-entry parsing, zakat, import
matching, backup, and the main screens. They are deterministic: no wall-clock
reads and no live network calls.

---

## Project layout

```
lib/
  models/      The book (accounts, entries, valuations), money, instruments,
               statement and message readers, zakat, net worth
  services/    Price providers, stores, sync, import, backup, alerts,
               on-device model and speech bridges
  blocs/       App state (flutter_bloc): AppCubit, MoneyCubit, ImportCubit
  screens/     Home shell, prices, holdings, zakat, settings
    money/     Home, Money, accounts, balance sheet, import review
  widgets/     Shared widget building blocks
  theme/       Design system, chart view, help topics
  mcp/         The read-only helper for AI apps on the desktop
  l10n/        ARB translations (en, ar, es, fr)
packages/
  qima_llm/    FFI plugin that runs a small model with llama.cpp
               (Windows and Linux)
android/       Android app, Glance widgets, bank SMS reader
ios/ macos/    Apple apps, WidgetKit extension, share extension (iOS)
windows/ linux/ web/   Platform shells
test/          Unit and widget tests
integration_test/      Store screenshot runs
tool/          Asset, string and screenshot scripts
site/          The qima.money website
brand/         Brand tokens and guidelines
docs/          Release, AI apps and planning notes
```

---

## Architecture

**The book** is the source of truth for money. `Book` holds accounts and
balanced entries; `MoneyCubit` owns it and `BookStore` persists it. Net worth,
budgets, people, zakat and the balance sheet are all computed from the book
rather than stored, so every screen agrees.

**Prices** flow one way:

```
Providers  ->  PriceRepository  ->  Stores (local storage)  ->  AppCubit  ->  Screens
                                                                           ->  Widgets
```

`QuoteProvider` is the seam for pricing. Routing is by asset class alone, so
adding a source means adding one type.

- `GoldAPIProvider` — metals and crypto spot (`api.gold-api.com`)
- `YahooQuoteProvider` / `YahooHistoryProvider` — equities, indices and
  historical series (`query1.finance.yahoo.com`)
- `ExchangeRateAPIProvider` — FX rates (`open.er-api.com`)
- `FiatQuoteProvider` — prices fiat instruments off the live FX table

**Canonical pricing** is the invariant worth knowing before changing anything:
quotes are stored in USD, per troy ounce for metals and per unit otherwise.
Currency, unit and karat are presentation concerns applied by `PriceConverter`
at the last moment, which is why the same series can be shown in any currency
without refetching.

**Persistence** is local JSON storage on native platforms (via
`path_provider`) and `shared_preferences`-backed storage on Web. Synced
collections go through `SyncedStore`, a last-write-wins-per-item merge engine
with soft-delete tombstones. Its cloud backend is iCloud key-value storage on
Apple platforms, off until you turn it on in Settings, and local-only
everywhere else.

**Reading statements and messages** is rule-based first (`StatementReader`,
`SpokenEntry`). An on-device model is an optional second reader behind
`AiAssistProvider`; its output is accepted only when it keeps your own numbers
unchanged and adds none.

---

## Data sources

Qima uses free, keyless public endpoints. There is no API key to configure and
nothing to sign up for.

> **Note:** Yahoo Finance's chart endpoint is *unofficial* (the public API was
> retired) and carries no stability or terms-of-service guarantee. The
> `QuoteProvider` seam keeps replacing it a single-file change.

Prices are indicative and may be delayed or wrong. Qima is a tracking tool, not
financial advice.

---

## Known limitations

- **Web**: browsers enforce CORS and Yahoo's chart endpoint does not allow
  cross-origin requests, so stock and index prices and all historical charts
  are unavailable on Web. Metal and crypto spot prices and live FX work. The
  on-device model, voice input and receipt scan are not available on Web.
- **Sync**: cross-device sync exists only through iCloud on Apple platforms.
  Android, Windows, Linux and Web keep the book on one device; use Backup to
  move it.
- **Mac widgets and iCloud** need the App Store build's entitlements; they do
  not work in a locally signed build.
- **watchOS**: there is no Apple Watch app. See
  [WATCHOS_SETUP.md](WATCHOS_SETUP.md).
- **Share to Qima** is an iOS share extension only; Android and macOS import
  through the file picker or paste.

---

## Privacy

Qima has no accounts, no analytics and no tracking SDKs. The book, watchlist
and settings are stored on your device, and in your own iCloud if you turn
sync on. Network traffic is limited to:

- anonymous HTTPS price and FX requests to the endpoints listed above, with no
  user data attached;
- on Windows and Linux, a one-time download of the model file when you turn
  the on-device model on (see below).

The full policy is in [`site/privacy.html`](site/privacy.html).

### On-device model

The model is off until you turn on Settings · On-device intelligence. It
reads bank messages the built-in rules cannot. What runs depends on the
platform:

- **iOS and macOS 26** — Apple's on-device Foundation Model
  (`SystemLanguageModel.default`, never Private Cloud Compute). Here it also
  reads purchases and words the month summary.
- **Android** — Gemini Nano through Google's ML Kit, on devices that have it.
  The model runs on the device; ML Kit itself reports usage figures to
  Google, which is why it is not touched until you turn the setting on.
- **Windows and Linux** — Qwen2.5-1.5B-Instruct (Apache 2.0), run on the CPU
  by llama.cpp. The model file is downloaded once from Hugging Face at a
  pinned revision and checked against a SHA-256 hash.
- **Web** — not available.

### Bank messages

On Android, Qima reads SMS only after you grant the permission, and reads them
on the device. On iOS, a Shortcuts automation you set up yourself passes each
message to the app. Account, card and IBAN numbers are kept only as their last
four digits.

### Voice input

The mic uses the operating system's **on-device** speech recognizer only:
`requiresOnDeviceRecognition` on iOS and macOS, and the on-device
`SpeechRecognizer` on Android 12 and later. Audio and text never leave the
device. When the device has no on-device recognizer for the chosen language,
the mic says so and stays off; there is no server fallback. Web, Windows and
Linux have no voice input.

### Receipt scan

The scan button reads a receipt photo with Apple's on-device Vision text
recognition (iOS and macOS). The photo is not uploaded and not kept: the app's
copy is deleted as soon as its text is read, and nothing is saved until you
confirm the preview.

### AI apps

Off by default and desktop only. While it is on, Qima writes a copy of the
book to a local file that a helper serves, read-only, to the AI apps you
configure. Whatever such an app reads goes to that app's model provider. See
[docs/ai-apps.md](docs/ai-apps.md) for exactly what is included and left out.

---

## Third-party notices

- Almarai typeface — SIL Open Font License 1.1 (`assets/fonts/almarai/OFL.txt`)
- Riyal symbol font — MIT (`assets/fonts/riyal/LICENSE`)
- llama.cpp — MIT (`packages/qima_llm/LICENSE`)

---

## Contributing

Issues and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md)
for the workflow. Report security problems privately, as described in
[SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE) © DevLab Technologies
