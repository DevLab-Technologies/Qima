import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../blocs/app_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/money_analysis.dart';
import '../../models/money_settings.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/money_widgets.dart';
import 'accounts_screens.dart';
import 'entry_editor_screen.dart';

/// Budget: a monthly amount per spending category, in the base currency.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final app = context.watch<AppCubit>().state;
    final money = context.read<MoneyCubit>();
    final state = context.watch<MoneyCubit>().state;
    final ccy = app.baseCurrency;
    final a = MonthAnalysis.of(state.book, DateTime.now(), currency: ccy, rates: app.rates, budgets: state.settings.budgets, budgetCurrency: state.settings.budgetCurrency);
    final categories = state.categories(AccountSide.spending);

    Future<void> edit(BookAccount c) async {
      final current = state.settings.budgets[c.id];
      final controller = TextEditingController(text: current == null ? '' : minorFieldText(current, ccy));
      final value = await showDialog<int>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.budgetFor(l10n.accountName(c))),
          content: AmountField(controller: controller, autofocus: true, label: l10n.budgetMonthly, currency: ccy, helper: l10n.budgetZeroHelp),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(parseMinor(controller.text.isEmpty ? '0' : controller.text, ccy)), child: Text(l10n.holdingsSave)),
          ],
        ),
      );
      controller.dispose();
      if (value != null) await money.setBudget(c.id, value);
    }

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.featBudget)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            Text(l10n.budgetIntro, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: DS.spaceMD),
            if (a.hasBudget)
              MoneySection(children: [
                MoneyRow(title: l10n.budgetTotal, bold: true, trailing: moneyText(a.budget, ccy, hidden: app.hideBalances)),
                MoneyRow(title: l10n.moneySpent, trailing: moneyText(a.spent, ccy, hidden: app.hideBalances)),
                MoneyRow(title: l10n.cardLeftToSpend, trailing: moneyText(a.leftToSpend, ccy, hidden: app.hideBalances), trailingColor: a.leftToSpend < 0 ? colors.down : colors.up),
              ]),
            MoneySection(
              children: [
                for (final c in categories)
                  MoneyRow(
                    icon: MoneyIcons.account(c),
                    title: l10n.accountName(c),
                    subtitle: l10n.moneySpentSoFar(moneyText(a.spentIn(c.id), ccy, hidden: app.hideBalances)),
                    trailing: a.budgets[c.id] == null ? l10n.budgetNone : moneyText(a.budgets[c.id]!, ccy, hidden: app.hideBalances),
                    onTap: () => edit(c),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Recurring payments: what comes back every month, and when.
class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final money = context.read<MoneyCubit>();
    final state = context.watch<MoneyCubit>().state;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final list = [...state.recurring]..sort((a, b) => a.nextDue(now).compareTo(b.nextDue(now)));
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.featRecurring),
          actions: [IconButton(tooltip: l10n.recurringAdd, icon: const Icon(Icons.add), onPressed: () => RecurringEditorScreen.open(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: list.isEmpty
              ? [MoneyEmpty(icon: Icons.event_repeat, title: l10n.recurringEmptyTitle, message: l10n.recurringEmptyMessage, action: l10n.recurringAdd, onAction: () => RecurringEditorScreen.open(context))]
              : [
                  MoneySection(children: [
                    for (final r in list)
                      Builder(builder: (context) {
                        final from = state.book.accounts[r.fromAccountId];
                        return MoneyRow(
                          icon: MoneyIcons.category(r.categoryId),
                          title: r.name,
                          subtitle: l10n.recurringNext(DateFormat.MMMd(locale).format(r.nextDue(now))),
                          trailing: from == null ? '' : minorText(r.amount, from.currency!, hidden: hidden),
                          onTap: () => RecurringEditorScreen.open(context, existing: r),
                        );
                      }),
                  ]),
                  for (final (r, due) in money.comingUp())
                    Padding(
                      padding: const EdgeInsets.only(bottom: DS.spaceSM),
                      child: FilledButton.tonal(
                        onPressed: () => money.payRecurring(r),
                        child: Text(l10n.recurringRecord(r.name, DateFormat.MMMd(locale).format(due))),
                      ),
                    ),
                ],
        ),
      ),
    );
  }
}

class RecurringEditorScreen extends StatefulWidget {
  final RecurringPayment? existing;

  const RecurringEditorScreen({super.key, this.existing});

