import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/split_donut.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/app_state.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/net_worth.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/money_widgets.dart';
import '../../theme/help_topics.dart';
import '../../widgets/help_button.dart';
import '../portfolio_detail_screen.dart';
import 'accounts_screens.dart';
import 'asset_screens.dart';

/// Net worth from both ledgers: holdings at live prices plus the book.
NetWorthSummary netWorthOf(AppCubit app, MoneyState money) {
  final s = app.state;
  return NetWorthSummary.of(
    book: money.book,
    holdingsValue: app.portfolioValuation?.value.amount ?? 0,
    currency: s.baseCurrency,
    rates: s.rates,
  );
}

/// S.4 Balance sheet: what you own and what you owe, each with a subtotal,
/// each line opening its list. Replaces the Wealth tab.
class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BalanceSheetScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final app = context.read<AppCubit>();
    context.watch<AppCubit>();
    final money = context.watch<MoneyCubit>().state;
    final hidden = app.state.hideBalances;
    final summary = netWorthOf(app, money);
    final ccy = summary.currency;

    void openGroup(SheetGroup g) {
      switch (g) {
        case SheetGroup.holdings:
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PortfolioDetailScreen()));
        case SheetGroup.assets:
          AssetsScreen.open(context);
        default:
          AccountsScreen.open(context, groups: {g}, title: l10n.sheetGroup(g));
      }
    }

    Widget side(String title, String total, List<SheetGroupTotal> groups) => MoneySection(
          title: title,
          trailing: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(total, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w800)),
          ),
          children: [
            for (final g in groups)
              MoneyRow(
                icon: _groupIcon(g.group),
                title: l10n.sheetGroup(g.group),
                subtitle: g.group == SheetGroup.holdings ? l10n.sheetHoldingsLive : l10n.sheetAccountsCount(g.lines.length),
                trailing: moneyText(g.amount, ccy, hidden: hidden),
                onTap: () => openGroup(g.group),
              ),
          ],
        );

    final own = [
      for (final g in summary.groups)
        if (g.group.side.name == 'own' && (g.amount != 0 || g.lines.isNotEmpty || g.group == SheetGroup.holdings)) g,
    ];
    final owe = [
      for (final g in summary.groups)
        if (g.group.side.name == 'owe' && (g.amount != 0 || g.lines.isNotEmpty)) g,
    ];

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.balanceSheet), actions: const [HelpButton(topic: HelpTopicId.balanceSheet)]),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            DSHeroCard(
              accent: colors.brand,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.netWorth, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(moneyText(summary.netWorth, ccy, hidden: hidden),
                        style: TextStyle(color: colors.textPrimary, fontSize: DS.figureHero, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  SplitDonut(
                    key: const ValueKey('ownOweDonut'),
                    centerValue: moneyText(summary.netWorth, ccy, hidden: hidden),
                    centerLabel: l10n.netLabel,
                    parts: [
                      DonutPart(label: l10n.youOwn, value: summary.owned, figure: moneyText(summary.owned, ccy, hidden: hidden), color: colors.accentGold),
                      DonutPart(label: l10n.youOweSide, value: summary.owed, figure: moneyText(summary.owed, ccy, hidden: hidden), color: colors.down),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: DS.spaceMD),
            side(l10n.youOwn, moneyText(summary.owned, ccy, hidden: hidden), own),
            side(l10n.youOweSide, moneyText(summary.owed, ccy, hidden: hidden), owe.isEmpty ? const [] : owe),
            if (owe.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: DS.spaceMD),
                child: Text(l10n.sheetNothingOwed, style: TextStyle(color: colors.textTertiary)),
              ),
            if (summary.missingRates.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: DS.spaceMD),
                child: Text(l10n.sheetMissingRates(summary.missingRates.join(', ')), style: TextStyle(color: colors.down)),
              ),
            MoneySection(
              children: [
                MoneyRow(icon: Icons.add, title: l10n.accountAdd, onTap: () => AccountEditorScreen.open(context)),
                MoneyRow(icon: Icons.home_work_outlined, title: l10n.assetAdd, onTap: () => AssetEditorScreen.open(context)),
                MoneyRow(icon: Icons.functions, title: l10n.howTotalWorked, onTap: () => HowTotalScreen.open(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _groupIcon(SheetGroup g) => switch (g) {
        SheetGroup.holdings => Icons.pie_chart_outline,
        SheetGroup.cash => Icons.account_balance_outlined,
        SheetGroup.owedToYou => Icons.call_received,
        SheetGroup.assets => Icons.home_work_outlined,
        SheetGroup.cards => Icons.credit_card,
        SheetGroup.loans => Icons.request_quote_outlined,
        SheetGroup.youOwe => Icons.call_made,
      };
}

/// 14.9 How the total is worked out: the sum written out, group by group.
class HowTotalScreen extends StatelessWidget {
  const HowTotalScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HowTotalScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, _) {
        final app = context.read<AppCubit>();
        final hidden = app.state.hideBalances;
        final summary = netWorthOf(app, context.watch<MoneyCubit>().state);
        final ccy = summary.currency;
        final rows = [
          for (final g in summary.groups)
            if (g.amount != 0)
              MoneyRow(
                title: l10n.sheetGroup(g.group),
                trailing: '${g.group.side.name == 'owe' ? '−' : '+'} ${moneyText(g.amount, ccy, hidden: hidden)}',
              ),
        ];
        return ScreenBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.howTotalWorked), actions: const [HelpButton(topic: HelpTopicId.balanceSheet)]),
            body: ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                Text(l10n.howTotalIntro, style: TextStyle(color: colors.textSecondary)),
                const SizedBox(height: DS.spaceMD),
                MoneySection(
                  children: [
                    ...rows,
                    const Divider(height: 1),
                    MoneyRow(title: l10n.netWorth, bold: true, trailing: moneyText(summary.netWorth, ccy, hidden: hidden)),
                  ],
                ),
                for (final point in [l10n.howTotalHoldings, l10n.howTotalAssets, l10n.howTotalLoans, l10n.howTotalRates])
                  Padding(
                    padding: const EdgeInsets.only(bottom: DS.spaceSM),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: const EdgeInsets.only(top: 3), child: Icon(Icons.circle, size: 6, color: colors.textTertiary)),
                        const SizedBox(width: DS.spaceSM),
                        Expanded(child: Text(point, style: TextStyle(color: colors.textSecondary))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
