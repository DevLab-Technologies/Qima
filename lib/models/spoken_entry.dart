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
    final digits = SpokenNumbers.toDigits(text);
    final said = _normalize(digits);
    final words = _words(said);
    // The same words as spoken, for the merchant: "بندة", not the folded "بنده".
    final spoken = _words(digits);
    final asSaid = spoken.length == words.length ? spoken : words;

    // Accounts and categories first, so their names never read as a merchant.
    // Position, id, length in words, how many of the name's other words
    // were said too ("CIB Debit" over "CIB Credit card" when "debit" is
    // heard), and whether it was said in the other script: an account's own
    // spelling wins a tie.
    final named = <(int, String, int, int, int)>[];
    for (final e in accounts.entries) {
      final spellings = _spellings(e.value);
      for (var k = 0; k < spellings.length; k++) {
        final at = _find(words, spellings[k]);
        if (at != null) {
          // "Debit" and "credit" don't tell an account apart on their own,
          // but they do between two accounts at one bank.
          final also = [for (final p in _words(_normalize(e.value))) if (p.length >= 3 && !const {'the', 'and', 'account', 'bank'}.contains(p)) p]
              .where((p) => words.any((w) => _same(w, p)))
              .length;
          named.add((at.$1, e.key, at.$2, also, k == 0 ? 0 : 1));
          break;
        }
      }
    }
    named.sort((a, b) => a.$1 != b.$1
        ? a.$1.compareTo(b.$1)
        : a.$3 != b.$3
            ? b.$3.compareTo(a.$3)
            : a.$4 != b.$4
                ? b.$4.compareTo(a.$4)
                : a.$5.compareTo(b.$5));
    final accountIds = <String>[];
    final taken = <int>{};
    for (final (at, id, length, _, _) in named) {
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
      merchant: _merchant(words, asSaid, taken),
      accountIds: accountIds,
      categoryId: categoryId,
      daysAgo: _daysAgo(said),
    );
  }

  static final _figure = RegExp(r'\d+(?:[.,]\d+)*');

  /// The first figure, as typed: "1,250.50" → "1250.50", "45,5" → "45.5".
  // Number words are digits by now, so "22 ألف" arrives as "22 1000".
  static final _thousand = RegExp(r'^\s*(1000(?![\d.,])|k(?![a-z]))');

  static String? _amount(String said) {
    final m = _figure.firstMatch(said);
    if (m == null) return null;
    final f = _asTyped(m.group(0)!);
    // "22 ألف", "18 thousand": the figure in thousands.
    if (_thousand.hasMatch(said.substring(m.end))) {
      final v = double.tryParse(f);
      if (v != null) {
        final t = v * 1000;
        return t == t.roundToDouble() ? t.round().toString() : t.toStringAsFixed(2);
      }
    }
    return f;
  }

  static String _asTyped(String figure) {
    var f = figure;
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

  static String? _merchant(List<String> words, List<String> asSaid, Set<int> taken) {
    for (var i = 0; i < words.length - 1; i++) {
      if (!_at.contains(words[i]) || taken.contains(i + 1)) continue;
      final out = <String>[];
      for (var j = i + 1; j < words.length; j++) {
        final w = words[j];
        if (taken.contains(j) || _stop.contains(w) || _at.contains(w) || _figure.hasMatch(w) || _paidWith(w)) break;
        out.add(asSaid[j]);
      }
      if (out.isNotEmpty) return out.map(_title).join(' ');
    }
    return null;
  }

  /// "بفيزا", "بالكاش", "بكارت": a card or cash word with "by" joined to it
  /// ends the shop's name.
  static bool _paidWith(String w) {
    if (!w.startsWith('ب') || w.length < 4) return false;
    final rest = w.startsWith('بال') ? w.substring(3) : w.substring(1);
    return _generic.contains(rest) || _sameNames.any((g) => g.contains(rest));
  }

  static String _title(String w) => w.isEmpty || !RegExp('[a-z]').hasMatch(w[0]) ? w : '${w[0].toUpperCase()}${w.substring(1)}';

  /// Names whose two spellings don't sound alike ("SNB" is "الأهلي"), or
  /// are too short to match by sound. Normalized forms.
  static const _sameNames = [
    {'rajhi', 'alrajhi', 'راجحي', 'الراجحي'},
    {'snb', 'ahli', 'alahli', 'اهلي', 'الاهلي'},
    {'alinma', 'inma', 'انماء', 'الانماء'},
    {'riyad', 'riyadh', 'الرياض'},
    {'sab', 'sabb', 'ساب'},
    {'albilad', 'bilad', 'البلاد'},
    {'aljazira', 'jazira', 'الجزيره'},
    {'anb', 'العربي'},
    {'samba', 'سامبا'},
    {'stc', 'stcpay'},
    {'cib', 'سي اي بي'},
    {'misr', 'مصر'},
    {'qnb', 'كيو ان بي'},
    {'visa', 'فيزا', 'الفيزا'},
    {'mastercard', 'master', 'ماستركارد', 'ماستر'},
    {'mada', 'مدي'},
    {'amex', 'امكس', 'اميكس'},
    {'wallet', 'محفظه', 'المحفظه'},
    {'cash', 'كاش', 'الكاش'},
    {'savings', 'توفير', 'التوفير'},
  ];

  /// [name] as written, then with each word that has a known spelling in the
  /// other script swapped for it.
  static List<String> _spellings(String name) {
    final words = _words(_normalize(name));
    final out = [name];
    for (var i = 0; i < words.length; i++) {
      for (final group in _sameNames) {
        if (!group.any((g) => _same(words[i], g))) continue;
        for (final other in group) {
          if (other == words[i]) continue;
          out.add([...words.sublist(0, i), other, ...words.sublist(i + 1)].join(' '));
          // A name said in several words ("سي اي بي" for CIB) can't be one
          // telling word, so it stands for the account on its own too.
          if (other.contains(' ') && !_generic.contains(words[i])) out.add(other);
        }
      }
    }
    return out;
  }

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

  /// Plurals and Arabic's attached "the" and one-letter prefixes don't
  /// matter: "grocery" is "Groceries", "بالراجحي" is "راجحي", "بتابي" is
  /// "تابي", "لسي" is "سي".
  static bool _same(String a, String b) {
    if (_sameWord(a, b)) return true;
    for (final p in const ['ب', 'ل', 'و', 'ف', 'ك']) {
      if (a.startsWith(p) && a.length - p.length >= 2 && !b.startsWith(p) && _sameWord(a.substring(p.length), b)) return true;
    }
    return false;
  }

  static bool _sameWord(String a, String b) {
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

    if (a == b || stem(a) == stem(b)) return true;
    // Across scripts, by sound: "راحلة" is "Rahalah", "راجحي" is "Rajhi".
    final arabic = RegExp('[\u0600-\u06FF]');
    if (arabic.hasMatch(a) == arabic.hasMatch(b)) return false;
    final sa = _sound(stem(a)), sb = _sound(stem(b));
    return sa.length >= 3 && sa == sb;
  }

  /// A word's consonants as plain Latin letters, the same for both scripts:
  /// vowels and long vowels dropped, letters that sound alike merged, a
  /// leading "al" and a closing h (ة) dropped. Used only to match a name
  /// across scripts, never within one.
  static String _sound(String w) {
    var s = w;
    const arabic = {
      'ب': 'b', 'ت': 't', 'ث': 't', 'ج': 'j', 'ح': 'h', 'خ': 'k', 'د': 'd', 'ذ': 'd', 'ر': 'r', 'ز': 'z',
      'س': 's', 'ش': 's', 'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z', 'ع': '', 'غ': 'g', 'ف': 'f', 'ق': 'k',
      'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n', 'ه': 'h', 'و': '', 'ي': '', 'ا': '', 'ء': '', 'ئ': '', 'ؤ': '',
    };
    final b = StringBuffer();
    if (RegExp('[\u0600-\u06FF]').hasMatch(s)) {
      if (s.startsWith('ال') && s.length > 4) s = s.substring(2);
      for (final r in s.runes) {
        b.write(arabic[String.fromCharCode(r)] ?? '');
      }
    } else {
      s = s.replaceAll(RegExp('[^a-z]'), '');
      if ((s.startsWith('al') || s.startsWith('el')) && s.length > 4) s = s.substring(2);
      s = s.replaceAll('sh', 's').replaceAll('kh', 'k').replaceAll('th', 't').replaceAll('dh', 'd').replaceAll('gh', 'g');
      for (final c in s.split('')) {
        b.write(switch (c) {
          'a' || 'e' || 'i' || 'o' || 'u' || 'y' || 'w' => '',
          'c' || 'q' => 'k',
          'p' => 'b',
          'v' => 'f',
          'g' => 'j',
          'x' => 'ks',
          _ => c,
        });
      }
    }
    var out = b.toString().replaceAllMapped(RegExp(r'(.)\1+'), (m) => m.group(1)!);
    if (out.length > 3 && out.endsWith('h')) out = out.substring(0, out.length - 1);
    return out;
  }

  static const _generic = {
    'account', 'current', 'savings', 'saving', 'card', 'bank', 'wallet', 'cash', 'the', 'my', 'and', 'signature', 'credit', 'debit',
    'حساب', 'جاري', 'توفير', 'بطاقه', 'بنك', 'محفظه', 'كاش', 'نقد', 'ائتمان', 'مدي', 'كارت', 'كرت', 'كارد', 'كريدت', 'ديبت',
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