  static Future<void> open(BuildContext context, {RecurringPayment? existing}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecurringEditorScreen(existing: existing)));

  @override
  State<RecurringEditorScreen> createState() => _RecurringEditorScreenState();
}

class _RecurringEditorScreenState extends State<RecurringEditorScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  BookAccount? _from;
  BookAccount? _category;
  int _day = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = context.read<MoneyCubit>().state;
    final r = widget.existing;
    _from = r == null ? _accounts(s).firstOrNull : s.book.accounts[r.fromAccountId];
    _category = r == null ? s.categories(AccountSide.spending).firstOrNull : s.book.accounts[r.categoryId];
    if (r != null) {
      _name.text = r.name;
      _day = r.dayOfMonth;
      if (_from != null) _amount.text = minorFieldText(r.amount, _from!.currency!);
    } else {
      _day = DateTime.now().day.clamp(1, 28);
    }
  }

  static List<BookAccount> _accounts(MoneyState s) => [...s.ofType(AccountType.debit), ...s.ofType(AccountType.credit), ...s.ofType(AccountType.cash)];

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    if (_name.text.trim().isEmpty) return setState(() => _error = l10n.accountErrorName);
    if (_from == null || _category == null) return setState(() => _error = l10n.entryErrorAccount);
    final amount = parseMinor(_amount.text, _from!.currency!);
    if (amount == null || amount <= 0) return setState(() => _error = l10n.entryErrorAmount);
    final r = widget.existing;
    await money.saveRecurring(RecurringPayment(
      id: r?.id ?? money.newId(),
      name: _name.text.trim(),
      amount: amount,
      fromAccountId: _from!.id,
      categoryId: _category!.id,
      dayOfMonth: _day,
      lastPaid: r?.lastPaid,
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<MoneyCubit>().state;
    final accounts = _accounts(state);
    final fields = <Widget>[
      TextField(controller: _name, autofocus: widget.existing == null, decoration: InputDecoration(labelText: l10n.accountNameLabel, border: const OutlineInputBorder())),
      AmountField(controller: _amount, label: l10n.entryAmount, currency: _from?.currency ?? context.read<AppCubit>().state.baseCurrency),
      AccountPicker(label: l10n.entryPaidFrom, accounts: accounts, value: _from, onChanged: (a) => setState(() => _from = a)),
      AccountPicker(label: l10n.entryCategory, accounts: state.categories(AccountSide.spending), value: _category, onChanged: (a) => setState(() => _category = a)),
      DropdownButtonFormField<int>(
        initialValue: _day,
        decoration: InputDecoration(labelText: l10n.recurringDay, border: const OutlineInputBorder()),
        items: [for (var d = 1; d <= 28; d++) DropdownMenuItem(value: d, child: Text('$d'))],
        onChanged: (v) => setState(() => _day = v ?? _day),
      ),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      if (widget.existing != null)
        OutlinedButton(
          onPressed: () async {
            await context.read<MoneyCubit>().deleteRecurring(widget.existing!.id);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(l10n.commonDelete),
        ),
    ];
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.existing == null ? l10n.recurringAdd : widget.existing!.name),
          actions: [if (accounts.isNotEmpty) TextButton(onPressed: _save, child: Text(l10n.holdingsSave))],
        ),
        body: accounts.isEmpty
            ? MoneyEmpty(icon: Icons.account_balance_outlined, title: l10n.entryNeedsAccountTitle, message: l10n.entryNeedsAccountMessage)
            : ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [for (final f in fields) Padding(padding: const EdgeInsets.only(bottom: DS.spaceMD), child: f)],
              ),
      ),
    );
  }
}

/// Lent and borrowed: who owes the person, and whom they owe.
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final state = context.watch<MoneyCubit>().state;
    Widget group(String title, AccountType type) {
      final people = state.ofType(type);
      if (people.isEmpty) return const SizedBox.shrink();
      return MoneySection(title: title, children: [
        for (final p in people)
          MoneyRow(
            icon: MoneyIcons.type(type),
            title: p.name,
            trailing: minorText(state.book.balanceOf(p.id), p.currency!, hidden: hidden),
            onTap: () => AccountDetailScreen.open(context, p.id),
          ),
      ]);
    }

    final none = state.ofType(AccountType.receivable).isEmpty && state.ofType(AccountType.payable).isEmpty;
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.featPeople)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              ActionChip(avatar: const Icon(Icons.call_made, size: 18), label: Text(l10n.tplLent), onPressed: () => EntryEditorScreen.open(context, EntryKind.lent)),
              ActionChip(avatar: const Icon(Icons.call_received, size: 18), label: Text(l10n.tplBorrowed), onPressed: () => EntryEditorScreen.open(context, EntryKind.borrowed)),
            ]),
            const SizedBox(height: DS.spaceMD),
            if (none) MoneyEmpty(icon: Icons.people_outline, title: l10n.peopleEmptyTitle, message: l10n.peopleEmptyMessage),
            group(l10n.sheetOwedToYou, AccountType.receivable),
            group(l10n.sheetYouOwe, AccountType.payable),
          ],
        ),
      ),
    );
  }
}

