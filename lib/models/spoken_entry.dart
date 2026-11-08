import 'spoken_numbers.dart';

/// Which tab of New transaction a sentence is about.
enum SpokenKind { spend, income, transfer }

/// What a spoken sentence says about a transaction ("Spent 45 at Panda
/// with Visa yesterday", "استلمت الراتب 18000 في الراجحي"), read by rules:
/// every figure is one the person said, word for word. Anything not said
/// stays null and the editor keeps what it had; nothing is saved until the
/// person taps Save.
class SpokenEntry {
  /// Set only when the sentence says so (received, transferred…).
  final SpokenKind? kind;

  /// The amount as field text ("45.50"), from the first figure said.
  final String? amount;

  final String? merchant;

  /// Money accounts named, in the order said: a transfer's from and to.
  final List<String> accountIds;

  /// A category named outright ("on groceries").
  final String? categoryId;

  /// 1 for yesterday, 2 for the day before.
  final int? daysAgo;

  const SpokenEntry({this.kind, this.amount, this.merchant, this.accountIds = const [], this.categoryId, this.daysAgo});

  bool get isEmpty => kind == null && amount == null && merchant == null && accountIds.isEmpty && categoryId == null && daysAgo == null;

  /// Reads [text] against the person's own [accounts] and [categories]
  /// (id → the name shown), in English, Arabic, French or Spanish.
  static SpokenEntry parse(String text, {Map<String, String> accounts = const {}, Map<String, String> categories = const {}}) {
    final said = _normalize(SpokenNumbers.toDigits(text));
    final words = _words(said);

    // Accounts and categories first, so their names never read as a merchant.
    final named = <(int, String, int)>[]; // position, id, length in words
    for (final e in accounts.entries) {
      final at = _find(words, e.value);
      if (at != null) named.add((at.$1, e.key, at.$2));
    }
    named.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : b.$3.compareTo(a.$3));
    final accountIds = <String>[];
    final taken = <int>{};
    for (final (at, id, length) in named) {
      final span = {for (var i = at; i < at + length; i++) i};
      if (span.any(taken.contains)) continue;
      taken.addAll(span);
      accountIds.add(id);
    }
    String? categoryId;
    var categoryLength = 0;
    for (final e in categories.entries) {
      final at = _find(words, e.value);
      if (at == null || at.$2 <= categoryLength) continue;
      final span = {for (var i = at.$1; i < at.$1 + at.$2; i++) i};
      if (span.any(taken.contains)) continue;
      categoryId = e.key;
      categoryLength = at.$2;
      taken.addAll(span);
    }

