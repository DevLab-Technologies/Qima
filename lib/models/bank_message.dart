part of 'statement_reader.dart';

/// What a bank message is about. A message is read in three steps: what it
/// says happened ([MessageIntent]), the fields it gives ([_MessageFields]),
/// then those fields mapped to a [StatementRow]. Only a message that says
/// money moved becomes a row; a statement notice, a reminder, a one-time
/// code or a declined payment never does, whatever figures it carries.
enum MessageIntent {
  /// A card or point-of-sale purchase.
  purchase(-1),

  /// Money given back: a refund, reversal or cashback.
  refund(1),

  /// Cash taken out.
  withdrawal(-1),

  /// A transfer sent to someone.
  transferOut(-1),

  /// A transfer received.
  transferIn(1),

  /// A deposit, salary or credit.
  deposit(1),

  /// A bank fee or commission.
  fee(-1),

  /// Money taken: a debit, bill or payment.
  debit(-1),

  /// Money moved but the message doesn't say which way.
  unknown(0),

  /// A statement issued, a minimum or a due date: nothing moved.
  notice(0, transaction: false),

  /// A one-time or verification code.
  code(0, transaction: false),

  /// A payment that didn't go through.
  declined(0, transaction: false);

  const MessageIntent(this.direction, {this.transaction = true});

  /// -1 money out, 1 money in, 0 not known.
  final int direction;

  /// Whether money moved.
  final bool transaction;

  bool get incoming => direction > 0;
}

/// The intents a message's words point to, strongest first. Words for a
/// notice only decide when no word says money moved, so "Installment
/// deducted, next due date" stays a debit.
final _intentWords = <(MessageIntent, RegExp)>[
  (
    MessageIntent.code,
    RegExp(
      r'\botp\b|one[- ]time (?:pass(?:word|code)|code)|verification code|activation code|'
      r'رمز التحقق|رمز التفعيل|كلمة المرور المؤقتة|رمز الدخول|code de vérification|código de verificación',
      caseSensitive: false,
    )
  ),
  (
    MessageIntent.declined,
    RegExp(
      r'declined|rejected|unsuccessful|not approved|insufficient (?:funds|balance)|transaction failed|'
      r'مرفوضة|مرفوض|تم رفض|لم تتم|غير ناجحة|رصيد غير كاف|refusée|refusé|rechazad',
      caseSensitive: false,
    )
  ),
  (
    MessageIntent.refund,
    RegExp(
      r'refund|reversal|reversed|chargeback|cash ?back|'
      r'استرداد|مسترد|استرجاع|مسترجع|عكس عملية|remboursement|reembolso|devolución',
      caseSensitive: false,
    )
  ),
  (
    MessageIntent.withdrawal,
    RegExp(r'withdrawal|withdrawn|\batm\b|cash out|سحب نقدي|سحب|retrait|retiro', caseSensitive: false)
  ),
  (
    MessageIntent.transferIn,
    RegExp(
      r'incoming transfer|transfer (?:in|received|from)|received (?:a )?transfer|'
      // Only a transfer sent to the person's account: a purchase "charged
      // to your card" or a balance "in your account" is not money in.
      r'(?:transfer(?:red)?|sent|deposited)\b.{0,40}\bto your (?:account|card|wallet)|credited to your|'
      r'حوالة واردة|تحويل وارد|حوالة محلية واردة|(?:تحويل|حوالة|إيداع|ايداع).{0,40}(?:(?:إلى|الى) حسابك|لحسابك)|'
      r'virement reçu|transferencia recibida',
      caseSensitive: false,
    )
  ),
  (
    MessageIntent.transferOut,
    RegExp(
      r'outgoing transfer|transfer (?:out|sent|to)|transferred to|'
      r'حوالة صادرة|تحويل صادر|حوالة محلية صادرة|virement émis|transferencia enviada',
      caseSensitive: false,
    )
  ),
  (
    MessageIntent.purchase,
    RegExp(
      r'purchase|\bpos\b|\bspent\b|\bcharged\b|apple pay|mada pay|'
      r'شراء|مشتريات|نقاط البيع|achat|compra',
      caseSensitive: false,
    )
  ),
  (
    MessageIntent.deposit,
    RegExp(
      r'deposit|salary|payroll|credited|\breceived\b|'
      r'إيداع|ايداع|راتب|رواتب|أضيف|اضيف|وارد|salaire|nómina|nomina|abono',
      caseSensitive: false,
    )
  ),
  (MessageIntent.fee, RegExp(r'\bfees?\b|commission|رسوم|عمولة|frais|comisión', caseSensitive: false)),
  (
    MessageIntent.debit,
    RegExp(
      r'debited|deducted|\bpaid\b|bill payment|\btransfer\b|'
      r'خصم|مخصوم|سداد|دفع|تحويل|حوالة|prélèvement|paiement|pago|débito',
      caseSensitive: false,
    )
  ),
];

