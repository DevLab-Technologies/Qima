import 'package:equatable/equatable.dart';

import 'book.dart';
import 'book_account.dart';
import 'book_entry.dart';
import 'categorizer.dart';
import 'default_categories.dart';
import 'entry_builder.dart';
import 'minor_units.dart';
import 'statement_facts.dart';
import 'statement_reader.dart';

/// Why a row starts unticked on the review screen.
enum ImportFlag {
  /// The book already has this transaction: the same amount, the same way,
  /// on this account within two days, from the same merchant (or one with
  /// no merchant, such as a transfer).
  inBook,

  /// The book has the same amount the same way within two days, but from a
  /// different merchant: maybe the same, maybe not, so the person decides.
  maybeInBook,

  /// The same row is in an earlier file of this batch (overlapping
  /// screenshots).
  repeated,

  /// Written in another currency than the account's.
  otherCurrency,

  /// The on-device model reads the line as the bank's own text (a balance,
  /// the account number), not a transaction.
  notTransaction,
}

/// The balance a statement ends at, for bringing the account to it.
class StatementBalance extends Equatable {
  /// As people read it, in the account's currency.
  final double closing;
  final DateTime date;

  const StatementBalance(this.closing, this.date);

  @override
  List<Object?> get props => [closing, date];
}

/// One row on the review screen, with what Qima suggests for it.
class ImportCandidate extends Equatable {
  /// `fileId:index`, stable while the batch is reviewed.
  final String key;
  final String fileId;
  final StatementRow row;
  final ImportFlag? flag;
  final String categoryId;

  /// The entry already in the book that [flag] ([ImportFlag.inBook] or
  /// [ImportFlag.maybeInBook]) is about.
  final BookEntry? match;

  const ImportCandidate({required this.key, required this.fileId, required this.row, required this.categoryId, this.flag, this.match});

  bool get suggested => flag == null;

  @override
  List<Object?> get props => [key, fileId, row, flag, categoryId, match?.id];
}

/// Plans a batch of statement rows against the book: which account they
/// belong to, which ones look like duplicates, and a category for each.
class ImportPlanner {
  ImportPlanner._();

  /// Accounts a statement can be from: money, cards and loans the person
  /// keeps (a loan's statement or app screen gives what is still owed).
  static bool canHoldStatement(BookAccount a) =>
      !a.archived &&
      (a.type == AccountType.debit || a.type == AccountType.cash || a.type == AccountType.credit || a.type == AccountType.loan);

  /// The account the rows most likely come from: one that an earlier
  /// statement with the same account or card number went to, else one whose
  /// currency the rows are written in, a bank account before a card, the
  /// most used.
  static BookAccount? guessAccount(List<BookAccount> accounts, List<StatementRow> rows, List<BookEntry> entries, {Iterable<StatementRef> refs = const []}) {
    final named = refs.toList();
    final options = accounts.where(canHoldStatement).toList();
    if (options.isEmpty) return null;
    final currencies = <String, int>{};
    for (final r in rows) {
      if (r.currency != null) currencies[r.currency!] = (currencies[r.currency!] ?? 0) + 1;
    }
    final use = <String, int>{};
    for (final e in entries) {
      for (final l in e.lines) {
        use[l.accountId] = (use[l.accountId] ?? 0) + 1;
      }
    }
    // A card's number in the account's name or note ("Visa 4821").
    bool namesNumber(BookAccount a) => named.any((r) => RegExp('(?<!\\d)${r.last4}(?!\\d)').hasMatch('${a.name} ${a.note}'));
    // A card message about a limit is from a credit card.
    final creditCard = named.any((r) => r.kind == StatementRefKind.card) &&
        !named.any((r) => r.kind != StatementRefKind.card) &&
        rows.any((r) => _creditWords.hasMatch('${r.detail} ${r.description}'));
    final preferred = creditCard ? AccountType.credit : AccountType.debit;
    // The card a message names by its name, as Wallet does for Apple Pay
    // ("Card: SNB Visa"): the account with the longest name in it.
    final cardNames = [
      for (final r in rows)
        for (final m in _cardField.allMatches(r.detail)) m[1]!.toLowerCase(),
    ];
    int nameFit(BookAccount a) {
      final n = a.name.trim().toLowerCase();
      return n.length >= 3 && cardNames.any((c) => c.contains(n)) ? n.length : 0;
    }
    int score(BookAccount a) =>
        (a.statementRefs.any((k) => named.any((r) => r.matches(k))) ? 1 << 40 : 0) +
        (namesNumber(a) ? 1 << 39 : 0) +
        (nameFit(a) > 0 ? (1 << 38) + (nameFit(a) << 20) : 0) +
        (currencies[a.currency] ?? 0) * 1000 +
        (a.type == preferred ? 500 : 0) +
        (use[a.id] ?? 0).clamp(0, 499);
    options.sort((a, b) => score(b) - score(a));
    return options.first;
  }

