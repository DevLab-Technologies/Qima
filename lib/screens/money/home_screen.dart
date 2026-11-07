import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../blocs/app_cubit.dart';
import '../../blocs/app_state.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/money_analysis.dart';
import '../../models/money_settings.dart';
import '../../models/net_worth.dart';
import '../../models/zakat_book.dart';
import '../../theme/design_system.dart';
import '../../theme/help_topics.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/help_button.dart';
import '../../widgets/money_widgets.dart';
import '../../widgets/portfolio_hero.dart';
import '../add_instrument_screen.dart';
import '../portfolio_detail_screen.dart';
import '../zakat_screen.dart';
import 'accounts_screens.dart';
import 'asset_screens.dart';
import 'balance_sheet_screen.dart';
import 'more_money_screens.dart';

/// The Home tab: "where do I stand?" The total first (it opens the balance
/// sheet), then the person's cards in their order.
class HomeScreen extends StatelessWidget {
  final ScrollController? scrollController;
  final VoidCallback? onOpenSettings;

  const HomeScreen({super.key, this.scrollController, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AppCubit>();
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, app) {
        final money = context.watch<MoneyCubit>().state;
        final hidden = app.hideBalances;
        final valuation = cubit.portfolioValuation;
        final summary = netWorthOf(cubit, money);
        final hasHoldings = valuation != null;

        final children = <Widget>[];
        // The total. Until the first account or asset, it is the Portfolio,
        // with its chart and ranges, as current users know it.
        if (!money.hasBook && hasHoldings) {
          children.add(PortfolioHero(
            valuation: valuation,
            history: cubit.portfolioHistory(app.preferredPortfolioRange),
            change: cubit.portfolioChange(app.preferredPortfolioRange),
            selectedRange: app.preferredPortfolioRange,
            onSelectRange: cubit.setPreferredPortfolioRange,
            onTap: () => BalanceSheetScreen.open(context),
            hideBalances: hidden,
            onToggleHideBalances: cubit.toggleHideBalances,
          ));
        } else if (money.hasBook) {
          children.add(_NetWorthCard(summary: summary, hidden: hidden));
        } else {
          children.add(const _StartCard());
        }
        children.add(const SizedBox(height: DS.spaceMD));

        for (final card in money.settings.visibleCards) {
          final w = _card(context, card, app, money, summary, hidden);
          if (w == null) continue;
          children.add(GestureDetector(
            onLongPress: () => EditHomeScreen.open(context),
            child: w,
          ));
        }
        children.add(Center(
          child: TextButton.icon(onPressed: () => EditHomeScreen.open(context), icon: const Icon(Icons.tune), label: Text(l10n.editHome)),
        ));

        return ScreenBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              title: Text(l10n.navHome),
              actions: [
                const HelpButton(topic: HelpTopicId.portfolio),
                IconButton(
                  icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  tooltip: hidden ? l10n.privacyShowBalances : l10n.privacyHideBalances,
                  onPressed: cubit.toggleHideBalances,
                ),
                if (onOpenSettings != null) IconButton(icon: const Icon(Icons.settings_outlined), tooltip: l10n.settingsTitle, onPressed: onOpenSettings),
              ],
            ),
            body: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, DS.spaceXL * 3),
              children: children,
            ),
          ),
        );
      },
    );
  }

  /// One Home card, or null when it has nothing to show right now.
  Widget? _card(BuildContext context, HomeCard card, AppState app, MoneyState money, NetWorthSummary summary, bool hidden) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ccy = app.baseCurrency;
    final cubit = context.read<MoneyCubit>();
    final book = money.book;
    switch (card) {
      case HomeCard.needsReview:
        final stale = staleAssets(money, cubit, DateTime.now());
        if (stale.isEmpty) return null;
        return MoneySection(title: l10n.cardNeedsReview, children: [
          for (final (a, since) in stale)
            MoneyRow(
              icon: Icons.update,
              title: l10n.reviewValue(a.name),
              subtitle: since == null ? null : l10n.assetUpdated(DateFormat.yMMMd(locale).format(since)),
              onTap: () => showUpdateValueSheet(context, a),
            ),
        ]);
      case HomeCard.comingUp:
        final due = cubit.comingUp();
        if (due.isEmpty) return null;
        return MoneySection(title: l10n.cardComingUp, children: [
          for (final (r, date) in due)
            MoneyRow(
              icon: Icons.event_repeat,
              title: r.name,
              subtitle: DateFormat.MMMEd(locale).format(date),
              trailing: book.accounts[r.fromAccountId] == null ? null : minorText(r.amount, book.accounts[r.fromAccountId]!.currency!, hidden: hidden),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecurringScreen())),
            ),
        ]);
      case HomeCard.leftToSpend:
        final s = money.settings;
        final a = MonthAnalysis.of(book, DateTime.now(), currency: ccy, rates: app.rates, budgets: s.budgets, budgetCurrency: s.budgetCurrency);
        return MoneySection(
          title: l10n.cardLeftToSpend,
          onTitleTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetScreen())),
          children: [
            if (!a.hasBudget)
              MoneyRow(icon: Icons.donut_large, title: l10n.budgetSet, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetScreen())))
            else
              MoneyRow(
                icon: Icons.donut_large,
                title: moneyText(a.leftToSpend, ccy, hidden: hidden),
                subtitle: l10n.moneySpentOf(moneyText(a.spent, ccy, hidden: hidden), moneyText(a.budget, ccy, hidden: hidden)),
              ),
          ],
        );
      case HomeCard.holdings:
        final v = context.read<AppCubit>().portfolioValuation;
        // Before the first account, the total above already is the holdings.
        if (v == null || !money.hasBook) return null;
        return MoneySection(
          title: l10n.sheetHoldings,
          onTitleTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PortfolioDetailScreen())),
          children: [
            MoneyRow(
              icon: Icons.pie_chart_outline,
              title: moneyText(v.value.amount, v.value.currencyCode, hidden: hidden),
              subtitle: l10n.holdingsGainLine(moneyText(v.gain.amount, v.gain.currencyCode, hidden: hidden)),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PortfolioDetailScreen())),
            ),
          ],
        );
      case HomeCard.accounts:
        final accounts = [
          for (final a in money.balanceAccounts)
            if (!a.archived && {AccountType.cash, AccountType.debit, AccountType.credit, AccountType.loan}.contains(a.type)) a,
        ];
        if (accounts.isEmpty) return null;
        return MoneySection(
          title: l10n.cardAccounts,
          onTitleTap: () => AccountsScreen.open(context),
          children: [
            for (final a in accounts.take(5))
              MoneyRow(
                icon: MoneyIcons.account(a),
                title: a.name,
                subtitle: l10n.accountType(a.type),
                trailing: minorText(book.balanceOf(a.id), a.currency!, hidden: hidden),
                onTap: () => AccountDetailScreen.open(context, a.id),
              ),
          ],
        );
      case HomeCard.assets:
        final assets = money.ofType(AccountType.asset);
        if (assets.isEmpty) return null;
        return MoneySection(
          title: l10n.sheetAssets,
          onTitleTap: () => AssetsScreen.open(context),
          children: [
            for (final a in assets.take(4))
              MoneyRow(
                icon: MoneyIcons.account(a),
                title: a.name,
                trailing: minorText(book.balanceOf(a.id), a.currency!, hidden: hidden),
                onTap: () => AssetDetailScreen.open(context, a.id),
              ),
          ],
        );
      case HomeCard.people:
        final owed = summary.group(SheetGroup.owedToYou), owe = summary.group(SheetGroup.youOwe);
        return MoneySection(
          title: l10n.featPeople,
          onTitleTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PeopleScreen())),
          children: [
            MoneyRow(icon: Icons.call_received, title: l10n.sheetOwedToYou, trailing: moneyText(owed.amount, ccy, hidden: hidden)),
            MoneyRow(icon: Icons.call_made, title: l10n.sheetYouOwe, trailing: moneyText(owe.amount, ccy, hidden: hidden)),
          ],
        );
      case HomeCard.zakat:
        final z = ZakatOnBook.of(book: book, holdings: context.read<AppCubit>().zakatAssessment, currency: ccy, rates: app.rates);
        return MoneySection(
          title: l10n.featZakat,
          onTitleTap: () => ZakatBookScreen.open(context),
          children: [
            MoneyRow(
              icon: Icons.volunteer_activism_outlined,
              title: z.above ? l10n.zakatDueLine(moneyText(z.due, ccy, hidden: hidden)) : l10n.zakatBelowLine,
              subtitle: l10n.zakatBaseLine(moneyText(z.base, ccy, hidden: hidden)),
              onTap: () => ZakatBookScreen.open(context),
            ),
          ],
        );
    }
  }
}

