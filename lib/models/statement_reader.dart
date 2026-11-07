import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'minor_units.dart';

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

  const StatementRow({
    required this.date,
    required this.description,
    required this.amount,
    this.dateGuessed = false,
    this.detail = '',
    this.signGuessed = false,
    this.currency,
    this.balance,
  });

  bool get isIn => amount > 0;

  StatementRow copyWith({double? amount, bool? signGuessed, String? currency}) => StatementRow(
        date: date,
        description: description,
        amount: amount ?? this.amount,
        dateGuessed: dateGuessed,
        detail: detail,
        signGuessed: signGuessed ?? this.signGuessed,
        currency: currency ?? this.currency,
        balance: balance,
      );

  @override
  List<Object?> get props => [date, dateGuessed, description, detail, amount, signGuessed, currency, balance];

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
  const _Found(this.value, this.span, this.x);
}

class _Money {
  final double major;

  /// -1 out, 1 in, 0 not said.
  final int sign;
  final String? currency;
  const _Money(this.major, this.sign, this.currency);
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
      b.write(_digitMap[ch] ?? ch);
    }
    return b.toString();
  }

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
  static final _relative = RegExp(r"(?<![\p{L}])(today|yesterday|اليوم|أمس|امس|aujourd'hui|aujourd’hui|hier|hoy|ayer)(?![\p{L}])", caseSensitive: false, unicode: true);
  static final _time = RegExp(r'(?<!\d)\d{1,2}:\d{2}(?::\d{2})?(?:\s?(?:am|pm|ص|م))?(?![\d])', caseSensitive: false);

  // Money.
  static const Map<String, String> _currencyWords = {
    'sar': 'SAR', 'sr': 'SAR', 'ر.س': 'SAR', 'ر س': 'SAR', 'ريال': 'SAR', 'رس': 'SAR', '﷼': 'SAR', //
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
    _Column.description: ['description', 'details', 'narrative', 'particulars', 'merchant', 'transaction', 'البيان', 'الوصف', 'التفاصيل', 'تفاصيل', 'العملية', 'libellé', 'libelle', 'concepto', 'descripción', 'descripcion'],
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

  DateTime? _day(int y, int m, int d) {
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final date = DateTime(y, m, d);
    return date.month == m ? date : null;
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

  List<_Found<DateTime>> _dates(String text) {
    final out = <_Found<DateTime>>[];
    final taken = <_Span>[];
    bool free(int s, int e) => !taken.any((t) => s < t.end && e > t.start);
    void take(RegExpMatch m, DateTime? d) {
      if (d == null || !free(m.start, m.end)) return;
      final span = _Span(m.start, m.end);
      taken.add(span);
      out.add(_Found(d, span, 0));
    }

    for (final m in _isoDate.allMatches(text)) {
      take(m, _day(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!)));
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
      take(m, _day(_year(m[3], mo, d), mo, d));
    }
    for (final m in _relative.allMatches(text)) {
      final w = m[1]!.toLowerCase();
      final today = DateTime(received.year, received.month, received.day);
      final isToday = const {'today', 'اليوم', "aujourd'hui", 'aujourd’hui', 'hoy'}.contains(w);
      take(m, isToday ? today : today.subtract(const Duration(days: 1)));
    }
    out.sort((a, b) => a.span.start - b.span.start);
    return out;
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
      if (!loose && ccy == null && !hasDecimals && !grouped) continue;
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
      out.add(_Found(_Money(value, sign, ccy), _Span(m.start, m.end), 0));
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
    final found = <_Column, double>{};
    for (final c in line.cells) {
      final t = normalize(c.text).toLowerCase().trim();
      for (final e in _headerWords.entries) {
        if (found.containsKey(e.key)) continue;
        if (e.value.any((w) => t == w || (w.length > 3 && t.split(RegExp(r'\s*[/(]\s*')).any((p) => p.trim() == w)))) {
          found[e.key] = c.x + c.w / 2;
          break;
        }
      }
    }
    final money = found.keys.where((k) => k == _Column.debit || k == _Column.credit || k == _Column.amount || k == _Column.balance);
    return found.length >= 2 && money.isNotEmpty ? found : null;
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
      .replaceAll(RegExp(r'[|•·]+'), ' ')
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
    DateTime? sectionDate;
    String pendingText = '';
    double? pendingBottom;

    for (final lines in allLines) {
      sectionDate = null;
      for (final line in lines) {
        final h = _header(line);
        if (h != null) {
          header = h;
          pendingText = '';
          continue;
        }

        // Per cell: dates, amounts, and what's left as words.
        final dates = <_Found<DateTime>>[];
        final amounts = <(_Found<_Money>, _Column?)>[];
        final words = <String>[];
        String? lineCurrency;
        for (final cell in line.cells) {
          final text = normalize(cell.text);
          final column = header == null ? null : _columnAt(header, cell.x + cell.w / 2);
          final ds = _dates(text);
          final times = [for (final m in _time.allMatches(text)) _Span(m.start, m.end)];
          final taken = [...ds.map((d) => d.span), ...times];
          final moneyColumn = column == _Column.debit || column == _Column.credit || column == _Column.amount || column == _Column.balance;
          final ams = _amounts(text, taken, loose: moneyColumn);
          for (final d in ds) {
            dates.add(d);
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

        if (_skipWords.hasMatch(description)) {
          pendingText = '';
          continue;
        }

        if (amounts.isEmpty) {
          if (dates.isNotEmpty && description.length < 3) {
            // A date on its own heads a group of rows (banking apps).
            sectionDate = dates.first.value;
            pendingText = '';
          } else if (description.isNotEmpty) {
            final prev = rowLines.isEmpty ? null : rowLines.last;
            final under = prev != null && rows.isNotEmpty && line.top - prev.bottom < prev.height * 1.2 && line.top > prev.top;
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
              ));
              rowLines.last = line;
            } else {
              pendingText = description;
              pendingBottom = line.bottom;
              if (dates.isNotEmpty) sectionDate = dates.first.value;
            }
          }
          continue;
        }

        // Which figure is the transaction and which the balance.
        double? balance;
        _Money? money;
        var sign = 0;
        final byColumn = header != null && amounts.any((a) => a.$2 != null);
        if (byColumn) {
          for (final (a, col) in amounts) {
            switch (col) {
              case _Column.balance:
                balance = a.value.major * (a.value.sign == 0 ? 1 : a.value.sign);
              case _Column.debit:
                money ??= a.value;
                sign = -1;
              case _Column.credit:
                money ??= a.value;
                sign = 1;
              case _Column.amount:
              case null:
                if (money == null) {
                  money = a.value;
                  sign = a.value.sign;
                }
              default:
                break;
            }
          }
        } else {
          final list = [for (final a in amounts) a.$1.value];
          money = list.first;
          sign = money.sign;
          if (list.length >= 2) {
            final last = list.last;
            balance = last.major * (last.sign == 0 ? 1 : last.sign);
          }
        }
        if (money == null) continue;

        var text = description;
        if (text.isEmpty && pendingText.isNotEmpty && pendingBottom != null && line.top - pendingBottom < line.height * 2.5) {
          text = pendingText;
        } else if (text.isEmpty && pendingText.isNotEmpty) {
          text = pendingText;
        }
        pendingText = '';

        var signGuessed = false;
        if (sign == 0) {
          signGuessed = true;
          sign = _incomeWords.hasMatch(text) && !_spendWords.hasMatch(text) ? 1 : -1;
        }
        final ccy = money.currency ?? lineCurrency;
        final date = dates.isNotEmpty ? dates.first.value : sectionDate;
        rows.add(StatementRow(
          date: date ?? DateTime(received.year, received.month, received.day),
          dateGuessed: date == null,
          description: text,
          amount: money.major * sign,
          signGuessed: signGuessed,
          currency: ccy,
          balance: balance,
        ));
        rowLines.add(line);
      }
    }
    return _signsFromBalances(_withDocumentCurrency(rows));
  }

  /// Rows without their own currency take the one the rest of the document
  /// uses, when it uses one.
  List<StatementRow> _withDocumentCurrency(List<StatementRow> rows) {
    final counts = <String, int>{};
    for (final r in rows) {
      if (r.currency != null) counts[r.currency!] = (counts[r.currency!] ?? 0) + 1;
    }
    if (counts.isEmpty) return rows;
    final top = (counts.entries.toList()..sort((a, b) => b.value - a.value)).first.key;
    return [for (final r in rows) r.currency == null ? r.copyWith(currency: top) : r];
  }

  static bool _same(double a, double b) => (a * 1000).round() == (b * 1000).round();

  /// Where rows carry a running balance, it says which way each amount went.
  /// Tries the rows oldest first and newest first and keeps whichever order
  /// the balances fit.
  List<StatementRow> _signsFromBalances(List<StatementRow> rows) {
    if (rows.where((r) => r.balance != null).length < 2) return rows;
    int fits(bool newestFirst) {
      var n = 0;
      for (var i = 1; i < rows.length; i++) {
        final (older, newer) = newestFirst ? (rows[i], rows[i - 1]) : (rows[i - 1], rows[i]);
        if (older.balance == null || newer.balance == null) continue;
        if (_same((newer.balance! - older.balance!).abs(), newer.amount.abs())) n++;
      }
      return n;
    }

    final forward = fits(false), backward = fits(true);
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
  List<StatementRow> readMessages(String text) {
    final rows = <StatementRow>[];
    for (final block in normalize(text).split(RegExp(r'\n\s*\n'))) {
      final flat = block.replaceAll(RegExp(r'\s*\n\s*'), ' · ').trim();
      if (flat.isEmpty) continue;
      _decideOrder([flat]);
      final dates = _dates(flat);
      final times = [for (final m in _time.allMatches(flat)) _Span(m.start, m.end)];
      final taken = [...dates.map((d) => d.span), ...times];
      final amounts = _amounts(flat, taken);
      if (amounts.isEmpty) continue;
      // The first amount with a currency is the transaction; a later one is
      // usually the balance.
      final main = amounts.firstWhere((a) => a.value.currency != null, orElse: () => amounts.first);
      final merchant = RegExp(r'(?:\bat\b|\bfrom\b|\bto\b|لدى|من|إلى|الى|في|chez|en)\s*:?\s*([^·\d][^·]{1,40})', caseSensitive: false).firstMatch(flat);
      var description = merchant == null ? '' : _clean(merchant[1]!.replaceAll(RegExp(r'(?:^|\s)(?:on|بتاريخ|في|le|el)(?:\s|$).*$', caseSensitive: false), ''));
      if (description.isEmpty) {
        final spans = [...taken, ...amounts.map((a) => a.span)]..sort((a, b) => a.start - b.start);
        final b = StringBuffer();
        var i = 0;
        for (final s in spans) {
          if (s.start > i) b.write(flat.substring(i, s.start));
          b.write(' ');
          i = math.max(i, s.end);
        }
        if (i < flat.length) b.write(flat.substring(i));
        description = _clean(b.toString().split(' · ').first);
      }
      var sign = main.value.sign;
      final guessed = sign == 0;
      if (guessed) sign = _incomeWords.hasMatch(flat) && !_spendWords.hasMatch(flat) ? 1 : -1;
      final ccy = main.value.currency;
      final date = dates.isEmpty ? null : dates.first.value;
      rows.add(StatementRow(
        date: date ?? DateTime(received.year, received.month, received.day),
        dateGuessed: date == null,
        description: description,
        detail: flat,
        amount: main.value.major * sign,
        signGuessed: guessed && !_spendWords.hasMatch(flat) && !_incomeWords.hasMatch(flat),
        currency: ccy,
      ));
    }
    return rows;
  }
}
