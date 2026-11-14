import 'package:equatable/equatable.dart';

import 'statement_reader.dart';

/// Which account a statement is from: the last four digits of an account
/// number, an IBAN or a card, as the statement shows them.
class StatementRef extends Equatable {
  final StatementRefKind kind;

  /// The last four digits.
  final String last4;

  /// How many digits the whole number has, when the statement shows it in
  /// full: two accounts can end alike (a loan's 16-digit …0001 and a bank
  /// account's 12-digit …001).
  final int? digits;

  const StatementRef(this.kind, this.last4, [this.digits]);

  /// As stored on an account to recognise its statements next time.
  String get key => '${kind.name}:$last4${digits == null ? '' : '/$digits'}';

  static StatementRef? fromKey(String key) {
    final m = RegExp(r'^(\w+):(\d{4})(?:/(\d{1,2}))?$').firstMatch(key);
    if (m == null) return null;
    final kind = StatementRefKind.values.where((k) => k.name == m[1]).firstOrNull;
    return kind == null ? null : StatementRef(kind, m[2]!, m[3] == null ? null : int.parse(m[3]!));
  }

  /// A number the person typed for an account: the whole number or just its
  /// last four digits. Only the last four are kept, with the length of a
  /// whole account number or IBAN to tell apart two that end alike. Null
  /// when fewer than four digits were typed.
  static StatementRef? typed(StatementRefKind kind, String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return null;
    final whole = kind != StatementRefKind.card && digits.length > 4;
    return StatementRef(kind, digits.substring(digits.length - 4), whole ? digits.length : null);
  }

  /// Whether a stored [key] names the same number. A length known on only
  /// one side doesn't tell them apart.
  bool matches(String key) {
    final other = fromKey(key);
    return other != null && other.kind == kind && other.last4 == last4 && (other.digits == null || digits == null || other.digits == digits);
  }

  @override
  List<Object?> get props => [kind, last4, digits];
}

enum StatementRefKind { account, iban, card }

/// What a statement says about itself, besides its transactions. Every
/// figure is read from the document (or worked out from its running
/// balance, said by [openingWorkedOut] and [closingWorkedOut]); none is
/// made up.
class StatementFacts extends Equatable {
  final double? opening;
  final double? closing;
  final bool openingWorkedOut;
  final bool closingWorkedOut;

  /// The closing figure was labelled "available": on a card that is the
  /// credit left, not what is owed.
  final bool closingAvailable;
  final List<StatementRef> refs;
  final DateTime? from;
  final DateTime? to;
  final String? currency;

  const StatementFacts({
    this.opening,
    this.closing,
    this.openingWorkedOut = false,
    this.closingWorkedOut = false,
    this.closingAvailable = false,
    this.refs = const [],
    this.from,
    this.to,
    this.currency,
  });

  static const none = StatementFacts();

  bool get isEmpty => opening == null && closing == null && refs.isEmpty;

  StatementFacts copyWith(
          {double? opening,
          double? closing,
          bool? openingWorkedOut,
          bool? closingWorkedOut,
          bool? closingAvailable,
          List<StatementRef>? refs,
          DateTime? from,
          DateTime? to}) =>
      StatementFacts(
        opening: opening ?? this.opening,
        closing: closing ?? this.closing,
        openingWorkedOut: openingWorkedOut ?? this.openingWorkedOut,
        closingWorkedOut: closingWorkedOut ?? this.closingWorkedOut,
        closingAvailable: closingAvailable ?? this.closingAvailable,
        refs: refs ?? this.refs,
        from: from ?? this.from,
        to: to ?? this.to,
        currency: currency,
      );

  @override
  List<Object?> get props => [opening, closing, openingWorkedOut, closingWorkedOut, closingAvailable, refs, from, to, currency];
}

/// Whether the rows read account for the whole statement: the opening
/// balance plus every row comes to the closing balance. When it does, no
/// row was missed or misread; when it doesn't, [gap] says by how much.
class Reconciliation extends Equatable {
  /// Closing balance minus what the opening balance and the rows come to,
  /// in the statement's currency. Zero when it adds up.
  final double gap;

  /// The statement counts what is owed (a card): money out raises it.
  final bool owed;

  const Reconciliation(this.gap, {this.owed = false});

  bool get addsUp => gap.abs() < 0.005;

