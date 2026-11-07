import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../blocs/app_cubit.dart';
import '../../blocs/app_state.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/money_analysis.dart';
import '../../models/money_settings.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/money_widgets.dart';
import 'accounts_screens.dart';
import 'entry_detail_screen.dart';
import 'entry_editor_screen.dart';
import 'more_money_screens.dart';

/// The Money tab: "where is my money going, and what should I do about
/// it?" The month against its budget and where it's heading, suggestions
/// that end in a choice, where the money went, cash flow, the trend, Ask,
/// and every transaction one tap away.
class MoneyScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const MoneyScreen({super.key, this.scrollController});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  int? _asked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (a, b) => a.hideBalances != b.hideBalances || a.baseCurrency != b.baseCurrency || a.rates != b.rates,
      builder: (context, app) {
        final state = context.watch<MoneyCubit>().state;
        final hidden = app.hideBalances;
        final ccy = app.baseCurrency;
        final book = state.book;
        final settings = state.settings;
        final now = DateTime.now();
        final a = MonthAnalysis.of(book, _month, currency: ccy, rates: app.rates, budgets: settings.budgets, budgetCurrency: settings.budgetCurrency);
        final isThisMonth = _month.year == now.year && _month.month == now.month;
        final recent = [for (final e in state.entriesNewestFirst) if (!e.date.isBefore(_month) && e.date.isBefore(a.end)) e];
        String name(String id) {
          final acc = book.accounts[id];
          return acc == null ? id : l10n.accountName(acc);
        }

        final sections = <Widget>[];

        // The month against its budget, and where it's heading.
        final projected = a.projected(now);
        sections.add(DSHeroCard(
          accent: colors.brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.hasBudget ? l10n.cardLeftToSpend : l10n.moneySpent, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(moneyText(a.hasBudget ? a.leftToSpend : a.spent, ccy, hidden: hidden),
                    style: TextStyle(color: a.hasBudget && a.leftToSpend < 0 ? colors.down : colors.textPrimary, fontSize: DS.figureHero, fontWeight: FontWeight.w800)),
              ),
              if (a.hasBudget) ...[
                const SizedBox(height: DS.spaceXS),
                LinearProgressIndicator(value: a.budget == 0 ? 0 : (a.spent / a.budget).clamp(0.0, 1.0), minHeight: 6, borderRadius: BorderRadius.circular(3)),
                const SizedBox(height: DS.space2XS),
                Text(l10n.moneySpentOf(moneyText(a.spent, ccy, hidden: hidden), moneyText(a.budget, ccy, hidden: hidden)), style: TextStyle(color: colors.textSecondary, fontSize: 13)),
              ],
              if (isThisMonth && projected != null && a.spent > 0)
                Text(l10n.moneyPace(moneyText(projected, ccy, hidden: hidden)), style: TextStyle(color: colors.textSecondary, fontSize: 13)),
            ],
          ),
        ));
        sections.add(const SizedBox(height: DS.spaceMD));

        // Worth a look: arithmetic on the person's own budget, ending in a choice.
        if (isThisMonth && a.hasBudget) {
          final ahead = a.aheadOfPace(now);
          final spare = a.spare(now);
          if (ahead.isNotEmpty) {
            sections.add(MoneySection(
              title: l10n.worthALook,
              children: [
                for (final (id, spent, budget) in ahead.take(3))
                  MoneyRow(
                    icon: Icons.speed,
                    title: l10n.aheadOfPace(name(id)),
                    subtitle: [
                      l10n.moneySpentOf(moneyText(spent, ccy, hidden: hidden), moneyText(budget, ccy, hidden: hidden)),
                      if (spare.isNotEmpty && spare.first.$1 != id) l10n.spareIn(name(spare.first.$1), moneyText(spare.first.$2, ccy, hidden: hidden)),
                    ].join(' · '),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetScreen())),
                  ),
              ],
            ));
          }
        }

        // Where it went.
        sections.add(MoneySection(
          title: l10n.whereItWent,
          children: a.byCategory.isEmpty
              ? [Padding(padding: const EdgeInsets.all(DS.spaceMD), child: Text(l10n.moneyNothingSpent, style: TextStyle(color: colors.textTertiary)))]
              : [
                  for (final (id, v) in a.byCategory)
                    _CategoryBar(
                      icon: MoneyIcons.category(id),
                      name: name(id),
                      amount: moneyText(v, ccy, hidden: hidden),
                      share: a.spent == 0 ? 0 : v / a.spent,
                      budget: a.budgets[id] == null ? null : moneyText(a.budgets[id]!, ccy, hidden: hidden),
                      over: a.budgets[id] != null && v > a.budgets[id]!,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AllTransactionsScreen(accountId: id, title: name(id), from: _month, to: a.end),
                      )),
                    ),
                ],
        ));

        // Cash flow.
        sections.add(MoneySection(
          title: l10n.cashFlow,
          children: [
            MoneyRow(icon: Icons.south_west, title: l10n.moneyIn, trailing: moneyText(a.income, ccy, hidden: hidden), trailingColor: colors.up),
            MoneyRow(icon: Icons.north_east, title: l10n.moneyOut, trailing: moneyText(a.spent, ccy, hidden: hidden)),
            MoneyRow(
              title: a.net >= 0 ? l10n.moneyLeftOver : l10n.moneyShort,
              bold: true,
              trailing: moneyText(a.net.abs(), ccy, hidden: hidden),
              trailingColor: a.net >= 0 ? colors.up : colors.down,
            ),
          ],
        ));

        // The trend across months.
        final trend = MonthAnalysis.trend(book, _month, currency: ccy, rates: app.rates);
        if (trend.any((t) => t.$2 > 0)) {
          final top = trend.map((t) => t.$2).reduce((x, y) => x > y ? x : y);
          sections.add(MoneySection(
            title: l10n.moneyTrend,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceXS, DS.spaceMD, DS.spaceSM),
                child: SizedBox(
                  height: 110,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final (m, v) in trend)
                          Expanded(
                            child: Semantics(
                              label: '${DateFormat.yMMM(locale).format(m)} ${moneyText(v, ccy, hidden: hidden)}',
                              // The bar takes what the label leaves, so a
                              // long month name never pushes it out.
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: top == 0 ? 0 : v / top,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: m == _month ? colors.brand : colors.brand.withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(DateFormat.MMM(locale).format(m), maxLines: 1, style: TextStyle(color: colors.textTertiary, fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ));
        }

        // Ask: suggested questions, answered from the ledger.
        final questions = <(String, String)>[
          (l10n.askSpentMonth, l10n.askSpentMonthAnswer(moneyText(a.spent, ccy, hidden: hidden))),
          if (a.byCategory.isNotEmpty) (l10n.askTopCategory, l10n.askTopCategoryAnswer(name(a.byCategory.first.$1), moneyText(a.byCategory.first.$2, ccy, hidden: hidden))),
          if (trend.length > 1) (l10n.askVsLastMonth, _vsLast(l10n, trend, ccy, hidden)),
          (l10n.askOwed, _owed(l10n, state, hidden)),
        ];
        sections.add(MoneySection(
          title: l10n.ask,
          children: [
            for (final (i, (q, answer)) in questions.indexed) ...[
              MoneyRow(icon: Icons.help_outline, title: q, onTap: () => setState(() => _asked = _asked == i ? null : i)),
              if (_asked == i)
                Padding(
                  padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceSM),
                  child: Text(answer, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                ),
            ],
          ],
        ));

        // Recent transactions.
        sections.add(MoneySection(
          title: l10n.moneyTransactions,
          onTitleTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllTransactionsScreen())),
          children: recent.isEmpty
              ? [
                  MoneyEmpty(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.transactionsEmptyTitle,
                    message: state.hasBook ? l10n.transactionsEmptyMessage : l10n.moneyStartMessage,
                    action: state.hasBook ? l10n.tplSpend : l10n.accountAdd,
                    onAction: () => state.hasBook ? EntryEditorScreen.open(context, EntryKind.spend) : AccountEditorScreen.open(context),
                  ),
                ]
              : [
                  for (final e in recent.take(6)) EntryRow(entry: e, book: book, hidden: hidden, onTap: () => EntryDetailScreen.open(context, e.id)),
                  MoneyRow(title: l10n.allTransactions, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllTransactionsScreen()))),
                ],
        ));

        // The rest of Money, as features are on.
        sections.add(MoneySection(
          children: [
            MoneyRow(icon: Icons.account_balance_outlined, title: l10n.cardAccounts, onTap: () => AccountsScreen.open(context)),
            if (settings.has(MoneyFeature.budget)) MoneyRow(icon: Icons.donut_large, title: l10n.featBudget, onTap: () => _push(context, const BudgetScreen())),
            if (settings.has(MoneyFeature.recurring)) MoneyRow(icon: Icons.event_repeat, title: l10n.featRecurring, onTap: () => _push(context, const RecurringScreen())),
            if (settings.has(MoneyFeature.people)) MoneyRow(icon: Icons.people_outline, title: l10n.featPeople, onTap: () => _push(context, const PeopleScreen())),
            if (settings.has(MoneyFeature.billSplit)) MoneyRow(icon: Icons.call_split, title: l10n.featBillSplit, onTap: () => _push(context, const BillSplitScreen())),
            MoneyRow(icon: Icons.label_outline, title: l10n.categoriesTitle, onTap: () => _push(context, const CategoriesScreen())),
          ],
        ));

        return ScreenBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              title: Text(l10n.navMoney),
              actions: [
                IconButton(
                  tooltip: l10n.previousMonth,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                ),
                Center(child: Text(DateFormat.yMMM(locale).format(_month), style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600))),
                IconButton(
                  tooltip: l10n.nextMonth,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isThisMonth ? null : () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                ),
              ],
            ),
            body: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, DS.spaceXL * 3),
              children: sections,
            ),
          ),
        );
      },
    );
  }

  static void _push(BuildContext context, Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  static String _vsLast(AppLocalizations l10n, List<(DateTime, double)> trend, String ccy, bool hidden) {
    final now = trend.last.$2, before = trend[trend.length - 2].$2;
    final d = now - before;
    if (d.abs() < 0.005) return l10n.askSame;
    return d > 0 ? l10n.askMore(moneyText(d, ccy, hidden: hidden)) : l10n.askLess(moneyText(-d, ccy, hidden: hidden));
  }

  static String _owed(AppLocalizations l10n, MoneyState state, bool hidden) {
    final people = state.ofType(AccountType.receivable);
    final parts = [
      for (final p in people)
        if (state.book.balanceOf(p.id) != 0) '${p.name} ${minorText(state.book.balanceOf(p.id), p.currency!, hidden: hidden)}',
    ];
    return parts.isEmpty ? l10n.askNobodyOwes : parts.join(' · ');
  }
}

class _CategoryBar extends StatelessWidget {
  final IconData icon;
  final String name;
  final String amount;
  final double share;
  final String? budget;
  final bool over;
  final VoidCallback onTap;

  const _CategoryBar({required this.icon, required this.name, required this.amount, required this.share, required this.budget, required this.over, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colors.brandText),
                const SizedBox(width: DS.spaceSM),
                Expanded(child: Text(name, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w500))),
                Directionality(textDirection: TextDirection.ltr, child: Text(amount, style: TextStyle(color: over ? colors.down : colors.textPrimary, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: share.clamp(0.0, 1.0), minHeight: 4, borderRadius: BorderRadius.circular(2), color: over ? colors.down : colors.brand),
            if (budget != null) Text(l10n.budgetOf(budget!), style: TextStyle(color: colors.textTertiary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
