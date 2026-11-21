import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../blocs/money_cubit.dart';
import '../l10n/app_localizations.dart';
import '../l10n/currency_names.dart';
import '../models/money_settings.dart';
import '../models/quote.dart';
import '../models/setup_answers.dart';
import '../models/watch_card.dart';
import '../services/import/bank_messages.dart';
import '../theme/design_system.dart';
import '../theme/money_labels.dart';
import '../theme/qima_colors.dart';
import '../widgets/instrument_row.dart';
import 'currency_picker.dart';

/// Setup: a few questions, one per screen, whose answers configure the app
/// (the base currency, which features are on, the watchlist, the tour and
/// Home's Get started card). Later questions appear only when an earlier
/// answer makes them relevant; see [SetupAnswers.steps].
///
/// Shown once on first launch, in place of the home shell (from
/// `main.dart`), and again from Settings as "Run setup again" ([rerun]).
/// Nothing is changed until the last screen is confirmed or Skip is pressed,
/// except the base currency, which applies as it is picked so every later
/// screen already shows prices in it (a rerun that is backed out of puts
/// the earlier currency back).
///
/// The first-launch showing never pops: finishing marks onboarding done
/// (`AppCubit.completeOnboarding`), and `main.dart` shows the home shell in
/// its place. A rerun pops back to the shell.
class SetupFlowScreen extends StatefulWidget {
  /// Started from Settings: no welcome screen, answers start from the last
  /// ones, and Back on the first screen leaves with nothing changed.
  final bool rerun;

  const SetupFlowScreen({super.key, this.rerun = false});

  @override
  State<SetupFlowScreen> createState() => _SetupFlowScreenState();
}

class _SetupFlowScreenState extends State<SetupFlowScreen> {
  late SetupAnswers _answers;
  late SetupStep _step;

  /// Keys ([SetupSuggestion.key]) of the suggested prices that are ticked;
  /// null until one is ticked or unticked, so the prices screen opens on
  /// the suggestions' own defaults for the products chosen by then. Keys do
  /// not name the currency, so the ticks survive a change of main currency.
  Set<String>? _picked;

  /// "Add" was pressed on the prices screen. Until then (the screen was
  /// skipped, never reached, or left by "Not now") the watchlist is left as
  /// it is: nothing is added that the person did not confirm.
  bool _addPrices = false;
  bool _busy = false;

  /// A rerun's currency when it opened, put back if it is backed out of;
  /// [_applied] once the answers were confirmed instead.
  late final String _currencyBefore;
  bool _applied = false;

  /// Prices for suggestions that are not on the watchlist, which nothing
  /// else fetches, by instrument id; [_previewing] holds the ones asked for.
  final Map<String, QuoteSeries> _previews = {};
  final Set<String> _previewing = {};

