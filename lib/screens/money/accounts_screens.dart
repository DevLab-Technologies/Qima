import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/app_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/entry_builder.dart';
import '../../models/money_settings.dart';
import '../../models/net_worth.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/currency_field.dart';
import '../../widgets/money_widgets.dart';
import '../../theme/help_topics.dart';
import '../../widgets/help_button.dart';
import 'entry_detail_screen.dart';
import 'entry_editor_screen.dart';

/// The account types a person adds from Accounts. Assets have their own
/// screens (14.x); holdings stay in the holdings ledger.
const accountTypesToAdd = [
  AccountType.debit,
  AccountType.cash,
  AccountType.credit,
  AccountType.loan,
  AccountType.receivable,
  AccountType.payable,
];

/// Every account the person keeps, grouped as on the balance sheet.
class AccountsScreen extends StatelessWidget {
  /// Show only these groups (a balance-sheet line opens its own list).
  final Set<SheetGroup>? groups;
  final String? title;

  const AccountsScreen({super.key, this.groups, this.title});

  static Future<void> open(BuildContext context, {Set<SheetGroup>? groups, String? title}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AccountsScreen(groups: groups, title: title)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final state = context.watch<MoneyCubit>().state;
    final book = state.book;
    final shownGroups = [
      for (final g in SheetGroup.values)
        if (g != SheetGroup.holdings && g != SheetGroup.assets && (groups == null || groups!.contains(g))) g,
    ];
    final sections = <Widget>[];
    for (final g in shownGroups) {
      final accounts = [
        for (final a in state.accounts)
          if (g.types.contains(a.type) && !a.archived) a,
      ];
      if (accounts.isEmpty) continue;
      sections.add(MoneySection(
        title: l10n.sheetGroup(g),
        children: [
          for (final a in accounts)
            MoneyRow(
              icon: MoneyIcons.account(a),
              title: a.name,
              subtitle: l10n.accountType(a.type),
              trailing: minorText(book.balanceOf(a.id), a.currency!, hidden: hidden),
              onTap: () => AccountDetailScreen.open(context, a.id),
            ),
        ],
      ));
    }
    final addTypes = groups == null ? accountTypesToAdd : [for (final t in accountTypesToAdd) if (groups!.any((g) => g.types.contains(t))) t];
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title ?? l10n.cardAccounts),
          actions: [
            const HelpButton(topic: HelpTopicId.accounts),
            IconButton(
              tooltip: l10n.accountAdd,
              icon: const Icon(Icons.add),
              onPressed: () => AccountEditorScreen.open(context, types: addTypes),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: sections.isEmpty
              ? [
                  MoneyEmpty(
                    icon: Icons.account_balance_outlined,
                    title: l10n.accountsEmptyTitle,
                    message: l10n.accountsEmptyMessage,
                    action: l10n.accountAdd,
                    onAction: () => AccountEditorScreen.open(context, types: addTypes),
                  ),
                ]
              : sections,
        ),
      ),
    );
  }
}

/// Adds an account (bank, cash, card, loan, a person) with what is in it
/// today, or edits one.
class AccountEditorScreen extends StatefulWidget {
  final List<AccountType> types;
  final BookAccount? existing;

  const AccountEditorScreen({super.key, this.types = accountTypesToAdd, this.existing});

  static Future<void> open(BuildContext context, {List<AccountType> types = accountTypesToAdd, BookAccount? existing}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AccountEditorScreen(types: types, existing: existing)));

  @override
  State<AccountEditorScreen> createState() => _AccountEditorScreenState();
}

class _AccountEditorScreenState extends State<AccountEditorScreen> {
  final _name = TextEditingController();
  final _balance = TextEditingController();
  final _limit = TextEditingController();
  late AccountType _type;
  late String _currency;
  DateTime _since = DateTime.now();
  bool _counts = true;
  String? _error;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? widget.types.first;
    _currency = e?.currency ?? context.read<AppCubit>().state.baseCurrency;
    if (e != null) {
      _name.text = e.name;
      _counts = e.countsInNetWorth;
      if (e.creditLimit != null) _limit.text = minorFieldText(e.creditLimit!, _currency);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    _limit.dispose();
    super.dispose();
  }