/// Bill split: the person paid the whole bill; only their share is
/// spending, and each other share becomes money owed to them.
class BillSplitScreen extends StatefulWidget {
  const BillSplitScreen({super.key});

  @override
  State<BillSplitScreen> createState() => _BillSplitScreenState();
}

class _BillSplitScreenState extends State<BillSplitScreen> {
  final _total = TextEditingController();
  final _merchant = TextEditingController();
  final List<(TextEditingController, TextEditingController)> _people = [];
  BookAccount? _from;
  BookAccount? _category;
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = context.read<MoneyCubit>().state;
    _from = [...s.ofType(AccountType.credit), ...s.ofType(AccountType.debit), ...s.ofType(AccountType.cash)].firstOrNull;
    _category = s.book.accounts['category.dining'] ?? s.categories(AccountSide.spending).firstOrNull;
    _addPerson();
  }

  void _addPerson() => setState(() => _people.add((TextEditingController(), TextEditingController())));

  @override
  void dispose() {
    _total.dispose();
    _merchant.dispose();
    for (final (a, b) in _people) {
      a.dispose();
      b.dispose();
    }
    super.dispose();
  }

  /// Splits what's left of the total evenly between the person and everyone
  /// whose share is blank.
  void _even() {
    final ccy = _from?.currency;
    if (ccy == null) return;
    final total = parseMinor(_total.text, ccy);
    if (total == null) return;
    final each = total ~/ (_people.length + 1);
    for (final (_, share) in _people) {
      share.text = minorFieldText(each, ccy);
    }
    setState(() {});
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    if (_from == null || _category == null) return setState(() => _error = l10n.entryErrorAccount);
    final ccy = _from!.currency!;
    final total = parseMinor(_total.text, ccy);
    if (total == null || total <= 0) return setState(() => _error = l10n.entryErrorAmount);
    final shares = <(String, int)>[];
    for (final (name, share) in _people) {
      if (name.text.trim().isEmpty && share.text.trim().isEmpty) continue;
      final v = parseMinor(share.text, ccy);
      if (name.text.trim().isEmpty || v == null || v <= 0) return setState(() => _error = l10n.splitErrorPerson);
      shares.add((name.text.trim(), v));
    }
    final others = shares.fold<int>(0, (a, s) => a + s.$2);
    final mine = total - others;
    if (shares.isEmpty || mine < 0) return setState(() => _error = l10n.splitErrorShares);
    final owed = <BookAccount, int>{};
    for (final (name, v) in shares) {
      final p = await money.personAccount(name, ccy, owesMe: true);
      owed[p] = (owed[p] ?? 0) + v;
    }
    if (mine == 0) {
      // Paid entirely for others: no spending, only money owed.
      final e = money.builder.billSplit(_from!, _category!, total: total, myShare: 0, others: owed, date: _date, merchant: _merchant.text.trim());
      final lines = [for (final l in e.lines) if (l.amount != 0) l];
      await money.saveEntry(e.copyWith(lines: lines));
    } else {
      await money.saveEntry(money.builder.billSplit(_from!, _category!, total: total, myShare: mine, others: owed, date: _date, merchant: _merchant.text.trim()));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = context.watch<MoneyCubit>().state;
    final accounts = [...state.ofType(AccountType.credit), ...state.ofType(AccountType.debit), ...state.ofType(AccountType.cash)];
    final ccy = _from?.currency ?? context.read<AppCubit>().state.baseCurrency;
    final total = parseMinor(_total.text, ccy) ?? 0;
    final others = _people.fold<int>(0, (a, p) => a + (parseMinor(p.$2.text, ccy) ?? 0));
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.featBillSplit),
          actions: [if (accounts.isNotEmpty) TextButton(onPressed: _save, child: Text(l10n.holdingsSave))],
        ),
        body: accounts.isEmpty
            ? MoneyEmpty(icon: Icons.account_balance_outlined, title: l10n.entryNeedsAccountTitle, message: l10n.entryNeedsAccountMessage)
            : ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [
                  AmountField(controller: _total, autofocus: true, label: l10n.splitTotal, currency: ccy, onChanged: (_) => setState(() {})),
                  const SizedBox(height: DS.spaceMD),
                  AccountPicker(label: l10n.entryPaidFrom, accounts: accounts, value: _from, onChanged: (a) => setState(() => _from = a)),
                  const SizedBox(height: DS.spaceMD),
                  AccountPicker(label: l10n.entryCategory, accounts: state.categories(AccountSide.spending), value: _category, onChanged: (a) => setState(() => _category = a)),
                  const SizedBox(height: DS.spaceMD),
                  TextField(controller: _merchant, decoration: InputDecoration(labelText: l10n.entryMerchant, border: const OutlineInputBorder())),
                  const SizedBox(height: DS.spaceMD),
                  DateField(label: l10n.entryDate, value: _date, onChanged: (d) => setState(() => _date = d)),
                  const SizedBox(height: DS.spaceMD),
                  Text(l10n.splitWho, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: DS.spaceSM),
                  for (final (name, share) in _people)
                    Padding(
                      padding: const EdgeInsets.only(bottom: DS.spaceSM),
                      child: Row(children: [
                        Expanded(flex: 3, child: TextField(controller: name, decoration: InputDecoration(labelText: l10n.entryPerson, border: const OutlineInputBorder()))),
                        const SizedBox(width: DS.spaceSM),
                        Expanded(flex: 2, child: AmountField(controller: share, label: l10n.splitShare, currency: ccy, onChanged: (_) => setState(() {}))),
                      ]),
                    ),
                  // Wraps rather than overflows where the labels are long (French).
                  Wrap(alignment: WrapAlignment.spaceBetween, children: [
                    TextButton.icon(onPressed: _addPerson, icon: const Icon(Icons.person_add_alt), label: Text(l10n.splitAddPerson)),
                    TextButton(onPressed: _even, child: Text(l10n.splitEvenly)),
                  ]),
                  MoneySection(children: [
                    MoneyRow(title: l10n.splitMine, trailing: minorText(total - others, ccy, hidden: hidden), trailingColor: total - others < 0 ? colors.down : null),
                    MoneyRow(title: l10n.splitOwedToYou, trailing: minorText(others, ccy, hidden: hidden)),
                  ]),
                  Text(l10n.splitHelp, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ),
      ),
    );
  }
}