  @override
  void initState() {
    super.initState();
    _answers = widget.rerun ? (context.read<AppCubit>().state.setup ?? const SetupAnswers()) : const SetupAnswers();
    _step = _steps.first;
    _currencyBefore = context.read<AppCubit>().state.baseCurrency;
    // On first launch nothing has fetched rates or prices yet (the home
    // shell does that, and it isn't up), and the currency list and the
    // suggested prices need them.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<AppCubit>().refreshIfStale());
      _leaveIfAlreadyInUse(context.read<MoneyCubit>().state);
    });
  }

  /// Someone whose book already has accounts (it arrived by sync, or was
  /// restored) is not new, whatever this device's first-launch flag says:
  /// setup makes way for the app. Only from the welcome screen, so answers
  /// under way are never thrown out.
  void _leaveIfAlreadyInUse(MoneyState money) {
    if (widget.rerun || _busy || _step != SetupStep.welcome || !money.loaded || !money.hasBook) return;
    unawaited(_skipAll());
  }

  /// Fetches the prices of suggestions that are not on the watchlist, so
  /// the prices screen shows what each one costs. A failure leaves the row
  /// without a price and is tried again the next time the screen opens.
  void _loadPreviews() {
    final app = context.read<AppCubit>();
    for (final s in _suggestions(app.state.baseCurrency)) {
      final instrument = s.card.instrument;
      if (instrument == null || app.state.seriesByID.containsKey(instrument.id) || !_previewing.add(instrument.id)) continue;
      unawaited(() async {
        try {
          final series = await app.repository.refresh(instrument);
          if (mounted) setState(() => _previews[instrument.id] = series);
        } catch (e) {
          debugPrint('Setup: price for ${instrument.id} failed: $e');
          _previewing.remove(instrument.id);
        }
      }());
    }
  }

  List<SetupStep> get _steps => [
        for (final s in _answers.steps)
          if (!(widget.rerun && s == SetupStep.welcome)) s,
      ];

  /// The questions, without the welcome and summary screens, for the
  /// progress bar.
  List<SetupStep> get _questions => [
        for (final s in _steps)
          if (s != SetupStep.welcome && s != SetupStep.summary) s,
      ];

  List<SetupSuggestion> _suggestions(String currency) => _answers.pruned.suggestions(currency);

  Set<String> _pickedFor(List<SetupSuggestion> suggestions) {
    final offered = {for (final s in suggestions) s.key};
    final picked = _picked ?? {for (final s in suggestions) if (s.preselected) s.key};
    // A product unticked after the prices were picked takes its prices along.
    return picked.intersection(offered);
  }

  List<WatchCard> _pickedCards(String currency) {
    if (!_addPrices || !_answers.pruned.hasPricedProducts) return const [];
    final suggestions = _suggestions(currency);
    final picked = _pickedFor(suggestions);
    return [for (final s in suggestions) if (picked.contains(s.key)) s.card];
  }

  void _go(SetupStep step) {
    setState(() => _step = step);
    if (step == SetupStep.prices) _loadPreviews();
  }

  void _next() {
    final steps = _steps;
    final i = steps.indexOf(_step);
    if (i >= 0 && i < steps.length - 1) _go(steps[i + 1]);
  }

  void _back() {
    final steps = _steps;
    final i = steps.indexOf(_step);
    if (i > 0) {
      _go(steps[i - 1]);
    } else if (widget.rerun) {
      Navigator.of(context).pop();
    }
  }

  /// Applies the answers and leaves, asking for the tour when [tour].
  /// Features are only ever added, so running setup again never hides
  /// something already in use.
  Future<void> _finish({required bool tour}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final app = context.read<AppCubit>();
    final money = context.read<MoneyCubit>();
    final navigator = Navigator.of(context);
    final answers = _answers.pruned;
    final cards = _pickedCards(app.state.baseCurrency);
    try {
      // The book loads right after the app does; on first launch setup can
      // be finished before it has, and a save now would be overwritten.
      if (!money.state.loaded) {
        try {
          await money.stream.firstWhere((s) => s.loaded, orElse: () => money.state).timeout(_bookWait);
        } on TimeoutException {
          debugPrint('Setup: the book did not load in time; features are left as they are');
        }
        // The book closed before it loaded: the app is shutting down.
        if (money.isClosed) return;
      }
      // A book that never loaded is not written to (the write would replace
      // what is stored); setup still finishes, and the features can be
      // switched on later from Settings.
      if (money.state.loaded) await money.applySetup(answers.features);
      await app.adoptSetupWatchlist(cards);
      await app.saveSetup(answers);
      _applied = true;
      if (widget.rerun) {
        // The tour runs over the shell, so it is asked for once setup is
        // out of its way.
        if (navigator.mounted) navigator.popUntil((route) => route.isFirst);
        if (tour) app.requestTour();
      } else {
        // Asked for first: marking onboarding done is what replaces this
        // screen with the shell, which starts the tour as it appears.
        if (tour) app.requestTour();
        await app.completeOnboarding();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// "Skip, I'll set it up myself" on the welcome screen: nothing is
  /// answered, so the app starts with the defaults it always had.
  Future<void> _skipAll() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<AppCubit>().completeOnboarding();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// How long finishing waits for the book before going on without it.
  static const _bookWait = Duration(seconds: 8);

  void _toggle<T>(Set<T> current, T value, SetupAnswers Function(Set<T>) apply) {
    final next = {...current};
    next.contains(value) ? next.remove(value) : next.add(value);
    setState(() => _answers = apply(next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final steps = _steps;
    final first = steps.indexOf(_step) == 0;

    return PopScope(
      // Back steps through the questions; on the first screen it leaves
      // (a rerun goes back to Settings, first launch closes the app).
      canPop: first,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (!first) _back();
        } else if (widget.rerun && !_applied) {
          // Backed out of a rerun: nothing else was changed, so the
          // currency goes back to what it was too.
          unawaited(context.read<AppCubit>().setBaseCurrency(_currencyBefore));
        }
      },
      child: BlocListener<MoneyCubit, MoneyState>(
        listenWhen: (a, b) => !a.loaded && b.loaded,
        listener: (context, money) => _leaveIfAlreadyInUse(money),
        child: Scaffold(
        backgroundColor: colors.bg0,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: BlocBuilder<AppCubit, AppState>(
                  buildWhen: (a, b) => a.baseCurrency != b.baseCurrency || a.rates != b.rates || a.seriesByID != b.seriesByID,
                  builder: (context, app) => switch (_step) {
                    SetupStep.welcome => _welcome(l10n, colors),
                    SetupStep.currency => _currency(l10n, colors, app),
                    SetupStep.uses => _uses(l10n),
                    SetupStep.products => _products(l10n),
                    SetupStep.prices => _prices(l10n, colors, app),
                    SetupStep.goals => _goals(l10n),
                    SetupStep.capture => _capture(l10n, colors),
                    SetupStep.summary => _summary(l10n, colors, app),
                  },
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Screens
  // ---------------------------------------------------------------------

  Widget _welcome(AppLocalizations l10n, QimaColors colors) {
    return _Page(
      key: const ValueKey(SetupStep.welcome),
      centered: true,
      primaryLabel: l10n.onboardingGetStarted,
      onPrimary: _busy ? null : _next,
      secondaryLabel: l10n.setupWelcomeSkip,
      onSecondary: _busy ? null : _skipAll,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DS.radiusCard),
            child: Image.asset('assets/icon/app_icon.png', width: 88, height: 88, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: DS.spaceXL),
        Text(
          l10n.setupWelcomeTitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800, height: 1.2),
        ),
        const SizedBox(height: DS.spaceSM),
        Text(l10n.setupWelcomeBody, textAlign: TextAlign.center, style: TextStyle(color: colors.textSecondary, fontSize: 16, height: 1.4)),
        const SizedBox(height: DS.spaceXL),
        DSCard(
          child: Column(
            children: [
              for (final (i, (icon, text)) in [
                (Icons.shield_outlined, l10n.setupWelcomeNoAccount),
                (Icons.smartphone, l10n.setupWelcomeOnDevice),
                (Icons.tune, l10n.setupWelcomeChangeLater),
              ].indexed) ...[
                if (i > 0) const SizedBox(height: DS.spaceSM),
                Row(
                  children: [
                    Icon(icon, color: colors.brandText, size: 22),
                    const SizedBox(width: DS.spaceSM),
                    Expanded(child: Text(text, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _currency(AppLocalizations l10n, QimaColors colors, AppState app) {
    final cubit = context.read<AppCubit>();
    final language = Localizations.localeOf(context).languageCode;
    final region = cubit.deviceRegionCurrency;
    final available = app.rates.availableCurrencies;
    final shown = <String>[];
    for (final code in [?region, app.baseCurrency, 'USD', 'EUR', 'SAR', 'AED', 'EGP', 'KWD', 'GBP']) {
      if (shown.length < 6 && !shown.contains(code) && (available.contains(code) || code == app.baseCurrency)) shown.add(code);
    }

    return _question(
      step: SetupStep.currency,
      title: l10n.setupCurrencyTitle,
      body: l10n.setupCurrencyBody,
      onPrimary: _next,
      children: [
        DSCard(
          padding: const EdgeInsets.symmetric(vertical: DS.spaceXS),
          child: RadioGroup<String>(
            groupValue: app.baseCurrency,
            onChanged: (code) {
              if (code != null) unawaited(cubit.setBaseCurrency(code));
            },
            child: Column(
              children: [
                for (final code in shown)
                  RadioListTile<String>(
                    value: code,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: _CodeBadge(code: code, selected: code == app.baseCurrency),
                    title: Text(
                      currencyDisplayName(code, language),
                      style: TextStyle(color: colors.textPrimary, fontWeight: code == app.baseCurrency ? FontWeight.w700 : FontWeight.w400),
                    ),
                    subtitle: code == region ? Text(l10n.setupCurrencyFromRegion, style: TextStyle(color: colors.brandText, fontSize: 13)) : null,
                  ),
                Divider(color: colors.hairline, height: 1),
                ListTile(
                  leading: Icon(Icons.search, color: colors.brandText),
                  title: Text(l10n.setupCurrencyMore, style: TextStyle(color: colors.brandText, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final selected = await CurrencyPicker.show(context, selected: app.baseCurrency, currencies: available);
                    if (selected != null) await cubit.setBaseCurrency(selected);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _uses(AppLocalizations l10n) {
    final options = [
      (SetupUse.money, Icons.account_balance_wallet_outlined, l10n.setupUseMoney, l10n.setupUseMoneyBody),
      (SetupUse.portfolio, Icons.pie_chart_outline, l10n.setupUsePortfolio, l10n.setupUsePortfolioBody),
      (SetupUse.prices, Icons.show_chart, l10n.setupUsePrices, l10n.setupUsePricesBody),
      (SetupUse.netWorth, Icons.layers_outlined, l10n.setupUseNetWorth, l10n.setupUseNetWorthBody),
      (SetupUse.zakat, Icons.balance, l10n.setupUseZakat, l10n.setupUseZakatBody),
    ];
    return _question(
      step: SetupStep.uses,
      title: l10n.setupUsesTitle,
      body: l10n.setupChooseAll,
      caption: l10n.setupChosen(_answers.uses.length),
      onPrimary: _answers.uses.isEmpty ? null : _next,
      children: [
        for (final (value, icon, title, body) in options)
          _OptionCard(
            icon: icon,
            title: title,
            body: body,
            selected: _answers.uses.contains(value),
            onTap: () => _toggle(_answers.uses, value, (v) => _answers.copyWith(uses: v)),
          ),
      ],
    );
  }

  Widget _products(AppLocalizations l10n) {
    final options = [
      (SetupProduct.metals, Icons.hexagon_outlined, l10n.setupProductMetals, l10n.setupProductMetalsBody),
      (SetupProduct.stocks, Icons.bar_chart, l10n.setupProductStocks, l10n.setupProductStocksBody),
      (SetupProduct.currencies, Icons.language, l10n.setupProductCurrencies, l10n.setupProductCurrenciesBody),
      (SetupProduct.crypto, Icons.currency_bitcoin, l10n.setupProductCrypto, l10n.setupProductCryptoBody),
      (SetupProduct.indices, Icons.trending_up, l10n.setupProductIndices, l10n.setupProductIndicesBody),
      (SetupProduct.property, Icons.home_work_outlined, l10n.setupProductProperty, l10n.setupProductPropertyBody),
    ];
    return _question(
      step: SetupStep.products,
      title: l10n.setupProductsTitle,
      body: l10n.setupProductsBody,
      caption: l10n.setupChosen(_answers.products.length),
      onPrimary: _answers.products.isEmpty ? null : _next,
      children: [
        for (final (value, icon, title, body) in options)
          _OptionCard(
            icon: icon,
            title: title,
            body: body,
            selected: _answers.products.contains(value),
            onTap: () => _toggle(_answers.products, value, (v) => _answers.copyWith(products: v)),
          ),
      ],
    );
  }

  Widget _prices(AppLocalizations l10n, QimaColors colors, AppState app) {
    final cubit = context.read<AppCubit>();
    final suggestions = _suggestions(app.baseCurrency);
    final picked = _pickedFor(suggestions);
    return _question(
      step: SetupStep.prices,
      title: l10n.setupPricesTitle,
      body: l10n.setupPricesBody(app.baseCurrency),
      primaryLabel: l10n.setupPricesAdd(picked.length),
      onPrimary: picked.isEmpty
          ? null
          : () {
              setState(() {
                _picked = picked;
                _addPrices = true;
              });
              _next();
            },
      secondaryLabel: l10n.setupPricesNotNow,
      onSecondary: () {
        setState(() => _addPrices = false);
        _next();
      },
      children: [
        DSCard(
          padding: const EdgeInsets.symmetric(horizontal: DS.spaceXS, vertical: DS.spaceXS),
          child: Column(
            children: [
              for (final s in suggestions)
                MergeSemantics(
                  child: Row(
                    children: [
                      Expanded(
                        child: InstrumentRow(
                          presentation: cubit.presentation(s.card, series: _previews[s.card.instrumentID]),
                          onTap: () => _togglePick(picked, s.key),
                        ),
                      ),
                      Checkbox(value: picked.contains(s.key), onChanged: (_) => _togglePick(picked, s.key)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _togglePick(Set<String> picked, String key) {
    final next = {...picked};
    next.contains(key) ? next.remove(key) : next.add(key);
    setState(() => _picked = next);
  }

  Widget _goals(AppLocalizations l10n) {
    final options = [
      (SetupGoal.whereItGoes, Icons.pie_chart_outline, l10n.setupGoalWhere, l10n.setupGoalWhereBody),
      (SetupGoal.saveMore, Icons.savings_outlined, l10n.setupGoalSave, l10n.setupGoalSaveBody),
      (SetupGoal.budget, Icons.track_changes, l10n.setupGoalBudget, l10n.setupGoalBudgetBody),
      (SetupGoal.bills, Icons.event_outlined, l10n.setupGoalBills, l10n.setupGoalBillsBody),
      (SetupGoal.people, Icons.people_outline, l10n.setupGoalPeople, l10n.setupGoalPeopleBody),
    ];
    return _question(
      step: SetupStep.goals,
      title: l10n.setupGoalsTitle,
      body: l10n.setupChooseAll,
      caption: l10n.setupChosen(_answers.goals.length),
      onPrimary: _next,
      children: [
        for (final (value, icon, title, body) in options)
          _OptionCard(
            icon: icon,
            title: title,
            body: body,
            selected: _answers.goals.contains(value),
            onTap: () => _toggle(_answers.goals, value, (v) => _answers.copyWith(goals: v)),
          ),
      ],
    );
  }

  Widget _capture(AppLocalizations l10n, QimaColors colors) {
    final options = [
      (SetupCapture.typeOrSay, Icons.mic_none, l10n.setupCaptureType, l10n.setupCaptureTypeBody),
      // Offered only where Qima can read bank messages at all.
      if (BankMessages.way != BankMessagesWay.none)
        (SetupCapture.bankMessages, Icons.sms_outlined, l10n.setupCaptureMessages, l10n.setupCaptureMessagesBody),
      (SetupCapture.statement, Icons.description_outlined, l10n.setupCaptureStatement, l10n.setupCaptureStatementBody),
    ];
    return _question(
      step: SetupStep.capture,
      title: l10n.setupCaptureTitle,
      body: l10n.setupCaptureBody,
      caption: l10n.setupChosen(_answers.captures.length),
      onPrimary: _next,
      children: [
        for (final (value, icon, title, body) in options)
          _OptionCard(
            icon: icon,
            title: title,
            body: body,
            selected: _answers.captures.contains(value),
            onTap: () => _toggle(_answers.captures, value, (v) => _answers.copyWith(captures: v)),
          ),
        DSTile(
          padding: const EdgeInsets.all(DS.spaceMD),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: colors.brandText, size: 22),
              const SizedBox(width: DS.spaceSM),
              Expanded(child: Text(l10n.setupCapturePrivacy, style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.35))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summary(AppLocalizations l10n, QimaColors colors, AppState app) {
    final language = Localizations.localeOf(context).languageCode;
    final answers = _answers.pruned;
    final features = answers.features;
    final cards = _pickedCards(app.baseCurrency);
    final onHome = [
      l10n.netWorth,
      if (answers.asksMoney) l10n.homeCard(HomeCard.accounts),
      if (answers.uses.contains(SetupUse.portfolio)) l10n.homeCard(HomeCard.holdings),
      for (final c in HomeCard.values)
        if (c.feature != null && features.contains(c.feature)) l10n.homeCard(c),
    ];
    final captures = [
      if (answers.captures.contains(SetupCapture.typeOrSay)) l10n.setupCaptureType,
      if (answers.captures.contains(SetupCapture.bankMessages)) l10n.setupCaptureMessages,
      if (answers.captures.contains(SetupCapture.statement)) l10n.setupCaptureStatement,
    ];
    final rows = [
      (SetupStep.currency, Icons.payments_outlined, l10n.setupSummaryCurrency, '${currencyDisplayName(app.baseCurrency, language)} (${app.baseCurrency})'),
      (SetupStep.uses, Icons.home_outlined, l10n.setupSummaryHome, onHome.join(l10n.setupListSeparator)),
      if (answers.asksMoney)
        (
          SetupStep.goals,
          Icons.toggle_on_outlined,
          l10n.setupSummaryFeatures,
          features.isEmpty ? l10n.setupSummaryNothingNew : [for (final f in MoneyFeature.values) if (features.contains(f)) l10n.feature(f)].join(l10n.setupListSeparator),
        ),
      if (answers.hasPricedProducts)
        (SetupStep.prices, Icons.show_chart, l10n.setupSummaryWatchlist, cards.isEmpty ? l10n.setupSummaryWatchlistKept : l10n.setupSummaryPrices(cards.length)),
      if (captures.isNotEmpty) (SetupStep.capture, Icons.mic_none, l10n.setupSummaryCapture, captures.join(l10n.setupListSeparator)),
    ];

    return _question(
      step: SetupStep.summary,
      title: l10n.setupSummaryTitle,
      body: l10n.setupSummaryBody,
      primaryLabel: l10n.setupSummaryTour,
      onPrimary: _busy ? null : () => _finish(tour: true),
      secondaryLabel: widget.rerun ? l10n.commonDone : l10n.setupSummaryGoHome,
      onSecondary: _busy ? null : () => _finish(tour: false),
      children: [
        DSCard(
          padding: const EdgeInsets.symmetric(vertical: DS.spaceXS),
          child: Column(
            children: [
              for (final (i, (step, icon, label, value)) in rows.indexed) ...[
                if (i > 0) Divider(color: colors.hairline, height: 1, indent: DS.spaceMD, endIndent: DS.spaceMD),
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.tileTop, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: colors.brandText, size: 20),
                  ),
                  title: Text(label, style: TextStyle(color: colors.textTertiary, fontSize: 13)),
                  subtitle: Text(value, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                  onTap: _busy ? null : () => _go(step),
                ),
              ],
            ],
          ),
        ),
        Text(l10n.setupSummaryLater, textAlign: TextAlign.center, style: TextStyle(color: colors.textTertiary, fontSize: 13)),
      ],
    );
  }

  /// A question screen: Back, progress and Skip on top, the title and the
  /// options scrolling in the middle, the buttons pinned below.
  Widget _question({
    required SetupStep step,
    required String title,
    required String body,
    required List<Widget> children,
    required VoidCallback? onPrimary,
    String? primaryLabel,
    String? caption,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final questions = _questions;
    final summary = step == SetupStep.summary;
    final done = summary ? questions.length : questions.indexOf(step) + 1;
    final canGoBack = _steps.indexOf(step) > 0 || widget.rerun;

    return _Page(
      key: ValueKey(step),
      primaryLabel: primaryLabel ?? l10n.commonContinue,
      onPrimary: onPrimary,
      caption: caption,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
      header: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(DS.space2XS, DS.space2XS, DS.spaceSM, 0),
        child: Row(
          children: [
            if (canGoBack)
              IconButton(icon: const BackButtonIcon(), tooltip: MaterialLocalizations.of(context).backButtonTooltip, onPressed: _busy ? null : _back)
            else
              const SizedBox(width: DS.spaceSM),
            Expanded(
              child: Semantics(
                label: l10n.onboardingSemanticStepOf(done, questions.length),
                child: Row(
                  children: [
                    for (var i = 0; i < questions.length; i++)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsetsDirectional.only(end: 5),
                          decoration: BoxDecoration(
                            color: i < done ? colors.brand : colors.hairlineStrong,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Skip keeps what was answered so far. The summary is the end,
            // so it has none; a rerun leaves by Back instead.
            if (!summary && !widget.rerun)
              TextButton(onPressed: _busy ? null : () => _finish(tour: false), child: Text(l10n.onboardingSkip))
            else
              const SizedBox(width: DS.spaceSM),
          ],
        ),
      ),
      children: [
        Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: DS.spaceXS),
        Text(body, style: TextStyle(color: colors.textSecondary, fontSize: 16, height: 1.35)),
        const SizedBox(height: DS.spaceLG),
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const SizedBox(height: DS.spaceSM),
          child,
        ],
      ],
    );
  }
}

/// One setup screen's frame: an optional header, scrolling content and the
/// buttons pinned to the bottom so they never move between screens.
class _Page extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final bool centered;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? caption;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _Page({
    super.key,
    this.header,
    required this.children,
    this.centered = false,
    required this.primaryLabel,
    required this.onPrimary,
    this.caption,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        ?header,
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DS.spaceLG, DS.spaceMD, DS.spaceLG, DS.spaceMD),
              child: ConstrainedBox(
                // Lets the welcome screen sit in the middle of a tall phone
                // and still scroll on a short one.
                constraints: BoxConstraints(minHeight: centered ? constraints.maxHeight - DS.spaceMD * 2 : 0),
                child: Column(
                  mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DS.spaceLG, DS.spaceXS, DS.spaceLG, DS.spaceSM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
              if (secondaryLabel != null)
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel!))
              else
                // Keeps the primary button at one height across screens.
                SizedBox(
                  height: 48,
                  child: Center(child: Text(caption ?? '', style: TextStyle(color: colors.textTertiary, fontSize: 13))),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A tappable answer: an icon, a title, one line of detail and a tick.
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({required this.icon, required this.title, required this.body, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(DS.radiusCard);
    return Semantics(
      checked: selected,
      button: true,
      child: Material(
        color: selected ? Color.alphaBlend(DS.selectedTint(colors, colors.brand), colors.surfaceTop) : colors.surfaceTop,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: selected ? colors.brand : colors.hairline, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colors.tileTop, borderRadius: BorderRadius.circular(DS.radiusTile)),
                  child: Icon(icon, color: colors.brandText, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(body, style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.3)),
                    ],
                  ),
                ),
                const SizedBox(width: DS.spaceSM),
                ExcludeSemantics(
                  child: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected ? colors.brand : colors.hairlineStrong,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  final String code;
  final bool selected;

  const _CodeBadge({required this.code, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 48,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? DS.selectedTint(colors, colors.brand) : colors.tileTop,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(code, style: TextStyle(color: selected ? colors.brandText : colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}