/// Assets whose value hasn't been reviewed for the reminder period.
List<(BookAccount, DateTime?)> staleAssets(MoneyState money, MoneyCubit cubit, DateTime now) {
  final months = money.settings.valueReviewMonths;
  if (months <= 0) return const [];
  final cutoff = DateTime(now.year, now.month - months, now.day);
  return [
    for (final a in money.ofType(AccountType.asset))
      if (cubit.valueHistory(a.id).lastOrNull case final last? when last.$1.isBefore(cutoff)) (a, last.$1),
  ];
}

class _NetWorthCard extends StatelessWidget {
  final NetWorthSummary summary;
  final bool hidden;

  const _NetWorthCard({required this.summary, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final ccy = summary.currency;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => BalanceSheetScreen.open(context),
        child: DSHeroCard(
          accent: colors.brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(child: Text(l10n.netWorth, style: TextStyle(color: colors.textTertiary, fontSize: 12))),
                Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
              ]),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(moneyText(summary.netWorth, ccy, hidden: hidden),
                      style: TextStyle(color: colors.textPrimary, fontSize: DS.figureDisplay, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: DS.spaceSM),
              Row(children: [
                Expanded(child: _Side(label: l10n.youOwn, value: moneyText(summary.owned, ccy, hidden: hidden))),
                Expanded(child: _Side(label: l10n.youOweSide, value: moneyText(summary.owed, ccy, hidden: hidden))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  final String label;
  final String value;

  const _Side({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        Directionality(textDirection: TextDirection.ltr, child: Text(value, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700))),
      ],
    );
  }
}

/// Home before anything is added: three ways to start.
class _StartCard extends StatelessWidget {
  const _StartCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSHeroCard(
      accent: colors.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.startTitle, style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: DS.space2XS),
          Text(l10n.startMessage, style: TextStyle(color: colors.textSecondary)),
          const SizedBox(height: DS.spaceMD),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ActionChip(avatar: const Icon(Icons.account_balance_outlined, size: 18), label: Text(l10n.accountAdd), onPressed: () => AccountEditorScreen.open(context)),
            ActionChip(
              avatar: const Icon(Icons.pie_chart_outline, size: 18),
              label: Text(l10n.addHoldingTitle),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddInstrumentScreen(start: AddStart.holding))),
            ),
            ActionChip(avatar: const Icon(Icons.home_work_outlined, size: 18), label: Text(l10n.assetAdd), onPressed: () => AssetEditorScreen.open(context)),
          ]),
        ],
      ),
    );
  }
}

