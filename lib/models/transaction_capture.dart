import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'holding_transaction.dart';
import 'instrument_aliases.dart';
import 'metal_breakdown.dart';

/// One field of a [TransactionDraft]: its value, the words of the input it
/// came from (null when it's a default), and whether it was guessed rather
/// than read — a guessed field is flagged for the user to check.
class Captured<T> extends Equatable {
  final T value;
  final String? source;
  final bool guessed;

  const Captured(this.value, {this.source, this.guessed = false});

  @override
  List<Object?> get props => [value, source, guessed];
}

/// Which words of a captured sentence belong to each field, as labelled by
/// an on-device model (see `AiAssistProvider.labelTransaction`).
///
/// Every value must be a span copied out of the user's own text. A span that
/// isn't a literal substring of the input is discarded, and the survivors go
/// through the same field parsers typed text does — a model can point at
/// "4,100" but can never turn it into a number itself.
class CaptureSpans extends Equatable {
  final String? kind;
  final String? instrument;
  final String? quantity;
  final String? unit;
  final String? karat;

  /// A per-unit price, with or without its currency.
  final String? unitPrice;

  /// A total paid or received, with or without its currency.
  final String? total;
  final String? currency;
  final String? date;

  const CaptureSpans({
    this.kind,
    this.instrument,
    this.quantity,
    this.unit,
    this.karat,
    this.unitPrice,
    this.total,
    this.currency,
    this.date,
  });

  @override
  List<Object?> get props => [kind, instrument, quantity, unit, karat, unitPrice, total, currency, date];
}

/// What [TransactionCapture] needs to know about the app, passed in so the
/// parser stays a pure function testable without Flutter.
class CaptureContext {
  final List<Instrument> catalog;

  /// The instrument's name in the user's language.
  final String Function(Instrument) displayName;
  final String baseCurrency;

  /// ISO codes the app can convert between.
  final Set<String> currencies;

  /// Midnight today, local time; no captured date may be later.
  final DateTime today;

  const CaptureContext({
    required this.catalog,
    required this.displayName,
    required this.baseCurrency,
    required this.currencies,
    required this.today,
  });
}

/// A transaction parsed from free text, waiting for the user to confirm it.
/// Nothing here is saved until they do.
class TransactionDraft extends Equatable {
  final Captured<TransactionKind> kind;
  final Captured<Instrument> instrument;
  final Captured<double> quantity;
  final Captured<PriceUnit> unit;

  /// Only for gold by weight; null means fine (24K), as on a ledger row.
  final Captured<GoldKarat>? karat;

  /// Per [unit], in [currency] — already divided out when a total was given.
  final Captured<double>? unitPrice;

  /// The total as typed, when the price was given as a total.
  final Captured<double>? total;
  final Captured<double>? fee;
  final Captured<String> currency;
  final Captured<DateTime> date;

  const TransactionDraft({
    required this.kind,
    required this.instrument,
    required this.quantity,
    required this.unit,
    required this.currency,
    required this.date,
    this.karat,
    this.unitPrice,
    this.total,
    this.fee,
  });

  /// A buy or a sell can't be recorded without its price.
  bool get isComplete => unitPrice != null;

  HoldingTransaction toTransaction(String id) => HoldingTransaction(
        id: id,
        instrumentID: instrument.value.id,
        kind: kind.value,
        quantity: quantity.value,
        unit: unit.value,
        karat: karat?.value,
        unitPrice: unitPrice?.value ?? 0,
        fee: fee?.value ?? 0,
        currency: currency.value,
        date: date.value,
      );

  @override
  List<Object?> get props => [kind, instrument, quantity, unit, karat, unitPrice, total, fee, currency, date];
}

/// Turns a sentence like "20 g of 21K gold at 4,100 EGP on the 12th" (or
/// "اشتريت ٢٠ جرام ذهب عيار ٢١ بسعر ٤١٠٠ جنيه") into a [TransactionDraft]
/// against a closed set — catalog instruments, the app's currencies, its
/// units and karats. Deterministic, offline, and the same on every device:
/// this is the path v4's capture is designed around, with or without a
/// model.
///
/// English and Arabic, with Western, Arabic-Indic or Persian digits and
/// either thousands separator. Returns null unless both an instrument and a
/// quantity were found.
class TransactionCapture {
  TransactionCapture._();

