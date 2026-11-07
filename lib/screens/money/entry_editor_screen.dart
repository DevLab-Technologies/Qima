import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/app_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/book_entry.dart';
import '../../models/categorizer.dart';
import '../../models/entry_builder.dart';
import '../../models/import_plan.dart';
import '../../models/spoken_entry.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/dictation_button.dart';
import '../../widgets/money_widgets.dart';
import '../../theme/help_topics.dart';
import '../../widgets/help_button.dart';

/// The ways a person adds a transaction. Each is one template; the editor
/// asks only what that template needs.
enum EntryKind {
  spend,
  income,
  transfer,
  cardPayment,
  loanPayment,
  lent,
  borrowed,
  repaymentIn,
  repaymentOut,
  refund,
  swap;

  EntryTemplate get template => switch (this) {
        EntryKind.spend => EntryTemplate.spend,
        EntryKind.income => EntryTemplate.income,
        EntryKind.transfer => EntryTemplate.transfer,
        EntryKind.cardPayment => EntryTemplate.cardPayment,
        EntryKind.loanPayment => EntryTemplate.loanPayment,
        EntryKind.lent => EntryTemplate.lent,
        EntryKind.borrowed => EntryTemplate.borrowed,
        EntryKind.repaymentIn => EntryTemplate.repaymentIn,
        EntryKind.repaymentOut => EntryTemplate.repaymentOut,
        EntryKind.refund => EntryTemplate.refund,
        EntryKind.swap => EntryTemplate.swap,
      };

  /// The kind an existing entry can be edited as, or null when it can only
  /// be deleted and made again (an import, a sale, a valuation).
  static EntryKind? forEntry(BookEntry e) => switch (e.template) {
        EntryTemplate.spend || EntryTemplate.declined => EntryKind.spend,
        EntryTemplate.income => EntryKind.income,
        EntryTemplate.transfer || EntryTemplate.atm => EntryKind.transfer,
        EntryTemplate.cardPayment => EntryKind.cardPayment,
        EntryTemplate.loanPayment => EntryKind.loanPayment,
        EntryTemplate.refund => EntryKind.refund,
        EntryTemplate.swap => EntryKind.swap,
        EntryTemplate.lent => EntryKind.lent,
        EntryTemplate.borrowed => EntryKind.borrowed,
        EntryTemplate.repaymentIn => EntryKind.repaymentIn,
        EntryTemplate.repaymentOut => EntryKind.repaymentOut,
        _ => null,
      };
}

class EntryEditorScreen extends StatefulWidget {
  final EntryKind kind;

  /// Editing: the entry being changed. Its id is kept.
  final BookEntry? existing;

  /// Starting values, e.g. the card a Pay card button came from.
  final String? fromAccountId;
  final String? toAccountId;

  const EntryEditorScreen({super.key, required this.kind, this.existing, this.fromAccountId, this.toAccountId});

