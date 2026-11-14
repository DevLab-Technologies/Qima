import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../models/book.dart';
import '../models/book_account.dart';
import '../models/book_entry.dart';
import '../models/categorizer.dart';
import '../models/default_categories.dart';
import '../models/deterministic_uuid.dart';
import '../models/entry_builder.dart';
import '../models/holding_transaction.dart';
import '../models/money.dart';
import '../models/money_analysis.dart';
import '../models/message_shape.dart';
import '../models/minor_units.dart';
import '../models/money_settings.dart';
import '../models/net_worth.dart';
import '../models/people.dart';
import '../models/statement_facts.dart';
import '../services/book_store.dart';

/// Everything Money shows: the books, recurring payments and Money's own
/// settings. Every figure is derived from [book]; nothing is stored twice.
class MoneyState extends Equatable {
  final bool loaded;

  /// Every account the person made, archived ones included. The system
  /// accounts are added by [book].
  final List<BookAccount> accounts;
  final List<BookEntry> entries;
  final List<RecurringPayment> recurring;
  final MoneySettings settings;

  MoneyState({
    this.loaded = false,
    this.accounts = const [],
    this.entries = const [],
    this.recurring = const [],
    this.settings = const MoneySettings(),
  });

  late final Book book = Book(accounts, entries);

  /// Accounts the person keeps (not categories or system accounts), in the
  /// order they were added.
  List<BookAccount> get balanceAccounts => [
        for (final a in accounts)
          if (a.side.onBalanceSheet && !a.isSystem) a,
      ];

  List<BookAccount> ofType(AccountType type, {bool archived = false}) => [
        for (final a in accounts)
          if (a.type == type && (archived || !a.archived)) a,
      ];

  /// Spending or income categories, the person's first; then Interest &
  /// fees and Uncategorized, which every book has.
  List<BookAccount> categories(AccountSide side) {
    final all = [
      for (final a in book.accounts.values)
        if (a.type == AccountType.category && a.side == side && !a.archived) a,
    ];
    return [...all.where((a) => !a.isSystem), ...all.where((a) => a.isSystem)];
  }

  /// Uncategorized entries grouped by merchant (Money › To categorize).
  late final List<UncategorizedGroup> uncategorized = Categorizer.uncategorized(book);

  /// True once the person has added anything Money keeps: Home then calls
  /// its total Net worth instead of Portfolio.
  bool get hasBook => balanceAccounts.isNotEmpty;

  /// Entries newest first, the way every list shows them.
  List<BookEntry> get entriesNewestFirst => [...entries]..sort((a, b) => b.date.compareTo(a.date));

  List<BookEntry> entriesFor(String accountId) => [
        for (final e in entriesNewestFirst)
          if (e.lines.any((l) => l.accountId == accountId)) e,
      ];

  MoneyState copyWith({
    bool? loaded,
    List<BookAccount>? accounts,
    List<BookEntry>? entries,
    List<RecurringPayment>? recurring,
    MoneySettings? settings,
  }) =>
      MoneyState(
        loaded: loaded ?? this.loaded,
        accounts: accounts ?? this.accounts,
        entries: entries ?? this.entries,
        recurring: recurring ?? this.recurring,
        settings: settings ?? this.settings,
      );

  @override
  List<Object?> get props => [loaded, accounts, entries, recurring, settings];
}

/// Raised when an entry would not balance or posts somewhere it can't.
/// Screens never hit this in normal use, because every entry is made by
/// [EntryBuilder]; it guards the books against a bug.
class BookRejected implements Exception {
  final List<EntryIssue> issues;
  const BookRejected(this.issues);

  @override
  String toString() => 'BookRejected: ${issues.join('; ')}';
}

/// Owns the money ledger. Base currency and rates belong to `AppCubit`
/// (they are shared with holdings), so they are read through callbacks
/// at the moment an entry is made.
class MoneyCubit extends Cubit<MoneyState> {
  final BookStore store;
  final String Function() baseCurrency;
  final FXRates Function() rates;
  final String Function() _newId;
  final DateTime Function() _now;