  static final _cardField = RegExp(r'(?:^|\s)(?:card|بطاقة|carte|tarjeta)\s*:\s*(.+?)(?=\s+\p{L}+\s*:|$)', caseSensitive: false, unicode: true);
  static final _creditWords = RegExp(r'credit|limit|ائتمان|ائتمانية|الحد|crédit|plafond|crédito|límite', caseSensitive: false);

  /// Each row with a flag when it should start unticked and a category.
  ///
  /// A row is "in the book" only when an entry not already matched to
  /// another row has the same amount going the same way on [account]: two
  /// equal charges on one day stay two, and a purchase never hides its
  /// refund. Rows from the same merchant are matched first, so a row that
  /// only shares the amount never takes the entry from the row that is
  /// really it. A row is "repeated" only when an earlier file (an
  /// overlapping screenshot) has it as many times; equal rows in one file
  /// are all kept.
  static List<ImportCandidate> plan({
    required List<(String fileId, List<StatementRow> rows)> files,
    required BookAccount account,
    required Book book,
    Map<String, String> rules = const {},
  }) {
    final categorizer = Categorizer(book, rules: rules);
    final earlier = <String, int>{};
    final flags = <String, ImportFlag>{};
    final rows = <(String key, String fileId, StatementRow row)>[];
    for (final (fileId, fileRows) in files) {
      final here = <String, int>{};
      for (var i = 0; i < fileRows.length; i++) {
        final r = fileRows[i];
        final key = '$fileId:$i';
        rows.add((key, fileId, r));
        final sameKey = '${_day(r.date)}|${r.amount.toStringAsFixed(3)}|${Categorizer.merchantKey(r.description)}';
        final nth = here[sameKey] = (here[sameKey] ?? 0) + 1;
        if (r.doubtful) {
          flags[key] = ImportFlag.notTransaction;
        } else if (r.currency != null && r.currency != account.currency) {
          flags[key] = ImportFlag.otherCurrency;
        } else if (nth <= (earlier[sameKey] ?? 0)) {
          flags[key] = ImportFlag.repeated;
        }
      }
      here.forEach((k, n) {
        if (n > (earlier[k] ?? 0)) earlier[k] = n;
      });
    }
    final claimed = <String>{};
    final matches = <String, BookEntry>{};
    for (final sameOnly in [true, false]) {
      for (final (key, _, r) in rows) {
        if (flags.containsKey(key)) continue;
        final found = _inBook(book, account, r, claimed, sameMerchantOnly: sameOnly);
        if (found == null) continue;
        claimed.add(found.entry.id);
        matches[key] = found.entry;
        flags[key] = found.sameMerchant ? ImportFlag.inBook : ImportFlag.maybeInBook;
      }
    }
    return [
      for (final (key, fileId, r) in rows)
        ImportCandidate(
          key: key,
          fileId: fileId,
          row: r,
          flag: flags[key],
          match: matches[key],
          categoryId: guessCategory(r.description, detail: r.detail, isIn: r.isIn, categorizer: categorizer).categoryId,
        ),
    ];
  }

  /// The closing balance of the newest statement that gives one in the
  /// account's currency, or null.
  static StatementBalance? statementBalance(List<(StatementFacts, List<StatementRow>)> files, BookAccount account) {
    StatementBalance? best;
    for (final (facts, rows) in files) {
      final closing = facts.closing;
      if (closing == null || (facts.currency != null && facts.currency != account.currency)) continue;
      // A card's "available balance" is the credit left, not what is owed.
      if (facts.closingAvailable && account.side == AccountSide.owe) continue;
      final date = facts.to ?? rows.map((r) => r.date).fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
      if (date == null) continue;
      if (best == null || date.isAfter(best.date)) best = StatementBalance(closing, date);
    }
    return best;
  }

