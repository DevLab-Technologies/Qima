# Qima v4 — plan

v4 is named for two jobs: **add a purchase without filling in a form**, and
**know what moved this month**. On-device models are an implementation detail
and are never what a feature depends on.

The design lives in Figma (file `nwZclLHxy1ip1QgOe3dBOk`, page
"v4 · Explorations").

## Rules every phase obeys

1. **The model never produces a number.** It may parse language or phrase a
   sentence. Every figure comes from `PriceConverter`, `PriceRepository` or
   the ledger. A number a model hands back is accepted only if the user
   literally typed or said it.
2. **No advice.** No prediction, no buy or sell suggestions, no scoring.
   Qima is a tracking tool.
3. **The deterministic path ships first.** No screen may exist only when a
   model is present. Models are hardware-gated (Apple Intelligence on A17 Pro
   or M-series, Gemini Nano on Pixel 9-class phones), so each feature is
   designed and built for the device without one.
4. **Nothing leaves the device.** Speech recognition is forced on-device. If
   that isn't available, the mic is disabled. There is never a server
   fallback, and Web gets no dictation.
5. **Nothing commits without a human tap.** Captured text becomes a preview
   in which each field shows the words it came from.

## Phases

Each phase is one branch and one PR, and each can ship on its own.

| # | Phase | Needs a model | Main pieces |
|---|-------|---------------|-------------|
| 1 | Typed capture and the seam | No | `AiAssistProvider` seam with a null default; deterministic English and Arabic transaction parser; "Check this" preview from the Add search field; editor accepts a draft |
| 2 | Multilingual aliases | No | Curated en/ar/es/fr aliases in the catalog; each search result says why it matched |
| 3 | Plain-language summaries | No (template first) | Month summary sentence built from snapshot deltas; spoken chart description from the sampled series; off by default |
| 4 | Dictation | No (on-device STT) | `speech_to_text` with on-device recognition forced; four mic states; permission strings; README privacy section. **Gate: test Arabic dictation quality first** |
| 5 | System assistant | No | Read-only App Intents (iOS/macOS) and App Functions (Android), reusing the widget data path |
| 6 | On-device models | Yes | Foundation Models (Apple) and Gemini Nano (Android) behind the seam, used only to phrase sentences and to parse what the deterministic parser misses; Settings · On-device intelligence |
| 7 | Receipt scan | OCR only | VisionKit / ML Kit text, then the phase 1 parser |