  MoneyCubit({
    required this.store,
    required this.baseCurrency,
    required this.rates,
    String Function()? newId,
    DateTime Function()? now,
  })  : _newId = newId ?? (() => const Uuid().v4()),
        _now = now ?? DateTime.now,
        super(MoneyState());

  String newId() => _newId();

  EntryBuilder get builder => EntryBuilder(baseCurrency: baseCurrency(), rates: rates(), newId: _newId);

  Future<void> load() async {
    final accounts = await store.loadAccounts();
    final entries = await store.entries.load();
    final recurring = await store.recurring.load();
    final settings = await store.loadSettings();
    if (isClosed) return;
    emit(state.copyWith(loaded: true, accounts: accounts, entries: entries, recurring: recurring, settings: settings));
  }

  /// Reloads the one store whose cloud key changed on another device.
  Future<void> adoptCloudChanges(String cloudKey) async {
    switch (cloudKey) {
      case BookStore.accountsKey:
        final a = await store.accounts.adoptCloudChanges();
        if (a != null && !isClosed) emit(state.copyWith(accounts: a));
      case BookStore.entriesKey:
        final e = await store.entries.adoptCloudChanges();
        if (e != null && !isClosed) emit(state.copyWith(entries: e));
      case BookStore.recurringKey:
        final r = await store.recurring.adoptCloudChanges();
        if (r != null && !isClosed) emit(state.copyWith(recurring: r));
      case BookStore.settingsKey:
        final s = await store.settings.adoptCloudChanges();
        if (s != null && !isClosed) emit(state.copyWith(settings: s.isEmpty ? const MoneySettings() : s.first));
    }
  }

  // -------------------------------------------------------------------
  // Accounts
  // -------------------------------------------------------------------

  /// Adds [account] with what is in it today ([opening], as people read
  /// it), and turns on the feature it belongs to. Returns that feature when
  /// this turned it on, so the screen can offer Undo.
  Future<MoneyFeature?> addAccount(BookAccount account, {int opening = 0, DateTime? openedOn}) async {
    final problem = account.problem;
    if (problem != null) throw ArgumentError(problem);
    // Built and checked first, so a refused opening (no rate yet, say)
    // leaves nothing half-saved.
    final e = opening == 0 ? null : builder.opening(account, opening, openedOn ?? _now());
    if (e != null) _check(Book([...state.accounts.where((a) => a.id != account.id), account], [e]), e);
    final accounts = await store.accounts.upsert(account);
    var entries = state.entries;
    if (e != null) entries = await store.entries.upsert(e);
    if (isClosed) return null;
    emit(state.copyWith(accounts: accounts, entries: entries));
    final feature = switch (account.type) {
      AccountType.loan => MoneyFeature.loans,
      AccountType.receivable || AccountType.payable => MoneyFeature.people,
      _ => null,
    };
    if (feature == null || state.settings.has(feature)) return null;
    await setFeature(feature, true);
    return feature;
  }

  Future<void> updateAccount(BookAccount account) async {
    final accounts = await store.accounts.upsert(account);
    if (!isClosed) emit(state.copyWith(accounts: accounts));
  }

  /// Saves [account] with these statement numbers (`StatementRef.key`) and
  /// takes them off any other account, so a statement or bank message is
  /// matched to one account only.
  Future<void> giveStatementRefs(BookAccount account, List<String> keys) async {
    final refs = keys.map(StatementRef.fromKey).nonNulls.toList();
    bool named(String key) => refs.any((r) => r.matches(key));
    for (final other in state.accounts) {
      if (other.id == account.id || !other.statementRefs.any(named)) continue;
      await updateAccount(other.copyWith(statementRefs: [for (final r in other.statementRefs) if (!named(r)) r]));
    }
    await updateAccount(account.copyWith(statementRefs: keys));
  }