  String _balanceLabel(AppLocalizations l10n) => switch (_type) {
        AccountType.credit => l10n.accountOwedToday,
        AccountType.loan => l10n.accountLoanLeft,
        AccountType.receivable => l10n.accountTheyOwe,
        AccountType.payable => l10n.accountYouOwe,
        _ => l10n.accountBalanceToday,
      };

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final name = _name.text.trim();
    if (name.isEmpty) return setState(() => _error = l10n.accountErrorName);
    final limit = _limit.text.trim().isEmpty ? null : parseMinor(_limit.text, _currency);
    final e = widget.existing;
    if (e != null) {
      await money.updateAccount(e.copyWith(name: name, countsInNetWorth: _counts, creditLimit: limit, clearCreditLimit: limit == null));
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final opening = _balance.text.trim().isEmpty ? 0 : parseMinor(_balance.text, _currency);
    if (opening == null) return setState(() => _error = l10n.entryErrorAmount);
    final account = BookAccount(
      id: money.newId(),
      name: name,
      side: _type.side!,
      type: _type,
      currency: _currency,
      countsInNetWorth: _counts,
      creditLimit: _type == AccountType.credit ? limit : null,
    );
    final turnedOn = await money.addAccount(account, opening: opening, openedOn: _since);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (turnedOn != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.featureTurnedOn(l10n.feature(turnedOn))),
        action: SnackBarAction(label: l10n.commonUndo, onPressed: () => money.setFeature(turnedOn, false)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final app = context.read<AppCubit>().state;
    final fields = <Widget>[
      if (!_editing && widget.types.length > 1)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in widget.types)
              ChoiceChip(
                avatar: Icon(MoneyIcons.type(t), size: 18),
                label: Text(l10n.accountType(t)),
                selected: _type == t,
                onSelected: (_) => setState(() => _type = t),
              ),
          ],
        ),
      TextField(
        controller: _name,
        autofocus: !_editing,
        decoration: InputDecoration(
          labelText: _type == AccountType.receivable || _type == AccountType.payable ? l10n.entryPerson : l10n.accountNameLabel,
          border: const OutlineInputBorder(),
        ),
      ),
      if (!_editing)
        CurrencyField(
          label: l10n.accountCurrency,
          selected: _currency,
          baseCurrency: app.baseCurrency,
          currencies: {...app.rates.availableCurrencies, app.baseCurrency}.toList()..sort(),
          onChanged: (c) => setState(() => _currency = c),
        ),
      if (!_editing) AmountField(controller: _balance, label: _balanceLabel(l10n), currency: _currency, helper: l10n.accountBalanceHelp),
      if (!_editing) DateField(label: l10n.accountSince, value: _since, onChanged: (d) => setState(() => _since = d)),
      if (_type == AccountType.credit) AmountField(controller: _limit, label: l10n.accountLimit, currency: _currency),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.accountCounts),
        subtitle: Text(l10n.accountCountsHelp),
        value: _counts,
        onChanged: (v) => setState(() => _counts = v),
      ),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ];
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_editing ? l10n.accountEdit : l10n.accountAdd),
          actions: [const HelpButton(topic: HelpTopicId.accounts), TextButton(onPressed: _save, child: Text(l10n.holdingsSave))],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [for (final f in fields) Padding(padding: const EdgeInsets.only(bottom: DS.spaceMD), child: f)],
        ),
      ),
    );
  }
}

/// One account: its balance, what can be done with it, and its history.
class AccountDetailScreen extends StatelessWidget {
  final String accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  static Future<void> open(BuildContext context, String id) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AccountDetailScreen(accountId: id)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final money = context.read<MoneyCubit>();
    final state = context.watch<MoneyCubit>().state;
    final a = state.book.accounts[accountId];
    if (a == null) return Scaffold(appBar: AppBar());
    final balance = state.book.balanceOf(a.id);
    final ccy = a.currency!;
    final entries = state.entriesFor(a.id);

