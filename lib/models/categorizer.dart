import 'book.dart';
import 'book_account.dart';
import 'book_entry.dart';

/// Where a category guess came from.
enum CategorySource {
  /// A choice the person made for this merchant before (Settings lists it).
  rule,

  /// Most of the person's own entries for this merchant use it.
  history,

  /// A known merchant or word ("panda", "راتب").
  keyword,

  /// Nothing placed it: Uncategorized, for the person to sort out.
  none,
}

class CategoryGuess {
  final String categoryId;
  final CategorySource source;

  const CategoryGuess(this.categoryId, this.source);

  bool get sure => source != CategorySource.none;
}

/// Groups uncategorized entries that share a merchant, so one choice sorts
/// them all.
class UncategorizedGroup {
  /// The merchant key; empty when the entry's text gave none, and then the
  /// group holds that one entry.
  final String key;
  final bool isIn;
  final List<BookEntry> entries;

  const UncategorizedGroup(this.key, this.isIn, this.entries);

  /// The rule key the person's choice for this group is remembered under.
  String get ruleKey => Categorizer.ruleKey(key, isIn: isIn);
}

/// Picks categories the way the person does, and remembers their choices.
///
/// Built once over the book: the rules the person taught and a count of
/// which category each merchant's entries use. Nothing here produces an
/// amount.
class Categorizer {
  final Book book;
  final Map<String, String> rules;
  final Map<String, Map<String, int>> _counts = {};
  final Map<String, Map<String, DateTime>> _latest = {};

  Categorizer(this.book, {this.rules = const {}}) {
    for (final e in book.entries) {
      if (!e.counts) continue;
      final category = categoryOf(e, book);
      if (category == null || isUncategorized(category.id)) continue;
      final key = keyOfEntry(e);
      if (key.isEmpty) continue;
      final k = ruleKey(key, isIn: category.side == AccountSide.income);
      final counts = _counts[k] ??= {};
      counts[category.id] = (counts[category.id] ?? 0) + 1;
      final latest = _latest[k] ??= {};
      if (latest[category.id] == null || e.date.isAfter(latest[category.id]!)) latest[category.id] = e.date;
    }
  }

  static final uncategorizedIds = {SystemAccount.uncategorized.id, SystemAccount.uncategorizedIncome.id};

  static bool isUncategorized(String id) => uncategorizedIds.contains(id);

  static String uncategorizedFor({required bool isIn}) => isIn ? SystemAccount.uncategorizedIncome.id : SystemAccount.uncategorized.id;

  /// Where a choice is remembered: the merchant, money in or out.
  static String ruleKey(String key, {required bool isIn}) => '${isIn ? 'in' : 'out'}:$key';

  /// The category for [text] (a statement row's name, with its [detail]
  /// when the name gives no merchant):
  /// 1. the person's rule for the merchant,
  /// 2. what most of their entries for it use (the latest wins a tie),
  /// 3. a known word, from [keywords],
  /// 4. Uncategorized.
  CategoryGuess guess(String text, {required bool isIn, String detail = '', Map<String, List<String>> keywords = const {}, bool Function(String id)? isIncomeKeyword}) {
    var key = merchantKey(text);
    if (key.isEmpty) key = merchantKey(detail);
    if (key.isNotEmpty) {
      final k = ruleKey(key, isIn: isIn);
      final ruled = rules[k];
      if (ruled != null && _usable(ruled, isIn)) return CategoryGuess(ruled, CategorySource.rule);
      final counts = _counts[k];
      if (counts != null) {
        final usable = [for (final e in counts.entries) if (_usable(e.key, isIn)) e];
        if (usable.isNotEmpty) {
          usable.sort((a, b) {
            final c = b.value - a.value;
            return c != 0 ? c : _latest[k]![b.key]!.compareTo(_latest[k]![a.key]!);
          });
          return CategoryGuess(usable.first.key, CategorySource.history);
        }
      }
    }
    final lower = ' ${[text, detail].join(' ').toLowerCase()} ';
    for (final e in keywords.entries) {
      if ((isIncomeKeyword?.call(e.key) ?? false) != isIn) continue;
      if (e.value.any(lower.contains) && _usable(e.key, isIn)) return CategoryGuess(e.key, CategorySource.keyword);
    }
    return CategoryGuess(uncategorizedFor(isIn: isIn), CategorySource.none);
  }