/// S.17 Edit Home: cards can be moved and hidden only. The total is always
/// first; Needs review and Coming up can move but not hide.
class EditHomeScreen extends StatelessWidget {
  const EditHomeScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditHomeScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final money = context.read<MoneyCubit>();
    final settings = context.watch<MoneyCubit>().state.settings;
    // Cards whose feature is off aren't offered; turning the feature on brings them.
    final cards = [for (final c in settings.orderedCards) if (c.feature == null || settings.has(c.feature!)) c];
    final visible = settings.visibleCards;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.editHome)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            Text(l10n.editHomeIntro, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: DS.spaceMD),
            DSCard(
              padding: EdgeInsets.zero,
              child: ListTile(leading: const Icon(Icons.lock_outline), title: Text(l10n.netWorth), subtitle: Text(l10n.editHomeTotalFixed)),
            ),
            const SizedBox(height: DS.spaceSM),
            DSCard(
              padding: EdgeInsets.zero,
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                onReorder: (from, to) {
                  final card = cards[from];
                  final rest = [...cards]..removeAt(from);
                  final target = to > from ? to - 1 : to;
                  final order = [...rest]..insert(target, card);
                  money.moveCard(card, [for (final c in order) if (visible.contains(c)) c].indexOf(card));
                },
                children: [
                  for (final (i, c) in cards.indexed)
                    Semantics(
                      key: ValueKey(c),
                      customSemanticsActions: {
                        if (i > 0) CustomSemanticsAction(label: l10n.moveUp): () => _move(money, cards, visible, i, i - 1),
                        if (i < cards.length - 1) CustomSemanticsAction(label: l10n.moveDown): () => _move(money, cards, visible, i, i + 1),
                        if (i > 0) CustomSemanticsAction(label: l10n.moveToTop): () => _move(money, cards, visible, i, 0),
                      },
                      child: ListTile(
                        leading: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)),
                        title: Text(l10n.homeCard(c)),
                        subtitle: c.canHide ? null : Text(l10n.editHomeCantHide),
                        trailing: c.canHide
                            ? Switch(value: !settings.hiddenCards.contains(c), onChanged: (v) => money.setCardHidden(c, !v))
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _move(MoneyCubit money, List<HomeCard> cards, List<HomeCard> visible, int from, int to) {
    final card = cards[from];
    final order = [...cards]
      ..removeAt(from)
      ..insert(to, card);
    money.moveCard(card, [for (final c in order) if (visible.contains(c) || c == card) c].indexOf(card));
  }
}

/// O.2 and O.3 in one sheet: what changed, and which parts of Money to
/// use. Nothing turns on without a tap.
Future<void> showWhatsNew(BuildContext context) async {
  final money = context.read<MoneyCubit>();
  final hasGold = context.read<AppCubit>().state.lots.isNotEmpty;
  final chosen = {...money.state.settings.features, if (hasGold) MoneyFeature.zakat};
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // A tall sheet stops below the status bar, drag handle in view.
    useSafeArea: true,
    showDragHandle: true,
    isDismissible: false,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      final colors = sheetContext.colors;
      return StatefulBuilder(
        builder: (sheetContext, setSheet) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.whatsNewTitle, style: Theme.of(sheetContext).textTheme.headlineSmall),
                const SizedBox(height: DS.spaceSM),
                for (final (icon, text) in [
                  (Icons.dashboard_outlined, l10n.whatsNewTabs),
                  (Icons.balance, l10n.whatsNewBalanceSheet),
                  (Icons.home_work_outlined, l10n.whatsNewAssets),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: DS.spaceSM),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(icon, color: colors.brandText),
                      const SizedBox(width: DS.spaceSM),
                      Expanded(child: Text(text, style: TextStyle(color: colors.textPrimary))),
                    ]),
                  ),
                const SizedBox(height: DS.spaceSM),
                Text(l10n.whatsNewPick, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700)),
                for (final f in MoneyFeature.values)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: chosen.contains(f),
                    title: Text(l10n.feature(f)),
                    subtitle: Text(l10n.featureDetail(f)),
                    onChanged: (v) => setSheet(() => v == true ? chosen.add(f) : chosen.remove(f)),
                  ),
                Text(l10n.whatsNewLater, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                const SizedBox(height: DS.spaceMD),
                FilledButton(
                  onPressed: () async {
                    await money.setFeatures(chosen);
                    await money.markWhatsNewSeen();
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                  child: Text(l10n.commonDone),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Zakat over the balance sheet: the holdings the zakat settings count,
/// plus cash, money owed to the person and assets held for sale, less
/// debts due.
class ZakatBookScreen extends StatelessWidget {
  const ZakatBookScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ZakatBookScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final app = context.watch<AppCubit>();
    final s = app.state;
    final money = context.watch<MoneyCubit>().state;
    final z = ZakatOnBook.of(book: money.book, holdings: app.zakatAssessment, currency: s.baseCurrency, rates: s.rates);
    final ccy = s.baseCurrency;
    final hidden = s.hideBalances;
    String label(ZakatPart p) => switch (p) {
          ZakatPart.holdings => l10n.sheetHoldings,
          ZakatPart.cash => l10n.sheetCash,
          ZakatPart.owedToYou => l10n.sheetOwedToYou,
          ZakatPart.heldForSale => l10n.zakatHeldForSale,
          ZakatPart.debtsDue => l10n.zakatDebtsDue,
        };
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.featZakat)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            DSHeroCard(
              accent: colors.accentGold,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.zakatDueTitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(moneyText(z.due, ccy, hidden: hidden), style: TextStyle(color: colors.textPrimary, fontSize: DS.figureHero, fontWeight: FontWeight.w800)),
                ),
                Text(
                  !z.thresholdKnown
                      ? l10n.zakatNoThreshold
                      : (z.above ? l10n.zakatAbove(moneyText(z.threshold!.amount, ccy, hidden: hidden)) : l10n.zakatBelow(moneyText(z.threshold!.amount, ccy, hidden: hidden))),
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ]),
            ),
            const SizedBox(height: DS.spaceMD),
            MoneySection(children: [
              for (final p in ZakatPart.values)
                MoneyRow(title: label(p), trailing: '${p == ZakatPart.debtsDue ? '−' : '+'} ${moneyText(z.parts[p] ?? 0, ccy, hidden: hidden)}'),
              const Divider(height: 1),
              MoneyRow(title: l10n.zakatBase, bold: true, trailing: moneyText(z.base, ccy, hidden: hidden)),
            ]),
            Text(l10n.zakatBookHelp, style: TextStyle(color: colors.textTertiary, fontSize: 13)),
            if (z.missingRates.isNotEmpty) Text(l10n.sheetMissingRates(z.missingRates.join(', ')), style: TextStyle(color: colors.down)),
            const SizedBox(height: DS.spaceMD),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ZakatScreen())),
              child: Text(l10n.zakatHoldingsDetail),
            ),
          ],
        ),
      ),
    );
  }
}
