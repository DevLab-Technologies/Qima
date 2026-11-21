import 'package:equatable/equatable.dart';

import 'statement_reader.dart';

/// Who sent a bank message, as one key: "SNB-AlAhli", "+966 55…" and
/// "snb-alahli " are the same sender. Empty when the sender isn't known.
String senderKey(String? raw) => (raw ?? '').trim().toLowerCase().replaceAll(RegExp(r'[\s+\-_.]'), '');

/// How one sender writes one kind of message, learned from a message the
/// person corrected on the review screen: the words just before its amount,
/// the words around who it was with, and which way the money went.
///
/// No bank's wording is written into Qima: a shape exists only because the
/// person fixed a message like it. The amount is still read from the new
/// message's own figures; the shape only says which of them it is.
class MessageShape extends Equatable {
  /// [senderKey] of the sender, or empty for messages that came without one.
  final String sender;

  /// The words before the amount, nearest last, as [_word] gives them.
  final List<String> amountBefore;

  /// The words before who it was with, nearest last; empty when the name
  /// wasn't found in the message.
  final List<String> nameBefore;

  /// The word just after the name, or [_lineEnd].
  final String nameAfter;

  /// -1 money out, 1 money in.
  final int direction;

  const MessageShape({
    required this.sender,
    required this.amountBefore,
    required this.direction,
    this.nameBefore = const [],
    this.nameAfter = '',
  });

  static const keep = 100;
  static const _lineEnd = '\n';
  static const _figure = '\u0001';

  /// The shape of [text] as the person corrected it ([corrected]), or null
  /// when its amount isn't one of the message's own figures.
  static MessageShape? learn({required String text, required String sender, required StatementRow corrected, required StatementReader reader}) {
    final words = _Words.of(text, reader);
    final at = words.figures.indexWhere((f) => _same(f.major, corrected.amount.abs()));
    if (at < 0) return null;
    final amountIndex = words.figureToken[at];
    final amountBefore = words.before(amountIndex, 3);
    if (amountBefore.isEmpty) return null;

    var nameBefore = const <String>[];
    var nameAfter = '';
    final name = _tokens(StatementReader.normalize(corrected.description)).map(_bare).where((w) => w.isNotEmpty).toList();
    if (name.isNotEmpty) {
      for (var i = 0; i + name.length <= words.raw.length; i++) {
        var fits = true;
        for (var j = 0; j < name.length && fits; j++) {
          fits = _bare(words.raw[i + j]) == name[j];
        }
        if (!fits) continue;
        nameBefore = words.before(i, 2);
        final end = i + name.length;
        nameAfter = end < words.shape.length ? words.shape[end] : _lineEnd;
        break;
      }
    }
    return MessageShape(
      sender: senderKey(sender),
      amountBefore: amountBefore,
      nameBefore: nameBefore,
      nameAfter: nameAfter,
      direction: corrected.amount < 0 ? -1 : 1,
    );
  }

  /// Whether two shapes would read the same message the same way, so the
  /// newer replaces the older.
  bool sameAs(MessageShape other) => other.sender == sender && _listEq(other.amountBefore, amountBefore);

  /// [rows] (the rules' reading of one message, or none) read the way this
  /// shape says, or null when [text] isn't a message of this shape.
  StatementRow? apply(String text, List<StatementRow> rows, StatementReader reader) {
    if (rows.length > 1) return null;
    final words = _Words.of(text, reader);
    int? amountAt;
    for (var k = 0; k < words.figures.length; k++) {
      if (_listEq(words.before(words.figureToken[k], amountBefore.length), amountBefore)) {
        amountAt = k;
        break;
      }
    }
    if (amountAt == null) return null;
    final figure = words.figures[amountAt];

    var name = '';
    if (nameBefore.isNotEmpty) {
      for (var i = 0; i < words.shape.length && name.isEmpty; i++) {
        if (!_listEq(words.before(i, nameBefore.length), nameBefore)) continue;
        final taken = <String>[];
        for (var j = i; j < words.shape.length && taken.length < 8; j++) {
          final w = words.shape[j];
          if (w == nameAfter || w == _lineEnd || w == _figure) break;
          taken.add(words.raw[j]);
        }
        name = taken.join(' ').replaceAll(RegExp(r'^[\s:،,.\-]+|[\s:،,.\-]+$'), '').trim();
      }
    }

    final base = rows.firstOrNull;
    final flat = StatementReader.normalize(text).replaceAll(RegExp(r'\s+'), ' ').trim();
    return StatementRow(
      date: base?.date ?? DateTime(reader.received.year, reader.received.month, reader.received.day),
      dateGuessed: base?.dateGuessed ?? true,
      description: name.isNotEmpty ? name : (base?.description ?? ''),
      detail: base?.detail ?? flat,
      amount: figure.major * direction,
      currency: figure.currency ?? base?.currency,
    );
  }

