import '../models/ai_snapshot.dart';
import '../models/book.dart';
import '../models/book_account.dart';
import '../models/book_entry.dart';
import '../models/minor_units.dart';
import '../models/money_analysis.dart';
import '../models/net_worth.dart';
import '../models/people.dart';

/// A tool call the caller got wrong (a bad date, an unknown account). The
/// server reports it as a tool error the model can read and correct.
class ToolInputError implements Exception {
  final String message;
  const ToolInputError(this.message);

  @override
  String toString() => message;
}

/// One read-only tool: its MCP description and the function that answers it.
class QimaTool {
  final String name;
  final String title;
  final String description;
  final Map<String, dynamic> inputSchema;
  final Map<String, dynamic> Function(AiSnapshot snapshot, Map<String, dynamic> args, DateTime now) run;

  const QimaTool({
    required this.name,
    required this.title,
    required this.description,
    required this.inputSchema,
    required this.run,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'description': description,
        'inputSchema': inputSchema,
        'annotations': {'readOnlyHint': true, 'destructiveHint': false, 'idempotentHint': true, 'openWorldHint': false},
      };
}

/// The tools `qima-mcp` offers. Every figure comes from the same models the
/// app uses ([Book], [NetWorthSummary], [MonthAnalysis], [Person]), so an
/// AI app sees exactly what Qima shows. None of them write.
abstract final class QimaTools {
  static const String _dateHelp = 'A date as YYYY-MM-DD.';

  static final List<QimaTool> all = [
    QimaTool(
      name: 'get_net_worth',
      title: 'Net worth',
      description: 'What the person owns minus what they owe, in their base currency, split into cash, '
          'money owed to them, assets, holdings, cards, loans and money they owe. Holdings are at the '
          'prices Qima last loaded.',
      inputSchema: _object({'as_of': _string('$_dateHelp Defaults to today.')}),
      run: _netWorth,
    ),
    QimaTool(
      name: 'list_accounts',
      title: 'Accounts',
      description: 'Accounts with their balances: cash, bank and card accounts, assets, loans, people, '
          'and optionally the spending and income categories.',
      inputSchema: _object({
        'include_categories': _bool('Also list spending and income categories. Defaults to false.'),
        'include_archived': _bool('Also list archived accounts. Defaults to false.'),
      }),
      run: _accounts,
    ),
    QimaTool(
      name: 'list_transactions',
      title: 'Transactions',
      description: 'Transactions, newest first. Each line shows how much it changed an account, as Qima '
          'shows it: positive adds to the account (more cash, more debt on a card, more spending in a category).',
      inputSchema: _object({
        'from': _string('First day to include. $_dateHelp'),
        'to': _string('Last day to include. $_dateHelp'),
        'account': _string('Only transactions touching this account or category, by id or name.'),
        'text': _string('Only transactions whose merchant or note contains this text.'),
        'kind': {
          'type': 'string',
          'description': 'Only this kind of transaction.',
          'enum': [for (final t in EntryTemplate.values) t.wireName],
        },
        'limit': {'type': 'integer', 'description': 'At most this many, 1 to 500. Defaults to 50.', 'minimum': 1, 'maximum': 500},
      }),
      run: _transactions,
    ),
    QimaTool(
      name: 'get_spending',
      title: 'Spending by category',
      description: 'Spending and income for one month in the base currency, by category, with the budget '
          'and what is left to spend when the person has a budget.',
      inputSchema: _object({'month': _string('The month as YYYY-MM. Defaults to this month.')}),
      run: _spending,
    ),
    QimaTool(
      name: 'list_planned_payments',
      title: 'Planned payments',
      description: 'Bills, subscriptions, installments and expected income the person planned, with the next due date.',
      inputSchema: _object({}),
      run: _planned,
    ),
    QimaTool(
      name: 'list_people',
      title: 'People',
      description: 'Money lent and borrowed with other people. A positive balance is what they owe the person; '
          'negative is what the person owes them.',
      inputSchema: _object({}),
      run: _people,
    ),
    QimaTool(
      name: 'list_holdings',
      title: 'Holdings',
      description: 'Investments (gold, stocks, funds, crypto) with their value and cost in the base currency, '
          'at the prices Qima last loaded.',
      inputSchema: _object({}),
      run: _holdings,
    ),
  ];