/// The label of a figure that is only what is left after a transaction.
final _leftLabel = RegExp(
  r'(?:(?:remaining|avail(?:able)?\.?|left)\s*(?:credit\s*)?(?:limit|bal(?:ance)?\.?)|(?:limit|bal(?:ance)?\.?)\s*(?:left|remaining|avail(?:able)?\.?)|'
  r'available credit|\bbal(?:ance)?\.?\s*:|'
  r'(?:الحد|الرصيد)\s*(?:الائتماني\s*)?(?:المتبقي|المتاح|المتوفر)|(?:الرصيد|المتبقي)\s*:|'
  r'solde disponible|plafond restant|saldo disponible|límite disponible)'
  r'[^\d]{0,20}$',
  caseSensitive: false,
);

final _noticeWords = RegExp(
  r'statement (?:has been |is |was )?(?:issued|generated|ready|available)|minimum (?:due|payment|amount)|'
  r'payment due|due date|amount due|due on|'
  r'تم إصدار كشف|كشف الحساب|كشف حساب|الحد الأدنى|تاريخ الاستحقاق|المبلغ المستحق|مستحق السداد|'
  r'relevé|paiement minimum|date d.échéance|extracto|pago mínimo|fecha de vencimiento',
  caseSensitive: false,
);

/// What [text] says happened.
MessageIntent messageIntent(String text) {
  final found = [for (final (intent, words) in _intentWords) if (words.hasMatch(text)) intent];
  if (found.contains(MessageIntent.code)) return MessageIntent.code;
  if (found.contains(MessageIntent.declined)) return MessageIntent.declined;
  // A notice talks about paying ("payment due"); only a word that money
  // already moved overrides it.
  if (_noticeWords.hasMatch(text)) {
    final moved = text.replaceAll(_noticeWords, ' ');
    final strong = [
      for (final (intent, words) in _intentWords)
        if (intent.transaction && words.hasMatch(moved)) intent
    ];
    if (strong.isEmpty) return MessageIntent.notice;
    return strong.first;
  }
  return found.firstOrNull ?? MessageIntent.unknown;
}

/// A field a message labels ("Amount: SAR 40.99"), by what it holds.
enum _Field { amount, to, from, merchant, date, card, account, place, left }

final _fieldNames = <_Field, RegExp>{
  _Field.amount: RegExp(r'^(?:amount|value|total|المبلغ|مبلغ|القيمة|montant|importe|monto)$', caseSensitive: false),
  _Field.to: RegExp(r'^(?:to|paid to|beneficiary|payee|recipient|إلى|الى|لصالح|المستفيد|à|bénéficiaire|para|beneficiario)$',
      caseSensitive: false),
  _Field.from: RegExp(r'^(?:from|sender|by|من|المرسل|المحول|de|desde|remitente)$', caseSensitive: false),
  _Field.merchant: RegExp(
      r'^(?:at|merchant|merchant name|store|shop|لدى|التاجر|اسم التاجر|المتجر|chez|marchand|commerçant|comercio)$',
      caseSensitive: false),
  _Field.date: RegExp(r'^(?:on|date|time|date ?& ?time|في|بتاريخ|التاريخ|الوقت|le|el|fecha)$', caseSensitive: false),
  _Field.card: RegExp(r'^(?:card|card no|card number|بطاقة|البطاقة|رقم البطاقة|carte|tarjeta)$', caseSensitive: false),
  _Field.account: RegExp(r'^(?:account|account no|account number|a/c|acct|حساب|الحساب|رقم الحساب|compte|cuenta)$',
      caseSensitive: false),
  _Field.place: RegExp(r'^(?:in|country|city|location|الدولة|المدينة|pays|país)$', caseSensitive: false),
  _Field.left: RegExp(
      r'^(?:(?:remaining|available) (?:limit|balance)|balance|limit|available|الرصيد(?: المتبقي| المتاح)?|المتبقي|الحد المتاح|solde|saldo)(?: \w+)?$',
      caseSensitive: false),
};