  static TransactionDraft? parse(String text, CaptureContext context) =>
      _scan(text, context)._finish(context);

  /// [parse], with the gaps filled from what a model labelled. Fields the
  /// deterministic parser found always win; a field taken from a model is
  /// marked guessed.
  static TransactionDraft? parseWithSpans(String text, CaptureSpans spans, CaptureContext context) {
    final partial = _scan(text, context);
    partial._fillFrom(_fromSpans(text, spans, context));
    return partial._finish(context);
  }

  // -------------------------------------------------------------------
  // Scanning
  // -------------------------------------------------------------------

  static _Partial _scan(String text, CaptureContext context) {
    final s = _Scanner(text);
    final p = _Partial();
    p.date = _date(s, context.today);
    p.fee = _fee(s);
    p.karat = _karat(s);
    _quantityWithUnit(s, p);
    _instrument(s, context, p);
    _price(s, context, p);
    if (p.quantity == null) {
      final n = s.take(_re(_number));
      if (n != null) p.quantity = Captured(_toDouble(n.group(0)!), source: s.source(n), guessed: true);
    }
    if (p.unitPrice == null && p.total == null && p.quantity != null) {
      final n = s.take(_re(_number));
      if (n != null) p.unitPrice = Captured(_toDouble(n.group(0)!), source: s.source(n), guessed: true);
    }
    p.currency ??= _currency(s, context);
    p.kind = _kind(s);
    return p;
  }

  static _Partial _fromSpans(String text, CaptureSpans spans, CaptureContext context) {
    final normalized = _normalizeDigits(text);
    _Scanner? scan(String? span) {
      if (span == null || span.trim().isEmpty) return null;
      // A span must be the user's own words; anything else is the model
      // inventing content, and is dropped.
      if (!normalized.contains(_normalizeDigits(span))) return null;
      return _Scanner(span);
    }

    Captured<T>? guess<T>(Captured<T>? c) => c == null ? null : Captured(c.value, source: c.source, guessed: true);

    final p = _Partial();
    if (scan(spans.date) case final s?) p.date = guess(_date(s, context.today));
    if (scan(spans.karat) case final s?) p.karat = guess(_karat(s));
    if (scan(spans.quantity) case final s?) {
      _quantityWithUnit(s, p);
      if (p.quantity == null) {
        final n = s.take(_re(_number));
        if (n != null) p.quantity = Captured(_toDouble(n.group(0)!), source: s.source(n));
      }
      p.quantity = guess(p.quantity);
      p.unit = guess(p.unit);
    }
    if (p.unit == null) {
      if (scan(spans.unit) case final s?) p.unit = guess(_unitWord(s));
    }
    if (scan(spans.instrument) case final s?) {
      final probe = _Partial();
      _instrument(s, context, probe, allowFiat: true);
      p.instrument = guess(probe.instrument);
    }
    for (final (span, isTotal) in [(spans.unitPrice, false), (spans.total, true)]) {
      final s = scan(span);
      if (s == null) continue;
      final cur = _currency(s, context, adjacent: true);
      final n = s.take(_re(_number));
      if (n == null) continue;
      final value = Captured(_toDouble(n.group(0)!), source: span!.trim(), guessed: true);
      if (isTotal) {
        p.total ??= value;
      } else {
        p.unitPrice ??= value;
      }
      p.currency ??= guess(cur);
    }
    if (p.currency == null) {
      if (scan(spans.currency) case final s?) p.currency = guess(_currency(s, context));
    }
    if (scan(spans.kind) case final s?) {
      final k = _kind(s);
      if (k.source != null) p.kind = guess(k);
    }
    return p;
  }

  // -------------------------------------------------------------------
  // Fields
  // -------------------------------------------------------------------