/// Spending and income categories: add, rename, archive.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final state = context.watch<MoneyCubit>().state;

    Future<void> rename(BookAccount c) async {
      final controller = TextEditingController(text: l10n.accountName(c));
      final result = await showDialog<String>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(l10n.categoryRename),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            if (c.id != SystemAccount.interestAndFees.id)
              TextButton(
                onPressed: () async {
                  final ok = await confirmDelete(d, title: l10n.categoryRemove, message: l10n.categoryRemoveMessage, confirmLabel: l10n.commonDelete);
                  if (ok && d.mounted) Navigator.of(d).pop('\u0000');
                },
                child: Text(l10n.commonDelete),
              ),
            TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(controller.text.trim()), child: Text(l10n.holdingsSave)),
          ],
        ),
      );
      controller.dispose();
      if (result == null) return;
      if (result == '\u0000') {
        await money.removeAccount(c.id);
      } else if (result.isNotEmpty) {
        await money.updateAccount(c.copyWith(name: result));
      }
    }

    Future<void> add(AccountSide side) async {
      final controller = TextEditingController();
      final name = await showDialog<String>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(side == AccountSide.spending ? l10n.categoryAddSpending : l10n.categoryAddIncome),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(controller.text.trim()), child: Text(l10n.holdingsSave)),
          ],
        ),
      );
      controller.dispose();
      if (name != null && name.isNotEmpty) await money.addCategory(name, side);
    }

    Widget list(String title, AccountSide side) => MoneySection(
          title: title,
          trailing: IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add), onPressed: () => add(side)),
          children: [
            for (final c in state.categories(side)) MoneyRow(icon: MoneyIcons.account(c), title: l10n.accountName(c), onTap: () => rename(c)),
          ],
        );

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.categoriesTitle)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [list(l10n.categoriesSpending, AccountSide.spending), list(l10n.categoriesIncome, AccountSide.income)],
        ),
      ),
    );
  }
}
