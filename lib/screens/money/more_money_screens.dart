import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../blocs/app_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/bill_split.dart';
import '../../models/people.dart';
import '../../models/book_account.dart';
import '../../models/money_analysis.dart';
import '../../models/money_settings.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/money_widgets.dart';
import '../../theme/help_topics.dart';
import '../../widgets/help_button.dart';
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
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.featBudget), actions: const [HelpButton(topic: HelpTopicId.budget)]),
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
/// How often a plan repeats, in words.
String planRepeatLabel(AppLocalizations l10n, PlanRepeat r) => switch (r) {
      PlanRepeat.once => l10n.planRepeatOnce,
      PlanRepeat.weekly => l10n.planRepeatWeekly,
      PlanRepeat.monthly => l10n.planRepeatMonthly,
      PlanRepeat.quarterly => l10n.planRepeatQuarterly,
      PlanRepeat.yearly => l10n.planRepeatYearly,
    };

/// Planned payments: money going out and coming in, once or on a repeat.
/// Tapping one records it, skips it, or opens it to change.
class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final state = context.watch<MoneyCubit>().state;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = DateUtils.dateOnly(DateTime.now());
    final open = [for (final r in state.recurring) if (!r.finished) r]..sort((a, b) => a.next!.compareTo(b.next!));
    final done = [for (final r in state.recurring) if (r.finished) r]..sort((a, b) => a.name.compareTo(b.name));

    MoneyRow row(RecurringPayment r) {
      final account = state.book.accounts[r.fromAccountId];
      final next = r.next;
      final when = next == null
          ? l10n.planFinished
          : next.isBefore(today)
              ? l10n.planOverdue(DateFormat.MMMd(locale).format(next))
              : l10n.recurringNext(DateFormat.MMMEd(locale).format(next));
      return MoneyRow(
        key: ValueKey('plan-${r.id}'),
        icon: MoneyIcons.category(r.categoryId),
        title: r.name,
        subtitle: [
          when,
          planRepeatLabel(l10n, r.repeat),
          if (r.times != null && r.repeat != PlanRepeat.once && !r.finished) l10n.planLeft(r.left!, r.times!),
        ].join(' · '),
        trailing: account == null ? '' : '${r.incoming ? '+' : ''}${minorText(r.amount, account.currency!, hidden: hidden)}',
        trailingColor: r.incoming ? context.colors.up : null,
        onTap: () => r.finished ? RecurringEditorScreen.open(context, existing: r) : _actions(context, r),
      );
    }

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.featRecurring),
          actions: [const HelpButton(topic: HelpTopicId.recurring), IconButton(tooltip: l10n.recurringAdd, icon: const Icon(Icons.add), onPressed: () => RecurringEditorScreen.open(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: state.recurring.isEmpty
              ? [MoneyEmpty(icon: Icons.event_repeat, title: l10n.recurringEmptyTitle, message: l10n.recurringEmptyMessage, action: l10n.recurringAdd, onAction: () => RecurringEditorScreen.open(context))]
              : [
                  if (open.isNotEmpty) MoneySection(title: l10n.cardComingUp, children: [for (final r in open) row(r)]),
                  if (done.isNotEmpty) MoneySection(title: l10n.planFinished, children: [for (final r in done) row(r)]),
                  MoneySection(children: [MoneyRow(icon: Icons.add, title: l10n.recurringAdd, onTap: () => RecurringEditorScreen.open(context))]),
                ],
        ),
      ),
    );
  }

  /// Record, skip, or change one plan.
  static Future<void> _actions(BuildContext context, RecurringPayment r) async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final next = r.next!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            key: const ValueKey('planRecord'),
            leading: const Icon(Icons.check_circle_outline),
            title: Text(l10n.recurringRecord(r.name, DateFormat.MMMd(locale).format(next))),
            onTap: () => Navigator.of(sheet).pop('record'),
          ),
          ListTile(key: const ValueKey('planSkip'), leading: const Icon(Icons.skip_next_outlined), title: Text(l10n.planSkip), onTap: () => Navigator.of(sheet).pop('skip')),
          ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l10n.planEdit), onTap: () => Navigator.of(sheet).pop('edit')),
        ]),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'record':
        await money.payRecurring(r);
      case 'skip':
        await money.skipRecurring(r);
      case 'edit':
        await RecurringEditorScreen.open(context, existing: r);
    }
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
  final _times = TextEditingController();
  BookAccount? _account;
  BookAccount? _category;
  bool _incoming = false;
  PlanRepeat _repeat = PlanRepeat.monthly;
  late DateTime _date;
  bool _remind = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = context.read<MoneyCubit>().state;
    final r = widget.existing;
    _account = r == null ? _accounts(s).firstOrNull : s.book.accounts[r.fromAccountId];
    if (r != null) {
      _incoming = r.incoming;
      _repeat = r.repeat;
      _remind = r.remind;
      _name.text = r.name;
      // The date shown is the next one due; changing it moves the plan.
      _date = r.next ?? r.dueAt(r.paid - 1);
      if (r.left != null && r.repeat != PlanRepeat.once) _times.text = '${r.finished ? r.times : r.left}';
      if (_account != null) _amount.text = minorFieldText(r.amount, _account!.currency!);
      _category = s.book.accounts[r.categoryId];
    } else {
      final now = DateTime.now();
      _date = DateTime(now.year, now.month, now.day);
      _category = s.categories(AccountSide.spending).firstOrNull;
    }
  }

  static List<BookAccount> _accounts(MoneyState s) => [...s.ofType(AccountType.debit), ...s.ofType(AccountType.credit), ...s.ofType(AccountType.cash)];

  List<BookAccount> _categories(MoneyState s) => s.categories(_incoming ? AccountSide.income : AccountSide.spending);

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _times.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final app = context.read<AppCubit>();
    if (_name.text.trim().isEmpty) return setState(() => _error = l10n.accountErrorName);
    if (_account == null || _category == null) return setState(() => _error = l10n.entryErrorAccount);
    final amount = parseMinor(_amount.text, _account!.currency!);
    if (amount == null || amount <= 0) return setState(() => _error = l10n.entryErrorAmount);
    final times = _repeat == PlanRepeat.once || _times.text.trim().isEmpty ? null : int.tryParse(_times.text.trim());
    if (times != null && times < 1) return setState(() => _error = l10n.entryErrorAmount);
    final r = widget.existing;
    // Same date, repeat and count: the plan keeps its history ("2 of 4
    // left"). Otherwise it is counted again from the date shown, with the
    // count as what's left.
    final same = r != null && !r.finished && r.next == _date && r.repeat == _repeat && times == (r.repeat == PlanRepeat.once ? null : r.left);
    final plan = RecurringPayment(
      id: r?.id ?? money.newId(),
      name: _name.text.trim(),
      amount: amount,
      fromAccountId: _account!.id,
      categoryId: _category!.id,
      repeat: _repeat,
      start: same ? r.start : _date,
      times: same ? r.times : times,
      paid: same ? r.paid : 0,
      incoming: _incoming,
      remind: _remind,
    );
    await money.saveRecurring(plan);
    if (_remind) await app.notificationService.requestPermission();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<MoneyCubit>().state;
    final accounts = _accounts(state);
    final categories = _categories(state);
    final fields = <Widget>[
      SegmentedButton<bool>(
        key: const ValueKey('planDirection'),
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: false, icon: const Icon(Icons.north_east), label: Text(l10n.planOut)),
          ButtonSegment(value: true, icon: const Icon(Icons.south_west), label: Text(l10n.planIn)),
        ],
        selected: {_incoming},
        onSelectionChanged: (v) => setState(() {
          _incoming = v.first;
          final choices = _categories(state);
          if (!choices.any((c) => c.id == _category?.id)) _category = choices.firstOrNull;
        }),
      ),
      TextField(controller: _name, autofocus: widget.existing == null, decoration: InputDecoration(labelText: l10n.accountNameLabel, border: const OutlineInputBorder())),
      AmountField(controller: _amount, label: l10n.entryAmount, currency: _account?.currency ?? context.read<AppCubit>().state.baseCurrency),
      AccountPicker(label: _incoming ? l10n.planPaidInto : l10n.entryPaidFrom, accounts: accounts, value: _account, onChanged: (a) => setState(() => _account = a)),
      CategoryPicker(
        accounts: categories,
        value: _category,
        side: _incoming ? AccountSide.income : AccountSide.spending,
        onChanged: (a) => setState(() => _category = a),
      ),
      DropdownButtonFormField<PlanRepeat>(
        key: const ValueKey('planRepeat'),
        initialValue: _repeat,
        decoration: InputDecoration(labelText: l10n.planRepeat, border: const OutlineInputBorder()),
        items: [for (final r in PlanRepeat.values) DropdownMenuItem(value: r, child: Text(planRepeatLabel(l10n, r)))],
        onChanged: (v) => setState(() => _repeat = v ?? _repeat),
      ),
      DateField(label: l10n.planDate, value: _date, allowFuture: true, onChanged: (d) => setState(() => _date = d)),
      if (_repeat != PlanRepeat.once)
        TextField(
          key: const ValueKey('planTimes'),
          controller: _times,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.planTimes, helperText: l10n.planTimesHelp, helperMaxLines: 2, border: const OutlineInputBorder()),
        ),
      SwitchListTile(
        key: const ValueKey('planRemind'),
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.planRemind),
        value: _remind,
        onChanged: (v) => setState(() => _remind = v),
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
          actions: [const HelpButton(topic: HelpTopicId.recurring), if (accounts.isNotEmpty) TextButton(onPressed: _save, child: Text(l10n.holdingsSave))],
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
    // One row per person and currency: what was lent to them and borrowed
    // from them nets out, in the group the net falls in.
    final everyone = Person.of(state.accounts);
    Future<void> open(Person p) async {
      final accounts = p.accounts;
      if (accounts.length == 1) return AccountDetailScreen.open(context, accounts.single.id);
      final id = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final a in accounts)
              MoneyRow(
                icon: MoneyIcons.type(a.type),
                title: a.type == AccountType.receivable ? l10n.sheetOwedToYou : l10n.sheetYouOwe,
                trailing: minorText(state.book.balanceOf(a.id), a.currency!, hidden: hidden),
                onTap: () => Navigator.of(sheet).pop(a.id),
              ),
          ]),
        ),
      );
      if (id != null && context.mounted) await AccountDetailScreen.open(context, id);
    }

    Widget group(String title, bool owedToMe) {
      final people = [for (final p in everyone) if ((p.net(state.book) >= 0) == owedToMe) p];
      if (people.isEmpty) return const SizedBox.shrink();
      return MoneySection(title: title, children: [
        for (final p in people)
          MoneyRow(
            key: ValueKey('person-${p.name}-${p.currency}'),
            icon: MoneyIcons.type(owedToMe ? AccountType.receivable : AccountType.payable),
            title: p.name,
            subtitle: p.accounts.length > 1
                ? '${l10n.tplLent} ${minorText(state.book.balanceOf(p.owesMe!.id), p.currency, hidden: hidden)} · '
                    '${l10n.tplBorrowed} ${minorText(state.book.balanceOf(p.iOwe!.id), p.currency, hidden: hidden)}'
                : null,
            trailing: minorText(p.net(state.book).abs(), p.currency, hidden: hidden),
            onTap: () => open(p),
          ),
      ]);
    }

    final none = state.ofType(AccountType.receivable).isEmpty && state.ofType(AccountType.payable).isEmpty;
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.featPeople), actions: const [HelpButton(topic: HelpTopicId.people)]),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              ActionChip(avatar: const Icon(Icons.call_made, size: 18), label: Text(l10n.tplLent), onPressed: () => EntryEditorScreen.open(context, EntryKind.lent)),
              ActionChip(avatar: const Icon(Icons.call_received, size: 18), label: Text(l10n.tplBorrowed), onPressed: () => EntryEditorScreen.open(context, EntryKind.borrowed)),
            ]),
            const SizedBox(height: DS.spaceMD),
            if (none) MoneyEmpty(icon: Icons.people_outline, title: l10n.peopleEmptyTitle, message: l10n.peopleEmptyMessage),
            group(l10n.sheetOwedToYou, true),
            group(l10n.sheetYouOwe, false),
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
  final _myShares = TextEditingController(text: '1');
  SplitBy _by = SplitBy.equally;
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

  void _addPerson() => setState(() => _people.add((TextEditingController(), TextEditingController(text: _by == SplitBy.shares ? '1' : ''))));

  /// A typed percentage or share count; blank is zero.
  static num? _number(String text) {
    final t = text.trim().replaceAll(',', '.');
    return t.isEmpty ? 0 : num.tryParse(t);
  }

  /// The people named so far, with what each typed, and every part of the
  /// bill; null parts when the values don't fit the total.
  /// While typing ([forSave] false) a row without a name yet still counts.
  ({List<(String, int)> named, int? mine, String? problem}) _parts(String ccy, AppLocalizations l10n, {bool forSave = true}) {
    final total = parseMinor(_total.text, ccy);
    final rows = [for (final (name, value) in _people) if (name.text.trim().isNotEmpty || value.text.trim().isNotEmpty) (name.text.trim(), value.text)];
    final values = <num>[];
    for (final (name, value) in rows) {
      final v = switch (_by) {
        SplitBy.amount => parseMinor(value, ccy),
        SplitBy.equally => 0,
        _ => _number(value),
      };
      if ((forSave && name.isEmpty) || v == null) return (named: const [], mine: null, problem: l10n.splitErrorPerson);
      values.add(v);
    }
    if (total == null || total <= 0) return (named: const [], mine: null, problem: l10n.entryErrorAmount);
    final split = BillSplit.divide(total, _by, values, myShares: _number(_myShares.text) ?? -1);
    if (rows.isEmpty || split == null) return (named: const [], mine: null, problem: l10n.splitErrorShares);
    return (named: [for (var i = 0; i < rows.length; i++) (rows[i].$1, split.others[i])], mine: split.mine, problem: null);
  }

  @override
  void dispose() {
    _total.dispose();
    _merchant.dispose();
    _myShares.dispose();
    for (final (a, b) in _people) {
      a.dispose();
      b.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    if (_from == null || _category == null) return setState(() => _error = l10n.entryErrorAccount);
    final ccy = _from!.currency!;
    final total = parseMinor(_total.text, ccy) ?? 0;
    final parts = _parts(ccy, l10n);
    if (parts.problem != null) return setState(() => _error = parts.problem);
    final mine = parts.mine!;
    final owed = <BookAccount, int>{};
    for (final (name, v) in parts.named) {
      if (v <= 0) continue;
      final p = await money.personAccount(name, ccy, owesMe: true);
      owed[p] = (owed[p] ?? 0) + v;
    }
    if (owed.isEmpty) return setState(() => _error = l10n.splitErrorShares);
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
    final parts = _parts(ccy, l10n, forSave: false);
    final others = parts.mine == null ? null : total - parts.mine!;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.featBillSplit),
          actions: [const HelpButton(topic: HelpTopicId.people), if (accounts.isNotEmpty) TextButton(onPressed: _save, child: Text(l10n.holdingsSave))],
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
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<SplitBy>(
                      key: const ValueKey('splitBy'),
                      showSelectedIcon: false,
                      segments: [
                        for (final by in SplitBy.values)
                          ButtonSegment(
                            value: by,
                            label: FittedBox(
                              child: Text(switch (by) {
                                SplitBy.amount => l10n.splitByAmount,
                                SplitBy.equally => l10n.splitByEqually,
                                SplitBy.percent => l10n.splitByPercent,
                                SplitBy.shares => l10n.splitByShares,
                              }),
                            ),
                          ),
                      ],
                      selected: {_by},
                      onSelectionChanged: (v) => setState(() {
                        _by = v.first;
                        for (final (_, value) in _people) {
                          value.text = _by == SplitBy.shares ? '1' : '';
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: DS.spaceMD),
                  if (_by == SplitBy.shares)
                    Padding(
                      padding: const EdgeInsets.only(bottom: DS.spaceSM),
                      child: Row(children: [
                        Expanded(flex: 3, child: Text(l10n.splitYou, style: const TextStyle(fontSize: 16))),
                        const SizedBox(width: DS.spaceSM),
                        Expanded(flex: 2, child: _NumberField(key: const ValueKey('splitMyShares'), controller: _myShares, label: l10n.splitByShares, onChanged: () => setState(() {}))),
                      ]),
                    ),
                  for (final (i, (name, share)) in _people.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: DS.spaceSM),
                      child: Row(children: [
                        Expanded(flex: 3, child: PersonField(key: ValueKey('splitPerson$i'), controller: name, label: l10n.entryPerson, onChanged: (_) => setState(() {}))),
                        if (_by != SplitBy.equally) ...[
                          const SizedBox(width: DS.spaceSM),
                          Expanded(
                            flex: 2,
                            child: switch (_by) {
                              SplitBy.amount => AmountField(key: ValueKey('splitShare$i'), controller: share, label: l10n.splitShare, currency: ccy, onChanged: (_) => setState(() {})),
                              SplitBy.percent => _NumberField(key: ValueKey('splitShare$i'), controller: share, label: '%', onChanged: () => setState(() {})),
                              _ => _NumberField(key: ValueKey('splitShare$i'), controller: share, label: l10n.splitByShares, onChanged: () => setState(() {})),
                            },
                          ),
                        ],
                      ]),
                    ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(onPressed: _addPerson, icon: const Icon(Icons.person_add_alt), label: Text(l10n.splitAddPerson)),
                  ),
                  MoneySection(children: [
                    MoneyRow(
                      key: const ValueKey('splitMine'),
                      title: l10n.splitMine,
                      trailing: parts.mine == null ? '—' : minorText(parts.mine!, ccy, hidden: hidden),
                    ),
                    if (_by != SplitBy.amount)
                      for (final (name, v) in parts.named) MoneyRow(title: name.isEmpty ? l10n.entryPerson : name, trailing: minorText(v, ccy, hidden: hidden)),
                    MoneyRow(title: l10n.splitOwedToYou, trailing: others == null ? '—' : minorText(others, ccy, hidden: hidden)),
                  ]),
                  Text(l10n.splitHelp, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ),
      ),
    );
  }
}

