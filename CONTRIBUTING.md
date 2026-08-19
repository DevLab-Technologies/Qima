# Contributing to Qima

Thanks for taking an interest. Bug reports, translations and focused pull
requests are all welcome.

## Before you start

- For anything beyond a small fix, open an issue first so we can agree on the
  approach. Qima keeps a deliberately small surface — a change that adds a
  screen, a dependency or a data source needs a reason.
- Dependencies are kept minimal and are all free, keyless, open-source
  packages (`flutter_bloc`, `http`, `shared_preferences`, `path_provider`,
  `intl`, `uuid`, `equatable`, `crypto`, `home_widget`). Anything that needs a
  paid key or an account belongs behind an issue and a discussion first.

## Setting up

```bash
flutter pub get
flutter run
```

Requires a recent stable Flutter SDK (`flutter doctor` should show no
blocking issues for whichever platform you're targeting).

## Tests

Every change to the domain layer (`lib/models/`, `lib/services/`) needs test
coverage, and the suite must be green before you open a pull request:

```bash
flutter analyze
flutter test
```

Tests are deterministic by rule: no wall-clock reads, no live network calls.
Anything that needs "now" takes an injected `DateTime`; FX tables and quotes
are constructed inline in the test.

Screens, widgets and platform-specific surfaces (home-screen widgets, Wear OS)
are verified manually; note in your PR what you checked and on which
platform.

## Code style

- Follow the surrounding code and standard `dart format`/`flutter analyze`
  conventions.
- Comments explain *why*, not *what*. Document invariants and the traps behind
  them; keep the comment density low otherwise.
- Respect the canonical-pricing invariant: prices are stored in USD, per troy
  ounce for metals and per unit otherwise. Currency, unit and karat are
  presentation concerns applied by `PriceConverter`. Do not persist converted
  values.
- User-facing strings are localized. Add the key to every ARB file under
  `lib/l10n/` (`app_en.arb`, `app_ar.arb`, `app_es.arb`, `app_fr.arb`) and run
  `flutter gen-l10n`. Check Arabic in RTL layout.

## Adding an instrument or a data source

- A new built-in instrument is usually one entry in `InstrumentCatalog`
  (`lib/models/instrument_catalog.dart`). Add its display-name key to every
  ARB file too.
- A genuinely new price source means a new `QuoteProvider` implementation
  plus routing in `PriceRepository` (`lib/services/`). Keep providers keyless
  and free where possible.

## Pull requests

- One concern per PR, with a description of what changed and why.
- State clearly whether `flutter analyze`/`flutter test` pass and what you
  verified by hand (which platform, which screens).

## Reporting a security issue

Please do not open a public issue. See [SECURITY.md](SECURITY.md).