    final actions = <(IconData, String, VoidCallback)>[
      if (a.type == AccountType.cash) (Icons.calculate_outlined, l10n.accountCountCash, () => _reconcile(context, a, balance)),
      if (a.type == AccountType.debit || a.type == AccountType.credit) (Icons.fact_check_outlined, l10n.accountCheckBalance, () => _reconcile(context, a, balance)),
      if (a.type == AccountType.credit) (Icons.credit_score_outlined, l10n.accountPayCard, () => EntryEditorScreen.open(context, EntryKind.cardPayment, to: a.id)),
      if (a.type == AccountType.loan) (Icons.request_quote_outlined, l10n.accountPayLoan, () => EntryEditorScreen.open(context, EntryKind.loanPayment, to: a.id)),
      if (a.type == AccountType.receivable) (Icons.call_received, l10n.tplRepaymentIn, () => EntryEditorScreen.open(context, EntryKind.repaymentIn, from: a.id)),
      if (a.type == AccountType.payable) (Icons.call_made, l10n.tplRepaymentOut, () => EntryEditorScreen.open(context, EntryKind.repaymentOut, from: a.id)),
      if (a.type == AccountType.cash || a.type == AccountType.debit || a.type == AccountType.credit)
        (Icons.shopping_cart_outlined, l10n.tplSpend, () => EntryEditorScreen.open(context, EntryKind.spend, from: a.id)),
      if (a.type == AccountType.cash || a.type == AccountType.debit) (Icons.swap_horiz, l10n.tplTransfer, () => EntryEditorScreen.open(context, EntryKind.transfer, from: a.id)),
    ];
    final limit = a.creditLimit;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(a.name),
          actions: [
            const HelpButton(topic: HelpTopicId.accounts),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  await AccountEditorScreen.open(context, existing: a);
                } else if (v == 'remove') {
                  final ok = await confirmDelete(context, title: l10n.accountRemoveTitle, message: l10n.accountRemoveMessage, confirmLabel: l10n.commonDelete);
                  if (!ok) return;
                  await money.removeAccount(a.id);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.accountEdit)),
                PopupMenuItem(value: 'remove', child: Text(l10n.accountRemoveTitle)),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            DSHeroCard(
              accent: colors.brand,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.accountType(a.type), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(minorText(balance, ccy, hidden: hidden),
                        style: TextStyle(color: colors.textPrimary, fontSize: DS.figureHero, fontWeight: FontWeight.w800)),
                  ),
                  if (limit != null && limit > 0) ...[
                    const SizedBox(height: DS.spaceXS),
                    LinearProgressIndicator(value: (balance / limit).clamp(0.0, 1.0), minHeight: 6, borderRadius: BorderRadius.circular(3)),
                    const SizedBox(height: DS.space2XS),
                    Text(l10n.accountAvailable(minorText(limit - balance, ccy, hidden: hidden)), style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  ],
                  if (!a.countsInNetWorth) Text(l10n.accountLeftOut, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: DS.spaceMD),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final (icon, label, onTap) in actions) ActionChip(avatar: Icon(icon, size: 18), label: Text(label), onPressed: onTap)],
            ),
            const SizedBox(height: DS.spaceMD),
            MoneySection(
              title: l10n.allTransactions,
              children: entries.isEmpty
                  ? [MoneyEmpty(icon: Icons.receipt_long_outlined, title: l10n.transactionsEmptyTitle, message: l10n.transactionsEmptyMessage)]
                  : [
                      for (final e in entries.take(50))
                        EntryRow(entry: e, book: state.book, hidden: hidden, forAccount: a.id, onTap: () => EntryDetailScreen.open(context, e.id)),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  /// A cash count, or checking a bank or card against its statement. The
  /// person picks how a difference comes in: a transaction (spending or
  /// income in Other) or a changed opening balance.
  static Future<void> _reconcile(BuildContext context, BookAccount a, int tracked) async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final answer = await showDialog<(int, BalanceWay)>(context: context, builder: (_) => _ReconcileDialog(account: a, tracked: tracked));
    if (answer == null || !context.mounted) return;
    final (counted, way) = answer;
    final e = money.builder.balanceBy(way, book: money.state.book, account: a, tracked: tracked, target: counted, date: DateTime.now());
    if (e == null) return;
    await money.saveEntry(e);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reconcileDone)));
    }
  }
}

/// The count or statement figure, and how a difference comes in. Owns its
/// field, so the field outlives the closing animation.
class _ReconcileDialog extends StatefulWidget {
  final BookAccount account;
  final int tracked;

  const _ReconcileDialog({required this.account, required this.tracked});

  @override
  State<_ReconcileDialog> createState() => _ReconcileDialogState();
}

class _ReconcileDialogState extends State<_ReconcileDialog> {
  late final _controller = TextEditingController(text: minorFieldText(widget.tracked, widget.account.currency!));
  var _way = BalanceWay.transaction;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final a = widget.account;
    final cash = a.type == AccountType.cash;
    return AlertDialog(
      title: Text(cash ? l10n.accountCountCash : l10n.accountCheckBalance),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.reconcileTracked(minorText(widget.tracked, a.currency!, hidden: false))),
            const SizedBox(height: DS.spaceSM),
            AmountField(controller: _controller, autofocus: true, label: cash ? l10n.reconcileCounted : l10n.reconcileStatement, currency: a.currency!),
            const SizedBox(height: DS.spaceSM),
            BalanceWayPicker(value: _way, onChanged: (w) => setState(() => _way = w)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            final counted = parseMinor(_controller.text, a.currency!);
            Navigator.of(context).pop(counted == null ? null : (counted, _way));
          },
          child: Text(l10n.commonDone),
        ),
      ],
    );
  }
}

/// Where Money's features are switched on and off (Settings › Features).
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final money = context.read<MoneyCubit>();
    final settings = context.watch<MoneyCubit>().state.settings;
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.featuresTitle), actions: const [HelpButton(topic: HelpTopicId.features)]),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: DS.spaceMD),
              child: Text(l10n.featuresIntro, style: TextStyle(color: colors.textSecondary)),
            ),
            DSCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final f in MoneyFeature.values)
                    SwitchListTile(
                      title: Text(l10n.feature(f)),
                      subtitle: Text(l10n.featureDetail(f)),
                      value: settings.has(f),
                      onChanged: (v) => money.setFeature(f, v),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