final _fieldLine = RegExp(r'^\s*([\p{L}][\p{L}\s&/.()-]{0,30}?)\s*:\s*(.+)$', unicode: true);

/// The labelled fields of a message's lines, first of each kind.
Map<_Field, String> _messageFields(List<String> lines) {
  final out = <_Field, String>{};
  for (final l in lines) {
    final m = _fieldLine.firstMatch(l);
    if (m == null) continue;
    final label = m[1]!.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    for (final MapEntry(key: field, value: names) in _fieldNames.entries) {
      if (names.hasMatch(label)) {
        out.putIfAbsent(field, () => m[2]!.trim());
        break;
      }
    }
  }
  return out;
}

extension _BankMessages on StatementReader {
  /// One message as a row, or null when it isn't money moving.
  StatementRow? _message(List<String> lines) {
    if (lines.isEmpty) return null;
    final flat = lines.join(' ');

    // 1. What happened.
    final intent = messageIntent(flat);
    if (!intent.transaction) return null;

    // 2. What it gives.
    final fields = _messageFields(lines);
    _decideOrder([flat]);
    final (dates, dateSpans) = _dates(flat);
    final times = [for (final m in StatementReader._time.allMatches(flat)) _Span(m.start, m.end)];
    final taken = [...dateSpans, ...times];
    final amounts = _amounts(flat, taken);
    if (amounts.isEmpty) return null;

    // 3. Into our fields. The amount: the labelled one, else the first with
    // a currency that isn't the balance or limit left.
    final labelled = fields[_Field.amount];
    final fromField = labelled == null ? null : _amounts(labelled, _dates(labelled).$2).firstOrNull;
    // What a figure follows says whether it is what is left: a loose word
    // ("balance", "remaining") only steers the choice of amount; a plain
    // label ("remaining limit", "Avail. Bal:") rules the figure out.
    String before(_Found<_Money> a) => flat.substring(math.max(0, a.span.start - 40), a.span.start);
    bool left(_Found<_Money> a) => StatementReader._leftBefore.hasMatch(before(a));
    bool onlyLeft(_Found<_Money> a) => _leftLabel.hasMatch(before(a));
    // A message whose only figures are the limit or balance left (its
    // amount line cut off in a screenshot) is not a transaction, but
    // "balance transfer of SAR 2,000" is.
    if (fromField == null && amounts.every(onlyLeft)) return null;
    final main = fromField ??
        amounts.where((a) => a.value.currency != null && !left(a)).firstOrNull ??
        amounts.where((a) => a.value.currency != null).firstOrNull ??
        amounts.first;
    final currency = main.value.currency ??
        (labelled == null ? null : StatementReader._currencyIn(labelled)) ??
        amounts.map((a) => a.value.currency).nonNulls.firstOrNull;

    // The direction: what happened, else the amount's own sign, else a guess.
    var sign = intent.direction != 0 ? intent.direction : main.value.sign;
    final guessed = sign == 0;
    if (guessed) {
      sign = StatementReader._incomeWords.hasMatch(flat) && !StatementReader._spendWords.hasMatch(flat) ? 1 : -1;
    }

    // Who: the other side, never the person's own card or account.
    final description = _counterparty(lines, flat, fields, sign);

    final dateField = fields[_Field.date];
    final date = (dateField == null ? null : _dates(dateField).$1.firstOrNull?.value) ?? dates.firstOrNull?.value;
    return StatementRow(
      date: date ?? DateTime(received.year, received.month, received.day),
      dateGuessed: date == null,
      description: description,
      detail: flat,
      amount: main.value.major * sign,
      signGuessed: guessed &&
          !StatementReader._spendWords.hasMatch(flat) &&
          !StatementReader._incomeWords.hasMatch(flat),
      currency: currency,
    );
  }

