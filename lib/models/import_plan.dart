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
  /// The book already has this amount on this account within two days.
  inBook,

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

  const ImportCandidate({required this.key, required this.fileId, required this.row, required this.categoryId, this.flag});

  bool get suggested => flag == null;

  @override
  List<Object?> get props => [key, fileId, row, flag, categoryId];
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
    int score(BookAccount a) =>
        (a.statementRefs.any((k) => named.any((r) => r.matches(k))) ? 1 << 40 : 0) +
        (currencies[a.currency] ?? 0) * 1000 +
        (a.type == AccountType.debit ? 500 : 0) +
        (use[a.id] ?? 0).clamp(0, 499);
    options.sort((a, b) => score(b) - score(a));
    return options.first;
  }

  static List<ImportCandidate> plan({
    required List<(String fileId, List<StatementRow> rows)> files,
    required BookAccount account,
    required Book book,
    Map<String, String> rules = const {},
  }) {
    final categorizer = Categorizer(book, rules: rules);
    final seen = <String>{};
    final out = <ImportCandidate>[];
    for (final (fileId, rows) in files) {
      for (var i = 0; i < rows.length; i++) {
        final r = rows[i];
        final sameKey = '${_day(r.date)}|${r.amount.toStringAsFixed(3)}|${Categorizer.merchantKey(r.description)}';
        ImportFlag? flag;
        if (r.doubtful) {
          flag = ImportFlag.notTransaction;
        } else if (r.currency != null && r.currency != account.currency) {
          flag = ImportFlag.otherCurrency;
        } else if (!seen.add(sameKey)) {
          flag = ImportFlag.repeated;
        } else if (_inBook(book, account, r)) {
          flag = ImportFlag.inBook;
        }
        out.add(ImportCandidate(
          key: '$fileId:$i',
          fileId: fileId,
          row: r,
          flag: flag,
          categoryId: guessCategory(r.description, detail: r.detail, isIn: r.isIn, categorizer: categorizer).categoryId,
        ));
      }
    }
    return out;
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
  /// at its first row), else a correction on the statement's last day.
  /// Null when the book already agrees.
  static BookEntry? balanceEntry({
    required EntryBuilder builder,
    required Book book,
    required BookAccount account,
    required List<BookEntry> added,
    required StatementBalance balance,
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
      return builder.opening(account, statement - tracked, first).copyWith(source: EntrySource.import);
    }
    return builder.balanceTo(account, tracked: tracked, statement: statement, date: balance.date)?.copyWith(source: EntrySource.import);
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

  static bool _inBook(Book book, BookAccount account, StatementRow r) {
    final currency = account.currency ?? 'SAR';
    final minor = MinorUnits.fromMajor(r.amount.abs(), currency);
    for (final e in book.entries) {
      if (!e.counts || e.template == EntryTemplate.opening) continue;
      if (e.date.difference(r.date).inDays.abs() > 2) continue;
      for (final l in e.lines) {
        if (l.accountId == account.id && l.amount.abs() == minor) return true;
      }
    }
    return false;
  }

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

  /// The entry for a row: a spend from the account, or money into it.
  static BookEntry entryFor({
    required EntryBuilder builder,
    required BookAccount account,
    required BookAccount category,
    required StatementRow row,
    required bool isIn,
  }) {
    final amount = MinorUnits.fromMajor(row.amount.abs(), account.currency ?? 'SAR');
    final name = row.description.isEmpty ? row.detail : row.description;
    final made = isIn
        ? (category.side == AccountSide.spending
            ? builder.refund(account, category, amount, row.date, merchant: name)
            : builder.income(account, category, amount, row.date, merchant: name))
        : builder.spend(account, category, amount, row.date, merchant: name);
    return made.copyWith(source: EntrySource.import, rawMerchant: [row.description, row.detail].where((s) => s.isNotEmpty).join(' · '));
  }
}