  static QimaTool? named(String name) {
    for (final t in all) {
      if (t.name == name) return t;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Tools
  // ---------------------------------------------------------------------

  static Map<String, dynamic> _netWorth(AiSnapshot s, Map<String, dynamic> args, DateTime now) {
    final asOf = _date(args, 'as_of');
    final day = asOf == null ? null : _endOfDay(asOf);
    final summary = NetWorthSummary.of(
      book: s.book,
      holdingsValue: s.holdingsValue ?? 0,
      currency: s.baseCurrency,
      rates: s.rates,
      asOf: day,
    );
    final c = s.baseCurrency;
    return {
      'currency': c,
      if (asOf != null) 'as_of': dayToJson(asOf),
      'net_worth': _round(summary.netWorth, c),
      'owned': _round(summary.owned, c),
      'owed': _round(summary.owed, c),
      'groups': {for (final g in summary.groups) _groupName(g.group): _round(g.amount, c)},
      if (s.holdingsValue == null)
        'holdings_note': 'Holding prices had not loaded when Qima last saved; holdings count as 0.'
      else if (asOf != null)
        'holdings_note': 'Holdings are at the prices Qima last loaded, not on ${dayToJson(asOf)}.',
      if (summary.missingRates.isNotEmpty) 'left_out_currencies': (summary.missingRates.toList()..sort()),
      ..._freshness(s),
    };
  }

  static Map<String, dynamic> _accounts(AiSnapshot s, Map<String, dynamic> args, DateTime now) {
    final categories = _bool_(args, 'include_categories');
    final archived = _bool_(args, 'include_archived');
    final book = s.book;
    final balances = book.balances();
    final out = <Map<String, dynamic>>[];
    for (final a in book.accounts.values) {
      if (a.type == AccountType.system) continue;
      if (a.archived && !archived) continue;
      final isCategory = !a.side.onBalanceSheet;
      if (isCategory && !categories) continue;
      final b = balances[a.id] ?? const <String, int>{};
      out.add({
        'id': a.id,
        'name': a.name,
        'type': isCategory ? (a.side == AccountSide.income ? 'income_category' : 'spending_category') : a.type.name,
        if (a.currency != null) 'currency': a.currency,
        if (a.currency != null)
          'balance': MinorUnits.toMajor(b[a.currency] ?? 0, a.currency!)
        else
          'all_time_total': {for (final e in b.entries) if (e.value != 0) e.key: MinorUnits.toMajor(e.value, e.key)},
        if (a.archived) 'archived': true,
        if (!a.countsInNetWorth) 'counts_in_net_worth': false,
        if (a.creditLimit != null && a.currency != null) 'credit_limit': MinorUnits.toMajor(a.creditLimit!, a.currency!),
        if (a.assetKind != null) 'asset_kind': a.assetKind!.name,
        if (a.heldForSale) 'held_for_sale': true,
      });
    }
    return {'accounts': out, ..._freshness(s)};
  }

  static Map<String, dynamic> _transactions(AiSnapshot s, Map<String, dynamic> args, DateTime now) {
    final from = _date(args, 'from');
    final to = _date(args, 'to');
    if (from != null && to != null && to.isBefore(from)) throw const ToolInputError('"to" is before "from".');
    final book = s.book;
    final account = _string_(args, 'account');
    final accountId = account == null ? null : _findAccount(book, account).id;
    final text = _string_(args, 'text')?.toLowerCase();
    final kindName = _string_(args, 'kind');
    final kind = kindName == null ? null : EntryTemplate.values.where((t) => t.wireName == kindName).firstOrNull;
    if (kindName != null && kind == null) throw ToolInputError('No kind "$kindName".');
    final limit = _int(args, 'limit') ?? 50;
    if (limit < 1 || limit > 500) throw const ToolInputError('"limit" must be 1 to 500.');

    final matched = [
      for (final e in book.entries)
        if ((from == null || !e.date.isBefore(from)) &&
            (to == null || e.date.isBefore(_nextDay(to))) &&
            (accountId == null || e.lines.any((l) => l.accountId == accountId)) &&
            (kind == null || e.template == kind) &&
            (text == null || e.merchant.toLowerCase().contains(text) || e.note.toLowerCase().contains(text)))
          e,
    ]..sort((a, b) => b.date.compareTo(a.date));

    return {
      'count': matched.length,
      'returned': matched.length < limit ? matched.length : limit,
      'transactions': [for (final e in matched.take(limit)) _entry(book, e)],
      ..._freshness(s),
    };
  }

  static Map<String, dynamic> _spending(AiSnapshot s, Map<String, dynamic> args, DateTime now) {
    final month = _month(args, 'month') ?? DateTime(now.year, now.month);
    final book = s.book;
    final thisMonth = month.year == now.year && month.month == now.month;
    final analysis = MonthAnalysis.of(
      book,
      month,
      currency: s.baseCurrency,
      rates: s.rates,
      budgets: s.budgets,
      budgetCurrency: s.budgetCurrency,
      planned: thisMonth ? _plannedThisMonth(s, book, now) : const [],
    );
    final c = s.baseCurrency;
    String name(String id) => book.accounts[id]?.name ?? id;
    return {
      'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
      'currency': c,
      'spent': _round(analysis.spent, c),
      'income': _round(analysis.income, c),
      'net': _round(analysis.net, c),
      'by_category': [
        for (final (id, v) in analysis.byCategory)
          {
            'category': name(id),
            'spent': _round(v, c),
            if (analysis.budgets[id] case final b?) 'budget': _round(b, c),
          },
      ],
      if (analysis.hasBudget) ...{
        'budget': _round(analysis.budget, c),
        if (thisMonth) 'planned_still_to_pay': _round(analysis.planned, c),
        'left_to_spend': _round(analysis.leftToSpend, c),
      },
      if (analysis.missingRates.isNotEmpty) 'left_out_currencies': (analysis.missingRates.toList()..sort()),
      ..._freshness(s),
    };
  }

  static Map<String, dynamic> _planned(AiSnapshot s, Map<String, dynamic> args, DateTime now) {
    final book = s.book;
    return {
      'planned_payments': [
        for (final r in s.planned)
          {
            'name': r.name,
            'direction': r.incoming ? 'incoming' : 'outgoing',
            if (book.accounts[r.fromAccountId]?.currency case final ccy?) ...{
              'amount': MinorUnits.toMajor(r.amount, ccy),
              'currency': ccy,
            },
            'account': book.accounts[r.fromAccountId]?.name ?? r.fromAccountId,
            'category': book.accounts[r.categoryId]?.name ?? r.categoryId,
            'repeat': r.repeat.name,
            if (r.next case final next?) 'next_due': dayToJson(next) else 'finished': true,
            if (r.times != null) 'payments_left': r.times! - r.paid,
          },
      ],
      ..._freshness(s),
    };
  }

  static Map<String, dynamic> _people(AiSnapshot s, Map<String, dynamic> args, DateTime now) {
    final book = s.book;
    return {
      'people': [
        for (final p in Person.of(s.accounts))
          {'name': p.name, 'currency': p.currency, 'balance': MinorUnits.toMajor(p.net(book), p.currency)},
      ],
      ..._freshness(s),
    };
  }

  static Map<String, dynamic> _holdings(AiSnapshot s, Map<String, dynamic> args, DateTime now) {
    final c = s.baseCurrency;
    return {
      'currency': c,
      if (s.holdingsValue != null) 'total_value': _round(s.holdingsValue!, c)
      else 'note': 'Holding prices had not loaded when Qima last saved.',
      'holdings': [
        for (final h in s.holdings)
          {
            'symbol': h.symbol,
            'class': h.assetClass,
            'value': _round(h.value, c),
            'cost': _round(h.cost, c),
            'gain': _round(h.value - h.cost, c),
          },
      ],
      ..._freshness(s),
    };
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// When the figures were saved, so the model can tell the person they may
  /// be out of date (Qima updates the copy only while it is open).
  static Map<String, dynamic> _freshness(AiSnapshot s) => {
        'saved_by_qima_at': s.writtenAt.toUtc().toIso8601String(),
        'exchange_rates_at': s.rates.updatedAt.toUtc().toIso8601String(),
      };

  static Map<String, dynamic> _entry(Book book, BookEntry e) => {
        'id': e.id,
        'date': dayToJson(e.date),
        'kind': e.template.wireName,
        if (e.status != EntryStatus.posted) 'status': e.status.name,
        if (e.merchant.isNotEmpty) 'merchant': e.merchant,
        if (e.note.isNotEmpty) 'note': e.note,
        'lines': [
          for (final l in e.lines)
            if (book.accounts[l.accountId] case final a?)
              {
                'account': a.name,
                'account_id': a.id,
                'change': MinorUnits.toMajor(l.amount * a.side.shownSign, l.currency),
                'currency': l.currency,
              },
        ],
      };

  /// Planned payments still due this month, as the app counts them
  /// (`MoneyCubit.plannedOutThisMonth`).
  static List<(String, int, String)> _plannedThisMonth(AiSnapshot s, Book book, DateTime now) {
    final end = DateTime(now.year, now.month + 1, 0);
    return [
      for (final r in s.planned)
        if (!r.incoming)
          for (final _ in r.dueThrough(end))
            if (book.accounts[r.fromAccountId]?.currency case final ccy?) (r.categoryId, r.amount, ccy),
    ];
  }

  static BookAccount _findAccount(Book book, String query) {
    final byId = book.accounts[query];
    if (byId != null) return byId;
    final key = personKey(query);
    final exact = [for (final a in book.accounts.values) if (personKey(a.name) == key) a];
    if (exact.length == 1) return exact.single;
    final partial = [for (final a in book.accounts.values) if (personKey(a.name).contains(key)) a];
    if (exact.isEmpty && partial.length == 1) return partial.single;
    final options = (exact.isNotEmpty ? exact : partial).map((a) => '${a.name} (${a.id})').join(', ');
    if (options.isEmpty) throw ToolInputError('No account or category named "$query". Call list_accounts to see them.');
    throw ToolInputError('"$query" matches several: $options. Pass the id.');
  }

  static String _groupName(SheetGroup g) => switch (g) {
        SheetGroup.holdings => 'holdings',
        SheetGroup.cash => 'cash_and_bank',
        SheetGroup.owedToYou => 'owed_to_you',
        SheetGroup.assets => 'assets',
        SheetGroup.cards => 'credit_cards',
        SheetGroup.loans => 'loans',
        SheetGroup.youOwe => 'you_owe',
      };

  static double _round(double v, String currency) {
    final scale = MinorUnits.fromMajor(1, currency);
    return (v * scale).round() / scale;
  }

  static DateTime _endOfDay(DateTime d) => _nextDay(d).subtract(const Duration(microseconds: 1));

  static DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

  static final RegExp _dayPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp _monthPattern = RegExp(r'^(\d{4})-(\d{2})$');

  static DateTime? _date(Map<String, dynamic> args, String key) {
    final v = _string_(args, key);
    if (v == null) return null;
    if (!_dayPattern.hasMatch(v)) throw ToolInputError('"$key" must be YYYY-MM-DD, not "$v".');
    final d = DateTime.tryParse(v);
    if (d == null || dayToJson(d) != v) throw ToolInputError('"$key" is not a real date: "$v".');
    return DateTime(d.year, d.month, d.day);
  }

  static DateTime? _month(Map<String, dynamic> args, String key) {
    final v = _string_(args, key);
    if (v == null) return null;
    final m = _monthPattern.firstMatch(v);
    final month = m == null ? 0 : int.parse(m.group(2)!);
    if (m == null || month < 1 || month > 12) throw ToolInputError('"$key" must be YYYY-MM, not "$v".');
    return DateTime(int.parse(m.group(1)!), month);
  }

  static String? _string_(Map<String, dynamic> args, String key) {
    final v = args[key];
    if (v == null) return null;
    if (v is! String) throw ToolInputError('"$key" must be text.');
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  static int? _int(Map<String, dynamic> args, String key) {
    final v = args[key];
    if (v == null) return null;
    if (v is int) return v;
    if (v is double && v == v.roundToDouble()) return v.toInt();
    throw ToolInputError('"$key" must be a whole number.');
  }

  static bool _bool_(Map<String, dynamic> args, String key) {
    final v = args[key];
    if (v == null) return false;
    if (v is bool) return v;
    throw ToolInputError('"$key" must be true or false.');
  }

  static Map<String, dynamic> _object(Map<String, dynamic> properties) =>
      {'type': 'object', 'properties': properties, 'additionalProperties': false};

  static Map<String, dynamic> _string(String description) => {'type': 'string', 'description': description};

  static Map<String, dynamic> _bool(String description) => {'type': 'boolean', 'description': description};
}