  String _counterparty(List<String> lines, String flat, Map<_Field, String> fields, int sign) {
    bool own(String s) =>
        StatementReader._accountWords.hasMatch(s) || StatementReader._masked.hasMatch(s) || RegExp(r'^\W*\d{4,}').hasMatch(s);
    String named(String raw) {
      final n = StatementReader._clean(raw.replaceAll(StatementReader._nameEnd, ''));
      return n.length >= 2 && !own(raw) ? n : '';
    }

    // Labelled fields first, in the order this direction names the other side.
    final order = sign < 0
        ? const [_Field.merchant, _Field.to, _Field.from]
        : const [_Field.from, _Field.merchant, _Field.to];
    for (final f in order) {
      final v = fields[f];
      if (v == null) continue;
      final n = named(v);
      if (n.isNotEmpty) return n;
    }
    for (final l in lines) {
      final m = StatementReader._payeeField.firstMatch(l);
      final n = m == null ? '' : named(m[1]!);
      if (n.isNotEmpty) return n;
    }

    // Free text: "at X", then "to X" or "from X" by direction.
    String inText(RegExp re) {
      for (final m in re.allMatches(flat)) {
        final n = named(m[1]!);
        if (n.isNotEmpty) return n;
      }
      return '';
    }

    for (final re in [
      StatementReader._merchantAt,
      if (sign < 0) StatementReader._paidTo else StatementReader._paidFrom,
      if (sign < 0) StatementReader._paidFrom else StatementReader._paidTo,
    ]) {
      final n = inText(re);
      if (n.isNotEmpty) return n;
    }

    // Else the first unlabelled words that aren't a figure or a date.
    final first = lines.firstWhere((l) => _fieldLine.firstMatch(l) == null, orElse: () => flat);
    final (_, spans) = _dates(first);
    final cut = [
      ...spans,
      for (final m in StatementReader._time.allMatches(first)) _Span(m.start, m.end),
      ..._amounts(first, spans).map((a) => a.span),
    ]..sort((a, b) => a.start - b.start);
    final b = StringBuffer();
    var i = 0;
    for (final s in cut) {
      if (s.start > i) b.write(first.substring(i, s.start));
      b.write(' · ');
      i = math.max(i, s.end);
    }
    if (i < first.length) b.write(first.substring(i));
    return StatementReader._clean(
        b.toString().split(' · ').firstWhere((p) => StatementReader._clean(p).length >= 2, orElse: () => ''));
  }
}

/// A figure written in a message, and where: offsets into the message as
/// `StatementReader.normalize` gives it.
class MessageFigure extends Equatable {
  final int start, end;

  /// As written, always positive.
  final double major;
  final String? currency;

  /// -1 written as out, 1 as in, 0 not said.
  final int sign;

  /// Words just before it name a balance or limit left.
  final bool left;

  const MessageFigure(this.start, this.end, this.major, this.currency, {this.sign = 0, this.left = false});

  @override
  List<Object?> get props => [start, end, major, currency, sign, left];
}

/// What learned shapes and the on-device model use to take a message's
/// figures from its own text.
extension MessageReading on StatementReader {
  /// Every amount [text] holds (dates, times and long reference numbers
  /// left out), in order. [text] must already be normalized.
  List<MessageFigure> figuresIn(String text) {
    _decideOrder([text]);
    final (_, dateSpans) = _dates(text);
    final times = [for (final m in StatementReader._time.allMatches(text)) _Span(m.start, m.end)];
    return [
      for (final a in _amounts(text, [...dateSpans, ...times]))
        MessageFigure(a.span.start, a.span.end, a.value.major.abs(), a.value.currency,
            sign: a.value.sign,
            left: StatementReader._leftBefore.hasMatch(text.substring(math.max(0, a.span.start - 40), a.span.start))),
    ];
  }

