import 'package:equatable/equatable.dart';

import 'syncable.dart';

/// The named ways an entry is made. Lists and filters show the template's
/// name ("Card payment", "Lent"); what counts as spending is decided by the
/// lines, never by the template.
enum EntryTemplate {
  opening('opening'),
  spend('spend'),
  income('income'),
  transfer('transfer'),
  atm('atm'),
  swap('swap'),
  cardPayment('card_payment'),
  loanPayment('loan_payment'),
  lent('lent'),
  borrowed('borrowed'),
  repaymentIn('repayment_in'),
  repaymentOut('repayment_out'),
  refund('refund'),
  declined('declined'),
  cashCount('cash_count'),
  billSplit('bill_split'),
  valuation('valuation'),
  assetSale('asset_sale'),

  /// The cash side of a holdings buy, sell or fee: money between a cash
  /// account and Holdings, kept in step with the holdings row it belongs to.
  holdingTrade('holding_trade'),
  adjustment('adjustment');

  /// The stored name, as in design.md section 7.
  final String wireName;

  const EntryTemplate(this.wireName);

  static EntryTemplate fromWire(String? name) =>
      EntryTemplate.values.firstWhere((t) => t.wireName == name, orElse: () => EntryTemplate.adjustment);
}

enum EntryStatus {
  pending,
  posted,

  /// Shown struck through; never in a balance.
  declined;

  static EntryStatus fromName(String? name) =>
      EntryStatus.values.firstWhere((s) => s.name == name, orElse: () => EntryStatus.posted);
}

/// How an entry came into the books.
enum EntrySource {
  typed,
  voice,
  import,
  count,
  rule,
  valuation,
  migration;

  static EntrySource fromName(String? name) =>
      EntrySource.values.firstWhere((s) => s.name == name, orElse: () => EntrySource.typed);
}

/// One line of an entry: an amount posted to one account.
class EntryLine extends Equatable {
  final String accountId;

  /// Whole minor units of [currency], debit-positive (see `AccountSide`).
  final int amount;
  final String currency;

  /// The same amount in minor units of the entry's base currency, at the
  /// rate the entry was made with. Equal to [amount] when [currency] is the
  /// base. Lets an entry that changes currency balance in one unit.
  final int baseAmount;

  const EntryLine({required this.accountId, required this.amount, required this.currency, required this.baseAmount});

  Map<String, dynamic> toJson() => {'account': accountId, 'amount': amount, 'currency': currency, 'base': baseAmount};

  factory EntryLine.fromJson(Map<String, dynamic> json) => EntryLine(
        accountId: json['account'] as String,
        amount: json['amount'] as int,
        currency: json['currency'] as String,
        baseAmount: json['base'] as int,
      );

  @override
  List<Object?> get props => [accountId, amount, currency, baseAmount];
}

/// Why an entry, or an account it uses, can't go into the books.
enum EntryProblem {
  tooFewLines,
  zeroLine,
  baseSignMismatch,
  baseMismatch,
  unbalanced,
  unknownAccount,
  wrongCurrency,
  badAccount,
}

class EntryIssue extends Equatable {
  final EntryProblem problem;

  /// The entry, or for [EntryProblem.badAccount] the account.
  final String id;
  final String detail;

  const EntryIssue(this.problem, this.id, this.detail);

  @override
  String toString() => '${problem.name} ($id): $detail';

  @override
  List<Object?> get props => [problem, id, detail];
}

/// One event in the books: two or more lines that balance. Shown to people
/// as a transaction. An entry and its lines sync as one record, so a device
/// never sees half an entry.
class BookEntry extends Equatable implements Syncable {
  @override
  final String id;
  final DateTime date;

  /// When the bank posted it, if later than [date].
  final DateTime? postedDate;
  final EntryTemplate template;
  final EntryStatus status;

  /// The currency [EntryLine.baseAmount] is in. Kept on the entry so a
  /// change of the person's base currency never unbalances old entries.
  final String baseCurrency;
  final List<EntryLine> lines;
  final String merchant;

  /// The text as it arrived (an SMS, a statement row), before merchant rules.
  final String rawMerchant;
  final String note;
  final EntrySource source;

  const BookEntry({
    required this.id,
    required this.date,
    required this.template,
    required this.baseCurrency,
    required this.lines,
    this.postedDate,
    this.status = EntryStatus.posted,
    this.merchant = '',
    this.rawMerchant = '',
    this.note = '',
    this.source = EntrySource.typed,
  });