  bool _usable(String id, bool isIn) {
    final a = book.accounts[id];
    return a != null && a.type == AccountType.category && !a.archived && (a.side == AccountSide.income) == isIn;
  }

  /// The category an entry is booked to: its line on a category, if any.
  static BookAccount? categoryOf(BookEntry e, Book book) {
    for (final l in e.lines) {
      final a = book.accounts[l.accountId];
      if (a != null && a.type == AccountType.category) return a;
    }
    return null;
  }

  /// [e] booked to [to] instead of its current category. The amounts stay.
  static BookEntry recategorized(BookEntry e, Book book, String to) {
    final from = categoryOf(e, book);
    if (from == null || from.id == to) return e;
    return e.copyWith(lines: [
      for (final l in e.lines) l.accountId == from.id ? EntryLine(accountId: to, amount: l.amount, currency: l.currency, baseAmount: l.baseAmount) : l,
    ]);
  }

  static String keyOfEntry(BookEntry e) {
    final key = merchantKey(e.merchant);
    return key.isNotEmpty ? key : merchantKey(e.rawMerchant);
  }

  /// Every uncategorized entry, grouped by merchant, the largest groups and
  /// then the newest first.
  static List<UncategorizedGroup> uncategorized(Book book) {
    final groups = <String, List<BookEntry>>{};
    final sides = <String, bool>{};
    final sorted = [...book.entries]..sort((a, b) => b.date.compareTo(a.date));
    for (final e in sorted) {
      if (!e.counts) continue;
      final category = categoryOf(e, book);
      if (category == null || !isUncategorized(category.id)) continue;
      final isIn = category.side == AccountSide.income;
      final key = keyOfEntry(e);
      // An entry with no merchant to go by is a group of its own.
      final k = key.isEmpty ? 'entry:${e.id}' : ruleKey(key, isIn: isIn);
      (groups[k] ??= []).add(e);
      sides[k] = isIn;
    }
    return [
      for (final MapEntry(:key, :value) in groups.entries)
        UncategorizedGroup(key.startsWith('entry:') ? '' : key.substring(key.indexOf(':') + 1), sides[key]!, value),
    ]..sort((a, b) {
        final c = b.entries.length - a.entries.length;
        return c != 0 ? c : b.entries.first.date.compareTo(a.entries.first.date);
      });
  }

  /// Entries for the merchant [key] in [categoryId] (earlier ones in Other,
  /// say), newest first.
  static List<BookEntry> withMerchantIn(Book book, String key, String categoryId) => [
        for (final e in [...book.entries]..sort((a, b) => b.date.compareTo(a.date)))
          if (e.counts && categoryOf(e, book)?.id == categoryId && keyOfEntry(e) == key) e,
      ];

  // Words that label a field rather than name anyone.
  static const _labels = {
    'payeename', 'payee', 'payername', 'payer', 'name', 'nam', 'benefacct', 'benef', 'payermobno', 'ref', 'auth', 'pos', //
    'transfer', 'to', 'from', 'ifo', 'funds', 'mob', 'acct', 'ac', 'no',
  };

  // The country a card network appends.
  static const _countries = {'sau', 'ksa', 'usa', 'nld', 'egy', 'are', 'uae', 'gbr', 'irl', 'deu', 'fra', 'kwt', 'qat', 'bhr', 'omn', 'jor', 'lux', 'sgp'};

  /// A merchant's text reduced for matching: lower case, the first two
  /// words that name someone. Reference codes ("FT26312Q1LQJ"), numbers,
  /// masks ("A.. E."), field labels ("PayeeName") and the country code go,
  /// so "FT26312Q1LQJ - PayeeName احمد" and the next transfer to the same
  /// payee match, and "PANDA RIYADH 4412" and "Panda Riyadh SAU" are one.
  static String merchantKey(String text) {
    final words = <String>[];
    for (final raw in text.toLowerCase().split(RegExp(r'[\s\-–:·|,/]+'))) {
      if (raw.isEmpty) continue;
      // A mask or a code: dots between letters, or letters mixed with digits.
      if (RegExp(r'\p{L}\.\.?', unicode: true).hasMatch(raw) && raw.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '').length <= 2) continue;
      if (RegExp(r'\d').hasMatch(raw)) continue;
      final w = raw.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
      if (w.length < 2 || _labels.contains(w) || _countries.contains(w)) continue;
      words.add(w);
      if (words.length == 2) break;
    }
    return words.join(' ');
  }
}