Out of v4: Windows MCP, Linux, Web dictation, and writes through a system
assistant (an assistant can't enforce confirm-before-commit).

## Phase 1 — typed capture and the seam

**Job:** at a dealer's counter, type `20 g 21K gold at 4,100 EGP on the 12th`
into the Add search field and record the purchase in two taps.

- `lib/services/ai_assist_provider.dart` sits beside `quote_provider.dart`.
  It holds `AiAssistProvider` (availability, `extractTransaction`,
  `describePeriod`) and `NullAiAssistProvider`, the default. Whatever a
  provider returns goes through the same closed-set and literal-number
  checks as typed input.
- `lib/models/transaction_capture.dart` is the deterministic parser. Input
  is free text in English or Arabic, with Western or Arabic-Indic digits
  and thousands separators. Output is a draft in which each field records
  the span of input it came from and whether it was guessed:
  - kind: bought / sold / اشتريت / بعت; default buy, marked guessed
  - quantity and unit: g, kg, oz, gram, ounce, غرام, جرام, جم, كيلو, أونصة
  - karat: 24K / 22K / 21K / 18K, or عيار 21; only for gold by weight
  - instrument: a catalog symbol or localized name, plus a small built-in
    word list (gold, ذهب, bitcoin, بيتكوين…)
  - unit price or total: `at` / `@` / بسعر means per unit; `for` / `total`
    / بمبلغ means the total, which the parser divides by quantity
  - currency: an ISO code or symbol. An ambiguous word such as "pounds",
    "riyal" or جنيه resolves to the base currency when that currency is in
    the word's family, and is marked guessed.
  - date: today, yesterday, اليوم, أمس, "the 12th", `12/3`, ISO dates. A
    day of the month on its own means the most recent such day, marked
    guessed.
- The Add screen keeps its search field. When the query parses into a
  transaction (an instrument and a quantity), a "Record this" card appears
  above the search results. Tapping it opens **Check this**, which lists each
  field with "from '…'" or a *check* badge on guessed fields. **Confirm**
  saves the transaction through `AppCubit.saveTransaction`, which is
  ledger-checked and refuses an oversell. **Edit fields** opens the normal
  transaction editor prefilled.
- Strings are added in all four locales.
- Tests: parser unit tests (English, Arabic, Arabic-Indic digits, ambiguous
  currency, the total-vs-per-unit split, the day-only date at month
  boundaries, the rejection cases) and a widget test of the Check this
  screen.

## Phase 2 — multilingual aliases

**Job:** find gold by typing دهب, Oro or gold, whatever language the app is in.

- `lib/models/instrument_aliases.dart` holds the curated everyday names
  (spelling variants, colloquial names, currency family words). The phase 1
  parser reads the same list, except currency words, which it resolves by
  family against the base currency.
- Search also matches each instrument's catalog label in all four app
  languages. A name or symbol match always wins; only when neither matched
  does the row show the other name that did ("XAU · Also “دهب”"), with the
  matched part highlighted.

## Phase 3 — plain-language summaries

**Job:** know what moved this month without reading a chart.

- `PeriodSummary` (`lib/models/period_summary.dart`) holds the facts for the
  past month: the gain change and percent from `PortfolioRangeChange`, the
  holding whose gain moved most, and how many transactions were recorded.
  The cubit memoizes it per day and per input, like the portfolio history.
- `periodSummarySentence` builds the sentence from a template in each
  language. Hidden balances mask the amounts and keep the direction.
- Portfolio shows it in a "Past month" card when Settings · Summaries ·
  Month in a sentence is on. It is off by default, per device.
- Every chart carries a spoken description for screen readers (dates,
  start and end, change, high and low with their dates; only the change
  when balances are hidden). This one is always on, because it is
  invisible and costs nothing.
- Summaries are rebuilt from the live history on each open, memoized per
  day, rather than cached with a snapshot: the inputs are already in
  memory and the walk is cheap.

## Phase 4 — dictation

**Job:** say "اشتريت عشرين جرام ذهب عيار واحد وعشرين" at the counter instead
of typing it.

- `DictationPlugin` (iOS and macOS, one Swift file per runner) and
  `DictationChannel` (Android) require on-device recognition and report a
  language as `unsupported` when no on-device model is installed for it.
  `PlatformDictation` (Dart) wraps both behind `DictationService`, which
  `AppCubit` takes like `aiAssist`, so tests use a fake.
- The mic sits in the Add field and has four states: ready, listening,
  unsupported (tapping explains why) and denied (tapping explains how to
  turn access back on).
- Recognized text goes into the field as if typed. `SpokenNumbers` first
  turns English and Arabic number words into digits ("واحد وعشرين" → 21),
  so the field shows what the parser reads and provenance stays literal.
- The recognizer locale follows the app language and uses the device's
  region for it when there is one (ar-EG on an Egyptian phone).
- Decisions on the open questions: dictation is in the Add flow only.
  Arabic voice is offered wherever the device has an on-device Arabic
  model, and the mic explains itself where it hasn't. **Still to do:** test
  Arabic dictation quality on real hardware before release. The simulator
  can't do this.

## Phase 5 — system assistant

**Job:** ask Siri what the portfolio is worth, or the price of gold, without
opening the app.

- `ios/Runner/AssistantIntents.swift` (compiled into the iOS and macOS
  apps) has two read-only App Intents, *Get portfolio value* and *Get a
  price*, and an `AppShortcutsProvider` with phrases in all four languages
  (`AppShortcuts.strings`). They read the snapshot the app already
  publishes for its widgets, through the widget's own `Snapshot.swift` and
  `Style.swift`, which both apps now compile too. The price and value rules
  moved into `Snapshot` (`livePrice`, `presentation`, `portfolioValue`), so
  the price widget and the assistant share one implementation.
- Hide balances in the app means hidden from the assistant too.
- Answers are localized through `tool/widget_strings.json`. Regenerating it
  also brought the widget's Arabic labels up to the app's Western digits.
- **Android App Functions are not in this phase.** Every
  `androidx.appfunctions` release with the current API (`alpha10` to
  `beta01`) needs compile SDK 37 and AGP 9.1. Qima builds with Flutter's
  defaults (SDK 36, AGP 8.11), and the releases that fit those are early
  alphas with a different API. The Android side should land after a
  toolchain upgrade. It reads the same snapshot through `widget/Snapshot.kt`
  and `PriceModel.resolve`, and the answer strings are already generated for
  Android.

## Phase 6 — on-device models

**Job:** read the purchases the parser can't, and word the month summary
like a person would, without anything leaving the device.

- `OnDeviceModelPlugin.swift` (iOS and macOS 26 and later) uses Apple's
  Foundation Models through `SystemLanguageModel.default` only, never the
  Private Cloud Compute model. The framework is weak-linked, so the app
  still runs on iOS 15 and macOS 12.
  - `labelTransaction` uses guided generation (`@Generable Labels`) to
    return the exact words for each field. Dart's
    `TransactionCapture.parseWithSpans` keeps only literal substrings and
    parses them like typed text, as the phase 1 seam requires.
  - `phrase` rewords a summary sentence. `acceptPhrasing` (Dart) shows the
    result only if it has exactly the template's numbers (Arabic-Indic
    digits fold), keeps masked amounts masked, and uses no advice or
    forecast words. Anything else falls back to the template.
- Settings · On-device intelligence has a switch (off by default, per
  device) and the model's status for the app language: ready, not on this
  device, Apple Intelligence off, still downloading, or language not
  supported. `AppCubit.assist` is the null provider unless the switch is on.
- Tested on this Mac: availability reports Apple Intelligence off, and
  Arabic is not a supported model language today, so Arabic users see "not
  available in this language yet".
- **Android (Gemini Nano) is not in this phase.** The only supported route
  is ML Kit GenAI (`com.google.mlkit:genai-prompt`), which brings in
  Google's `transport-backend-cct` usage-logging stack. That conflicts with
  Qima's "no analytics, nothing leaves the device" promise, so it needs a
  product decision first.

## Open questions

- Gemini Nano on Android: accept ML Kit's usage logging (and update the
  privacy policy), or wait for an on-device route without it? (Phase 6.)
- If Arabic dictation turns out poor on real hardware, should the mic be
  hidden in Arabic, or kept with its quality caveat? (Phase 4 gate.)