  /// Pending and posted entries move balances; a declined one doesn't.
  bool get counts => status != EntryStatus.declined;

  Set<String> get currencies => {for (final l in lines) l.currency};

  /// Whatever is wrong with the entry on its own, before looking at the
  /// accounts. Empty means it balances.
  ///
  /// The rule: lines in one currency must sum to zero in that currency.
  /// Lines in several currencies must sum to zero in the base currency
  /// (an FX difference is closed with a Rounding line, see `EntryBuilder`).
  List<EntryIssue> get issues {
    final out = <EntryIssue>[];
    if (lines.isEmpty && status == EntryStatus.declined) return out;
    if (lines.length < 2) out.add(EntryIssue(EntryProblem.tooFewLines, id, 'An entry needs two lines or more; it has ${lines.length}.'));
    for (final l in lines) {
      if (l.amount == 0) out.add(EntryIssue(EntryProblem.zeroLine, id, 'The line on ${l.accountId} is zero.'));
      if (l.currency == baseCurrency && l.baseAmount != l.amount) {
        out.add(EntryIssue(EntryProblem.baseMismatch, id, 'The line on ${l.accountId} is in the base currency, so its base amount must equal it.'));
      } else if (l.baseAmount != 0 && l.baseAmount.sign != l.amount.sign) {
        out.add(EntryIssue(EntryProblem.baseSignMismatch, id, 'The line on ${l.accountId} changes sign in the base currency.'));
      }
    }
    final ccys = currencies;
    if (ccys.length == 1) {
      final sum = lines.fold<int>(0, (a, l) => a + l.amount);
      if (sum != 0) out.add(EntryIssue(EntryProblem.unbalanced, id, 'The lines are off by $sum in ${ccys.first}.'));
    } else if (ccys.length > 1) {
      final sum = lines.fold<int>(0, (a, l) => a + l.baseAmount);
      if (sum != 0) out.add(EntryIssue(EntryProblem.unbalanced, id, 'The lines are off by $sum in $baseCurrency.'));
    }
    return out;
  }

  bool get isBalanced => issues.isEmpty;

  BookEntry copyWith({DateTime? date, DateTime? postedDate, EntryStatus? status, List<EntryLine>? lines, String? merchant, String? note, String? rawMerchant, EntrySource? source}) =>
      BookEntry(
        id: id,
        date: date ?? this.date,
        postedDate: postedDate ?? this.postedDate,
        template: template,
        status: status ?? this.status,
        baseCurrency: baseCurrency,
        lines: lines ?? this.lines,
        merchant: merchant ?? this.merchant,
        rawMerchant: rawMerchant ?? this.rawMerchant,
        note: note ?? this.note,
        source: source ?? this.source,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toUtc().toIso8601String(),
        if (postedDate != null) 'postedDate': postedDate!.toUtc().toIso8601String(),
        'template': template.wireName,
        if (status != EntryStatus.posted) 'status': status.name,
        'base': baseCurrency,
        'lines': [for (final l in lines) l.toJson()],
        if (merchant.isNotEmpty) 'merchant': merchant,
        if (rawMerchant.isNotEmpty) 'rawMerchant': rawMerchant,
        if (note.isNotEmpty) 'note': note,
        if (source != EntrySource.typed) 'source': source.name,
      };

  factory BookEntry.fromJson(Map<String, dynamic> json) => BookEntry(
        id: json['id'] as String,
        // Stored as a UTC instant, read back in local time so the calendar
        // day shown is the one the person picked (as HoldingTransaction).
        date: DateTime.parse(json['date'] as String).toLocal(),
        postedDate: json['postedDate'] == null ? null : DateTime.parse(json['postedDate'] as String).toLocal(),
        template: EntryTemplate.fromWire(json['template'] as String?),
        status: EntryStatus.fromName(json['status'] as String?),
        baseCurrency: json['base'] as String,
        lines: [for (final l in json['lines'] as List) EntryLine.fromJson((l as Map).cast<String, dynamic>())],
        merchant: json['merchant'] as String? ?? '',
        rawMerchant: json['rawMerchant'] as String? ?? '',
        note: json['note'] as String? ?? '',
        source: EntrySource.fromName(json['source'] as String?),
      );

  @override
  List<Object?> get props => [id, date, postedDate, template, status, baseCurrency, lines, merchant, rawMerchant, note, source];
}