  /// The rules' reading of one message ([rows]) with what the on-device
  /// model says it is ([labels]):
  ///
  /// - A message the model reads as no money moving (a notice, a code, a
  ///   declined payment) keeps its row, marked doubtful (unticked); one the
  ///   rules read as no money moving but the model does gets a row, also
  ///   doubtful.
  /// - Every figure comes from the words the model copied; words that are
  ///   not in the message, or hold no figure, drop the model's reading.
  /// - The model's amount replaces the rules' only when the rules took the
  ///   balance left, or gave no amount; its direction replaces a guessed
  ///   one (a direction it disagrees on is left for the person to check);
  ///   its name, when the message holds it, replaces the rules'.
  List<StatementRow> withMessageLabels(String text, List<StatementRow> rows, MessageLabels labels) {
    if (rows.length > 1) return rows;
    final t = StatementReader.normalize(text).replaceAll(RegExp(r'\s+'), ' ').trim();
    final figures = figuresIn(t);

    // The figure inside the words the model copied: null when none was
    // copied, false when the words aren't in the message or hold no figure.
    Object? figureAt(String words) {
      final w = StatementReader.normalize(words).replaceAll(RegExp(r'\s+'), ' ').trim();
      if (w.isEmpty) return null;
      final at = t.toLowerCase().indexOf(w.toLowerCase());
      if (at < 0) return false;
      return figures.where((f) => f.start < at + w.length && f.end > at).firstOrNull ?? false;
    }

    final amount = figureAt(labels.amount);
    final balance = figureAt(labels.balance);
    if (amount == false || balance == false) return rows;
    final amountFigure = amount as MessageFigure?;
    final balanceFigure = balance as MessageFigure?;
    if (amountFigure != null && amountFigure == balanceFigure) return rows;

    final intent = labels.intent;
    if (intent != null && !intent.transaction) {
      return [for (final r in rows) r.copyWith(doubtful: true)];
    }

    final name = labels.name.isNotEmpty && t.toLowerCase().contains(labels.name.toLowerCase())
        ? StatementReader._clean(labels.name)
        : '';
    final direction = intent?.direction ?? 0;

    if (rows.isEmpty) {
      if (amountFigure == null || intent == null) return rows;
      final sign = direction != 0 ? direction : (amountFigure.sign != 0 ? amountFigure.sign : -1);
      final date = _dates(t).$1.firstOrNull?.value;
      return [
        StatementRow(
          date: date ?? DateTime(received.year, received.month, received.day),
          dateGuessed: date == null,
          description: name,
          detail: t,
          amount: amountFigure.major * sign,
          signGuessed: direction == 0 && amountFigure.sign == 0,
          currency: amountFigure.currency ?? figures.map((f) => f.currency).nonNulls.firstOrNull,
          // The words say nothing moved (a code, a decline): the person decides.
          doubtful: !messageIntent(t).transaction,
        ),
      ];
    }

    var r = rows.single;
    if (amountFigure != null && !StatementReader._same(amountFigure.major, r.amount.abs())) {
      final rulesTookLeft = figures.any((f) => f.left && StatementReader._same(f.major, r.amount.abs())) ||
          (balanceFigure != null && StatementReader._same(balanceFigure.major, r.amount.abs()));
      if (rulesTookLeft && !amountFigure.left) {
        r = r.copyWith(amount: amountFigure.major * (r.amount < 0 ? -1 : 1), currency: amountFigure.currency ?? r.currency);
      }
    }
    if (direction != 0 && r.signGuessed) {
      r = r.copyWith(amount: r.amount.abs() * direction, signGuessed: false);
    } else if (direction != 0 && (r.amount > 0) != (direction > 0)) {
      // The words and the model disagree: the person decides.
      r = r.copyWith(signGuessed: true);
    }
    // Who it was with is language: the model's reading, found in the
    // message, beats the rules' fallback of the first words.
    if (name.length >= 2) r = r.copyWith(description: name);
    return [r];
  }
}