  static Captured<DateTime>? _date(_Scanner s, DateTime today) {
    Captured<DateTime>? result(RegExpMatch m, DateTime? d, {bool guessed = false}) {
      if (d == null || d.isAfter(today)) return null;
      return Captured(d, source: s.source(m), guessed: guessed);
    }

    if (s.take(_re('$_b(?:today|اليوم|النهارده|hoy|aujourd\'hui)$_e'))
        case final m?) {
      return Captured(today, source: s.source(m));
    }
    if (s.take(_re('$_b(?:yesterday|أمس|امس|البارحة|امبارح|ayer|hier)$_e'))
        case final m?) {
      return Captured(today.subtract(const Duration(days: 1)), source: s.source(m));
    }
    // 2026-03-12
    if (s.take(RegExp(r'(?<!\d)(\d{4})-(\d{1,2})-(\d{1,2})(?!\d)')) case final m?) {
      return result(m, _validDate(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!)));
    }
    // 12/3 or 12/3/2026 — day first, as across the Arabic-speaking world
    // and Europe; flagged when month-first would also have been valid.
    if (s.take(RegExp(r'(?<![\d.,])(\d{1,2})/(\d{1,2})(?:/(\d{2}|\d{4}))?(?![\d.,])')) case final m?) {
      final day = int.parse(m[1]!), month = int.parse(m[2]!);
      final ambiguous = day <= 12 && month <= 12 && day != month;
      if (m[3] case final y?) {
        final year = y.length == 2 ? 2000 + int.parse(y) : int.parse(y);
        return result(m, _validDate(year, month, day), guessed: ambiguous);
      }
      return result(m, _latestMonthDay(month, day, today), guessed: true);
    }
    // 12 March [2026], March 12th [2026], 12 مارس
    final months = _months.keys.join('|');
    final dayFirst = _re('$_b(\\d{1,2})(?:st|nd|rd|th)?\\s+(?:of\\s+)?($months)$_e(?:,?\\s*(\\d{4}))?');
    final monthFirst = _re('$_b($months)\\s+(\\d{1,2})(?:st|nd|rd|th)?$_e(?:,?\\s*(\\d{4}))?');
    for (final (re, dayGroup, monthGroup) in [(dayFirst, 1, 2), (monthFirst, 2, 1)]) {
      final m = s.take(re);
      if (m == null) continue;
      final day = int.parse(m[dayGroup]!);
      final month = _months[m[monthGroup]!.toLowerCase()]!;
      if (m[3] case final y?) return result(m, _validDate(int.parse(y), month, day));
      return result(m, _latestMonthDay(month, day, today), guessed: true);
    }
    // "on the 12th", "the 12th", "on 12", "يوم 12": the most recent 12th.
    final dayOnly = s.take(_re('$_b(?:on\\s+)?(?:the\\s+)?(\\d{1,2})(?:st|nd|rd|th)$_e')) ??
        s.take(_re('$_b(?:on\\s+(?:the\\s+)?|يوم\\s*)(\\d{1,2})(?![\\d.,]|\\s*(?:$_unitWords))'));
    if (dayOnly != null) return result(dayOnly, _latestDay(int.parse(dayOnly[1]!), today), guessed: true);
    return null;
  }

  static Captured<double>? _fee(_Scanner s) {
    final m = s.take(_re('$_b(?:fees?|commission|عمولة|العمولة|رسوم|مصاريف|frais|comisión)\\s*(?:of\\s+)?:?\\s*($_number)'));
    if (m == null) return null;
    return Captured(_toDouble(m[1]!), source: s.source(m));
  }

  static Captured<GoldKarat>? _karat(_Scanner s) {
    final m = s.take(_re('$_b(\\d{2})\\s*(?:k|kt|karat|carat|ct|قيراط|ق)$_e')) ??
        s.take(_re('$_b(?:عيار|karat|carat)\\s*(\\d{2})(?!\\d)'));
    if (m == null) return null;
    final karat = GoldKarat.fromRawValue(int.parse(m[1]!));
    return karat == null ? null : Captured(karat, source: s.source(m));
  }

  static void _quantityWithUnit(_Scanner s, _Partial p) {
    final m = s.take(_re('$_b($_number)\\s*($_unitWords)$_e'));
    if (m == null) return;
    p.quantity = Captured(_toDouble(m[1]!), source: s.source(m));
    p.unit = Captured(_unitFor(m[2]!), source: s.source(m));
  }

  static Captured<PriceUnit>? _unitWord(_Scanner s) {
    final m = s.take(_re('$_b($_unitWords)$_e'));
    return m == null ? null : Captured(_unitFor(m[1]!), source: s.source(m));
  }

  /// The first instrument named, preferring anything over a currency (in
  /// "gold at 4,100 EGP", EGP is the price's currency, not the asset). A
  /// currency is only the asset when a quantity sits right before it, as in
  /// "1000 USD at 48.5 EGP".
  static void _instrument(_Scanner s, CaptureContext context, _Partial p, {bool allowFiat = false}) {
    ({int start, int end, Instrument instrument})? best;
    for (final instrument in context.catalog) {
      if (instrument.assetClass == AssetClass.fiat && !allowFiat) continue;
      for (final term in _termsFor(instrument, context)) {
        final hit = s.findWord(term);
        if (hit == null) continue;
        final better = best == null || hit.start < best.start || (hit.start == best.start && hit.end > best.end);
        if (better) best = (start: hit.start, end: hit.end, instrument: instrument);
      }
    }
    if (best == null && !allowFiat && p.quantity == null && p.karat == null) {
      final fiat = {
        for (final i in context.catalog.where((i) => i.assetClass == AssetClass.fiat)) i.symbol.toLowerCase(): i,
      };
      if (fiat.isNotEmpty) {
        final m = s.take(_re('$_b($_number)\\s*(${fiat.keys.map(RegExp.escape).join('|')})$_e'));
        if (m != null) {
          p.quantity = Captured(_toDouble(m[1]!), source: s.source(m));
          p.instrument = Captured(fiat[m[2]!.toLowerCase()]!, source: s.source(m));
        }
      }
      return;
    }
    if (best == null) return;
    s.claimRange(best.start, best.end);
    p.instrument = Captured(best.instrument, source: s.sourceRange(best.start, best.end));
    // "0.5 BTC", "3 shares of Apple": the number just before the name.
    if (p.quantity == null) {
      final before = s.lastBefore(
        _re('$_b($_number)\\s*(?:(?:shares?|units?|coins?|سهم|أسهم|اسهم|وحدة)\\s*)?(?:of\\s+|من\\s+)?\$'),
        best.start,
      );
      if (before != null) {
        s.claim(before);
        p.quantity = Captured(_toDouble(before[1]!), source: s.source(before));
      }
    }
  }

  static void _price(_Scanner s, CaptureContext context, _Partial p) {
    final re = _re('(?:$_b(?<kw>$_totalWords|$_perUnitWords)|(?<![$_letter])(?<ba>بـ?))?\\s*'
      '(?<c1>${_currencyPattern(context)})?\\s*'
      '(?<num>$_number)\\s*'
      '(?<c2>${_currencyPattern(context)})?\\s*'
      '(?<per>$_perUnitSuffix)?');
    for (final m in s.all(re)) {
      final kw = m.namedGroup('kw')?.toLowerCase();
      final hasCurrency = m.namedGroup('c1') != null || m.namedGroup('c2') != null;
      if (kw == null && m.namedGroup('ba') == null && !hasCurrency) continue;
      s.claim(m);
      final value = _toDouble(m.namedGroup('num')!);
      final isTotal = kw != null && _re('^(?:$_totalWords)\$').hasMatch(kw);
      final explicitPerUnit = m.namedGroup('per') != null ||
          (kw != null && _re('^(?:$_perUnitWords)\$').hasMatch(kw));
      if (isTotal && m.namedGroup('per') == null) {
        p.total = Captured(value, source: s.source(m));
      } else {
        p.unitPrice = Captured(value, source: s.source(m), guessed: !explicitPerUnit);
      }
      final currencyText = m.namedGroup('c1') ?? m.namedGroup('c2');
      if (currencyText != null) {
        p.currency = _currency(_Scanner(currencyText), context, source: s.source(m), adjacent: true);
      }
      return;
    }
  }

  /// [adjacent] is set when the text sits right next to an amount, where
  /// a lower-case code ("4100 egp") can only be a currency.
  static Captured<String>? _currency(_Scanner s, CaptureContext context, {String? source, bool adjacent = false}) {
    for (final (pattern, family, symbol) in _currencies) {
      final re = symbol
          ? _re(pattern)
          : _re('$_b(?:$pattern)$_e');
      final m = s.take(re);
      if (m == null) continue;
      final available = family.where(context.currencies.contains).toList();
      if (available.isEmpty) continue;
      final code = available.contains(context.baseCurrency) ? context.baseCurrency : available.first;
      return Captured(code, source: source ?? s.source(m), guessed: family.length > 1);
    }
    // A bare ISO code. Away from an amount, lower-case "all" or "try" are
    // words, not the lek or the lira, so the code must be in capitals.
    for (final m in s.all(_re(r'(?<![a-z])([a-z]{3})(?![a-z])'))) {
      final word = s.source(m);
      final code = word.toUpperCase();
      if (!context.currencies.contains(code) || (!adjacent && word != code)) continue;
      s.claim(m);
      return Captured(code, source: source ?? word);
    }
    return null;
  }

  static Captured<TransactionKind> _kind(_Scanner s) {
    for (final (pattern, kind) in [(_sellWords, TransactionKind.sell), (_buyWords, TransactionKind.buy)]) {
      final m = s.take(_re('$_b(?:$pattern)$_e'));
      if (m != null) return Captured(kind, source: s.source(m));
    }
    return const Captured(TransactionKind.buy, guessed: true);
  }

  // -------------------------------------------------------------------
  // Vocabulary
  // -------------------------------------------------------------------

  /// Each pattern is compiled once. Patterns run against lower-cased text
  /// ([_Scanner]) and so are written in lower case and matched
  /// case-sensitively: Unicode case folding made the VM take seconds to
  /// compile the first match against Arabic text.
  static final Map<String, RegExp> _compiled = {};
  static RegExp _re(String pattern) => _compiled[pattern] ??= RegExp(pattern);

  /// Not a letter or digit on either side — `\b` is ASCII-only in Dart, so
  /// it can't bound Arabic words. Spelled as explicit Latin and Arabic
  /// ranges rather than `\p{L}`: the patterns are long, and Unicode property
  /// classes made compiling them for Arabic text take seconds.
  static const _letter = r'a-z0-9\u00C0-\u024F\u0600-\u06FF';
  static const _b = '(?<![$_letter])';
  static const _e = '(?![$_letter])';

  /// 4,100 · 4100 · 4100.50 · 2,5 (a comma decimal) — after digit folding.
  static const _number = r'(?<![\d.,])(?:\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:[.,]\d+)?)(?![\d])';

  static const _unitWords = 'troy ounces?|ounces?|ozt|oz|onzas?|onces?|أونصات|أونصة|اونصة|أوقية|اوقية|'
      'kilograms?|kilogrammes?|kilos?|kgs?|كيلوجرام|كيلوغرام|كيلو|كجم|كغ|'
      'grams?|grammes?|gramos?|grm|gr|gm|g|جرامات|جرام|غرامات|غرام|جم|غم|غ';

  static PriceUnit _unitFor(String word) {
    final w = word.toLowerCase();
    if (RegExp(r'^(?:troy ounces?|ounces?|ozt|oz|onzas?|onces?|أونصات|أونصة|اونصة|أوقية|اوقية)$').hasMatch(w)) {
      return PriceUnit.troyOunce;
    }
    if (RegExp(r'^(?:kilo|kg|كيلو|كجم|كغ)').hasMatch(w)) return PriceUnit.kilogram;
    return PriceUnit.gram;
  }

  static const _perUnitWords = 'priced at|price|at|@|بسعر|سعر|à';
  static const _totalWords = 'for a total of|totaling|total|for|paid|بمبلغ|بإجمالي|إجمالي|اجمالي|مجموع|دفعت|pour|por';
  static const _perUnitSuffix = r'/\s*(?:g|gm|gr|kg|oz)(?![a-z])|per\s+(?:gram|g|ounce|oz|kilo|kg|share|unit|coin)'
      r'|an?\s+(?:gram|ounce|kilo|share)|each|apiece'
      r'|(?:لل|ل|لكل\s+)(?:جرام|غرام|أونصة|اونصة|كيلو|سهم)|الجرام|الغرام';

  static const _buyWords = 'bought|buy|buying|purchased|purchase|got|اشتريت|اشتري|شريت|شراء|compré|acheté';
  static const _sellWords = 'sold|sell|selling|بعت|ابيع|أبيع|بيع|vendí|vendu';

  /// Pattern, the currencies it can mean (the base currency wins when it's
  /// one of them, otherwise the first), and whether it's a symbol rather
  /// than a word. Qualified names come before the bare word they qualify.
  static const List<(String, List<String>, bool)> _currencies = [
    (r'e£|ج\.م\.?', ['EGP'], true),
    (r'us\$|\$', ['USD'], true),
    ('€', ['EUR'], true),
    ('£', ['GBP'], true),
    (r'ر\.س\.?', ['SAR'], true),
    (r'ر\.ق\.?', ['QAR'], true),
    (r'د\.إ\.?|د\.ا\.?', ['AED'], true),
    (r'د\.ك\.?', ['KWD'], true),
    (r'egyptian\s+pounds?|جنيه(?:ات)?\s+مصري(?:ة)?|livres?\s+égyptiennes?', ['EGP'], false),
    (r'british\s+pounds?|pounds?\s+sterling|sterling|جنيه(?:ات)?\s+(?:إ|ا)سترليني(?:ة)?', ['GBP'], false),
    (r'saudi\s+riyals?|ريال(?:ات)?\s+سعودي(?:ة)?', ['SAR'], false),
    (r'qatari\s+riyals?|ريال(?:ات)?\s+قطري(?:ة)?', ['QAR'], false),
    (r'omani\s+rials?|ريال(?:ات)?\s+عماني(?:ة)?', ['OMR'], false),
    (r'kuwaiti\s+dinars?|دينار\s+كويتي|دنانير\s+كويتية', ['KWD'], false),
    (r'bahraini\s+dinars?|دينار\s+بحريني|دنانير\s+بحرينية', ['BHD'], false),
    (r'jordanian\s+dinars?|دينار\s+أردني|دينار\s+اردني|دنانير\s+أردنية', ['JOD'], false),
    (r'dollars?|bucks|dólares?|دولار(?:ات)?', ['USD'], false),
    (r'euros?|يورو', ['EUR'], false),
    (r'pounds?|livres?|libras?|جنيه(?:ات)?|جنيهًا|جنيها', ['EGP', 'GBP'], false),
    (r'riyals?|rials?|ريال(?:ات)?|ريالا', ['SAR', 'QAR', 'OMR'], false),
    (r'dirhams?|درهم(?:ا)?|دراهم', ['AED'], false),
    (r'dinars?|دينار(?:ا)?|دنانير', ['KWD', 'BHD', 'JOD'], false),
  ];

  static String _currencyPattern(CaptureContext context) => [
        for (final (pattern, _, symbol) in _currencies) symbol ? pattern : '$_b(?:$pattern)$_e',
        if (context.currencies.isNotEmpty)
          '(?<![a-z])(?:${context.currencies.map((c) => c.toLowerCase()).join('|')})(?![a-z])',
      ].join('|');

  static const Map<String, int> _months = {
    'january': 1, 'jan': 1, 'february': 2, 'feb': 2, 'march': 3, 'mar': 3, 'april': 4, 'apr': 4,
    'may': 5, 'june': 6, 'jun': 6, 'july': 7, 'jul': 7, 'august': 8, 'aug': 8,
    'september': 9, 'sept': 9, 'sep': 9, 'october': 10, 'oct': 10, 'november': 11, 'nov': 11,
    'december': 12, 'dec': 12,
    'يناير': 1, 'فبراير': 2, 'مارس': 3, 'أبريل': 4, 'ابريل': 4, 'مايو': 5, 'يونيو': 6, 'يونيه': 6,
    'يوليو': 7, 'يوليه': 7, 'أغسطس': 8, 'اغسطس': 8, 'سبتمبر': 9, 'أكتوبر': 10, 'اكتوبر': 10,
    'نوفمبر': 11, 'ديسمبر': 12,
  };

  static List<String> _termsFor(Instrument instrument, CaptureContext context) {
    final terms = <String>{
      instrument.symbol,
      context.displayName(instrument),
      // Currency words ("riyal", جنيه) name a family, not one currency;
      // the price scan resolves those against the base currency instead.
      if (instrument.assetClass != AssetClass.fiat) ...InstrumentAliases.of(instrument.id),
    };
    // Arabic nouns usually carry the definite article: ذهب / الذهب.
    for (final t in terms.toList()) {
      if (RegExp(r'^[\u0600-\u06FF]').hasMatch(t) && !t.startsWith('ال')) terms.add('ال$t');
    }
    return terms.where((t) => t.trim().isNotEmpty).toList();
  }

  // -------------------------------------------------------------------
  // Numbers and dates
  // -------------------------------------------------------------------

  /// Arabic-Indic and Persian digits to ASCII, and the Arabic thousands and
  /// decimal separators to `,` and `.` — one code unit for one, so offsets
  /// into the folded text are offsets into the original.
  static String _normalizeDigits(String input) {
    final out = StringBuffer();
    for (final unit in input.codeUnits) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        out.writeCharCode(0x30 + unit - 0x0660);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        out.writeCharCode(0x30 + unit - 0x06F0);
      } else if (unit == 0x066C) {
        out.write(',');
      } else if (unit == 0x066B) {
        out.write('.');
      } else {
        out.writeCharCode(unit);
      }
    }
    return out.toString();
  }

  /// "4,100" → 4100 (a comma before exactly three digits groups
  /// thousands); "2,5" → 2.5 (a comma decimal).
  static double _toDouble(String text) {
    final grouped = RegExp(r'^\d{1,3}(?:,\d{3})+(?:\.\d+)?$').hasMatch(text);
    return double.parse(grouped ? text.replaceAll(',', '') : text.replaceAll(',', '.'));
  }

  static DateTime? _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final d = DateTime(year, month, day);
    return d.month == month && d.day == day ? d : null;
  }

  /// The most recent [day] of a month on or before [today].
  static DateTime? _latestDay(int day, DateTime today) {
    for (var back = 0; back < 12; back++) {
      final month = DateTime(today.year, today.month - back);
      final d = _validDate(month.year, month.month, day);
      if (d != null && !d.isAfter(today)) return d;
    }
    return null;
  }

  /// The most recent [month]/[day] on or before [today].
  static DateTime? _latestMonthDay(int month, int day, DateTime today) {
    for (var year = today.year; year > today.year - 8; year--) {
      final d = _validDate(year, month, day);
      if (d != null && !d.isAfter(today)) return d;
    }
    return null;
  }
}

