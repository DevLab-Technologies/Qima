# Contributing to Qima

Thanks for taking an interest. Bug reports, translations and focused pull
requests are all welcome.

## Before you start

- For anything beyond a small fix, open an issue first so we can agree on the
  approach. A change that adds a screen, a dependency, a permission or a
  network call needs a reason.
- Qima's promise is that the book stays on the device. A change must not add
  analytics, tracking, accounts, or a network request beyond the price and FX
  endpoints listed in the README. Anything that would send user data off the
  device will not be merged.
- Dependencies are listed in `pubspec.yaml`. New ones must be open source and
  work without a paid key or an account; raise them in an issue first.

## Setting up

Use the Flutter version CI pins (`FLUTTER_VERSION` in
`.github/workflows/ci.yml`), then:

```bash
flutter pub get
```

```bash
flutter run
```

Debug builds need no signing keys. Turn on the pre-commit hook once per clone;
it refuses to commit signing material:

```bash
git config core.hooksPath .githooks
```

Windows and Linux builds also need CMake 3.28 or later, and fetch the
llama.cpp sources the first time they are configured.

## Tests

The suite must be green before you open a pull request:

```bash
flutter analyze
```

```bash
flutter test
```

- Every change to the domain layer (`lib/models/`, `lib/services/`,
  `lib/blocs/`) needs test coverage. Screens have widget tests under
  `test/screens/` and `test/widgets/`; extend them when you change a screen.
- Tests are deterministic: no wall-clock reads and no live network calls.
  Anything that needs "now" takes an injected `DateTime`; FX tables and quotes
  are built inline in the test.
- Never put real financial data in tests or fixtures: no real statements, bank
  messages, card or account digits, names or amounts. Make them up.
- Platform surfaces that tests cannot reach (home-screen widgets, Wear OS,
  share extension, SMS reading, speech) are checked by hand. Say in your pull
  request what you checked and on which platform.

CI analyzes, tests and builds Web, Android, macOS, Windows and Linux on every
pull request. Runs from first-time contributors wait for a maintainer's
approval.

## Code style

- Follow the surrounding code. Do not run `dart format` over existing files:
  they are not formatted at the default line width, and a reformat buries the
  real change. Keep the diff to the lines you mean to change.
- Comments explain *why*, not *what*. Document invariants and the traps behind
  them; keep the comment density low otherwise.
- Money goes through the book. A transaction is a balanced entry built by
  `EntryBuilder`; do not write balances directly. Totals such as net worth,
  budgets and zakat are computed from the book, not stored.
- Respect the canonical-pricing invariant: quotes are stored in USD, per troy
  ounce for metals and per unit otherwise. Currency, unit and karat are
  presentation concerns applied by `PriceConverter`. Do not persist converted
  values.
- Never invent a figure. Asset values exist only on the days someone entered
  them, and a model's reading is accepted only when it keeps the person's own
  numbers.
- User-facing strings are localized. Add the key to every ARB file under
  `lib/l10n/` (`app_en.arb`, `app_ar.arb`, `app_es.arb`, `app_fr.arb`) and run
  `flutter gen-l10n`. Check Arabic in right-to-left layout.

## Adding an instrument or a data source

- A new built-in instrument is usually one entry in `InstrumentCatalog`
  (`lib/models/instrument_catalog.dart`). Add its display-name key to every
  ARB file too.
- A new price source means a new `QuoteProvider` implementation plus routing
  in `PriceRepository` (`lib/services/`). Providers must be keyless and free.

## Pull requests

- Open pull requests against `main`. One concern per pull request, with a
  description of what changed and why.
- State whether `flutter analyze` and `flutter test` pass, and what you
  checked by hand (which platform, which screens).
- By contributing you agree that your work is released under the project's
  [MIT licence](LICENSE).

## Reporting a security issue

Please do not open a public issue. See [SECURITY.md](SECURITY.md).