  /// What brings [account] to the statement's [balance] once [added] are in
  /// [book]: an opening balance when the account had nothing before (dated
  /// at its first row), else the difference brought in [way]: a changed
  /// opening balance, or a transaction on the statement's last day. Null
  /// when the book already agrees.
  static BalanceEntry? balanceEntry({
    required EntryBuilder builder,
    required Book book,
    required BookAccount account,
    required List<BookEntry> added,
    required StatementBalance balance,
    BalanceWay way = BalanceWay.opening,
  }) {
    final currency = account.currency ?? 'SAR';
    final ids = {for (final e in added) e.id};
    final before = [for (final e in book.entries) if (!ids.contains(e.id)) e];
    final fresh = !before.any((e) => e.lines.any((l) => l.accountId == account.id));
    final withAdded = Book(book.accounts.values, [...before, ...added]);
    final end = DateTime(balance.date.year, balance.date.month, balance.date.day, 23, 59, 59, 999);
    final tracked = withAdded.balanceOf(account.id, asOf: end);
    final statement = MinorUnits.fromMajor(balance.closing, currency);
    if (statement == tracked) return null;
    if (fresh) {
      final first = added.map((e) => e.date).fold<DateTime>(balance.date, (a, b) => b.isBefore(a) ? b : a);
      return (entry: builder.opening(account, statement - tracked, first).copyWith(source: EntrySource.import), tracked: tracked, statement: statement, fresh: true);
    }
    final entry = builder.balanceBy(way, book: withAdded, account: account, tracked: tracked, target: statement, date: balance.date);
    if (entry == null) return null;
    // A changed opening balance keeps where it came from.
    final isNew = !book.entries.any((e) => e.id == entry.id);
    return (entry: isNew ? entry.copyWith(source: EntrySource.import) : entry, tracked: tracked, statement: statement, fresh: false);
  }

  /// The numbers of the statements a batch came from, to remember on the
  /// account they were added to. Empty when the files disagree, so one
  /// account never takes another's number.
  static List<String> refsToKeep(List<StatementFacts> files) {
    final sets = [for (final f in files) if (f.refs.isNotEmpty) {for (final r in f.refs) r.key}];
    if (sets.isEmpty) return const [];
    final first = sets.first;
    if (sets.any((s) => s.length != first.length || !s.containsAll(first))) return const [];
    return first.toList()..sort();
  }

  /// The entry in the book that is most likely [r], not yet [claimed]:
  /// the same amount going the same way on [account] within two days,
  /// closest in date, one from the same merchant first.
  static ({BookEntry entry, bool sameMerchant})? _inBook(Book book, BookAccount account, StatementRow r, Set<String> claimed, {bool sameMerchantOnly = false}) {
    final currency = account.currency ?? 'SAR';
    final minor = MinorUnits.fromMajor(r.amount.abs(), currency);
    final day = DateTime(r.date.year, r.date.month, r.date.day);
    final rowWords = _words('${r.description} ${r.detail}');
    ({BookEntry entry, bool sameMerchant, int days})? best;
    for (final e in book.entries) {
      if (!e.counts || e.template == EntryTemplate.opening || claimed.contains(e.id)) continue;
      final days = DateTime(e.date.year, e.date.month, e.date.day).difference(day).inDays.abs();
      if (days > 2) continue;
      // A row whose sign was guessed matches either way.
      final fits = e.lines.any((l) => l.accountId == account.id && l.amount.abs() == minor && (r.signGuessed || (l.amount > 0) == r.isIn));
      if (!fits) continue;
      final entryWords = _words('${e.merchant} ${e.rawMerchant}');
      // No merchant on one side (a transfer, a row with only a code) can't
      // contradict the other.
      final same = rowWords.isEmpty || entryWords.isEmpty || rowWords.any(entryWords.contains);
      if (sameMerchantOnly && !same) continue;
      final b = best;
      if (b == null || (same && !b.sameMerchant) || (same == b.sameMerchant && days < b.days)) best = (entry: e, sameMerchant: same, days: days);
    }
    final b = best;
    return b == null ? null : (entry: b.entry, sameMerchant: b.sameMerchant);
  }

  /// The words a merchant is known by, without codes, places and labels.
  static Set<String> _words(String text) => {
        for (final w in text.toLowerCase().split(RegExp(r'[^\p{L}]+', unicode: true)))
          if (w.length >= 3 && !Categorizer.isNoiseWord(w)) w,
      };

  static String _day(DateTime d) => '${d.year}-${d.month}-${d.day}';