  /// An account with entries is archived, so its history still adds up;
  /// one that was never used is deleted.
  Future<void> removeAccount(String id) async {
    final used = state.entries.any((e) => e.lines.any((l) => l.accountId == id));
    final account = state.accounts.firstWhere((a) => a.id == id);
    final accounts = used ? await store.accounts.upsert(account.copyWith(archived: true)) : await store.accounts.delete(id);
    if (!isClosed) emit(state.copyWith(accounts: accounts));
  }

  /// Makes a category, for spending or income.
  Future<BookAccount> addCategory(String name, AccountSide side) async {
    final a = BookAccount(id: 'category.${_newId()}', name: name, side: side, type: AccountType.category);
    final accounts = await store.accounts.upsert(a);
    if (!isClosed) emit(state.copyWith(accounts: accounts));
    return a;
  }

  /// Someone the person lends to or borrows from, in [currency]. People
  /// are accounts on either side; the same name can have both.
  Future<BookAccount> personAccount(String name, String currency, {required bool owesMe}) async {
    final type = owesMe ? AccountType.receivable : AccountType.payable;
    for (final a in state.accounts) {
      if (a.type == type && a.currency == currency && !a.archived && personKey(a.name) == personKey(name)) return a;
    }
    // Someone already in the book keeps the name they were first given.
    final known = state.accounts
        .where((a) => (a.type == AccountType.receivable || a.type == AccountType.payable) && !a.archived && personKey(a.name) == personKey(name))
        .firstOrNull;
    final a = BookAccount(
      id: _newId(),
      name: known?.name ?? name.trim(),
      side: owesMe ? AccountSide.own : AccountSide.owe,
      type: type,
      currency: currency,
    );
    await addAccount(a);
    return a;
  }

  // -------------------------------------------------------------------
  // Entries
  // -------------------------------------------------------------------

  void _check(Book book, BookEntry entry) {
    final issues = [
      ...entry.issues,
      for (final i in book.issues)
        if (i.id == entry.id) i,
    ];
    if (issues.isNotEmpty) throw BookRejected(issues);
  }

  /// Adds or replaces [entry] after checking that it balances. Using a
  /// feature's template turns that feature on; the feature is returned so
  /// the screen can offer Undo.
  Future<MoneyFeature?> saveEntry(BookEntry entry) async {
    final others = [for (final e in state.entries) if (e.id != entry.id) e];
    _check(Book(state.accounts, [...others, entry]), entry);
    final old = state.entries.where((e) => e.id == entry.id).firstOrNull;
    final from = old == null || entry.date.isBefore(old.date) ? entry.date : old.date;
    final stated = _laterValues({..._assetsIn(old), ..._assetsIn(entry)}, from, except: entry.id);
    final entries = await store.entries.upsert(entry);
    if (isClosed) return null;
    emit(state.copyWith(entries: entries));
    await _restate(stated);
    if (isClosed) return null;
    final feature = switch (entry.template) {
      EntryTemplate.lent || EntryTemplate.borrowed => MoneyFeature.people,
      EntryTemplate.billSplit => MoneyFeature.billSplit,
      EntryTemplate.loanPayment => MoneyFeature.loans,
      _ => null,
    };
    if (feature == null || state.settings.has(feature)) return null;
    await setFeature(feature, true);
    return feature;
  }

  /// Adds a batch of imported entries in one write, after checking every
  /// one against the book with the others in it, and remembers the files
  /// they came from so the same file is never imported twice. Nothing is
  /// saved if any entry is refused.
  Future<void> importEntries(List<BookEntry> entries, {Iterable<String> fileHashes = const []}) async {
    final ids = {for (final e in entries) e.id};
    final book = Book(state.accounts, [for (final e in state.entries) if (!ids.contains(e.id)) e, ...entries]);
    for (final e in entries) {
      _check(book, e);
    }
    if (entries.isNotEmpty) {
      final saved = await store.entries.upsertAll(entries);
      if (isClosed) return;
      emit(state.copyWith(entries: saved));
    }
    await markImported(fileHashes);
  }

  bool wasImported(String fileHash) => state.settings.importedHashes.contains(fileHash);