  static Future<void> open(BuildContext context, EntryKind kind, {BookEntry? existing, String? from, String? to}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EntryEditorScreen(kind: kind, existing: existing, fromAccountId: from, toAccountId: to)));

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  final _amount = TextEditingController();
  final _second = TextEditingController(); // received (swap) or profit (loan)
  final _merchant = TextEditingController();
  final _note = TextEditingController();
  final _person = TextEditingController();
  BookAccount? _from;
  BookAccount? _to;
  BookAccount? _category;
  DateTime _date = DateTime.now();
  bool _declined = false;
  String? _error;

  /// What the mic heard, shown while and after listening.
  String? _heard;
  bool _listening = false;

  late EntryKind kind = widget.kind;

  /// Spend, income and transfer share one page, one tab each, while adding.
  static const tabs = [EntryKind.spend, EntryKind.income, EntryKind.transfer];
  bool get _showTabs => widget.existing == null && tabs.contains(widget.kind);
  MoneyCubit get _money => context.read<MoneyCubit>();

  @override
  void initState() {
    super.initState();
    final s = _money.state;
    final book = s.book;
    final e = widget.existing;
    if (e != null) {
      _prefill(e);
      return;
    }
    _from = widget.fromAccountId == null ? null : book.accounts[widget.fromAccountId];
    _to = widget.toAccountId == null ? null : book.accounts[widget.toAccountId];
    _from ??= _fromChoices.firstOrNull;
    _to ??= _toChoices.where((a) => a.id != _from?.id).firstOrNull;
    _category = _categoryChoices.firstOrNull;
  }

  /// Moves to another tab. The amount, date, merchant and note stay; the
  /// money account chosen stays where the new tab has a place for it.
  void _switchTo(EntryKind next) {
    if (next == kind) return;
    final money = kind == EntryKind.income ? _to : _from;
    setState(() {
      kind = next;
      _error = null;
      BookAccount? keep(List<BookAccount> choices) => choices.where((a) => a.id == money?.id).firstOrNull ?? choices.firstOrNull;
      _from = _fromChoices.isEmpty ? null : keep(_fromChoices);
      _to = kind == EntryKind.income ? keep(_toChoices) : _toChoices.where((a) => a.id != _from?.id).firstOrNull;
      _category = _categoryChoices.firstOrNull;
    });
  }

  void _prefill(BookEntry e) {
    final book = _money.state.book;
    BookAccount? acct(bool Function(BookAccount) test, {bool positive = false, bool negative = false}) {
      for (final l in e.lines) {
        final a = book.accounts[l.accountId];
        if (a == null || !test(a)) continue;
        if (positive && l.amount <= 0) continue;
        if (negative && l.amount >= 0) continue;
        return a;
      }
      return null;
    }

    int lineOf(BookAccount? a) => a == null ? 0 : e.lines.firstWhere((l) => l.accountId == a.id).amount;
    bool own(BookAccount a) => a.side.onBalanceSheet;
    bool cat(BookAccount a) => a.type == AccountType.category && a.id != SystemAccount.interestAndFees.id;
    _date = e.date;
    _merchant.text = e.merchant;
    _note.text = e.note;
    _declined = e.status == EntryStatus.declined;
    switch (kind) {
      case EntryKind.spend:
        _from = acct(own);
        _category = acct(cat);
        _amount.text = minorFieldText(lineOf(_category), _from?.currency ?? 'USD');
      case EntryKind.income || EntryKind.refund:
        _to = acct(own);
        _category = acct(cat);
        _amount.text = minorFieldText(lineOf(_to), _to?.currency ?? 'USD');
      case EntryKind.loanPayment:
        _to = acct((a) => a.type == AccountType.loan);
        _from = acct(own, negative: true);
        final interest = e.lines.where((l) => l.accountId == SystemAccount.interestAndFees.id).firstOrNull;
        _amount.text = minorFieldText(lineOf(_to), _to?.currency ?? 'USD');
        _second.text = interest == null ? '' : minorFieldText(interest.amount, interest.currency);
      case EntryKind.swap:
        _from = acct(own, negative: true);
        _to = acct(own, positive: true);
        _amount.text = minorFieldText(-lineOf(_from), _from?.currency ?? 'USD');
        _second.text = minorFieldText(lineOf(_to), _to?.currency ?? 'USD');
      default:
        _from = acct(own, negative: true);
        _to = acct(own, positive: true);
        _amount.text = minorFieldText(lineOf(_to).abs(), _to?.currency ?? 'USD');
        // Repaying someone: the editor's "from" is the person, "to" the money.
        if (kind == EntryKind.repaymentOut) {
          final person = _to;
          _to = _from;
          _from = person;
        }
        if (kind == EntryKind.lent || kind == EntryKind.borrowed) {
          _person.text = (kind == EntryKind.lent ? _to : _from)?.name ?? '';
        }
    }
  }

  /// Fills the form from a spoken sentence. Only what was said changes,
  /// and every figure is the person's own; they check it and tap Save.
  void _applySpoken(String text) {
    final l10n = AppLocalizations.of(context)!;
    final state = _money.state;
    final heard = SpokenEntry.parse(
      text,
      accounts: {for (final a in _of({..._money_, AccountType.credit})) a.id: l10n.accountName(a)},
      categories: {
        for (final a in [...state.categories(AccountSide.spending), ...state.categories(AccountSide.income)])
          if (!Categorizer.isUncategorized(a.id)) a.id: l10n.accountName(a),
      },
    );
    if (heard.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(persist: false, content: Text(l10n.entryVoiceNothing)));
      return;
    }
    final next = switch (heard.kind) {
      SpokenKind.spend => EntryKind.spend,
      SpokenKind.income => EntryKind.income,
      SpokenKind.transfer => EntryKind.transfer,
      null => null,
    };
    if (_showTabs && next != null) _switchTo(next);
    final book = state.book;
    BookAccount? pick(List<BookAccount> choices, String? id) => id == null ? null : choices.where((a) => a.id == id).firstOrNull;
    setState(() {
      _error = null;
      if (heard.amount != null) _amount.text = heard.amount!;
      if (heard.merchant != null) _merchant.text = heard.merchant!;
      if (heard.daysAgo != null) {
        final now = DateTime.now();
        _date = DateTime(now.year, now.month, now.day - heard.daysAgo!);
      }
      final ids = heard.accountIds;
      if (ids.isNotEmpty) {
        if (kind == EntryKind.income || kind == EntryKind.refund) {
          _to = pick(_toChoices, ids.first) ?? _to;
        } else if (_toChoices.isNotEmpty && ids.length > 1) {
          _from = pick(_fromChoices, ids[0]) ?? _from;
          _to = pick(_toChoices, ids[1]) ?? _to;
        } else if (kind == EntryKind.cardPayment || kind == EntryKind.loanPayment) {
          _from = pick(_fromChoices, ids.first) ?? _from;
          _to = pick(_toChoices, ids.first) ?? _to;
        } else {
          _from = pick(_fromChoices, ids.first) ?? _from;
        }
      }
      final said = pick(_categoryChoices, heard.categoryId);
      if (said != null) {
        _category = said;
      } else if (heard.merchant != null && _categoryChoices.isNotEmpty) {
        final guess = ImportPlanner.guessCategory(heard.merchant!, isIn: kind == EntryKind.income, categorizer: Categorizer(book, rules: state.settings.categoryRules));
        if (guess.sure) _category = pick(_categoryChoices, guess.categoryId) ?? _category;
      }
    });
  }

  @override
  void dispose() {
    for (final c in [_amount, _second, _merchant, _note, _person]) {
      c.dispose();
    }
    super.dispose();
  }

  List<BookAccount> _of(Set<AccountType> types) => [
        for (final a in _money.state.accounts)
          if (types.contains(a.type) && !a.archived) a,
      ];

  static const _money_ = {AccountType.cash, AccountType.debit};

  List<BookAccount> get _fromChoices => switch (kind) {
        EntryKind.spend => _of({..._money_, AccountType.credit}),
        EntryKind.income || EntryKind.borrowed || EntryKind.repaymentIn || EntryKind.refund => const [],
        EntryKind.repaymentOut => _of({AccountType.payable}),
        _ => _of(_money_),
      };

  List<BookAccount> get _toChoices => switch (kind) {
        EntryKind.income || EntryKind.borrowed => _of(_money_),
        EntryKind.refund => _of({..._money_, AccountType.credit}),
        EntryKind.transfer || EntryKind.swap => _of(_money_),
        EntryKind.cardPayment => _of({AccountType.credit}),
        EntryKind.loanPayment => _of({AccountType.loan}),
        EntryKind.repaymentIn => _of(_money_),
        _ => const [],
      };

  List<BookAccount> get _categoryChoices => switch (kind) {
        EntryKind.spend || EntryKind.refund => [
            for (final a in _money.state.categories(AccountSide.spending))
              if (a.id != SystemAccount.interestAndFees.id) a,
          ],
        EntryKind.income => _money.state.categories(AccountSide.income),
        _ => const [],
      };

  /// The money account the amount is in.
  String get _currency {
    final a = switch (kind) {
      EntryKind.income || EntryKind.refund || EntryKind.borrowed || EntryKind.repaymentIn => _to,
      EntryKind.cardPayment || EntryKind.loanPayment => _to ?? _from,
      _ => _from,
    };
    return a?.currency ?? context.read<AppCubit>().state.baseCurrency;
  }

  EntryBuilder get _builder {
    final id = widget.existing?.id;
    final b = _money.builder;
    return id == null ? b : EntryBuilder(baseCurrency: b.baseCurrency, rates: b.rates, newId: () => id);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = parseMinor(_amount.text, _currency);
    if (amount == null || amount <= 0) return setState(() => _error = l10n.entryErrorAmount);
    final b = _builder;
    final merchant = _merchant.text.trim();
    BookEntry? entry;
    try {
      switch (kind) {
        case EntryKind.spend:
          if (_from == null || _category == null) return setState(() => _error = l10n.entryErrorAccount);
          entry = b.spend(_from!, _category!, amount, _date, merchant: merchant, status: _declined ? EntryStatus.declined : EntryStatus.posted);
        case EntryKind.income:
          if (_to == null || _category == null) return setState(() => _error = l10n.entryErrorAccount);
          entry = b.income(_to!, _category!, amount, _date, merchant: merchant);
        case EntryKind.refund:
          if (_to == null || _category == null) return setState(() => _error = l10n.entryErrorAccount);
          entry = b.refund(_to!, _category!, amount, _date, merchant: merchant);
        case EntryKind.transfer:
          if (_from == null || _to == null || _from!.id == _to!.id) return setState(() => _error = l10n.entryErrorAccount);
          if (_from!.currency != _to!.currency) return setState(() => _error = l10n.entryErrorSameCurrency);
          entry = b.transfer(_from!, _to!, amount, _date, atm: _from!.type == AccountType.debit && _to!.type == AccountType.cash);
        case EntryKind.swap:
          final received = _to == null ? null : parseMinor(_second.text, _to!.currency!);
          if (_from == null || _to == null || _from!.currency == _to!.currency) return setState(() => _error = l10n.entryErrorSwap);
          if (received == null || received <= 0) return setState(() => _error = l10n.entryErrorAmount);
          entry = b.swap(_from!, amount, _to!, received, _date);
        case EntryKind.cardPayment:
          if (_from == null || _to == null) return setState(() => _error = l10n.entryErrorAccount);
          if (_from!.currency != _to!.currency) return setState(() => _error = l10n.entryErrorSameCurrency);
          entry = b.cardPayment(_from!, _to!, amount, _date);
        case EntryKind.loanPayment:
          if (_from == null || _to == null) return setState(() => _error = l10n.entryErrorAccount);
          if (_from!.currency != _to!.currency) return setState(() => _error = l10n.entryErrorSameCurrency);
          final profit = _second.text.trim().isEmpty ? 0 : parseMinor(_second.text, _to!.currency!);
          if (profit == null || profit < 0) return setState(() => _error = l10n.entryErrorAmount);
          entry = b.loanPayment(_from!, _to!, principal: amount, profit: profit, date: _date);
        case EntryKind.lent || EntryKind.borrowed:
          final money = kind == EntryKind.lent ? _from : _to;
          final name = _person.text.trim();
          if (money == null) return setState(() => _error = l10n.entryErrorAccount);
          if (name.isEmpty) return setState(() => _error = l10n.entryErrorPerson);
          final person = await _money.personAccount(name, money.currency!, owesMe: kind == EntryKind.lent);
          entry = kind == EntryKind.lent ? b.lent(money, person, amount, _date) : b.borrowed(money, person, amount, _date);
        case EntryKind.repaymentIn:
          if (_from == null || _to == null) return setState(() => _error = l10n.entryErrorAccount);
          if (_from!.currency != _to!.currency) return setState(() => _error = l10n.entryErrorSameCurrency);
          entry = b.repaymentIn(_to!, _from!, amount, _date);
        case EntryKind.repaymentOut:
          if (_from == null || _to == null) return setState(() => _error = l10n.entryErrorAccount);
          if (_from!.currency != _to!.currency) return setState(() => _error = l10n.entryErrorSameCurrency);
          entry = b.repaymentOut(_to!, _from!, amount, _date);
      }
    } on ArgumentError {
      return setState(() => _error = l10n.entryErrorRate);
    }
    final withNote = _note.text.trim().isEmpty ? entry : entry.copyWith(note: _note.text.trim());
    final turnedOn = await _money.saveEntry(withNote);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (turnedOn != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.featureTurnedOn(l10n.feature(turnedOn))),
        action: SnackBarAction(label: l10n.commonUndo, onPressed: () => _money.setFeature(turnedOn, false)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<MoneyCubit>().state;
    // Lent and repayment-in take the person from the people lists.
    final people = switch (kind) {
      EntryKind.repaymentIn => state.ofType(AccountType.receivable),
      _ => const <BookAccount>[],
    };
    final title = widget.existing != null
        ? l10n.entryEditTitle
        : _showTabs
            ? l10n.entryNewTitle
            : l10n.template(kind.template);
    final missingAccount = (_fromChoices.isEmpty && !{EntryKind.income, EntryKind.refund, EntryKind.borrowed, EntryKind.repaymentIn}.contains(kind)) ||
        (_toChoices.isEmpty && {EntryKind.income, EntryKind.refund, EntryKind.borrowed, EntryKind.transfer, EntryKind.cardPayment, EntryKind.loanPayment, EntryKind.swap, EntryKind.repaymentIn}.contains(kind));

    final kindTabs = !_showTabs
        ? null
        : SegmentedButton<EntryKind>(
            key: const ValueKey('entryKindTabs'),
            showSelectedIcon: false,
            segments: [
              for (final k in tabs) ButtonSegment(value: k, icon: Icon(MoneyIcons.template(k.template)), label: Text(l10n.template(k.template))),
            ],
            selected: {kind},
            onSelectionChanged: (s) => _switchTo(s.first),
          );

    final heard = _heard;
    final fields = <Widget>[
      ?kindTabs,
      if (_listening || heard != null)
        Row(key: const ValueKey('entryHeard'), crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.graphic_eq, size: 18, color: _listening ? context.colors.brand : context.colors.textTertiary),
          const SizedBox(width: DS.spaceSM),
          Expanded(
            child: Text(
              heard == null || heard.isEmpty ? l10n.entryVoiceHint : '“$heard”',
              style: TextStyle(color: context.colors.textSecondary, fontStyle: heard == null || heard.isEmpty ? FontStyle.normal : FontStyle.italic),
            ),
          ),
        ]),
      AmountField(
        controller: _amount,
        autofocus: widget.existing == null,
        label: switch (kind) {
          EntryKind.loanPayment => l10n.entryPrincipal,
          EntryKind.swap => l10n.entrySent,
          _ => l10n.entryAmount,
        },
        currency: _currency,
      ),
      if (kind == EntryKind.loanPayment) AmountField(controller: _second, label: l10n.entryProfit, currency: _currency, helper: l10n.entryProfitHelp),
      if (kind == EntryKind.swap && _to != null) AmountField(controller: _second, label: l10n.entryReceived, currency: _to!.currency!),
      if (_fromChoices.isNotEmpty)
        AccountPicker(
          label: switch (kind) {
            EntryKind.repaymentOut => l10n.entryPerson,
            EntryKind.spend => l10n.entryPaidFrom,
            _ => l10n.entryFrom,
          },
          accounts: _fromChoices,
          value: _from,
          onChanged: (a) => setState(() => _from = a),
        ),
      if (kind == EntryKind.repaymentOut)
        AccountPicker(label: l10n.entryFrom, accounts: _of(_money_), value: _to, onChanged: (a) => setState(() => _to = a)),
      if (kind == EntryKind.repaymentIn)
        AccountPicker(label: l10n.entryPerson, accounts: people, value: _from, onChanged: (a) => setState(() => _from = a)),
      if (_toChoices.isNotEmpty)
        AccountPicker(
          label: switch (kind) {
            EntryKind.cardPayment => l10n.acctCredit,
            EntryKind.loanPayment => l10n.acctLoan,
            _ => l10n.entryTo,
          },
          accounts: _toChoices,
          value: _to,
          onChanged: (a) => setState(() => _to = a),
        ),
      if (kind == EntryKind.lent || kind == EntryKind.borrowed)
        Autocomplete<String>(
          initialValue: TextEditingValue(text: _person.text),
          optionsBuilder: (v) => {
            for (final a in state.accounts)
              if ((a.type == AccountType.receivable || a.type == AccountType.payable) && a.name.toLowerCase().contains(v.text.toLowerCase())) a.name,
          },
          onSelected: (v) => _person.text = v,
          fieldViewBuilder: (context, controller, focus, submit) => TextField(
            controller: controller,
            focusNode: focus,
            onChanged: (v) => _person.text = v,
            decoration: InputDecoration(labelText: l10n.entryPerson, border: const OutlineInputBorder()),
          ),
        ),
      if (_categoryChoices.isNotEmpty)
        AccountPicker(label: l10n.entryCategory, accounts: _categoryChoices, value: _category, onChanged: (a) => setState(() => _category = a)),
      DateField(label: l10n.entryDate, value: _date, onChanged: (d) => setState(() => _date = d)),
      if ({EntryKind.spend, EntryKind.income, EntryKind.refund}.contains(kind))
        TextField(controller: _merchant, decoration: InputDecoration(labelText: l10n.entryMerchant, border: const OutlineInputBorder())),
      TextField(controller: _note, decoration: InputDecoration(labelText: l10n.entryNote, border: const OutlineInputBorder())),
      if (kind == EntryKind.spend)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.entryDeclined),
          subtitle: Text(l10n.entryDeclinedHelp),
          value: _declined,
          onChanged: (v) => setState(() => _declined = v),
        ),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ];

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title),
          actions: [
            const HelpButton(topic: HelpTopicId.newTransaction),
            if (!missingAccount && widget.existing == null)
              DictationButton(
                onText: (t) => setState(() => _heard = t),
                onFinal: _applySpoken,
                onListening: (on) => setState(() {
                  _listening = on;
                  if (on) _heard = null;
                }),
              ),
            if (!missingAccount) TextButton(onPressed: _save, child: Text(l10n.holdingsSave)),
          ],
        ),
        body: missingAccount
            ? Column(children: [
                if (kindTabs != null) Padding(padding: const EdgeInsets.all(DS.spaceMD), child: kindTabs),
                Expanded(child: MoneyEmpty(icon: Icons.account_balance_outlined, title: l10n.entryNeedsAccountTitle, message: l10n.entryNeedsAccountMessage)),
              ])
            : ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [
                  for (final f in fields) Padding(padding: const EdgeInsets.only(bottom: DS.spaceMD), child: f),
                ],
              ),
      ),
    );
  }
}