  static const Map<String, List<String>> _keywords = {
    'category.groceries': ['panda', 'danube', 'tamimi', 'carrefour', 'lulu', 'othaim', 'farm superstore', 'nesto', 'spinneys', 'grocery', 'supermarket', 'hypermarket', 'بنده', 'الدانوب', 'التميمي', 'كارفور', 'العثيم', 'لولو', 'سوبرماركت', 'تموينات', 'بقالة'],
    'category.dining': ['albaik', 'al baik', 'starbucks', 'mcdonald', 'kfc', 'burger', 'pizza', 'cafe', 'café', 'coffee', 'restaurant', 'hungerstation', 'jahez', 'talabat', 'mrsool', 'careem food', 'dunkin', 'shawarma', 'البيك', 'مطعم', 'مطاعم', 'كوفي', 'كافيه', 'قهوة', 'مقهى', 'ستاربكس', 'ماكدونالدز', 'كنتاكي', 'دانكن', 'بيتزا', 'برجر', 'شاورما', 'هنقرستيشن', 'جاهز', 'طلبات', 'مرسول'],
    'category.transport': ['uber', 'careem', 'aldrees', 'sasco', 'petrol', 'fuel', 'gas station', 'parking', 'saptco', 'metro', 'taxi', 'بنزين', 'محطة', 'وقود', 'الدريس', 'ساسكو', 'مواقف', 'أوبر', 'اوبر', 'كريم', 'تاكسي', 'سابتكو'],
    'category.bills': ['stc', 'mobily', 'zain', 'saudi electricity', 'electricity', 'الكهربائية', 'كهرباء', 'السعودية للطاقة', 'water', 'vodafone', 'etisalat', 'orange', 'we ', 'internet', 'netflix', 'shahid', 'spotify', 'apple.com', 'icloud', 'فاتورة', 'الكهرباء', 'المياه', 'اتصالات', 'موبايلي', 'زين'],
    'category.shopping': ['amazon', 'noon', 'namshi', 'jarir', 'extra', 'ikea', 'centrepoint', 'h&m', 'zara', 'shein', 'mall', 'جرير', 'اكسترا', 'نون', 'أمازون', 'امازون', 'ايكيا'],
    'category.health': ['pharmacy', 'nahdi', 'dawaa', 'al-dawaa', 'hospital', 'clinic', 'medical', 'dental', 'lab', 'صيدلية', 'النهدي', 'الدواء', 'مستشفى', 'عيادة', 'مستوصف'],
    'category.home': ['rent', 'ejar', 'furniture', 'maintenance', 'إيجار', 'ايجار', 'أثاث', 'صيانة'],
    'category.salary': ['salary', 'payroll', 'wages', 'راتب', 'رواتب', 'salaire', 'nómina', 'nomina'],
  };

  /// A category for a row, the way the person would pick it (see
  /// [Categorizer.guess]): Uncategorized when nothing places it.
  static CategoryGuess guessCategory(String description, {String detail = '', required bool isIn, required Categorizer categorizer}) =>
      categorizer.guess(description, detail: detail, isIn: isIn, keywords: _keywords, isIncomeKeyword: DefaultCategories.income.containsKey);

  /// The other accounts a row can move money to or from, in the account's
  /// currency: a transfer, a card or loan payment.
  static List<BookAccount> counterparts(Iterable<BookAccount> accounts, BookAccount account) => [
        for (final a in accounts)
          if (a.id != account.id && canHoldStatement(a) && a.currency == account.currency) a,
      ];

  /// The entry for a row: a spend from the account or money into it, or,
  /// when [category] is another of the person's accounts, a move between
  /// the two (a card payment when money goes from a bank account to a
  /// card).
  static BookEntry entryFor({
    required EntryBuilder builder,
    required BookAccount account,
    required BookAccount category,
    required StatementRow row,
    required bool isIn,
  }) {
    final amount = MinorUnits.fromMajor(row.amount.abs(), account.currency ?? 'SAR');
    final name = row.description.isEmpty ? row.detail : row.description;
    final BookEntry made;
    if (category.side.onBalanceSheet) {
      final from = isIn ? category : account, to = isIn ? account : category;
      made = to.type == AccountType.credit && from.type != AccountType.credit
          ? builder.cardPayment(from, to, amount, row.date)
          : builder.transfer(from, to, amount, row.date);
    } else {
      made = isIn
          ? (category.side == AccountSide.spending
              ? builder.refund(account, category, amount, row.date, merchant: name)
              : builder.income(account, category, amount, row.date, merchant: name))
          : builder.spend(account, category, amount, row.date, merchant: name);
    }
    return made.copyWith(source: EntrySource.import, rawMerchant: [row.description, row.detail].where((s) => s.isNotEmpty).join(' · '));
  }
}

/// The entry that brings an account to a statement's balance, with the
/// balances it bridges, as people read them, in minor units. [fresh]: the
/// account had nothing before, so the entry is simply its opening balance
/// and there is no way to choose.
typedef BalanceEntry = ({BookEntry entry, int tracked, int statement, bool fresh});