/// The fields found so far; [_finish] turns them into a draft.
class _Partial {
  Captured<TransactionKind>? kind;
  Captured<Instrument>? instrument;
  Captured<double>? quantity;
  Captured<PriceUnit>? unit;
  Captured<GoldKarat>? karat;
  Captured<double>? unitPrice;
  Captured<double>? total;
  Captured<double>? fee;
  Captured<String>? currency;
  Captured<DateTime>? date;

  void _fillFrom(_Partial other) {
    // A default kind ("buy", nothing said) yields to one the model found.
    if (other.kind != null && (kind == null || kind!.source == null)) kind = other.kind;
    instrument ??= other.instrument;
    if (quantity == null) {
      quantity = other.quantity;
      unit ??= other.unit;
    }
    unit ??= other.unit;
    karat ??= other.karat;
    if (unitPrice == null && total == null) {
      unitPrice = other.unitPrice;
      total = other.total;
    }
    fee ??= other.fee;
    currency ??= other.currency;
    date ??= other.date;
  }

  TransactionDraft? _finish(CaptureContext context) {
    final inst = instrument ?? _goldFromKarat(context);
    final qty = quantity;
    if (inst == null || qty == null || qty.value <= 0) return null;
    final instrument_ = inst.value;

    var unit_ = unit;
    if (unit_ != null && !instrument_.supportedUnits.contains(unit_.value)) unit_ = null;
    // Gold with a karat is bought by the gram; anything else starts in its
    // quoted unit.
    unit_ ??= Captured(
      karat != null && instrument_.supportedUnits.contains(PriceUnit.gram) ? PriceUnit.gram : instrument_.quotation.defaultUnit,
      guessed: instrument_.supportedUnits.length > 1,
    );

    // As in the editor: a karat only means something for gold by weight.
    final karat_ = karat != null && instrument_.supportedKarats.contains(karat!.value) && unit_.value != PriceUnit.troyOunce
        ? karat
        : null;

    var price = unitPrice;
    if (price == null && total != null) {
      price = Captured(total!.value / qty.value, source: total!.source, guessed: total!.guessed);
    }
    if (price != null && price.value <= 0) price = null;

    return TransactionDraft(
      kind: kind ?? const Captured(TransactionKind.buy, guessed: true),
      instrument: inst,
      quantity: qty,
      unit: unit_,
      karat: karat_,
      unitPrice: price,
      total: price != null && unitPrice == null ? total : null,
      fee: fee,
      currency: currency ?? Captured(context.baseCurrency, guessed: true),
      date: date ?? Captured(context.today),
    );
  }