  Future<void> markImported(Iterable<String> fileHashes) async {
    final add = [for (final h in fileHashes) if (!state.settings.importedHashes.contains(h)) h];
    if (add.isEmpty) return;
    final all = [...state.settings.importedHashes, ...add];
    final kept = all.length > MoneySettings.keptHashes ? all.sublist(all.length - MoneySettings.keptHashes) : all;
    await _saveSettings(state.settings.copyWith(importedHashes: kept));
  }

  Future<void> deleteEntry(String id) async {
    final old = state.entries.where((e) => e.id == id).firstOrNull;
    final stated = old == null ? const <(BookEntry, String, int)>[] : _laterValues(_assetsIn(old), old.date, except: id);
    final entries = await store.entries.delete(id);
    if (isClosed) return;
    emit(state.copyWith(entries: entries));
    await _restate(stated);
  }

  static DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  Set<String> _assetsIn(BookEntry? e) => {
        if (e != null)
          for (final l in e.lines)
            if (state.book.accounts[l.accountId]?.type == AccountType.asset) l.accountId,
      };

  /// The value each later value update of [assetIds] states today. A value
  /// is what the asset was worth on its date, so a change before it (a
  /// back-dated value, a deleted one) must not move what it says; see
  /// [_restate].
  List<(BookEntry, String, int)> _laterValues(Set<String> assetIds, DateTime from, {required String except}) {
    if (assetIds.isEmpty) return const [];
    final book = state.book;
    return [
      for (final e in state.entries)
        if (e.id != except && e.counts && e.template == EntryTemplate.valuation && _endOfDay(e.date).isAfter(_endOfDay(from)))
          for (final l in e.lines)
            if (assetIds.contains(l.accountId)) (e, l.accountId, book.balanceOf(l.accountId, asOf: _endOfDay(e.date))),
    ]..sort((a, b) => a.$1.date.compareTo(b.$1.date));
  }

  /// Rewrites each value update in [stated] so it still lands on the value
  /// it stated; one that no longer changes anything is removed.
  Future<void> _restate(List<(BookEntry, String, int)> stated) async {
    for (final (old, assetId, value) in stated) {
      final e = state.entries.where((x) => x.id == old.id).firstOrNull;
      final asset = state.book.accounts[assetId];
      if (e == null || asset == null) continue;
      final line = e.lines.firstWhere((l) => l.accountId == assetId);
      final before = state.book.balanceOf(assetId, asOf: _endOfDay(e.date)) - line.amount;
      final fixed = builder.valuation(asset, current: before, value: value, date: e.date, note: e.note);
      if (fixed != null && fixed.lines.first.amount == line.amount) continue;
      final entries = fixed == null ? await store.entries.delete(e.id) : await store.entries.upsert(e.copyWith(lines: fixed.lines));
      if (isClosed) return;
      emit(state.copyWith(entries: entries));
    }
  }

  // -------------------------------------------------------------------
  // Assets the person values themselves
  // -------------------------------------------------------------------

  /// A dated new value for [asset]. The difference from its value on that
  /// day goes to Change in value. Returns false when nothing changed.
  /// A value is what the asset is worth at the end of its day, like the
  /// history it draws; a second value the same day replaces the first.
  Future<bool> revalue(BookAccount asset, int value, DateTime date, {String note = ''}) async {
    final day = DateTime(date.year, date.month, date.day);
    final current = state.book.balanceOf(asset.id, asOf: _endOfDay(day));
    final e = builder.valuation(asset, current: current, value: value, date: day, note: note);
    if (e == null) return false;
    await saveEntry(e);
    return true;
  }