  /// Null when the statement doesn't give both balances. Rows not written
  /// in the statement's currency are left out.
  static Reconciliation? of(StatementFacts facts, List<StatementRow> rows) {
    final opening = facts.opening, closing = facts.closing;
    if (opening == null || closing == null || rows.isEmpty) return null;
    // Balances worked out from the rows always add up; that proves nothing.
    if (facts.openingWorkedOut && facts.closingWorkedOut) return null;
    var sum = 0.0;
    for (final r in rows) {
      if (r.currency != null && facts.currency != null && r.currency != facts.currency) continue;
      sum += r.amount;
    }
    final asMoney = closing - (opening + sum);
    final asOwed = closing - (opening - sum);
    double round(double v) => (v * 100).round() / 100;
    return asOwed.abs() < asMoney.abs() - 0.005 ? Reconciliation(round(asOwed), owed: true) : Reconciliation(round(asMoney));
  }

  @override
  List<Object?> get props => [gap, owed];
}

/// What the on-device model says one line of a document is.
enum LineKind { transaction, opening, closing, account, other }

/// The on-device model's reading of one line: its kind and, for a
/// transaction, the words naming who was paid. The words are only used
/// when they are copied exactly from the line; the model never gives a
/// number.
class LineLabel extends Equatable {
  final int line;
  final LineKind kind;
  final String name;

  const LineLabel(this.line, this.kind, [this.name = '']);

  static LineLabel? fromMap(Map<Object?, Object?> m) {
    final line = m['line'], kind = m['kind'], name = m['name'];
    if (line is! int || kind is! String) return null;
    final k = switch (kind) {
      'transaction' => LineKind.transaction,
      'opening balance' => LineKind.opening,
      'closing balance' => LineKind.closing,
      'account' => LineKind.account,
      'other' => LineKind.other,
      _ => null,
    };
    return k == null ? null : LineLabel(line, k, name is String ? name.trim() : '');
  }

  @override
  List<Object?> get props => [line, kind, name];
}

/// One transaction as the on-device model sees it on a page: which of the
/// page's words ([DocPage.tokens], by index) are its date, amount, balance
/// and direction, and who it was with in its own words. Never a figure:
/// the reader takes every figure from the words pointed at.
class StructuredRow extends Equatable {
  final int? date;
  final int? amount;
  final int? balance;
  final List<int> direction;

  /// The payee or merchant as written on the picture; digits are dropped.
  final String name;

  const StructuredRow({this.date, this.amount, this.balance, this.direction = const [], this.name = ''});

  static StructuredRow? fromMap(Map<Object?, Object?> m) {
    int? id(Object? v) => v is int && v >= 0 ? v : null;
    final name = m['name'];
    return StructuredRow(
      date: id(m['date']),
      amount: id(m['amount']),
      balance: id(m['balance']),
      direction: [for (final v in (m['direction'] as List? ?? const [])) ?id(v)],
      name: name is String ? name.replaceAll(RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]'), '').trim() : '',
    );
  }

  @override
  List<Object?> get props => [date, amount, balance, direction, name];
}

/// What the on-device model says one page holds, as word indexes.
class PageStructure extends Equatable {
  final List<StructuredRow> rows;
  final int? opening;
  final int? closing;
  final int? account;

  const PageStructure({this.rows = const [], this.opening, this.closing, this.account});

  static PageStructure fromMap(Map<Object?, Object?> m) {
    int? id(Object? v) => v is int && v >= 0 ? v : null;
    return PageStructure(
      rows: [for (final r in (m['rows'] as List? ?? const [])) if (r is Map<Object?, Object?>) ?StructuredRow.fromMap(r)],
      opening: id(m['opening']),
      closing: id(m['closing']),
      account: id(m['account']),
    );
  }

  @override
  List<Object?> get props => [rows, opening, closing, account];
}

/// What the on-device model says one bank message is: what happened, and
/// the exact words of its amount, the balance it leaves and who it was
/// with. Never a figure of its own: the reader finds each of these words in
/// the message and reads the figure from them
/// (`StatementReader.withMessageLabels`).
class MessageLabels extends Equatable {
  /// Null when the model named no intent the reader knows.
  final MessageIntent? intent;
  final String amount;
  final String balance;

  /// Who the money went to or came from; digits are dropped.
  final String name;

  const MessageLabels({this.intent, this.amount = '', this.balance = '', this.name = ''});

  static MessageLabels? fromMap(Map<Object?, Object?> m) {
    String text(String key) => m[key] is String ? (m[key] as String).trim() : '';
    final intent = MessageIntent.values.asNameMap()[text('intent')];
    final out = MessageLabels(
      intent: intent,
      amount: text('amount'),
      balance: text('balance'),
      name: text('name').replaceAll(RegExp(r'[0-9٠-٩۰-۹]'), '').trim(),
    );
    return out.intent == null && out.amount.isEmpty ? null : out;
  }

  @override
  List<Object?> get props => [intent, amount, balance, name];
}