  /// "20 g 21K at 4,100": a karat names gold even when the word doesn't.
  Captured<Instrument>? _goldFromKarat(CaptureContext context) {
    final k = karat;
    if (k == null) return null;
    for (final i in context.catalog) {
      if (i.supportedKarats.contains(k.value)) return Captured(i, source: k.source, guessed: true);
    }
    return null;
  }
}

/// Matches against the digit-folded input, never reusing text a field has
/// already claimed, and reports each match's words from the original.
class _Scanner {
  final String original;
  final String text;

  /// [text] lower-cased, or [text] itself if lower-casing changed its
  /// length (a dotted capital I), which would break offsets.
  final String _lower;
  final List<bool> _used;

  _Scanner._(this.original, this.text)
      : _lower = text.toLowerCase().length == text.length ? text.toLowerCase() : text,
        _used = List.filled(original.length, false);

  _Scanner(String original) : this._(original, TransactionCapture._normalizeDigits(original));

  bool _free(RegExpMatch m) {
    for (var i = m.start; i < m.end; i++) {
      if (_used[i]) return false;
    }
    return true;
  }

  /// Every match of [re] against the lower-cased text that doesn't overlap
  /// claimed text, leftmost first. Lookbehinds still see the text before
  /// each restart.
  Iterable<RegExpMatch> all(RegExp re) sync* {
    var start = 0;
    while (start <= _lower.length) {
      final m = re.allMatches(_lower, start).firstOrNull;
      if (m == null) return;
      if (m.end > m.start && _free(m)) yield m;
      start = m.start + 1;
    }
  }