  /// Sells [asset] for [proceeds] paid into [into]. The gap from its last
  /// value is the gain or loss. With [payOffLoan], the sale also pays off
  /// the loan secured on it from the same account. The asset is archived.
  Future<void> sellAsset(BookAccount asset, {required int proceeds, required BookAccount into, required DateTime date, bool payOffLoan = false}) async {
    final book = state.book;
    final carried = book.balanceOf(asset.id, asOf: _endOfDay(date));
    final sale = builder.assetSale(asset, carried: carried, proceeds: proceeds, into: into, date: date);
    final loanId = asset.securedLoanId;
    final loan = payOffLoan && loanId != null ? book.accounts[loanId] : null;
    final owed = loan == null ? 0 : book.balanceOf(loan.id, asOf: _endOfDay(date));
    final payoff = owed > 0 ? builder.loanPayment(into, loan!, principal: owed, profit: 0, date: date) : null;
    // Both are checked before either is saved, so a sale never lands
    // without the payoff it was meant to make.
    final all = Book(state.accounts, [...state.entries, sale, ?payoff]);
    _check(all, sale);
    if (payoff != null) _check(all, payoff);
    await saveEntry(sale);
    if (payoff != null) await saveEntry(payoff);
    await updateAccount(asset.copyWith(archived: true));
  }

  /// The asset's value history: one point per day it changed, oldest first.
  List<(DateTime, int)> valueHistory(String assetId) {
    final dates = <DateTime>{
      for (final e in state.entries)
        if (e.counts && e.lines.any((l) => l.accountId == assetId)) DateTime(e.date.year, e.date.month, e.date.day),
    }.toList()
      ..sort();
    return [
      for (final d in dates) (d, state.book.balanceOf(assetId, asOf: _endOfDay(d))),
    ];
  }

  // -------------------------------------------------------------------
  // Recurring payments
  // -------------------------------------------------------------------

  Future<void> saveRecurring(RecurringPayment r) async {
    final list = await store.recurring.upsert(r);
    if (isClosed) return;
    emit(state.copyWith(recurring: list));
    if (!state.settings.has(MoneyFeature.recurring)) await setFeature(MoneyFeature.recurring, true);
  }

  Future<void> deleteRecurring(String id) async {
    final list = await store.recurring.delete(id);
    if (!isClosed) emit(state.copyWith(recurring: list));
  }

  /// Records the next payment of [r] (a spend, or income when it is
  /// incoming) and moves it on to the one after.
  Future<void> payRecurring(RecurringPayment r, {DateTime? date}) async {
    final account = state.book.accounts[r.fromAccountId];
    final category = state.book.accounts[r.categoryId];
    if (account == null || category == null) throw StateError('The account or category of ${r.name} is gone.');
    final due = r.next;
    if (due == null) return;
    final now = _now();
    // Paid before it is due: it happened today, not on the due day.
    final on = date ?? (due.isAfter(now) ? now : due);
    await saveEntry(r.incoming ? builder.income(account, category, r.amount, on, merchant: r.name) : builder.spend(account, category, r.amount, on, merchant: r.name));
    await _advance(r);
  }

  /// Moves [r] past its next payment without recording anything (a month
  /// it wasn't due, or paid some other way).
  Future<void> skipRecurring(RecurringPayment r) => _advance(r);

  Future<void> _advance(RecurringPayment r) async {
    final list = await store.recurring.upsert(r.copyWith(paid: r.paid + 1));
    if (!isClosed) emit(state.copyWith(recurring: list));
  }