    return SpokenEntry(
      kind: _kind(words),
      amount: _amount(said),
      merchant: _merchant(words, taken),
      accountIds: accountIds,
      categoryId: categoryId,
      daysAgo: _daysAgo(said),
    );
  }

  static final _figure = RegExp(r'\d+(?:[.,]\d+)*');

  /// The first figure, as typed: "1,250.50" → "1250.50", "45,5" → "45.5".
  static String? _amount(String said) {
    final m = _figure.firstMatch(said);
    if (m == null) return null;
    var f = m.group(0)!;
    final parts = f.split(RegExp('[.,]'));
    if (parts.length > 1) {
      final last = parts.last;
      final grouped = parts.skip(1).every((p) => p.length == 3);
      // Thousands separators only, or a decimal part at the end.
      f = grouped && !(parts.length == 2 && f.contains('.')) ? parts.join() : '${parts.sublist(0, parts.length - 1).join()}.$last';
    }
    return f;
  }

  static const _income = {
    'received', 'receive', 'got paid', 'earned', 'salary', 'income', 'deposit', 'deposited', 'paycheck',
    'استلمت', 'وصلني', 'وصلتني', 'جاني', 'قبضت', 'راتب', 'الراتب', 'دخل', 'ايداع', 'اودعت',
    'recu', 'reçu', 'touche', 'touché', 'salaire', 'gagne', 'gagné', 'revenu',
    'recibi', 'recibí', 'cobre', 'cobré', 'nomina', 'nómina', 'sueldo', 'ingreso', 'gane', 'gané',
  };
  static const _transfer = {
    'transfer', 'transferred', 'moved', 'move',
    'حولت', 'تحويل', 'نقلت', 'حوالة', 'حواله',
    'vire', 'viré', 'virement', 'transfere', 'transféré',
    'transferi', 'transferí', 'transferencia', 'pase', 'pasé',
  };
  static const _spend = {
    'spent', 'spend', 'paid', 'pay', 'bought', 'buy', 'cost',
    'صرفت', 'دفعت', 'اشتريت', 'شريت', 'خصم',
    'depense', 'dépensé', 'paye', 'payé', 'achete', 'acheté',
    'gaste', 'gasté', 'pague', 'pagué', 'compre', 'compré',
  };

  static SpokenKind? _kind(List<String> words) {
    final joined = ' ${words.join(' ')} ';
    bool any(Set<String> set) => set.any((w) => joined.contains(' ${_normalize(w)} '));
    if (any(_transfer)) return SpokenKind.transfer;
    // "Paid" wins over "salary" only when no income word is said.
    if (any(_income)) return SpokenKind.income;
    if (any(_spend)) return SpokenKind.spend;
    return null;
  }

  /// The words after "at" (في, chez, en…) up to the next joining word, a
  /// figure, or a name already placed.
  static const _at = {'at', 'in', 'في', 'عند', 'لدى', 'من', 'chez', 'à', 'en', 'au'};
  static const _stop = {
    'with', 'using', 'from', 'on', 'for', 'to', 'and', 'by', 'via', 'yesterday', 'today', 'riyals', 'riyal', 'pounds', 'dollars', 'euros', 'dirhams', 'sar', 'egp', 'usd', 'aed', 'eur',
    'ب', 'بال', 'على', 'الى', 'الي', 'امس', 'اليوم', 'امبارح', 'البارحه', 'ريال', 'ريالات', 'جنيه', 'دولار', 'درهم', 'يورو', 'و',
    'avec', 'par', 'pour', 'sur', 'hier', 'aujourdhui', 'et',
    'con', 'por', 'para', 'ayer', 'hoy', 'y',
  };

  static String? _merchant(List<String> words, Set<int> taken) {
    for (var i = 0; i < words.length - 1; i++) {
      if (!_at.contains(words[i]) || taken.contains(i + 1)) continue;
      final out = <String>[];
      for (var j = i + 1; j < words.length; j++) {
        final w = words[j];
        if (taken.contains(j) || _stop.contains(w) || _at.contains(w) || _figure.hasMatch(w)) break;
        out.add(w);
      }
      if (out.isNotEmpty) return out.map(_title).join(' ');
    }
    return null;
  }

  static String _title(String w) => w.isEmpty || !RegExp('[a-z]').hasMatch(w[0]) ? w : '${w[0].toUpperCase()}${w.substring(1)}';

  static int? _daysAgo(String said) {
    const two = ['day before yesterday', 'قبل امس', 'اول امبارح', 'avant hier', 'avant-hier', 'anteayer', 'antes de ayer'];
    const one = ['yesterday', 'امس', 'امبارح', 'البارحه', 'hier', 'ayer'];
    if (two.any(said.contains)) return 2;
    if (one.any((w) => ' $said '.contains(' $w ') || said.contains('ب$w'))) return 1;
    return null;
  }

  /// Where [name] is said: all its telling words in a row, or one word that
  /// sets it apart ("Rajhi" for "Al Rajhi current account"). Position and
  /// length in words.
  static (int, int)? _find(List<String> words, String name) {
    final parts = _words(_normalize(name));
    if (parts.isEmpty) return null;
    for (var i = 0; i + parts.length <= words.length; i++) {
      var all = true;
      for (var k = 0; k < parts.length && all; k++) {
        all = _same(words[i + k], parts[k]);
      }
      if (all) return (i, parts.length);
    }
    final telling = [for (final p in parts) if (p.length >= 3 && !_generic.contains(p)) p];
    for (var i = 0; i < words.length; i++) {
      if (telling.any((p) => _same(words[i], p))) return (i, 1);
    }
    return null;
  }

  /// Plurals and Arabic's attached "the" don't matter: "grocery" is
  /// "Groceries", "بالراجحي" is "راجحي".
  static bool _same(String a, String b) {
    String stem(String w) {
      var s = w;
      // بالفيزا, والراجحي, للبنك: a joined letter and "the".
      for (final p in const ['بال', 'وال', 'فال', 'كال', 'لل', 'ال']) {
        if (s.startsWith(p) && s.length > p.length + 2) {
          s = s.substring(p.length);
          break;
        }
      }
      if (s.endsWith('ies') && s.length > 4) s = '${s.substring(0, s.length - 3)}y';
      if (s.endsWith('s') && s.length > 3) s = s.substring(0, s.length - 1);
      return s;
    }

    return a == b || stem(a) == stem(b);
  }

  static const _generic = {
    'account', 'current', 'savings', 'saving', 'card', 'bank', 'wallet', 'cash', 'the', 'my', 'and', 'signature', 'credit', 'debit',
    'حساب', 'جاري', 'توفير', 'بطاقه', 'بنك', 'محفظه', 'كاش', 'نقد', 'ائتمان', 'مدى',
    'compte', 'courant', 'carte', 'banque', 'cuenta', 'tarjeta', 'banco',
  };

  static List<String> _words(String s) => s.split(RegExp(r'[\s،,;:!?؟"“”«»()]+')).where((w) => w.isNotEmpty).map((w) => w.replaceAll(RegExp(r'^[.]+|[.]+$'), '')).where((w) => w.isNotEmpty).toList();

  /// Lower case, Arabic letter forms folded (أ إ آ → ا, ة → ه, ى → ي),
  /// diacritics and tatweel dropped, Arabic digits as ASCII.
  static String _normalize(String s) {
    final b = StringBuffer();
    for (final r in s.toLowerCase().runes) {
      final c = String.fromCharCode(r);
      if (r >= 0x064B && r <= 0x0652 || r == 0x0640) continue;
      if (r >= 0x0660 && r <= 0x0669) {
        b.write(r - 0x0660);
      } else if (r >= 0x06F0 && r <= 0x06F9) {
        b.write(r - 0x06F0);
      } else if (r == 0x066B) {
        b.write('.');
      } else if (r == 0x066C) {
        b.write(',');
      } else {
        b.write(switch (c) { 'أ' || 'إ' || 'آ' => 'ا', 'ة' => 'ه', 'ى' => 'ي', _ => c });
      }
    }
    return b.toString();
  }
}