/// A percentage or share count.
class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  const _NumberField({super.key, required this.controller, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      );
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
            if (!c.isSystem)
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

    // What Qima learned from the person's choices, each one forgettable.
    final learned = [
      for (final MapEntry(:key, :value) in state.settings.categoryRules.entries)
        if (state.book.accounts[value] case final category?) (key, key.substring(key.indexOf(':') + 1), category),
    ]..sort((a, b) => a.$2.compareTo(b.$2));

    Future<void> forget(String ruleKey, String name, BookAccount category) async {
      final ok = await confirmDelete(context,
          title: l10n.categoriesForgetTitle,
          message: l10n.categoriesForgetMessage(name, l10n.accountName(category)),
          confirmLabel: l10n.categoriesForget);
      if (ok) await money.forgetCategory(ruleKey);
    }

    Widget list(String title, AccountSide side) => MoneySection(
          title: title,
          children: [
            for (final c in state.categories(side)) MoneyRow(icon: MoneyIcons.account(c), title: l10n.accountName(c), onTap: () => rename(c)),
            MoneyRow(
              key: ValueKey('addCategory-${side.name}'),
              icon: Icons.add,
              title: side == AccountSide.spending ? l10n.categoryAddSpending : l10n.categoryAddIncome,
              onTap: () => addCategory(context, side),
            ),
          ],
        );

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.categoriesTitle), actions: const [HelpButton(topic: HelpTopicId.categories)]),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            list(l10n.categoriesSpending, AccountSide.spending),
            list(l10n.categoriesIncome, AccountSide.income),
            if (learned.isNotEmpty)
              MoneySection(
                title: l10n.categoriesLearned,
                children: [
                  for (final (ruleKey, name, category) in learned)
                    MoneyRow(
                      key: ValueKey('rule:$ruleKey'),
                      icon: MoneyIcons.account(category),
                      title: name,
                      subtitle: l10n.accountName(category),
                      onTap: () => forget(ruleKey, name, category),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