  /// Payments due within [days] (overdue ones included), soonest first, in
  /// and out.
  List<(RecurringPayment, DateTime)> comingUp({int days = 14}) {
    final today = _now();
    final until = DateTime(today.year, today.month, today.day + days);
    final out = [
      for (final r in state.recurring)
        if (r.next != null && !r.next!.isAfter(until)) (r, r.next!),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    return out;
  }

  /// Outgoing payments still to record through the end of this month
  /// (overdue ones included), each with its due date: what Left to spend
  /// still has to cover.
  List<(RecurringPayment, DateTime)> plannedOutThisMonth() {
    final today = _now();
    final end = DateTime(today.year, today.month + 1, 0);
    return [
      for (final r in state.recurring)
        if (!r.incoming)
          for (final d in r.dueThrough(end)) (r, d),
    ];
  }

  /// The month of [anyDay] against the budget, in [currency]. For this
  /// month, planned payments still to come in budgeted categories are
  /// taken off Left to spend, so Home, Money and Budgets agree.
  MonthAnalysis monthAnalysis(DateTime anyDay, {required String currency, required FXRates rates}) {
    final today = _now();
    final thisMonth = anyDay.year == today.year && anyDay.month == today.month;
    return MonthAnalysis.of(
      state.book,
      anyDay,
      currency: currency,
      rates: rates,
      budgets: state.settings.budgets,
      budgetCurrency: state.settings.budgetCurrency,
      planned: [
        if (thisMonth)
          for (final (r, _) in plannedOutThisMonth())
            if (state.book.accounts[r.fromAccountId]?.currency case final ccy?) (r.categoryId, r.amount, ccy),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Holdings and cash
  // -------------------------------------------------------------------

  /// The id of the cash entry that belongs to the holdings row [transactionId]:
  /// derived from it, so every device links the same pair and editing or
  /// deleting the row finds its cash entry.
  static String holdingCashId(String transactionId) => deterministicUuid('holding-cash:$transactionId');

  /// The account the holdings row [transactionId] was paid from or into,
  /// or null when it moved no cash.
  BookAccount? holdingCashAccount(String transactionId) {
    final e = state.entries.where((e) => e.id == holdingCashId(transactionId)).firstOrNull;
    if (e == null) return null;
    for (final l in e.lines) {
      final a = state.book.accounts[l.accountId];
      if (a != null && a.side.onBalanceSheet) return a;
    }
    return null;
  }

  /// Accounts a holdings trade can be paid from or into.
  List<BookAccount> get holdingCashAccounts => [
        for (final a in state.balanceAccounts)
          if (!a.archived && (a.type == AccountType.debit || a.type == AccountType.cash || a.type == AccountType.credit)) a,
      ];

  /// Keeps the cash side of holdings row [t] in step with it: a buy or fee
  /// takes what it cost off [accountId], a sell puts what it brought in,
  /// converted at today's rate when the account keeps another currency.
  /// No account, or a transfer, removes any cash entry the row had.
  Future<void> syncHoldingCash(HoldingTransaction t, {String? accountId, String label = ''}) async {
    final id = holdingCashId(t.id);
    final account = accountId == null ? null : state.book.accounts[accountId];
    final total = switch (t.kind) {
      TransactionKind.buy => t.totalCost,
      TransactionKind.sell => t.netProceeds,
      TransactionKind.fee => t.fee,
      TransactionKind.transferIn || TransactionKind.transferOut => 0.0,
    };
    final has = state.entries.any((e) => e.id == id);
    if (account == null || account.currency == null || total <= 0) {
      if (has) await deleteEntry(id);
      return;
    }
    final b = builder;
    final amount = b.convert(MinorUnits.fromMajor(total, t.currency), t.currency, account.currency!);
    if (amount <= 0) {
      if (has) await deleteEntry(id);
      return;
    }
    await saveEntry(b.holdingTrade(account, amount, t.date, incoming: t.kind == TransactionKind.sell, id: id, merchant: label));
  }

  /// Removes the cash entry of a deleted holdings row, if it had one.
  Future<void> removeHoldingCash(String transactionId) async {
    final id = holdingCashId(transactionId);
    if (state.entries.any((e) => e.id == id)) await deleteEntry(id);
  }

  // -------------------------------------------------------------------
  // Settings
  // -------------------------------------------------------------------

  Future<void> _saveSettings(MoneySettings s) async {
    emit(state.copyWith(settings: s));
    await store.settings.upsert(s);
  }

  Future<void> setFeature(MoneyFeature f, bool on) =>
      _saveSettings(state.settings.copyWith(features: on ? {...state.settings.features, f} : ({...state.settings.features}..remove(f))));

  Future<void> setFeatures(Set<MoneyFeature> features) => _saveSettings(state.settings.copyWith(features: features));

  /// Moves Home's [card] to [index] among the cards Home shows.
  Future<void> moveCard(HomeCard card, int index) {
    final order = state.settings.orderedCards..remove(card);
    final visible = [for (final c in order) if (state.settings.visibleCards.contains(c)) c];
    // Insert relative to the visible cards, keeping hidden ones where they were.
    final target = index >= visible.length ? null : visible[index];
    order.insert(target == null ? order.length : order.indexOf(target), card);
    return _saveSettings(state.settings.copyWith(homeOrder: order));
  }

  Future<void> setCardHidden(HomeCard card, bool hidden) {
    if (hidden && !card.canHide) throw ArgumentError('${card.name} can’t be hidden.');
    final set = {...state.settings.hiddenCards};
    hidden ? set.add(card) : set.remove(card);
    return _saveSettings(state.settings.copyWith(hiddenCards: set, homeOrder: state.settings.orderedCards));
  }

  /// Sets the monthly budget for [categoryId] in the base currency; zero
  /// removes it. Turns Budget on.
  Future<void> setBudget(String categoryId, int amount) {
    final base = baseCurrency();
    final was = state.settings.budgetCurrency;
    // Budgets set before the base currency changed are converted, so they
    // keep their worth rather than being read in the new currency.
    final budgets = was == null || was == base
        ? {...state.settings.budgets}
        : {
            for (final MapEntry(:key, :value) in state.settings.budgets.entries)
              if (NetWorthSummary.inCurrency(value, was, base, rates()) case final v?) key: MinorUnits.fromMajor(v, base),
          };
    amount <= 0 ? budgets.remove(categoryId) : budgets[categoryId] = amount;
    return _saveSettings(state.settings.copyWith(
      budgets: budgets,
      budgetCurrency: base,
      features: {...state.settings.features, MoneyFeature.budget},
    ));
  }

  /// Books [entryIds] to [categoryId], and with [ruleKey] remembers the
  /// choice for that merchant so later imports use it. All or nothing.
  Future<void> categorize(Iterable<String> entryIds, String categoryId, {String? ruleKey}) async {
    final ids = entryIds.toSet();
    final book = state.book;
    final changed = [
      for (final e in state.entries)
        if (ids.contains(e.id)) Categorizer.recategorized(e, book, categoryId),
    ];
    final all = Book(state.accounts, [for (final e in state.entries) if (!ids.contains(e.id)) e, ...changed]);
    for (final e in changed) {
      _check(all, e);
    }
    if (changed.isNotEmpty) {
      final saved = await store.entries.upsertAll(changed);
      if (isClosed) return;
      emit(state.copyWith(entries: saved));
    }
    if (ruleKey != null) await learnCategories({ruleKey: categoryId});
  }

  /// Remembers categories picked for merchants, by rule key.
  Future<void> learnCategories(Map<String, String> rules) async {
    if (rules.isEmpty) return;
    await _saveSettings(state.settings.copyWith(categoryRules: {...state.settings.categoryRules, ...rules}));
  }

  /// Remembers, from the review screen, which account each bank message
  /// sender's messages went to ([senders], by `senderKey`) and how senders
  /// write the messages the person corrected ([shapes]).
  Future<void> learnMessages({Map<String, String> senders = const {}, List<MessageShape> shapes = const []}) async {
    if (senders.isEmpty && shapes.isEmpty) return;
    final s = state.settings;
    await _saveSettings(s.copyWith(
      messageSenders: {...s.messageSenders, ...senders},
      messageShapes: MessageShape.merge(s.messageShapes, shapes),
    ));
  }

  Future<void> setAutoAddMessages(bool on) => _saveSettings(state.settings.copyWith(autoAddMessages: on));

  Future<void> markBankMessagesAsked() => _saveSettings(state.settings.copyWith(askedBankMessages: true));

  Future<void> forgetCategory(String ruleKey) =>
      _saveSettings(state.settings.copyWith(categoryRules: {...state.settings.categoryRules}..remove(ruleKey)));

  Future<void> markWhatsNewSeen() => _saveSettings(state.settings.copyWith(seenWhatsNew: true));

  Future<void> setValueReviewMonths(int months) => _saveSettings(state.settings.copyWith(valueReviewMonths: months));

  /// Whether [id] is a default category that was never renamed, so screens
  /// show its name in the person's language.
  static bool isUnrenamedDefault(BookAccount a) => DefaultCategories.seededName(a.id) == a.name;
}
