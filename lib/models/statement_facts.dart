import 'package:equatable/equatable.dart';

import 'statement_reader.dart';

/// Which account a statement is from: the last four digits of an account
/// number, an IBAN or a card, as the statement shows them.
class StatementRef extends Equatable {
  final StatementRefKind kind;

  /// The last four digits.
  final String last4;

  const StatementRef(this.kind, this.last4);

  /// As stored on an account to recognise its statements next time.
  String get key => '${kind.name}:$last4';

  static StatementRef? fromKey(String key) {
    final i = key.indexOf(':');
    if (i < 0) return null;
    final kind = StatementRefKind.values.where((k) => k.name == key.substring(0, i)).firstOrNull;
    final last4 = key.substring(i + 1);
    return kind == null || !RegExp(r'^\d{4}$').hasMatch(last4) ? null : StatementRef(kind, last4);
  }

  @override
  List<Object?> get props => [kind, last4];
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
          {double? opening, double? closing, bool? openingWorkedOut, bool? closingWorkedOut, bool? closingAvailable, List<StatementRef>? refs}) =>
      StatementFacts(
        opening: opening ?? this.opening,
        closing: closing ?? this.closing,
        openingWorkedOut: openingWorkedOut ?? this.openingWorkedOut,
        closingWorkedOut: closingWorkedOut ?? this.closingWorkedOut,
        closingAvailable: closingAvailable ?? this.closingAvailable,
        refs: refs ?? this.refs,
        from: from,
        to: to,
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
