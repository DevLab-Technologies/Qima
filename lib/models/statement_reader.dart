import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'minor_units.dart';
import 'statement_facts.dart';

/// A piece of text on a page and where it sits, in page fractions (0 to 1,
/// top left origin). PDFs give one per run of text, screenshots one per
/// recognized line, spreadsheets one per cell.
class DocToken extends Equatable {
  final String text;
  final double x, y, w, h;

  const DocToken(this.text, this.x, this.y, this.w, this.h);

  double get midY => y + h / 2;
  double get right => x + w;

  factory DocToken.fromJson(Map<dynamic, dynamic> json) => DocToken(
        json['t'] as String? ?? '',
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
        (json['w'] as num).toDouble(),
        (json['h'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [text, x, y, w, h];
}

class DocPage {
  final List<DocToken> tokens;
  const DocPage(this.tokens);

  /// A spreadsheet or CSV as pages of cells: each row a line, each column at
  /// its own place across the page, so the same reader handles both.
  factory DocPage.fromTable(List<List<String>> rows) {
    final columns = rows.fold<int>(1, (m, r) => math.max(m, r.length));
    final w = 1 / columns;
    final h = rows.isEmpty ? 1.0 : 1 / rows.length;
    return DocPage([
      for (var r = 0; r < rows.length; r++)
        for (var c = 0; c < rows[r].length; c++)
          if (rows[r][c].trim().isNotEmpty) DocToken(rows[r][c].trim(), c * w, r * h, w * 0.98, h * 0.9),
    ]);
  }
}

/// One transaction read from a statement, a screenshot or a message.
class StatementRow extends Equatable {
  final DateTime date;

  /// No date was found on the row or above it; [date] is the day it was
  /// shared.
  final bool dateGuessed;
  final String description;

  /// More text found under the row (a second line, a reference).
  final String detail;

  /// As written, in [currency] (or the account's currency when null);
  /// positive is money in, negative money out.
  final double amount;

  /// Nothing on the row said whether the money came in or went out.
  final bool signGuessed;
  final String? currency;
  final double? balance;

  /// The line of the document the row was read from ([StatementReader.lineTexts]).
  final int? line;

  /// The on-device model read the row's line as the bank's own text, not a
  /// transaction. Kept for the person to decide, unticked.
  final bool doubtful;

  const StatementRow({
    required this.date,
    required this.description,
    required this.amount,
    this.dateGuessed = false,
    this.detail = '',
    this.signGuessed = false,
    this.currency,
    this.balance,
    this.line,
    this.doubtful = false,
  });

  bool get isIn => amount > 0;

  StatementRow copyWithLine(int line) => StatementRow(
        date: date,
        description: description,
        amount: amount,
        dateGuessed: dateGuessed,
        detail: detail,
        signGuessed: signGuessed,
        currency: currency,
        balance: balance,
        line: line,
        doubtful: doubtful,
      );

  StatementRow copyWith(
          {DateTime? date, bool? dateGuessed, String? description, double? amount, bool? signGuessed, String? currency, double? balance, bool? doubtful}) =>
      StatementRow(
        date: date ?? this.date,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        dateGuessed: dateGuessed ?? this.dateGuessed,
        detail: detail,
        signGuessed: signGuessed ?? this.signGuessed,
        currency: currency ?? this.currency,
        balance: balance ?? this.balance,
        line: line,
        doubtful: doubtful ?? this.doubtful,
      );

  @override
  List<Object?> get props => [date, dateGuessed, description, detail, amount, signGuessed, currency, balance, line, doubtful];

  @override
  String toString() => 'StatementRow(${date.toIso8601String().substring(0, 10)}, $description, $amount ${currency ?? ''})';
}

enum _Column { date, description, debit, credit, amount, balance }

class _Span {
  final int start, end;
  const _Span(this.start, this.end);
}

class _Found<T> {
  final T value;
  final _Span span;
  final double x;

  /// A date written in the Hijri calendar (and converted).
  final bool hijri;

  /// A day and month in figures with no year ("24/3"): often the Hijri
  /// date a Saudi statement prints under the real one.
  final bool loose;
  const _Found(this.value, this.span, this.x, {this.hijri = false, this.loose = false});
}

class _Money {
  final double major;

  /// -1 out, 1 in, 0 not said.
  final int sign;
  final String? currency;

  /// A whole number with no grouping, decimals or currency, only taken
  /// because it sits under an amount column.
  final bool bare;
  const _Money(this.major, this.sign, this.currency, {this.bare = false});
}

class _Line {
  final List<DocToken> cells;
  _Line(this.cells);
  double get top => cells.map((c) => c.y).reduce(math.min);
  double get bottom => cells.map((c) => c.y + c.h).reduce(math.max);
  double get height => bottom - top;
  double get left => cells.first.x;
  String get text => cells.map((c) => c.text).join(' ');
}

/// Reads transactions out of whatever a bank gives: statement PDFs (with a
/// text layer or scanned), tables, screenshots of a banking app, CSV and
/// Excel exports, and bank messages. Everything arrives as positioned text
/// ([DocPage]); rows are rebuilt from where the text sits, and columns from
/// a header row when there is one.
///
/// It never makes up an amount: a row without one is dropped. When it can't
/// tell the date or whether money came in or went out, it says so
/// ([StatementRow.dateGuessed], [StatementRow.signGuessed]) and the review
/// screen asks.
class StatementReader {
  /// When the file was shared: the year for dates written without one, and
  /// the day for "Today".
  final DateTime received;

  StatementReader({required this.received});

  // ---------------------------------------------------------------- text

  static const _digitMap = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4', '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9', //
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4', '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
    '٫': '.', '٬': ',', '−': '-', '–': '-', ' ': ' ', '‏': '', '‎': '', '؜': '',
  };

  static String normalize(String s) {
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final unit = ch.codeUnitAt(0);
      if (unit >= 0xFE70 && unit <= 0xFEFC) {
        b.write(_arabicForms[unit] ?? ch);
        continue;
      }
      b.write(_digitMap[ch] ?? ch);
    }
    return b.toString();
  }

  /// Arabic letters as many PDFs store them: one shape per position in the
  /// word (Arabic Presentation Forms-B), folded back to the letters people
  /// type, so "ﺍﻟﺮﺻﻴﺪ" reads as "الرصيد". Isolated vowel marks are dropped.
  static final Map<int, String> _arabicForms = () {
    const runs = [
      (0xFE80, 1, 'ء'), (0xFE81, 2, 'آ'), (0xFE83, 2, 'أ'), (0xFE85, 2, 'ؤ'), (0xFE87, 2, 'إ'), (0xFE89, 4, 'ئ'), //
      (0xFE8D, 2, 'ا'), (0xFE8F, 4, 'ب'), (0xFE93, 2, 'ة'), (0xFE95, 4, 'ت'), (0xFE99, 4, 'ث'), (0xFE9D, 4, 'ج'),
      (0xFEA1, 4, 'ح'), (0xFEA5, 4, 'خ'), (0xFEA9, 2, 'د'), (0xFEAB, 2, 'ذ'), (0xFEAD, 2, 'ر'), (0xFEAF, 2, 'ز'),
      (0xFEB1, 4, 'س'), (0xFEB5, 4, 'ش'), (0xFEB9, 4, 'ص'), (0xFEBD, 4, 'ض'), (0xFEC1, 4, 'ط'), (0xFEC5, 4, 'ظ'),
      (0xFEC9, 4, 'ع'), (0xFECD, 4, 'غ'), (0xFED1, 4, 'ف'), (0xFED5, 4, 'ق'), (0xFED9, 4, 'ك'), (0xFEDD, 4, 'ل'),
      (0xFEE1, 4, 'م'), (0xFEE5, 4, 'ن'), (0xFEE9, 4, 'ه'), (0xFEED, 2, 'و'), (0xFEEF, 2, 'ى'), (0xFEF1, 4, 'ي'),
      (0xFEF5, 2, 'لآ'), (0xFEF7, 2, 'لأ'), (0xFEF9, 2, 'لإ'), (0xFEFB, 2, 'لا'),
    ];
    return {
      for (var c = 0xFE70; c <= 0xFE7F; c++) c: '',
      for (final (start, count, letter) in runs)
        for (var c = start; c < start + count; c++) c: letter,
    };
  }();

  // -------------------------------------------------------------- months

  static final Map<String, int> _months = () {
    final m = <String, int>{};
    void add(List<String> names) {
      for (var i = 0; i < 12; i++) {
        for (final n in names[i].split('|')) {
          m[n] = i + 1;
        }
      }
    }

    add([
      'jan|january', 'feb|february', 'mar|march', 'apr|april', 'may', 'jun|june', //
      'jul|july', 'aug|august', 'sep|sept|september', 'oct|october', 'nov|november', 'dec|december',
    ]);
    add([
      'janv|janvier', 'févr|fevr|février|fevrier', 'mars', 'avr|avril', 'mai', 'juin', //
      'juil|juillet', 'août|aout', 'sept|septembre', 'oct|octobre', 'nov|novembre', 'déc|dec|décembre|decembre',
    ]);
    add([
      'ene|enero', 'febrero', 'marzo', 'abr|abril', 'mayo', 'junio', //
      'julio', 'ago|agosto', 'septiembre|setiembre', 'octubre', 'noviembre', 'dic|diciembre',
    ]);
    add([
      'يناير|كانون الثاني', 'فبراير|شباط', 'مارس|آذار', 'أبريل|ابريل|إبريل|نيسان', 'مايو|أيار', 'يونيو|يونيه|حزيران', //
      'يوليو|يوليه|تموز', 'أغسطس|اغسطس|آب', 'سبتمبر|أيلول', 'أكتوبر|اكتوبر|تشرين الأول', 'نوفمبر|تشرين الثاني', 'ديسمبر|كانون الأول',
    ]);
    return m;
  }();

  static final String _monthAlt = (_months.keys.toList()..sort((a, b) => b.length - a.length)).map(RegExp.escape).join('|');

  // Dates. Order matters: the first pattern that matches a span wins.
  static final _isoDate = RegExp(r'(?<!\d)(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})(?!\d)');
  static final _numDate = RegExp(r'(?<!\d)(\d{1,2})[-/.](\d{1,2})(?:[-/.](\d{2}|\d{4}))?(?!\d|[.,]\d)');
  static final _dayMonth = RegExp('(?<![\\p{L}\\d])(\\d{1,2})(?:st|nd|rd|th)?[\\s\\-/.]*($_monthAlt)\\.?(?:[\\s\\-/.,]*(\\d{4}|\\d{2}))?(?![\\p{L}\\d])', caseSensitive: false, unicode: true);
  static final _monthDay = RegExp('(?<![\\p{L}\\d])($_monthAlt)\\.?[\\s\\-/.]*(\\d{1,2})(?:st|nd|rd|th)?(?:[\\s,]+(\\d{4}))?(?![\\p{L}\\d])', caseSensitive: false, unicode: true);
  static final _misreadDate = RegExp(r'(?<!\d)(\d{2})[1lI|](\d{2})/(\d{4})(?!\d)');
  static final _relative = RegExp(r"(?<![\p{L}])(today|yesterday|اليوم|أمس|امس|aujourd'hui|aujourd’hui|hier|hoy|ayer)(?![\p{L}])", caseSensitive: false, unicode: true);
  static final _time = RegExp(r'(?<!\d)\d{1,2}:\d{2}(?::\d{2})?(?:\s?(?:am|pm|ص|م))?(?![\d])', caseSensitive: false);

  // Money.
  static const Map<String, String> _currencyWords = {
    'sar': 'SAR', 'sr': 'SAR', '\u20c1': 'SAR', 'ر.س': 'SAR', 'ر س': 'SAR', 'ريال': 'SAR', 'رس': 'SAR', '﷼': 'SAR', //
    'egp': 'EGP', 'le': 'EGP', 'ج.م': 'EGP', 'جم': 'EGP', 'جنيه': 'EGP', //
    'aed': 'AED', 'د.إ': 'AED', 'درهم': 'AED', 'kwd': 'KWD', 'د.ك': 'KWD', 'qar': 'QAR', 'ر.ق': 'QAR', //
    'bhd': 'BHD', 'د.ب': 'BHD', 'omr': 'OMR', 'ر.ع': 'OMR', 'jod': 'JOD', 'usd': 'USD', r'$': 'USD', r'us$': 'USD', //
    'eur': 'EUR', '€': 'EUR', 'gbp': 'GBP', '£': 'GBP', 'mad': 'MAD', 'try': 'TRY', 'inr': 'INR', '₹': 'INR',
  };
  static final String _ccyAlt = (_currencyWords.keys.toList()..sort((a, b) => b.length - a.length)).map(RegExp.escape).join('|');
  static final _amount = RegExp(
    '(?<![\\p{L}\\d.,*])(\\()?\\s*([-+])?\\s*(?:($_ccyAlt)\\s?)?([-+])?\\s*'
    r'(\d{1,3}(?:[,\s.]\d{3})+(?:[.,]\d{1,3})?|\d+(?:[.,]\d{1,3})?)'
    '(?:\\s?($_ccyAlt))?\\s*(\\))?\\s*(-|cr\\b|dr\\b|db\\b|مدين|دائن)?(?![\\p{L}\\d])',
    caseSensitive: false,
    unicode: true,
  );

  // Header words, per column.
  static const Map<_Column, List<String>> _headerWords = {
    _Column.date: ['date', 'posting date', 'transaction date', 'value date', 'التاريخ', 'تاريخ', 'تاريخ العملية', 'fecha', 'date opération', 'datum'],
    _Column.description: ['description', 'details', 'narrative', 'narratives', 'particulars', 'merchant', 'transaction', 'البيان', 'الوصف', 'التفاصيل', 'تفاصيل', 'العملية', 'libellé', 'libelle', 'concepto', 'descripción', 'descripcion'],
    _Column.debit: ['debit', 'debits', 'withdrawal', 'withdrawals', 'money out', 'paid out', 'out', 'مدين', 'سحب', 'مسحوبات', 'المدين', 'خصم', 'débit', 'debito', 'débito', 'cargo', 'cargos'],
    _Column.credit: ['credit', 'credits', 'deposit', 'deposits', 'money in', 'paid in', 'in', 'دائن', 'إيداع', 'ايداع', 'إيداعات', 'الدائن', 'crédit', 'credito', 'crédito', 'abono', 'abonos'],
    _Column.amount: ['amount', 'value', 'المبلغ', 'مبلغ', 'القيمة', 'montant', 'importe', 'monto'],
    _Column.balance: ['balance', 'running balance', 'الرصيد', 'رصيد', 'solde', 'saldo'],
  };

  static final _skipWords = RegExp(
    r'opening balance|closing balance|balance brought forward|balance carried forward|brought forward|carried forward|'
    r'previous balance|total|subtotal|statement period|page \d|الرصيد الافتتاحي|الرصيد الختامي|رصيد افتتاحي|رصيد ختامي|الرصيد السابق|'
    r'المجموع|الإجمالي|اجمالي|إجمالي|solde initial|solde final|saldo inicial|saldo final|total',
    caseSensitive: false,
  );

  static final _summaryWords = RegExp(
    r'credit limit|available limit|available credit|minimum payment|minimum due|payment due|due date|outstanding|overdue|'
    r'installment amount|instalment amount|final installment|finance amount|amount paid|tenure|deferment|last payment received|'
    r'الحد الائتماني|الحد المتاح|الحد الأدنى|تاريخ الاستحقاق|المبلغ المستحق|المبلغ المتبقي|قيمة القسط|'
    r'plafond|paiement minimum|límite de crédito|pago mínimo',
    caseSensitive: false,
  );

  static final _incomeWords = RegExp(
    r'salary|payroll|deposit|credited|received|refund|reversal|cashback|transfer in|incoming|interest earned|'
    r'راتب|رواتب|إيداع|ايداع|وارد|واردة|استرداد|مسترد|استرجاع|أضيف|اضيف|salaire|virement reçu|remboursement|nómina|nomina|abono|reembolso',
    caseSensitive: false,
  );
  static final _spendWords = RegExp(
    r'purchase|debited|withdrawal|paid|payment|pos\b|atm|transfer out|outgoing|fee|charge|'
    r'شراء|مشتريات|خصم|سحب|صادرة|صادر|دفع|سداد|رسوم|achat|retrait|paiement|compra|retiro|pago',
    caseSensitive: false,
  );

  // ---------------------------------------------------------- dates

  /// Whether dates written as numbers put the day first. Decided once per
  /// document from any date whose first or second number is over 12.
  bool _dayFirst = true;

  void _decideOrder(Iterable<String> texts) {
    var day = 0, month = 0;
    for (final t in texts) {
      for (final m in _numDate.allMatches(t)) {
        if (m[3] == null && t.substring(m.start, m.end).contains('.')) continue;
        final a = int.parse(m[1]!), b = int.parse(m[2]!);
        if (a > 12 && b <= 12) day++;
        if (b > 12 && a <= 12) month++;
      }
    }
    _dayFirst = month <= day;
  }

  /// Years Saudi and Gulf statements print Hijri dates in (1448 is 2026).
  static bool _isHijriYear(int y) => y >= 1350 && y <= 1500;

  /// A real day near the statement, or null. Hijri dates are converted; any
  /// other year far from the share date is a reference number, a register
  /// number or a birth date, not a transaction.
  DateTime? _day(int y, int m, int d) {
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    if (_isHijriYear(y)) {
      if (d > 30) return null;
      return _near(hijriToGregorian(y, m, d));
    }
    final date = DateTime(y, m, d);
    return date.month == m ? _near(date) : null;
  }

  DateTime? _near(DateTime d) => d.year >= received.year - 20 && !d.isAfter(received.add(const Duration(days: 366))) ? d : null;

  /// Umm al-Qura, the calendar Saudi banks print: the length of each month
  /// from Muharram 1420 to Dhu al-Hijjah 1480 ('0' is 30 days, '9' is 29),
  /// from 1 Muharram 1420 (day 10698 after 1970-01-01).
  static const _ummAlQuraFrom = 1420;
  static const _ummAlQuraStart = 10698;
  static const _ummAlQuraLengths =
      '909909000090990999000090099099900090090909909090090090990909090090900909909090090090990909009009'
      '099099000900909909900900900990909090900909090990900090909099090090090909909090090099090909090090'
      '909090909090090099090990090009909909090009090990909000909099090900900909909090900909090909090900'
      '909009909090900090990990900090099099090009090909909009009090990909009009090990909009000990990090'
      '090099099090090090909909090090090909909009090090990909090009099099090000909909909000900990990900'
      '900909099090900909090099090900909009909090900090909909900090090990990090009099909009009009909090'
      '909009090909909009009090990900900909099090900900909909090090909009909090900900990909900900099099'
      '090900090909909900009090990909009009099090909009090909090909';

  static DateTime hijriToGregorian(int y, int m, int d) {
    final index = (y - _ummAlQuraFrom) * 12 + m - 1;
    if (index >= 0 && index < _ummAlQuraLengths.length) {
      var days = _ummAlQuraStart;
      for (var i = 0; i < index; i++) {
        days += _ummAlQuraLengths[i] == '0' ? 30 : 29;
      }
      final epoch = DateTime.utc(1970).add(Duration(days: days + d - 1));
      return DateTime(epoch.year, epoch.month, epoch.day);
    }
    // Outside the table: the tabular calendar, within a day or two.
    final jd = ((11 * y + 3) / 30).floor() + 354 * y + 30 * m - ((m - 1) / 2).floor() + d + 1948440 - 385;
    // Julian day to Gregorian (Fliegel and Van Flandern).
    var l = jd + 68569;
    final n = (4 * l / 146097).floor();
    l = l - ((146097 * n + 3) / 4).floor();
    final i = (4000 * (l + 1) / 1461001).floor();
    l = l - (1461 * i / 4).floor() + 31;
    final j = (80 * l / 2447).floor();
    final day = l - (2447 * j / 80).floor();
    l = (j / 11).floor();
    final month = j + 2 - 12 * l;
    final year = 100 * (n - 49) + i + l;
    return DateTime(year, month, day);
  }

  int _year(String? raw, int month, int day) {
    if (raw == null) {
      // No year: the latest such day that isn't after the share date.
      final y = received.year;
      final candidate = DateTime(y, month, day);
      return candidate.isAfter(received.add(const Duration(days: 1))) ? y - 1 : y;
    }
    final v = int.parse(raw);
    return raw.length == 2 ? 2000 + v : v;
  }

  /// The dates in [text], and every span that looked like one (a far year
  /// included), so those digits aren't read as money.
  (List<_Found<DateTime>>, List<_Span>) _dates(String text0) {
    var text = text0;
    final out = <_Found<DateTime>>[];
    final taken = <_Span>[];
    bool free(int s, int e) => !taken.any((t) => s < t.end && e > t.start);
    void take(RegExpMatch m, DateTime? d, {bool hijri = false, bool loose = false}) {
      if (!free(m.start, m.end)) return;
      final span = _Span(m.start, m.end);
      // Not a usable day (a far year): the digits still aren't money.
      taken.add(span);
      if (d != null) out.add(_Found(d, span, 0, hijri: hijri, loose: loose));
    }

    // Text recognition reads a leading zero as the letter O ("O6SEP").
    text = text.replaceAllMapped(RegExp('(?<![\\p{L}\\d])[Oo](?=\\d\\s?(?:$_monthAlt)(?![\\p{L}]))', caseSensitive: false, unicode: true), (_) => '0');

    for (final m in _isoDate.allMatches(text)) {
      final y = int.parse(m[1]!);
      take(m, _day(y, int.parse(m[2]!), int.parse(m[3]!)), hijri: _isHijriYear(y));
    }
    for (final m in _dayMonth.allMatches(text)) {
      final month = _months[m[2]!.toLowerCase()];
      if (month == null) continue;
      final day = int.parse(m[1]!);
      take(m, _day(_year(m[3], month, day), month, day));
    }
    for (final m in _monthDay.allMatches(text)) {
      final month = _months[m[1]!.toLowerCase()];
      if (month == null) continue;
      final day = int.parse(m[2]!);
      take(m, _day(_year(m[3], month, day), month, day));
    }
    for (final m in _numDate.allMatches(text)) {
      final a = int.parse(m[1]!), b = int.parse(m[2]!);
      final (d, mo) = _dayFirst ? (a, b) : (b, a);
      // "12.50" is money, not a date: a date without a year needs a slash
      // or a dash.
      if (m[3] == null && text.substring(m.start, m.end).contains('.')) continue;
      final y = _year(m[3], mo, d);
      take(m, _day(y, mo, d), hijri: _isHijriYear(y), loose: m[3] == null);
    }
    for (final m in _misreadDate.allMatches(text)) {
      final (a, b) = (int.parse(m[1]!), int.parse(m[2]!));
      final (d, mo) = _dayFirst ? (a, b) : (b, a);
      take(m, _day(int.parse(m[3]!), mo, d));
    }
    for (final m in _relative.allMatches(text)) {
      final w = m[1]!.toLowerCase();
      final today = DateTime(received.year, received.month, received.day);
      final isToday = const {'today', 'اليوم', "aujourd'hui", 'aujourd’hui', 'hoy'}.contains(w);
      take(m, isToday ? today : today.subtract(const Duration(days: 1)));
    }
    out.sort((a, b) => a.span.start - b.span.start);
    return (out, taken);
  }

  // ---------------------------------------------------------- money

  static String? _currencyOf(String? word) => word == null ? null : _currencyWords[word.toLowerCase()];

  static double? parseNumber(String raw, {String? currency}) {
    var s = raw.replaceAll(' ', '');
    final lastDot = s.lastIndexOf('.'), lastComma = s.lastIndexOf(',');
    final last = math.max(lastDot, lastComma);
    if (last >= 0) {
      final decimals = s.length - last - 1;
      final sep = s[last];
      final other = sep == '.' ? ',' : '.';
      final threeDigit = currency != null && MinorUnits.digits(currency) == 3;
      final isDecimal = decimals <= 2 || (decimals == 3 && (threeDigit || s.contains(other)) && !s.substring(0, last).contains(sep));
      if (isDecimal && !(decimals == 3 && s.indexOf(sep) != last)) {
        s = '${s.substring(0, last).replaceAll(RegExp(r'[.,]'), '')}.${s.substring(last + 1)}';
      } else {
        s = s.replaceAll(RegExp(r'[.,]'), '');
      }
    }
    return double.tryParse(s);
  }

  /// The amounts in [text]. [loose] accepts a bare whole number (a cell under
  /// an amount column); otherwise a figure needs decimals or a currency so
  /// that reference numbers, card digits and times are never read as money.
  List<_Found<_Money>> _amounts(String text, List<_Span> notHere, {bool loose = false}) {
    final out = <_Found<_Money>>[];
    for (final m in _amount.allMatches(text)) {
      if (notHere.any((t) => m.start < t.end && m.end > t.start)) continue;
      final digits = m[5]!;
      final ccy = _currencyOf(m[3]) ?? _currencyOf(m[6]);
      final hasDecimals = RegExp(r'[.,]\d{1,3}$').hasMatch(digits) && !RegExp(r'^\d{1,3}[.,]\d{3}$').hasMatch(digits);
      final grouped = RegExp(r'^\d{1,3}(?:[,\s.]\d{3})+').hasMatch(digits) && digits.length > 4;
      final bare = ccy == null && !hasDecimals && !grouped;
      if (!loose && bare) continue;
      // A long run of digits is a phone, account or register number.
      if (bare && digits.length > 7) continue;
      if (!loose && ccy == null && digits.replaceAll(RegExp(r'\D'), '').length > 9) continue;
      final value = parseNumber(digits, currency: ccy);
      if (value == null || value == 0) continue;
      final marker = (m[8] ?? '').toLowerCase();
      var sign = 0;
      if (m[2] == '-' || m[4] == '-' || marker == '-' || (m[1] != null && m[7] != null) || marker == 'dr' || marker == 'db' || marker == 'مدين') {
        sign = -1;
      } else if (m[2] == '+' || m[4] == '+' || marker == 'cr' || marker == 'دائن') {
        sign = 1;
      }
      out.add(_Found(_Money(value, sign, ccy, bare: bare), _Span(m.start, m.end), 0));
    }
    return out;
  }

  // ---------------------------------------------------------- lines

  /// Tokens grouped into lines: a token joins a line when its middle is
  /// within half a line's height of the line's middle.
  static List<_Line> _lines(List<DocToken> tokens) {
    final sorted = [...tokens.where((t) => t.text.trim().isNotEmpty)]..sort((a, b) => a.midY.compareTo(b.midY));
    final lines = <List<DocToken>>[];
    for (final t in sorted) {
      final line = lines.isEmpty ? null : lines.last;
      if (line != null) {
        final mid = line.map((c) => c.midY).reduce((a, b) => a + b) / line.length;
        final h = line.map((c) => c.h).reduce(math.min);
        if ((t.midY - mid).abs() <= math.min(h, t.h) * 0.5) {
          line.add(t);
          continue;
        }
      }
      lines.add([t]);
    }
    return [for (final l in lines) _Line(l..sort((a, b) => a.x.compareTo(b.x)))];
  }

  /// A header row: two or more cells that each name a column. Returns each
  /// column's middle across the page.
  Map<_Column, double>? _header(_Line line) {
    // Each column's extent over all the cells naming it: a bilingual
    // header names a column twice ("Debit المدين"), and its figures sit
    // under both names, not under the first.
    final spans = <_Column, (double, double)>{};
    for (final c in line.cells) {
      final t = normalize(c.text).toLowerCase().trim();
      for (final e in _headerWords.entries) {
        // Long words match with one letter misread ("Vithdrawals").
        if (e.value.any((w) => t == w || (w.length >= 6 && _oneEdit(t, w)) || (w.length > 3 && t.split(RegExp(r'\s*[/(]\s*')).any((p) => p.trim() == w)))) {
          final had = spans[e.key];
          spans[e.key] = had == null ? (c.x, c.x + c.w) : (math.min(had.$1, c.x), math.max(had.$2, c.x + c.w));
          break;
        }
      }
    }
    final found = {for (final e in spans.entries) e.key: (e.value.$1 + e.value.$2) / 2};
    final money = found.keys.where((k) => k == _Column.debit || k == _Column.credit || k == _Column.amount || k == _Column.balance);
    return found.length >= 2 && money.isNotEmpty ? found : null;
  }

  /// Whether [a] is [b] with at most one letter added, dropped or changed.
  static bool _oneEdit(String a, String b) {
    if ((a.length - b.length).abs() > 1) return false;
    var i = 0, j = 0, edits = 0;
    while (i < a.length && j < b.length) {
      if (a[i] == b[j]) {
        i++;
        j++;
        continue;
      }
      if (++edits > 1) return false;
      if (a.length > b.length) {
        i++;
      } else if (a.length < b.length) {
        j++;
      } else {
        i++;
        j++;
      }
    }
    return edits + (a.length - i) + (b.length - j) <= 1;
  }

  _Column? _columnAt(Map<_Column, double> header, double x) {
    final xs = header.values.toList()..sort();
    var gap = 1.0;
    for (var i = 1; i < xs.length; i++) {
      gap = math.min(gap, xs[i] - xs[i - 1]);
    }
    _Column? best;
    var bestD = double.infinity;
    for (final e in header.entries) {
      final d = (e.value - x).abs();
      if (d < bestD) {
        bestD = d;
        best = e.key;
      }
    }
    return bestD <= math.max(gap * 0.75, 0.04) ? best : null;
  }

  static String _clean(String s) => s
      .replaceAll(RegExp(r'\*{2,}\d*|x{4,}\d*|#\d+', caseSensitive: false), ' ')
      // Card networks separate the merchant, city and country with tildes;
      // text recognition reads the new riyal sign as '#'.
      .replaceAll(RegExp(r'[|•·~#]+'), ' ')
      // The country and region code a card network appends ("SAU682").
      .replaceAll(RegExp(r'(?:^|\s)[A-Z]{3}\d{3}(?=\s|$)'), ' ')
      // Debris of a misread date or number ("27109/2026").
      .replaceAll(RegExp(r'(?:^|\s)[\d/\-.:]{5,}(?=\s|$)'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'^[\s\-–:,.]+|[\s\-–:,]+$'), '')
      .trim();

  // ---------------------------------------------------------- reading

  /// Rows from positioned pages: statement PDFs, screenshots, tables.
  List<StatementRow> readPages(List<DocPage> pages) {
    final allLines = [for (final p in pages) _lines(p.tokens)];
    _decideOrder([for (final ls in allLines) for (final l in ls) normalize(l.text)]);

    final rows = <StatementRow>[];
    final rowLines = <_Line>[];
    Map<_Column, double>? header;
    // A statement with a table: nothing above its first header is a
    // transaction (the summary, the address, the statement's own date).
    final hasTable = allLines.any((ls) => ls.any((l) => _header(l) != null));
    double? pendingLeft;
    // Rows read without columns: the other way to read their figures, with
    // the balance first (right-to-left statements put it on the left).
    final balanceFirst = <int, (_Money, double)>{};
    // Rows whose only figure is the balance: their amount cell was lost or
    // misplaced (some PDFs misreport where a figure is), so the change in
    // the running balance gives it.
    final fromBalance = <int>{};
    DateTime? sectionDate;
    String pendingText = '';
    double? pendingBottom;
    // Tables whose cells centre their lines on the dated one: a row's
    // reference sits on the line above its date, so a line between two
    // rows belongs to the nearer one. Decided by the table's first row.
    bool? centred;
    _Line? rowAnchor;
    // The last line of a page, with more pages to come, heads the next
    // page's first row.
    bool nearerNext(List<_Line> lines, _Line line, _Line anchor, {required bool morePages}) {
      for (final next in lines.skip(lines.indexOf(line) + 1)) {
        if (_dates(normalize(next.text)).$1.isEmpty) continue;
        return next.top - line.bottom < line.top - anchor.bottom;
      }
      return morePages && identical(line, lines.last);
    }

    var lineBase = 0;
    for (final lines in allLines) {
      final base = lineBase;
      lineBase += lines.length;
      sectionDate = null;
      // A screenshot of messages: each bubble is read as one message, so the
      // limit or balance a bank adds is never a transaction of its own.
      final messages = hasTable ? const <int, List<_Line>>{} : _messageBlocks(lines);
      final skip = <_Line>{};
      for (final line in lines) {
        if (skip.contains(line)) continue;
        final bubble = messages[lines.indexOf(line)];
        if (bubble != null) {
          skip.addAll(bubble);
          final row = _message([for (final l in bubble) normalize(l.text)]);
          if (row != null) rows.add(row.copyWithLine(base + lines.indexOf(line)));
          pendingText = '';
          continue;
        }
        final h = _header(line);
        if (h != null) {
          header = h;
          pendingText = '';
          // A date above the table (the statement's own date) heads nothing.
          sectionDate = null;
          continue;
        }

        if (hasTable && header == null) continue;

        // Per cell: dates, amounts, and what's left as words.
        final dates = <_Found<DateTime>>[];
        final amounts = <(_Found<_Money>, _Column?)>[];
        final words = <String>[];
        String? lineCurrency;
        for (final cell in line.cells) {
          final text = normalize(cell.text);
          final column = header == null ? null : _columnAt(header, cell.x + cell.w / 2);
          final (ds, dateSpans) = _dates(text);
          final times = [for (final m in _time.allMatches(text)) _Span(m.start, m.end)];
          final taken = [...dateSpans, ...times];
          final moneyColumn = column == _Column.debit || column == _Column.credit || column == _Column.amount || column == _Column.balance;
          final ams = _amounts(text, taken, loose: moneyColumn);
          for (final d in ds) {
            dates.add(_Found(d.value, d.span, cell.x + cell.w / 2, hijri: d.hijri, loose: d.loose));
          }
          for (final a in ams) {
            final at = cell.x + cell.w * ((a.span.start + a.span.end) / 2 / math.max(text.length, 1));
            final col = header == null ? null : _columnAt(header, at) ?? column;
            amounts.add((_Found(a.value, a.span, at), col));
          }
          final spans = [...taken, ...ams.map((a) => a.span)]..sort((a, b) => a.start - b.start);
          var rest = StringBuffer();
          var i = 0;
          for (final s in spans) {
            if (s.start > i) rest.write(text.substring(i, s.start));
            rest.write(' ');
            i = math.max(i, s.end);
          }
          if (i < text.length) rest.write(text.substring(i));
          final cleaned = _clean(rest.toString());
          final asCurrency = _currencyOf(cleaned);
          if (asCurrency != null) {
            lineCurrency = asCurrency;
          } else if (cleaned.isNotEmpty && column != _Column.balance) {
            words.add(cleaned);
          }
        }
        final description = _clean(words.join(' '));

        // The day a line gives the rows under it. In a table only the date
        // column's dates count (a transfer's details carry their own
        // timestamps), and a day and month with no year never replaces a
        // full date: it is the Hijri date printed under it.
        DateTime? heading(List<_Found<DateTime>> found) {
          final dateColumn = header?[_Column.date];
          for (final d in found) {
            if (d.hijri || (d.loose && sectionDate != null)) continue;
            if (dateColumn != null && header != null && _columnAt(header, d.x) != _Column.date) continue;
            return d.value;
          }
          return null;
        }

        if (_skipWords.hasMatch(description)) {
          pendingText = '';
          continue;
        }

        if (amounts.isEmpty) {
          if (dates.isNotEmpty && description.length < 3) {
            final prev = rowLines.isEmpty ? null : rowLines.last;
            if (prev != null && rows.isNotEmpty && rows.last.dateGuessed && line.top - prev.bottom < prev.height * 1.5) {
              // A date under a row that had none is that row's (card lists).
              rows.last = rows.last.copyWith(date: dates.first.value, dateGuessed: false);
              rowLines.last = line;
            } else {
              // A date on its own heads a group of rows (banking apps).
              sectionDate = heading(dates) ?? sectionDate;
            }
            pendingText = '';
          } else if (description.isNotEmpty) {
            final prev = rowLines.isEmpty ? null : rowLines.last;
            final close = prev != null && rows.isNotEmpty && line.top - prev.bottom < prev.height * 1.2 && line.top > prev.top;
            final under = close && !(centred == true && rowAnchor != null && nearerNext(lines, line, rowAnchor, morePages: !identical(lines, allLines.last)));
            if (under && pendingText.isEmpty && dates.isEmpty) {
              final last = rows.removeLast();
              rows.add(StatementRow(
                date: last.date,
                dateGuessed: last.dateGuessed,
                description: last.description.isEmpty ? description : last.description,
                detail: last.description.isEmpty ? last.detail : [last.detail, description].where((s) => s.isNotEmpty).join(' '),
                amount: last.amount,
                signGuessed: last.signGuessed,
                currency: last.currency,
                balance: last.balance,
                line: last.line,
              ));
              rowLines.last = line;
            } else {
              // A name wrapped onto the next line continues it.
              final wraps = pendingText.isNotEmpty && pendingBottom != null && pendingLeft != null && line.top - pendingBottom < line.height * 0.6 && (line.left - pendingLeft).abs() < 0.03;
              pendingText = wraps ? '$pendingText $description' : description;
              pendingBottom = line.bottom;
              pendingLeft = line.left;
              sectionDate = heading(dates) ?? sectionDate;
            }
          }
          continue;
        }

        // Which figure is the transaction and which the balance.
        double? balance;
        _Money? money;
        var sign = 0;
        (_Money, double)? flip;
        final byColumn = header != null && amounts.any((a) => a.$2 != null);
        // A card row in a foreign currency gives that amount and then the
        // local one: the local one is the transaction, the foreign one its
        // detail.
        _Money? foreign;
        // A figure with decimals or a currency beats a bare number in a
        // name ("Branch 101"), and the local amount beats a foreign one.
        bool better(_Money a, _Money than) => (than.bare && !a.bare) || (than.currency != null && a.currency == null && !a.bare);
        if (byColumn) {
          for (final (a, col) in amounts) {
            final s = switch (col) {
              _Column.debit => -1,
              _Column.credit => 1,
              _Column.amount || null => a.value.sign,
              _ => null,
            };
            if (col == _Column.balance) {
              balance = a.value.major * (a.value.sign == 0 ? 1 : a.value.sign);
            } else if (s != null && (money == null || better(a.value, money))) {
              if (money?.currency != null && a.value.currency == null) foreign = money;
              money = a.value;
              sign = s;
            }
          }
        } else {
          // A bare number in a name ("Branch 101") is not the amount when the
          // line has figures with decimals.
          final all = [for (final a in amounts) a.$1.value];
          final list = all.any((m) => !m.bare) ? all.where((m) => !m.bare).toList() : all;
          money = list.first;
          sign = money.sign;
          if (list.length >= 2) {
            final last = list.last;
            balance = last.major * (last.sign == 0 ? 1 : last.sign);
            final first = list.first;
            flip = (list[1], first.major * (first.sign == 0 ? 1 : first.sign));
          }
        }
        final balanceOnly = money == null && balance != null && byColumn;
        if (money == null && !balanceOnly) continue;

        // The day: the date column's, else a Gregorian one, else the first.
        final dateColumn = header?[_Column.date];
        // Ties keep the line's order: a transaction date comes before the
        // posting date.
        final ownDates = [...dates]
          ..sort((a, b) {
            if (dateColumn != null) {
              final c = (a.x - dateColumn).abs().compareTo((b.x - dateColumn).abs());
              if (c != 0) return c;
            }
            if (a.hijri != b.hijri) return a.hijri ? 1 : -1;
            if (a.loose != b.loose) return a.loose ? 1 : -1;
            return a.x.compareTo(b.x) != 0 ? a.x.compareTo(b.x) : a.span.start - b.span.start;
          });
        // In a statement table every transaction carries its date. A line
        // without one is the bank's address, register number or terms at
        // the foot of the page, unless a date line inside the table heads it
        // and its figure is real money.
        if (header != null && ownDates.isEmpty && (sectionDate == null || balanceOnly || money!.bare)) {
          pendingText = '';
          continue;
        }

        // A name with no word in it is a mask ("A.. E. K...") or a misread
        // figure, not a name.
        var text = RegExp(r'\p{L}{2,}', unicode: true).hasMatch(description) ? description : '';
        if (header != null && centred == null) {
          // A line just above the first row and one just below it, before
          // the next row: the row's text is centred on its date.
          final i = lines.indexOf(line);
          final next = i + 1 < lines.length ? lines[i + 1] : null;
          centred = pendingText.isNotEmpty &&
              pendingBottom != null &&
              line.top - pendingBottom < line.height * 1.5 &&
              next != null &&
              _dates(normalize(next.text)).$1.isEmpty;
        }
        final wrapped = pendingText.isNotEmpty && pendingBottom != null && pendingLeft != null && line.top - pendingBottom < line.height * 0.5 && (line.left - pendingLeft).abs() < 0.03;
        if (text.isNotEmpty && pendingText.isNotEmpty && (wrapped || centred == true)) {
          // The name's first line sits above, its second on this line.
          text = '$pendingText $text';
        } else if (text.isEmpty && pendingText.isNotEmpty) {
          text = pendingText;
        }
        pendingText = '';

        // The statement's summary (limit, minimum payment, what is still
        // owed) is not a transaction, nor an undated line of bare figures.
        // A dated row stays even when its name came out unreadable.
        if (_summaryWords.hasMatch(text) || (ownDates.isEmpty && text.isEmpty)) continue;

        var signGuessed = false;
        if (sign == 0) {
          signGuessed = true;
          sign = _incomeWords.hasMatch(text) && !_spendWords.hasMatch(text) ? 1 : -1;
        }
        final ccy = money?.currency ?? lineCurrency;
        // A row that starts (or, right to left, ends) with two dates gives
        // the transaction and posting dates: it happened on the earlier.
        final paired = _edgeDates(line);
        final date = paired.length >= 2
            ? paired.reduce((a, b) => a.isBefore(b) ? a : b)
            : ownDates.isNotEmpty
                ? ownDates.first.value
                : sectionDate;
        if (flip != null) balanceFirst[rows.length] = flip;
        if (balanceOnly) fromBalance.add(rows.length);
        rows.add(StatementRow(
          date: date ?? DateTime(received.year, received.month, received.day),
          dateGuessed: date == null,
          description: text,
          detail: foreign == null ? '' : '${foreign.major.toStringAsFixed(2)} ${foreign.currency}',
          amount: (money?.major ?? 0) * sign,
          signGuessed: signGuessed,
          currency: ccy,
          balance: balance,
          line: base + lines.indexOf(line),
        ));
        rowLines.add(line);
        rowAnchor = line;
      }
    }
    return _signsFromMarkers(_signsFromBalances(_withDocumentCurrency(_amountsFromBalances(_balanceSide(_localAmounts(rows), balanceFirst), fromBalance))));
  }

  /// The full Gregorian dates in the cells at the start of a line and at
  /// its end that hold nothing but dates.
  List<DateTime> _edgeDates(_Line line) {
    List<DateTime>? only(DocToken cell) {
      final t = normalize(cell.text);
      final (ds, spans) = _dates(t);
      if (ds.isEmpty) return null;
      var rest = t;
      for (final s in [...spans]..sort((a, b) => b.start - a.start)) {
        rest = rest.replaceRange(s.start, s.end, ' ');
      }
      if (RegExp(r'[\p{L}\d]', unicode: true).hasMatch(rest)) return null;
      return [for (final d in ds) if (!d.hijri && !d.loose) d.value];
    }

    List<DateTime> run(Iterable<DocToken> cells) {
      final out = <DateTime>[];
      for (final c in cells) {
        final ds = only(c);
        if (ds == null) break;
        out.addAll(ds);
      }
      return out;
    }

    final start = run(line.cells);
    return start.length >= 2 ? start : run(line.cells.reversed);
  }

  /// Rows read without columns whose figures are a foreign amount and then
  /// another figure, in a list whose rows carry no balance: the other
  /// figure is the amount in the statement's own currency (card rows), not
  /// a balance.
  List<StatementRow> _localAmounts(List<StatementRow> rows) {
    final foreign = rows.where((r) => r.currency != null && r.balance != null).length;
    if (foreign == 0) return rows;
    final plain = rows.where((r) => r.currency == null && r.balance == null).length;
    if (plain < rows.length / 2) return rows;
    return [
      for (final r in rows)
        r.currency == null || r.balance == null
            ? r
            : StatementRow(
                date: r.date,
                dateGuessed: r.dateGuessed,
                description: r.description,
                detail: [r.detail, '${r.amount.abs().toStringAsFixed(2)} ${r.currency}'].where((s) => s.isNotEmpty).join(' '),
                amount: r.balance!.abs() * (r.amount < 0 ? -1 : 1),
                signGuessed: r.signGuessed,
                line: r.line,
                doubtful: r.doubtful,
              ),
    ];
  }

  /// A list that marks only one direction (refunds and payments "CR" on a
  /// card, or money in "+" in an app): its unmarked rows went the other way.
  List<StatementRow> _signsFromMarkers(List<StatementRow> rows) {
    final marked = rows.where((r) => !r.signGuessed).toList();
    final guessed = rows.length - marked.length;
    // Two marked rows at least: one is no pattern.
    if (marked.length < 2 || guessed < marked.length) return rows;
    final sign = marked.first.amount.sign;
    if (sign == 0 || marked.any((r) => r.amount.sign != sign)) return rows;
    return [for (final r in rows) r.signGuessed ? r.copyWith(amount: -sign * r.amount.abs(), signGuessed: false) : r];
  }

  /// Rows whose only figure was read as the amount but is really their
  /// balance: in a statement where the rows carry balances, the figure is
  /// taken as this row's balance when a neighbouring row's balance moves
  /// from it by exactly that row's amount. Their amounts then come from
  /// the balances, like rows whose amount cell was lost.
  (List<StatementRow>, Set<int>) _balancesTakenForAmounts(List<StatementRow> rows, Set<int> lost) {
    final withBalance = rows.where((r) => r.balance != null).length;
    if (rows.length < 3 || withBalance < rows.length * 2 / 3) return (rows, lost);
    final out = [...rows];
    final missing = {...lost};
    bool movesFrom(double figure, int j) {
      if (j < 0 || j >= rows.length || missing.contains(j)) return false;
      final b = rows[j].balance;
      return b != null && _same((b - figure).abs(), rows[j].amount.abs());
    }

    for (var i = 0; i < rows.length; i++) {
      if (rows[i].balance != null || missing.contains(i)) continue;
      final figure = rows[i].amount.abs();
      if (movesFrom(figure, i + 1) || movesFrom(figure, i - 1)) {
        out[i] = rows[i].copyWith(balance: figure);
        missing.add(i);
      }
    }
    return (out, missing);
  }

  /// Fills in rows that only showed a balance with the change from the row
  /// before (in time); one with nothing to compare against is dropped.
  List<StatementRow> _amountsFromBalances(List<StatementRow> input, Set<int> lost) {
    final (rows, missing) = _balancesTakenForAmounts(input, lost);
    if (missing.isEmpty) return rows;
    // Which way the rows run, from the rows that have both figures.
    var forward = 0, backward = 0;
    for (var i = 1; i < rows.length; i++) {
      if (missing.contains(i) || missing.contains(i - 1)) continue;
      final a = rows[i - 1].balance, b = rows[i].balance;
      if (a == null || b == null) continue;
      if (_same((b - a).abs(), rows[i].amount.abs())) forward++;
      if (_same((a - b).abs(), rows[i - 1].amount.abs())) backward++;
    }
    final newestFirst = backward > forward;
    return [
      for (var i = 0; i < rows.length; i++)
        if (!missing.contains(i))
          rows[i]
        else if ((newestFirst ? i + 1 : i - 1) case final j when j >= 0 && j < rows.length && rows[j].balance != null && !_same(rows[i].balance!, rows[j].balance!))
          rows[i].copyWith(amount: ((rows[i].balance! - rows[j].balance!) * 1000).round() / 1000, signGuessed: false),
    ];
  }

  /// Which figure is the running balance, decided by the numbers: the
  /// reading whose balances move by exactly the amounts wins.
  List<StatementRow> _balanceSide(List<StatementRow> rows, Map<int, (_Money, double)> balanceFirst) {
    if (balanceFirst.length < 2) return rows;
    final flipped = [
      for (var i = 0; i < rows.length; i++)
        if (balanceFirst[i] case (final money, final balance))
          StatementRow(
            date: rows[i].date,
            dateGuessed: rows[i].dateGuessed,
            description: rows[i].description,
            detail: rows[i].detail,
            amount: money.major * (money.sign == 0 ? -1 : money.sign),
            signGuessed: money.sign == 0,
            currency: rows[i].currency,
            balance: balance,
            line: rows[i].line,
          )
        else
          rows[i],
    ];
    int fits(List<StatementRow> rs) {
      var n = 0;
      for (var i = 1; i < rs.length; i++) {
        final a = rs[i - 1].balance, b = rs[i].balance;
        if (a == null || b == null) continue;
        final d = (b - a).abs();
        if (_same(d, rs[i].amount.abs()) || _same(d, rs[i - 1].amount.abs())) n++;
      }
      return n;
    }

    return fits(flipped) > fits(rows) ? flipped : rows;
  }

  /// Message bubbles on a page, by the index of their first line: runs of
  /// lines with no gap between them that read as sentences (a dozen words
  /// or more over two lines or more) with the amount inside a sentence. In
  /// a list the amount is a piece of text of its own, beside the name.
  Map<int, List<_Line>> _messageBlocks(List<_Line> lines) {
    final out = <int, List<_Line>>{};
    var start = 0;
    void close(int end) {
      final block = lines.sublist(start, end);
      final words = block.fold(0, (n, l) => n + l.text.trim().split(RegExp(r'\s+')).length);
      if (block.length < 2 || words < 12) return;
      var inSentence = false;
      for (final cell in block.expand((l) => l.cells)) {
        final text = normalize(cell.text);
        final found = _amounts(text, _dates(text).$2);
        if (found.isEmpty) continue;
        final rest = found.fold(text, (t, a) => t.replaceRange(a.span.start, a.span.end, ' '.padRight(a.span.end - a.span.start)));
        final restWords = rest.split(RegExp(r'\s+')).where((w) => RegExp(r'\p{L}{2,}', unicode: true).hasMatch(w) && _currencyOf(w) == null).length;
        // A message written as fields ("Amount: SAR 13.00") names each
        // figure with one word.
        if (restWords < 2 && !_fieldLabel.hasMatch(text)) return;
        inSentence = true;
      }
      if (inSentence) out[start] = block;
    }

    for (var i = 1; i <= lines.length; i++) {
      if (i == lines.length) {
        close(i);
        break;
      }
      final prev = lines[i - 1], line = lines[i];
      if (line.top - prev.bottom > math.min(prev.height, line.height)) {
        close(i);
        start = i;
      }
    }
    return out;
  }

  /// Rows without their own currency take the one the rest of the document
  /// uses, when it uses one.
  List<StatementRow> _withDocumentCurrency(List<StatementRow> rows) {
    final counts = <String, int>{};
    for (final r in rows) {
      if (r.currency != null) counts[r.currency!] = (counts[r.currency!] ?? 0) + 1;
    }
    if (counts.isEmpty) return rows;
    final top = (counts.entries.toList()..sort((a, b) => b.value - a.value)).first;
    // One foreign row on a card doesn't make the card foreign.
    if (top.value * 2 < rows.length) return rows;
    return [for (final r in rows) r.currency == null ? r.copyWith(currency: top.key) : r];
  }

  static bool _same(double a, double b) => (a * 1000).round() == (b * 1000).round();

  /// Where rows carry a running balance, it says which way each amount went.
  /// Tries the rows oldest first and newest first and keeps whichever order
  /// the balances fit.
  /// How many neighbouring rows the running balance links, read oldest
  /// first and newest first.
  static (int, int) _balanceFits(List<StatementRow> rows) {
    int fits(bool newestFirst) {
      var n = 0;
      for (var i = 1; i < rows.length; i++) {
        final (older, newer) = newestFirst ? (rows[i], rows[i - 1]) : (rows[i - 1], rows[i]);
        if (older.balance == null || newer.balance == null) continue;
        if (_same((newer.balance! - older.balance!).abs(), newer.amount.abs())) n++;
      }
      return n;
    }

    return (fits(false), fits(true));
  }

  List<StatementRow> _signsFromBalances(List<StatementRow> rows) {
    if (rows.where((r) => r.balance != null).length < 2) return rows;
    final (forward, backward) = _balanceFits(rows);
    if (forward == 0 && backward == 0) return rows;
    final newestFirst = backward > forward;
    final out = [...rows];
    for (var i = 0; i < rows.length; i++) {
      final j = newestFirst ? i + 1 : i - 1;
      if (j < 0 || j >= rows.length) continue;
      final r = rows[i], older = rows[j];
      if (r.balance == null || older.balance == null) continue;
      final delta = r.balance! - older.balance!;
      if (!_same(delta.abs(), r.amount.abs()) || delta == 0) continue;
      out[i] = r.copyWith(amount: r.amount.abs() * delta.sign, signGuessed: false);
    }
    return out;
  }

  /// One row per message: shared text such as a bank SMS. Messages are
  /// separated by blank lines.
  List<StatementRow> readMessages(String text) => [
        for (final block in normalize(text).split(RegExp(r'\n\s*\n')))
          ?_message(block.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList()),
      ];

  static final _merchantAt = RegExp(r'(?:\bat\b|لدى|\bchez\b|\ben\b)\s*:?\s*([^\d\s*][^·]{1,40})', caseSensitive: false);
  static final _paidTo = RegExp(r'(?:\bto\b|(?:^|\s)(?:إلى|الى|لصالح)(?=\s))\s*:?\s*([^\d\s*][^·]{1,40})', caseSensitive: false);
  static final _paidFrom = RegExp(r'(?:\bfrom\b|(?:^|\s)من(?=\s))\s*:?\s*([^\d\s*][^·]{1,40})', caseSensitive: false);
  // Where a name stops: the date, a reference, the next sentence.
  static final _nameEnd = RegExp(r'(?:\s(?:on|at|ref|reference|بتاريخ|في|برقم|رقم|le|el|via|عبر)(?:\s|$)|(?<![\s.]\p{L})(?<!\.)\.(?=\s|$)|[،,;:](?:\s|$)|\s\d).*$', caseSensitive: false, unicode: true);
  // A message's "Label: value" line, and the labels that name who was paid.
  static final _fieldLabel = RegExp(r'^\s*\p{L}[\p{L}\s()/.-]{0,30}:\s*\S', unicode: true);
  static final _payeeField = RegExp(
    r'^\s*(?:merchant(?: name)?|payee|beneficiary|store|shop|اسم التاجر|التاجر|المتجر|لدى|المستفيد|marchand|commerçant|bénéficiaire|comercio|beneficiario)\s*:\s*(.+)$',
    caseSensitive: false,
  );
  // The figure a message gives after the transaction: the limit or the
  // balance left.
  static final _leftBefore = RegExp(
    r'(?:limit|balance|available|remaining|الرصيد|المتبقي|المتاح|الحد|المتوفر|solde|plafond|disponible|saldo|límite)[^\d]{0,20}$',
    caseSensitive: false,
  );
  static final _accountWords = RegExp(r'^(?:your\s)?(?:account|card|a/c|حساب|حسابك|بطاقة|بطاقتك|compte|cuenta)', caseSensitive: false);

  /// One message as its lines: the amount with a currency, the date, and
  /// who was paid (the merchant, else the person paid or paying).
  StatementRow? _message(List<String> lines) {
    if (lines.isEmpty) return null;
    final flat = lines.join(' ');
    _decideOrder([flat]);
    final (dates, dateSpans) = _dates(flat);
    final times = [for (final m in _time.allMatches(flat)) _Span(m.start, m.end)];
    final taken = [...dateSpans, ...times];
    final amounts = _amounts(flat, taken);
    if (amounts.isEmpty) return null;
    // The first amount with a currency is the transaction; a later one is
    // usually the balance or the limit left.
    bool left(_Found<_Money> a) => _leftBefore.hasMatch(flat.substring(math.max(0, a.span.start - 40), a.span.start));
    final main = amounts.where((a) => a.value.currency != null && !left(a)).firstOrNull ??
        amounts.where((a) => a.value.currency != null).firstOrNull ??
        amounts.first;
    var sign = main.value.sign;
    final guessed = sign == 0;
    if (guessed) sign = _incomeWords.hasMatch(flat) && !_spendWords.hasMatch(flat) ? 1 : -1;

    String name(RegExp re) {
      for (final m in re.allMatches(flat)) {
        final n = _clean(m[1]!.replaceAll(_nameEnd, ''));
        if (n.length >= 2 && !_accountWords.hasMatch(n)) return n;
      }
      return '';
    }

    var description = '';
    for (final l in lines) {
      final m = _payeeField.firstMatch(l);
      final n = m == null ? '' : _clean(m[1]!.replaceAll(_nameEnd, ''));
      if (n.length >= 2 && !_accountWords.hasMatch(n)) {
        description = n;
        break;
      }
    }
    if (description.isEmpty) description = name(_merchantAt);
    if (description.isEmpty) description = sign < 0 ? name(_paidTo) : name(_paidFrom);
    if (description.isEmpty) description = sign < 0 ? name(_paidFrom) : name(_paidTo);
    if (description.isEmpty) {
      final spans = [...taken, ...amounts.map((a) => a.span)]..sort((a, b) => a.start - b.start);
      final b = StringBuffer();
      var i = 0;
      for (final s in spans) {
        if (s.start > i) b.write(flat.substring(i, s.start));
        b.write(' · ');
        i = math.max(i, s.end);
      }
      if (i < flat.length) b.write(flat.substring(i));
      description = _clean(b.toString().split(' · ').firstWhere((p) => _clean(p).length >= 2, orElse: () => ''));
    }
    final date = dates.isEmpty ? null : dates.first.value;
    return StatementRow(
      date: date ?? DateTime(received.year, received.month, received.day),
      dateGuessed: date == null,
      description: description,
      detail: flat,
      amount: main.value.major * sign,
      signGuessed: guessed && !_spendWords.hasMatch(flat) && !_incomeWords.hasMatch(flat),
      currency: main.value.currency,
    );
  }

  // ---------------------------------------------------------- facts

  static final _openingLabel = RegExp(
    r'opening balance|beginning balance|starting balance|previous balance|balance brought forward|brought forward|'
    r'الرصيد الافتتاحي|رصيد افتتاحي|الرصيد السابق|رصيد أول المدة|رصيد اول المدة|الرصيد المرحل|'
    r'solde initial|solde précédent|solde precedent|ancien solde|saldo inicial|saldo anterior',
    caseSensitive: false,
  );
  static final _closingLabel = RegExp(
    r'closing balance|ending balance|end balance|new balance|current balance|balance carried forward|carried forward|statement balance|available balance|'
    r'الرصيد الختامي|رصيد ختامي|الرصيد الحالي|رصيد آخر المدة|رصيد اخر المدة|الرصيد المتاح|الرصيد المتوفر|الرصيد الجديد|'
    r'solde final|nouveau solde|solde actuel|saldo final|saldo actual|saldo disponible',
    caseSensitive: false,
  );
  /// What is still owed on a loan or card, when no closing balance is
  /// labelled.
  static final _outstandingLabel = RegExp(
    r'outstanding amount|outstanding balance|amount outstanding|remaining balance|'
    r'المبلغ المتبقي|الرصيد المتبقي|المبلغ المستحق المتبقي|montant restant|solde restant|saldo pendiente',
    caseSensitive: false,
  );
  // Miles and points have balances of their own.
  static final _rewards = RegExp(r'\bmiles\b|\bpoints\b|\brewards\b|أميال|نقاط|مكافآت|\bpuntos\b', caseSensitive: false);
  static final _available = RegExp(r'available|المتاح|المتوفر|disponible', caseSensitive: false);
  static final _from = RegExp(r'^(?:.*\s)?(?:from|du|desde|من)(?:\s|$)', caseSensitive: false);
  static final _to = RegExp(r'^(?:.*\s)?(?:to|au|hasta|إلى|الى)(?:\s|$)', caseSensitive: false);
  static final _periodLabel = RegExp(
    r'\bperiod\b|\bfrom\b.*\bto\b|statement date|الفترة|من تاريخ|للفترة|\bpériode\b|\bdu\b.*\bau\b|\bperíodo\b|\bdel\b.*\bal\b',
    caseSensitive: false,
  );
  static final _accountLabel = RegExp(
    r'account (?:no|number|#)|a/c (?:no|number)|acct|رقم الحساب|الحساب رقم|حساب رقم|numéro de compte|n° de compte|número de cuenta|cuenta n',
    caseSensitive: false,
  );
  static final _cardLabel = RegExp(r'card|بطاقة|بطاقتك|carte|tarjeta', caseSensitive: false);
  static final _iban = RegExp(r'\b([A-Z]{2}\d{2}(?:\s?[A-Z0-9]{4}){3,7}(?:\s?[A-Z0-9]{1,4})?)\b');
  // A masked number: stars or x's then its last digits, or the reverse as
  // right-to-left text sometimes comes out.
  static final _masked = RegExp(r'(?:[*xX•]{2,}[\s-]?(\d{4})(?!\d))|(?:(?<!\d)(\d{4})[*xX•]{4,})');
  static final _cardEnding = RegExp(r'(?:ending(?: in)?|ends with|#|رقم|المنتهية بـ?|المنتهية ب)\s*:?\s*(\d{4})(?!\d)', caseSensitive: false);
  static final _longNumber = RegExp(r'(?<![\d.,])\d{8,20}(?![\d.,])');

  static bool _validIban(String raw) {
    final s = raw.replaceAll(' ', '').toUpperCase();
    if (s.length < 15 || s.length > 34) return false;
    final moved = s.substring(4) + s.substring(0, 4);
    var rem = 0;
    for (final ch in moved.codeUnits) {
      final v = ch >= 65 ? ch - 55 : ch - 48;
      if (v < 0 || v > 35) return false;
      rem = int.parse('$rem$v') % 97;
    }
    return rem == 1;
  }

  /// The account or card a text names, as last four digits.
  List<StatementRef> _refs(String text, {bool cardContext = false}) {
    final out = <StatementRef>{};
    for (final m in _iban.allMatches(text.toUpperCase())) {
      final digits = m[1]!.replaceAll(RegExp(r'\D'), '');
      if (_validIban(m[1]!) && digits.length >= 4) out.add(StatementRef(StatementRefKind.iban, digits.substring(digits.length - 4), digits.length));
    }
    final card = cardContext || _cardLabel.hasMatch(text);
    final account = _accountLabel.hasMatch(text);
    for (final m in _masked.allMatches(text)) {
      out.add(StatementRef(card && !account ? StatementRefKind.card : StatementRefKind.account, m[1] ?? m[2]!));
    }
    if (card) {
      for (final m in _cardEnding.allMatches(text)) {
        out.add(StatementRef(StatementRefKind.card, m[1]!));
      }
    }
    if (account && out.isEmpty) {
      final i = _accountLabel.firstMatch(text)!.end;
      final m = _longNumber.firstMatch(text.substring(i).replaceAll(RegExp(r'(?<=\d)[\s-](?=\d)'), ''));
      if (m != null) out.add(StatementRef(StatementRefKind.account, m[0]!.substring(m[0]!.length - 4), m[0]!.length));
    }
    return out.toList();
  }

  /// The figure a label names: on its own line after it, else just under it.
  double? _labelled(List<_Line> lines, int i, RegExp label) {
    final line = lines[i];
    final text = normalize(line.text);
    final m = label.firstMatch(text);
    if (m == null) return null;
    double signed(_Found<_Money> a) => a.value.major * (a.value.sign < 0 ? -1 : 1);
    // Text up to the next label ("Days: 31") is this label's.
    String upToLabel(String s) {
      final next = RegExp(r'\p{L}[\p{L} ]{2,}:', unicode: true).firstMatch(s);
      return next == null ? s : s.substring(0, next.start);
    }

    final at = line.cells.indexWhere((c) => label.hasMatch(normalize(c.text)));
    if (at >= 0) {
      // In the label's own text the value follows it.
      final own = normalize(line.cells[at].text);
      final after = upToLabel(own.substring(label.firstMatch(own)!.end));
      final here = _amounts(after, _dates(after).$2, loose: true);
      if (here.isNotEmpty) return signed(here.first);
      // Beside it: to the right of a left-to-right label, to the left of
      // an Arabic one, up to the next label.
      final rtl = RegExp(r'[\u0600-\u06FF]').hasMatch(label.firstMatch(own)![0]!);
      final order = rtl ? [for (var j = at - 1; j >= 0; j--) j] : [for (var j = at + 1; j < line.cells.length; j++) j];
      for (final j in order) {
        final t = normalize(line.cells[j].text);
        final found = _amounts(t, _dates(t).$2, loose: true);
        if (found.isNotEmpty) return signed(rtl ? found.last : found.first);
        if (RegExp(r'\p{L}{2,}', unicode: true).hasMatch(t)) break;
      }
    } else {
      final after = upToLabel(text.substring(m.end));
      final here = _amounts(after, _dates(after).$2, loose: true);
      if (here.isNotEmpty) return signed(here.first);
    }
    // A label over its value (summary boxes).
    if (i + 1 < lines.length) {
      final below = lines[i + 1];
      if (below.top - line.bottom < line.height * 1.5) {
        // Where in its cell the label and each figure sit: a summary box
        // can come out as one wide cell of six labels over one of six
        // figures.
        (double, double) extent(DocToken cell, String text, int start, int end) {
          final n = math.max(text.length, 1);
          return (cell.x + cell.w * start / n, cell.x + cell.w * end / n);
        }
        final labelCell = line.cells.firstWhere((c) => label.hasMatch(normalize(c.text)), orElse: () => line.cells.first);
        final labelText = normalize(labelCell.text);
        final lm = label.firstMatch(labelText);
        final (l0, l1) = lm == null ? (labelCell.x, labelCell.x + labelCell.w) : extent(labelCell, labelText, lm.start, lm.end);
        // A figure under the label overlaps it across the page, however
        // wide it is (a banking app prints the balance large under a small
        // label); among those, and failing that, the nearest middle wins.
        _Found<_Money>? best;
        var bestD = double.infinity;
        for (final c in below.cells) {
          final t = normalize(c.text);
          for (final a in _amounts(t, _dates(t).$2, loose: true)) {
            final (f0, f1) = extent(c, t, a.span.start, a.span.end);
            final apart = ((f0 + f1) - (l0 + l1)).abs() / 2;
            final overlaps = f0 < l1 && l0 < f1;
            final d = overlaps ? apart : 1 + apart;
            if (d < bestD && (overlaps || apart < 0.2)) {
              bestD = d;
              best = a;
            }
          }
        }
        if (best != null) return best.value.major * (best.value.sign < 0 ? -1 : 1);
      }
    }
    return null;
  }

  /// Everything a document gives: its rows and what it says about itself,
  /// each checked against the other. Use this rather than [readPages] and
  /// [facts] apart.
  (List<StatementRow>, StatementFacts) read(List<DocPage> pages) {
    var rows = readPages(pages);
    // A banking app's account screen shows the balance large at its top;
    // that figure is the balance its labels give, not a transaction, and
    // the screen is no receipt.
    final hasTable = pages.any((p) => _lines(p.tokens).any((l) => _header(l) != null));
    final shown = hasTable ? null : this.facts(pages, const []).closing;
    final headline = shown == null ? const <StatementRow>[] : rows.where((r) => r.dateGuessed && _same(r.amount.abs(), shown.abs())).toList();
    if (headline.isNotEmpty) rows = [for (final r in rows) if (!headline.contains(r)) r];
    // A receipt, a bill or a transfer confirmation: one transaction.
    final single = headline.isEmpty && rows.length <= 2 && rows.map((r) => _dayKey(r.date)).toSet().length <= 1 ? _receipt(pages) : null;
    // Only when the rows found are that one transaction read in pieces; a
    // short list with a "Total" line under it keeps its rows.
    if (single != null && (rows.isEmpty || rows.any((r) => _same(r.amount.abs(), single.$1.single.amount.abs())))) return single;
    var facts = this.facts(pages, rows);
    final settled = _lastFromClosing(rows, facts);
    if (!identical(settled, rows)) {
      rows = settled;
      facts = this.facts(pages, rows);
    }
    // A balance with no transactions and no period (a loan's screen) is
    // the balance on the day the document was received.
    if (rows.isEmpty && facts.closing != null && facts.to == null) {
      facts = facts.copyWith(to: DateTime(received.year, received.month, received.day));
    }
    return (rows, facts);
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  // Labels of the figure a receipt or bill comes to, strongest first.
  static final _totalLabels = [
    RegExp(
      r'total amount|grand total|amount due|total due|total to pay|amount payable|net amount|'
      r'المبلغ الإجمالي|المبلغ الاجمالي|إجمالي الفاتورة|اجمالي الفاتورة|المبلغ المطلوب سداده|المبلغ المستحق|الإجمالي المستحق|'
      r'montant total|total à payer|montant dû|importe total|total a pagar',
      caseSensitive: false,
    ),
    RegExp(r'^\s*total\b|\btotal\s*:|amount including vat|المبلغ شامل الضريبة|الإجمالي\s*:|^\s*الإجمالي|^\s*total\b', caseSensitive: false),
    RegExp(r'debit amount|amount paid|paid amount|مبلغ الخصم|المبلغ المدفوع|montant débité|importe cargado', caseSensitive: false),
  ];
  // What says a document is one transaction, not a list of them.
  static final _receiptWords = RegExp(
    r'\b(?:receipt|invoice|bill|transfer|payment|purchase|transaction details|order)\b|'
    r'فاتورة|إيصال|ايصال|حوالة|تحويل|سداد|شراء|تفاصيل العملية|'
    r'\b(?:reçu|facture|virement|paiement|recibo|factura|transferencia|pago)\b',
    caseSensitive: false,
  );
  // A title that says only what kind of paper it is ("Simplified tax invoice").
  static final _genericTitle = RegExp(
    r'^(?:simplified|tax|vat|invoice|receipt|bill|e-?receipt|فاتورة|ضريبية|مبسطة|إيصال|ايصال|facture|reçu|factura|recibo|\s)+$',
    caseSensitive: false,
  );
  static final _dateLabels = [
    RegExp(
      r'invoice date|transaction date|date (?:&|and) time|payment date|purchase date|issue date|'
      r'تاريخ الفاتورة|التاريخ والوقت|تاريخ العملية|تاريخ الدفع|تاريخ الإصدار|date de facture|date de l.opération|fecha de factura|fecha de la operación',
      caseSensitive: false,
    ),
    RegExp(r'\bdate\b|التاريخ|تاريخ|fecha', caseSensitive: false),
  ];
  static final _fromLabel = RegExp(r'^\s*(?:from|من)\b|\bfrom account\b|من حساب|\bdu compte\b|\bdesde\b', caseSensitive: false);
  static final _creditOnly = RegExp(r'credit amount|amount received|deposit|مبلغ الإيداع|إيداع|crédit|abono', caseSensitive: false);

  /// One transaction read from a receipt, a bill or a transfer
  /// confirmation: the figure it comes to, its date, what it was for, and
  /// the account it was paid from. Null when the document is not one.
  (List<StatementRow>, StatementFacts)? _receipt(List<DocPage> pages) {
    final lines = [for (final p in pages) ..._lines(p.tokens)];
    final texts = [for (final l in lines) normalize(l.text)];
    if (!texts.any(_receiptWords.hasMatch)) return null;

    // A bill repeats its total (on each page, in each language); a figure
    // misread beside one label is outvoted by the others.
    double? total;
    int? totalLine;
    String? totalCurrency;
    for (final label in _totalLabels) {
      final votes = <double, List<int>>{};
      for (var i = 0; i < lines.length; i++) {
        if (!label.hasMatch(texts[i])) continue;
        final v = _labelled(lines, i, label);
        if (v != null && v != 0) (votes[v.abs()] ??= []).add(i);
      }
      if (votes.isEmpty) continue;
      final best = votes.entries.reduce((a, b) => b.value.length > a.value.length ? b : a);
      total = best.key;
      totalLine = best.value.first;
      totalCurrency = _currencyIn(texts[totalLine]);
      break;
    }
    if (total == null || totalLine == null) return null;

    DateTime? date;
    for (final label in _dateLabels) {
      for (var i = 0; i < lines.length && date == null; i++) {
        final m = label.firstMatch(texts[i]);
        if (m == null) continue;
        // The date beside its label, not another one on the same line.
        final here = _dates(texts[i]).$1.where((d) => !d.hijri).toList();
        final after = here.where((d) => d.span.start >= m.end);
        final before = here.where((d) => d.span.end <= m.start);
        if (after.isNotEmpty) {
          date = after.first.value;
        } else if (before.isNotEmpty) {
          date = before.last.value;
        } else if (i + 1 < lines.length) {
          final below = _dates(texts[i + 1]).$1.where((d) => !d.hijri);
          if (below.isNotEmpty) date = below.first.value;
        }
      }
      if (date != null) break;
    }
    date ??= [for (final t in texts) ..._dates(t).$1.where((d) => !d.hijri).map((d) => d.value)].firstOrNull;

    // What it was for: the first line naming a kind of transaction, with
    // the line under it when it only says "tax invoice".
    var title = '';
    for (var i = 0; i < texts.length; i++) {
      // "Transaction details" heads the page; it names nothing.
      final text = texts[i].replaceAll(RegExp(r'transaction details|تفاصيل العملية', caseSensitive: false), '');
      if (!_receiptWords.hasMatch(text) || RegExp(r'\d{3,}').hasMatch(text)) continue;
      title = _clean(text);
      if (title.isEmpty) continue;
      if (_genericTitle.hasMatch(title) && i + 1 < texts.length && !RegExp(r'\d').hasMatch(texts[i + 1])) {
        title = '$title ${_clean(texts[i + 1])}';
      }
      break;
    }
    // Text in two scripts says the same thing twice: keep the first.
    final halves = RegExp(r'^([^\u0600-\u06FF]*[A-Za-z][^\u0600-\u06FF]*?)\s+([\u0600-\u06FF].*)$').firstMatch(title);
    final description = halves == null ? title : halves[1]!.trim();
    final detail = halves == null ? '' : halves[2]!.trim();

    // The account it was paid from.
    final refs = <StatementRef>[];
    for (var i = 0; i < texts.length && refs.isEmpty; i++) {
      if (!_fromLabel.hasMatch(texts[i])) continue;
      for (final t in texts.skip(i).take(3)) {
        final number = RegExp(r'(?<![\d.,])\d{8,20}(?![\d.,])').firstMatch(t.replaceAll(RegExp(r'(?<=\d)[\s-](?=\d)'), ''));
        final ref = _refs(t, cardContext: _cardLabel.hasMatch(t));
        if (ref.isNotEmpty) {
          refs.addAll(ref);
        } else if (number != null) {
          refs.add(StatementRef(StatementRefKind.account, number[0]!.substring(number[0]!.length - 4), number[0]!.length));
        }
        if (refs.isNotEmpty) break;
      }
    }

    final moneyIn = texts.any(_creditOnly.hasMatch) && !texts.any((t) => _totalLabels.last.hasMatch(t) || RegExp(r'invoice|bill|فاتورة|facture|factura', caseSensitive: false).hasMatch(t));
    final currency = totalCurrency ?? texts.map((t) => _currencyLabel.hasMatch(t) ? _currencyIn(t) : null).nonNulls.firstOrNull;
    final row = StatementRow(
      date: date ?? DateTime(received.year, received.month, received.day),
      dateGuessed: date == null,
      description: description,
      detail: detail,
      amount: moneyIn ? total : -total,
      signGuessed: !moneyIn && !texts.any((t) => _totalLabels.last.hasMatch(t) || RegExp(r'invoice|bill|فاتورة|purchase|شراء|facture|factura', caseSensitive: false).hasMatch(t)),
      currency: currency,
      line: totalLine,
    );
    return ([row], StatementFacts(refs: refs, currency: currency));
  }

  /// The newest row, when its only figure was read as the amount but is the
  /// closing balance the statement prints: its amount is the change from
  /// the row before it.
  static List<StatementRow> _lastFromClosing(List<StatementRow> rows, StatementFacts facts) {
    final closing = facts.closing;
    if (closing == null || facts.closingWorkedOut || rows.length < 2) return rows;
    final oldestFirst = !rows.first.date.isAfter(rows.last.date);
    final i = oldestFirst ? rows.length - 1 : 0;
    final before = rows[oldestFirst ? i - 1 : 1];
    final r = rows[i];
    if (r.balance != null || before.balance == null || !_same(r.amount.abs(), closing.abs())) return rows;
    final amount = ((closing - before.balance!) * 1000).round() / 1000;
    if (amount == 0) return rows;
    return [...rows]..[i] = r.copyWith(amount: amount, balance: closing, signGuessed: false);
  }

  /// The statement's balances, account and period, read from its pages.
  StatementFacts facts(List<DocPage> pages, List<StatementRow> rows) {
    double? opening, closing, outstanding;
    var available = false;
    // Every closing figure read, as each page repeats it.
    final closings = <(double, bool)>[];
    final refs = <StatementRef>{};
    int? tableStart;
    DateTime? from, to, firstSeen, lastSeen;
    String? currency;
    // The table: card numbers in a row's details (a card payment) are not
    // the statement's own account.
    final rowLines = [for (final r in rows) ?r.line];
    final firstRow = rowLines.isEmpty ? null : rowLines.reduce(math.min);
    final lastRow = rowLines.isEmpty ? null : rowLines.reduce(math.max);
    var base = 0;
    for (final page in pages) {
      final lines = _lines(page.tokens);
      for (var i = 0; i < lines.length; i++) {
        final at = base + i;
        final text = normalize(lines[i].text);
        // The first opening and the last closing balance: a multi-page
        // statement repeats them per page.
        if (tableStart == null && _header(lines[i]) != null) tableStart = at;
        if (_openingLabel.hasMatch(text) && !_rewards.hasMatch(text)) opening ??= _labelled(lines, i, _openingLabel);
        if (_outstandingLabel.hasMatch(text)) outstanding ??= _labelled(lines, i, _outstandingLabel);
        if (_closingLabel.hasMatch(text) && !_rewards.hasMatch(text)) {
          final v = _labelled(lines, i, _closingLabel);
          if (v != null) {
            closing = v;
            available = _available.hasMatch(_closingLabel.firstMatch(text)![0]!);
            closings.add((v, available));
          }
        }
        // From the table's header down: a transfer's details name the
        // other side's account.
        final start = tableStart ?? firstRow;
        final inTable = start != null && lastRow != null && at >= start && at <= lastRow;
        if (!inTable) refs.addAll(_refs(text));
        if (currency == null && _currencyLabel.hasMatch(text) && !_foreignLabel.hasMatch(text)) currency = _currencyIn(text);
        final (ds, spans) = _dates(text);
        // Two dates and no money: a row with a value date is not the period.
        final dated = ds.where((d) => !d.hijri).map((d) => d.value).toList();
        final money = _amounts(text, spans).where((a) => !a.value.bare);
        if (from == null && dated.length == 1 && money.isEmpty && _from.hasMatch(text)) {
          // "From 16/06/2026" over "To 15/09/2026".
          for (final next in lines.skip(i + 1).take(2)) {
            final t = normalize(next.text);
            final until = _dates(t).$1.where((d) => !d.hijri).toList();
            if (_to.hasMatch(t) && until.length == 1 && until.first.value.isAfter(dated.first)) {
              from = dated.first;
              to = until.first.value;
              break;
            }
          }
        }
        if (dated.length < 2 || money.isNotEmpty) continue;
        if (from == null && _periodLabel.hasMatch(text)) {
          from = dated.first;
          to = dated.last;
        } else if (firstSeen == null && (firstRow == null || at < firstRow)) {
          // Dates side by side above the table, often under "Date" labels.
          final sorted = [...dated]..sort();
          if (sorted.last.difference(sorted.first).inDays.abs() <= 400 && sorted.first != sorted.last) {
            firstSeen = sorted.first;
            lastSeen = sorted.last;
          }
        }
      }
      base += lines.length;
    }
    from ??= firstSeen;
    to ??= lastSeen;
    // Pages that print different closing figures (one page's text placed
    // wrongly): the one the opening balance and the rows add up to.
    if (opening != null && closings.map((c) => c.$1).toSet().length > 1) {
      for (final (v, avail) in closings) {
        if (Reconciliation.of(StatementFacts(opening: opening, closing: v), rows)?.addsUp ?? false) {
          closing = v;
          available = avail;
          break;
        }
      }
    }
    // A card's own number also shows as an account number: one card.
    final cards = {for (final r in refs) if (r.kind == StatementRefKind.card) r.last4};
    refs.removeWhere((r) => r.kind == StatementRefKind.account && cards.contains(r.last4));
    return _withWorkedOut(
        StatementFacts(
          opening: opening,
          closing: closing ?? outstanding,
          closingAvailable: closing != null && available,
          refs: refs.toList(),
          from: from,
          to: to,
          currency: _currencyOfRows(rows) ?? currency,
        ),
        rows);
  }

  static final _currencyLabel = RegExp(r'currency|العملة|devise|moneda', caseSensitive: false);
  static final _foreignLabel = RegExp(r'foreign|exchange|الأجنبية|الاجنبية|تحويل العملة|étrangère|change|extranjera|cambio', caseSensitive: false);

  /// The currency a line names, word by word ("ريال سعودي", "SAR").
  static String? _currencyIn(String text) {
    for (final w in text.toLowerCase().split(RegExp(r'[\s\-–/,:()&]+'))) {
      final c = _currencyOf(w);
      if (c != null) return c;
    }
    return null;
  }

  /// What a bank message says: the account or card, and the balance after.
  StatementFacts messageFacts(String text, List<StatementRow> rows) {
    final t = normalize(text);
    final refs = _refs(t);
    double? closing;
    final m = _closingLabel.firstMatch(t);
    if (m != null) {
      final after = t.substring(m.end);
      final found = _amounts(after, _dates(after).$2);
      if (found.isNotEmpty) closing = found.first.value.major;
    }
    return StatementFacts(
        closing: closing, closingAvailable: m != null && _available.hasMatch(m[0]!), refs: refs, currency: _currencyOfRows(rows));
  }

  static String? _currencyOfRows(List<StatementRow> rows) {
    final counts = <String, int>{};
    for (final r in rows) {
      if (r.currency != null) counts[r.currency!] = (counts[r.currency!] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    final top = (counts.entries.toList()..sort((a, b) => b.value - a.value)).first;
    return top.value * 2 >= rows.length ? top.key : null;
  }

  /// Balances the statement doesn't print but its running balance shows:
  /// the oldest row's balance before it, and the newest row's after it.
  StatementFacts _withWorkedOut(StatementFacts f, List<StatementRow> rows) {
    final withBalance = rows.where((r) => r.balance != null).toList();
    if (withBalance.length < 2) return f;
    final newestFirst = withBalance.first.date.isAfter(withBalance.last.date);
    final oldest = newestFirst ? withBalance.last : withBalance.first;
    final newest = newestFirst ? withBalance.first : withBalance.last;
    var out = f;
    if (out.opening == null) out = out.copyWith(opening: oldest.balance! - oldest.amount, openingWorkedOut: true);
    if (out.closing == null) out = out.copyWith(closing: newest.balance, closingWorkedOut: true);
    return out;
  }

  // ---------------------------------------------------------- the model

  /// The document's lines as the reader sees them, for the on-device model;
  /// [StatementRow.line] indexes into them.
  List<String> lineTexts(List<DocPage> pages) => [
        for (final p in pages)
          for (final l in _lines(p.tokens)) normalize(l.text),
      ];

  /// What the on-device model adds to a reading: rows on lines it reads as
  /// the bank's own text are marked doubtful (kept, unticked), names it
  /// copied from a line replace the reader's, and balances or an account
  /// the reader missed are read, by this code, from the lines it points at.
  /// The on-device model's reading of each page ([structures], word
  /// indexes into [pages]) against the rules' [rows] and [facts]:
  ///
  /// - Every figure comes from a word the model pointed at; a pointer to a
  ///   word with no figure in it drops the model's whole reading.
  /// - The model's rows are kept only when the numbers back them at least
  ///   as well as the rules' rows (the statement adds up, the running
  ///   balance links the rows) and none are lost.
  /// - Otherwise the rules' rows stay, taking the model's name for a row
  ///   whose own name came out unreadable, when both readings have the same
  ///   rows with the same amounts.
  (List<StatementRow>, StatementFacts) withStructure(
      List<DocPage> pages, List<StatementRow> rows, StatementFacts facts, List<PageStructure> structures) {
    final read = _fromStructure(pages, structures);
    if (read == null) return (rows, facts);
    final (found, opening, closing) = read;
    final modelFacts = facts.copyWith(opening: facts.opening ?? opening, closing: facts.closing ?? closing);
    final modelRows = _signFromOpening(found, modelFacts.opening);
    if (modelRows.isNotEmpty && modelRows.length >= rows.length && _score(modelRows, modelFacts) >= _score(rows, facts)) {
      return (modelRows, _withWorkedOut(modelFacts, modelRows));
    }
    final sameRows = modelRows.length == rows.length &&
        [for (var i = 0; i < rows.length; i++) _same(rows[i].amount.abs(), modelRows[i].amount.abs())].every((x) => x);
    if (!sameRows) return (rows, facts);
    return (
      [
        for (var i = 0; i < rows.length; i++)
          _unreadable(rows[i].description) && modelRows[i].description.isNotEmpty ? rows[i].copyWith(description: modelRows[i].description) : rows[i],
      ],
      facts
    );
  }

  /// The oldest row's direction from the opening balance, when the running
  /// balance has no earlier row to go by. Rows run oldest or newest first.
  static List<StatementRow> _signFromOpening(List<StatementRow> rows, double? opening) {
    if (opening == null || rows.isEmpty) return rows;
    final (forward, backward) = _balanceFits(rows);
    final i = backward > forward ? rows.length - 1 : 0;
    final r = rows[i];
    if (!r.signGuessed || r.balance == null) return rows;
    final change = r.balance! - opening;
    if (!_same(change.abs(), r.amount.abs()) || change == 0) return rows;
    return [...rows]..[i] = r.copyWith(amount: r.amount.abs() * change.sign, signGuessed: false);
  }

  /// A name with no word in it, or more dots than letters (a mask).
  static bool _unreadable(String name) {
    final letters = RegExp(r'\p{L}', unicode: true).allMatches(name).length;
    return !RegExp(r'\p{L}{2,}', unicode: true).hasMatch(name) || '.'.allMatches(name).length >= letters;
  }

  /// How well the numbers back a reading: the statement adding up counts
  /// most, then each pair of rows the running balance links, then each row
  /// whose direction and date were read rather than guessed.
  static int _score(List<StatementRow> rows, StatementFacts facts) {
    final (forward, backward) = _balanceFits(rows);
    return ((Reconciliation.of(facts, rows)?.addsUp ?? false) ? 100000 : 0) +
        math.max(forward, backward) * 100 +
        rows.where((r) => !r.signGuessed).length +
        rows.where((r) => !r.dateGuessed).length;
  }

  /// Rows, and the opening and closing figures, from the words the model
  /// pointed at. Null when it pointed at a word that holds no figure.
  (List<StatementRow>, double?, double?)? _fromStructure(List<DocPage> pages, List<PageStructure> structures) {
    final out = <StatementRow>[];
    double? opening, closing;
    var base = 0;
    for (var p = 0; p < pages.length && p < structures.length; p++) {
      final tokens = pages[p].tokens;
      final lines = _lines(tokens);
      final s = structures[p];
      String? word(int? id) => id == null || id >= tokens.length ? null : normalize(tokens[id].text);
      List<_Found<_Money>>? figures(int? id) {
        final t = word(id);
        if (t == null) return null;
        final found = _amounts(t, _dates(t).$2, loose: true);
        return found.isEmpty ? null : found;
      }

      int? lineOf(int? id) {
        if (id == null || id >= tokens.length) return null;
        final i = lines.indexWhere((l) => l.cells.contains(tokens[id]));
        return i < 0 ? null : base + i;
      }

      for (final r in s.rows) {
        final amounts = figures(r.amount);
        if (amounts == null) return null;
        final money = amounts.first.value;
        final balanceFigures = r.balance == null ? null : figures(r.balance);
        if (r.balance != null && balanceFigures == null) return null;
        // The balance shares the amount's word when the two were read as one.
        final balanceMoney = balanceFigures == null ? null : (r.balance == r.amount ? (balanceFigures.length > 1 ? balanceFigures.last.value : null) : balanceFigures.last.value);
        final dateText = word(r.date);
        final date = dateText == null ? null : _dates(dateText).$1.where((d) => !d.hijri).firstOrNull?.value;
        var sign = money.sign;
        if (sign == 0) {
          final cue = [for (final id in r.direction) ?word(id)].join(' ').toLowerCase();
          if (RegExp(r'\bcr\b|\+|credit|deposit|دائن|إيداع|ايداع|crédit|abono').hasMatch(cue)) sign = 1;
          if (RegExp(r'\bdr\b|(?:^|\s)-|debit|withdrawal|مدين|سحب|خصم|débit|cargo').hasMatch(cue)) sign = -1;
        }
        out.add(StatementRow(
          date: date ?? DateTime(received.year, received.month, received.day),
          dateGuessed: date == null,
          description: r.name,
          amount: money.major * (sign == 0 ? -1 : sign),
          signGuessed: sign == 0,
          currency: money.currency,
          balance: balanceMoney == null ? null : balanceMoney.major * (balanceMoney.sign == 0 ? 1 : balanceMoney.sign),
          line: lineOf(r.amount),
        ));
      }
      if (s.opening != null) {
        final f = figures(s.opening);
        if (f == null) return null;
        opening ??= f.last.value.major * (f.last.value.sign < 0 ? -1 : 1);
      }
      if (s.closing != null) {
        final f = figures(s.closing);
        if (f == null) return null;
        closing = f.last.value.major * (f.last.value.sign < 0 ? -1 : 1);
      }
      base += lines.length;
    }
    return (_signsFromMarkers(_signsFromBalances(_withDocumentCurrency(out))), opening, closing);
  }

  (List<StatementRow>, StatementFacts) withLabels(List<StatementRow> rows, StatementFacts facts, List<String> lines, List<LineLabel> labels) {
    final byLine = {for (final l in labels) if (l.line >= 0 && l.line < lines.length) l.line: l};
    StatementRow labelled(StatementRow r) {
      final label = r.line == null ? null : byLine[r.line];
      if (label == null) return r;
      // A balance line or the account number read as a row is kept, flagged.
      return label.kind == LineKind.transaction ? _named(r, label.name, lines[label.line]) : r.copyWith(doubtful: true);
    }

    final out = rows.map(labelled).toList();
    var f = facts;
    for (final l in byLine.values) {
      final text = lines[l.line];
      double? figure() {
        final found = _amounts(text, _dates(text).$2);
        return found.isEmpty ? null : found.last.value.major * (found.last.value.sign < 0 ? -1 : 1);
      }

      switch (l.kind) {
        case LineKind.opening when f.opening == null || f.openingWorkedOut:
          final v = figure();
          if (v != null) f = f.copyWith(opening: v, openingWorkedOut: false);
        case LineKind.closing when f.closing == null || f.closingWorkedOut:
          final v = figure();
          if (v != null) f = f.copyWith(closing: v, closingWorkedOut: false, closingAvailable: _available.hasMatch(text));
        case LineKind.account when f.refs.isEmpty:
          final digits = RegExp(r'\d[\d\s-]{3,}\d').allMatches(text).map((m) => m[0]!.replaceAll(RegExp(r'\D'), '')).where((d) => d.length >= 4).toList()
            ..sort((a, b) => b.length - a.length);
          final refs = _refs(text);
          if (refs.isNotEmpty) {
            f = f.copyWith(refs: refs);
          } else if (digits.isNotEmpty) {
            f = f.copyWith(refs: [
              StatementRef(_cardLabel.hasMatch(text) ? StatementRefKind.card : StatementRefKind.account, digits.first.substring(digits.first.length - 4), digits.first.length)
            ]);
          }
        default:
          break;
      }
    }
    return (out, f);
  }

  /// A row named by the model, when its words are on the line and aren't
  /// a figure.
  StatementRow _named(StatementRow r, String name, String line) {
    final clean = _clean(name);
    if (clean.length < 2 || !line.toLowerCase().contains(name.toLowerCase())) return r;
    if (_amounts(clean, const []).isNotEmpty || RegExp(r'^[\d\s.,/-]+$').hasMatch(clean)) return r;
    return r.copyWith(description: clean);
  }
}