  Map<String, dynamic> toJson() => {
        's': sender,
        'a': amountBefore,
        if (nameBefore.isNotEmpty) 'nb': nameBefore,
        if (nameAfter.isNotEmpty) 'na': nameAfter,
        'd': direction,
      };

  static MessageShape? fromJson(Object? json) {
    if (json is! Map) return null;
    List<String> words(Object? v) => [for (final w in (v as List? ?? const [])) if (w is String) w];
    final before = words(json['a']);
    final d = json['d'];
    if (before.isEmpty || d is! num) return null;
    return MessageShape(
      sender: json['s'] as String? ?? '',
      amountBefore: before,
      nameBefore: words(json['nb']),
      nameAfter: json['na'] as String? ?? '',
      direction: d < 0 ? -1 : 1,
    );
  }

  /// [shapes] with [learned] in, newest last, each replacing one that reads
  /// the same way, and at most [keep] kept.
  static List<MessageShape> merge(List<MessageShape> shapes, Iterable<MessageShape> learned) {
    final out = [...shapes];
    for (final s in learned) {
      out.removeWhere(s.sameAs);
      out.add(s);
    }
    return out.length > keep ? out.sublist(out.length - keep) : out;
  }

  /// The first of [shapes] from [sender] that reads [text], or null.
  static StatementRow? read(List<MessageShape> shapes, String? sender, String text, List<StatementRow> rows, StatementReader reader) {
    final key = senderKey(sender);
    for (final s in shapes.reversed) {
      if (s.sender != key) continue;
      final row = s.apply(text, rows, reader);
      if (row != null) return row;
    }
    return null;
  }

  static bool _same(double a, double b) => (a * 1000).round() == (b * 1000).round();

  static bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// A word without the punctuation around it, in lower case.
  static String _bare(String w) => w.toLowerCase().replaceAll(RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true), '');

  static List<String> _tokens(String s) => RegExp(r'\S+').allMatches(s).map((m) => m[0]!).toList();

  @override
  List<Object?> get props => [sender, amountBefore, nameBefore, nameAfter, direction];
}

/// A message as words: each figure is one word of its own, and each line
/// break is a word, so a shape can say "the line ends here".
class _Words {
  /// The words as written (a figure as written too, a line break as "\n").
  final List<String> raw;

  /// The same words as shapes compare them: lower case, digits as "#", a
  /// figure as [MessageShape._figure].
  final List<String> shape;
  final List<MessageFigure> figures;

  /// For each figure, the index of its word.
  final List<int> figureToken;

  _Words(this.raw, this.shape, this.figures, this.figureToken);

  factory _Words.of(String text, StatementReader reader) {
    final lines = StatementReader.normalize(text).split('\n').map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim()).where((l) => l.isNotEmpty);
    final raw = <String>[], shape = <String>[], figures = <MessageFigure>[], figureToken = <int>[];
    for (final line in lines) {
      if (raw.isNotEmpty) {
        raw.add(MessageShape._lineEnd);
        shape.add(MessageShape._lineEnd);
      }
      final found = reader.figuresIn(line);
      var i = 0;
      void words(String s) {
        for (final w in RegExp(r'\S+').allMatches(s)) {
          raw.add(w[0]!);
          shape.add(_word(w[0]!));
        }
      }

      for (final f in found) {
        if (f.start < i) continue;
        words(line.substring(i, f.start));
        figureToken.add(raw.length);
        figures.add(f);
        raw.add(line.substring(f.start, f.end));
        shape.add(MessageShape._figure);
        i = f.end;
      }
      words(line.substring(i));
    }
    return _Words(raw, shape, figures, figureToken);
  }

  /// Up to [n] words before [index], nearest last.
  List<String> before(int index, int n) => shape.sublist((index - n).clamp(0, index), index);

  static String _word(String w) => w.toLowerCase().replaceAll(RegExp(r'\d+'), '#');
}