  RegExpMatch? peek(RegExp re) => all(re).firstOrNull;

  /// [word] as a whole word, ignoring case, in text not yet claimed — a
  /// plain search, since a pattern per catalog name would be compiled for
  /// every name.
  ({int start, int end})? findWord(String word) {
    final needle = word.toLowerCase();
    if (needle.isEmpty) return null;
    for (var i = _lower.indexOf(needle); i >= 0; i = _lower.indexOf(needle, i + 1)) {
      final end = i + needle.length;
      if (_isWordChar(i - 1) || _isWordChar(end)) continue;
      if (_used.sublist(i, end).contains(true)) continue;
      return (start: i, end: end);
    }
    return null;
  }

  bool _isWordChar(int index) =>
      index >= 0 && index < text.length && _wordChar.hasMatch(text[index]);

  static final _wordChar = RegExp('[${TransactionCapture._letter}]');

  RegExpMatch? take(RegExp re) {
    final m = peek(re);
    if (m != null) claim(m);
    return m;
  }

  /// The match of [re] that ends closest before [end] (the pattern should
  /// be anchored with `$`).
  RegExpMatch? lastBefore(RegExp re, int end) {
    final head = _lower.substring(0, end);
    final m = re.firstMatch(head);
    if (m == null) return null;
    for (var i = m.start; i < m.end; i++) {
      if (_used[i]) return null;
    }
    return m;
  }

  void claim(RegExpMatch m) => claimRange(m.start, m.end);

  void claimRange(int start, int end) {
    for (var i = start; i < end; i++) {
      _used[i] = true;
    }
  }

  String source(RegExpMatch m) => sourceRange(m.start, m.end);

  String sourceRange(int start, int end) => original.substring(start, end).trim();
}
