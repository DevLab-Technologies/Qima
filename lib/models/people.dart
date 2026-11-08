import 'book.dart';
import 'book_account.dart';

/// The same person however their name was typed: case, spaces, Arabic
/// letter forms (أ إ آ ا, ى ي, ة ه), diacritics and tatweel don't matter.
String personKey(String name) => name
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[ً-ْٰـ]'), '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ة', 'ه')
    .replaceAll(RegExp(r'\s+'), ' ');

/// One person the book has money with, in one currency: the account for
/// what they owe the person using Qima, and the one for what is owed to
/// them. Either can be missing.
class Person {
  final String name;
  final String currency;
  final BookAccount? owesMe;
  final BookAccount? iOwe;

  const Person({required this.name, required this.currency, this.owesMe, this.iOwe});

  List<BookAccount> get accounts => [?owesMe, ?iOwe];

  /// What they owe minus what is owed to them, in [currency]; below zero
  /// when the person using Qima owes them.
  int net(Book book) => (owesMe == null ? 0 : book.balanceOf(owesMe!.id)) - (iOwe == null ? 0 : book.balanceOf(iOwe!.id));

  /// Everyone, once per name and currency, in the order first met.
  static List<Person> of(Iterable<BookAccount> accounts) {
    final found = <String, Person>{};
    for (final a in accounts) {
      if (a.archived || a.currency == null || (a.type != AccountType.receivable && a.type != AccountType.payable)) continue;
      final key = '${personKey(a.name)}|${a.currency}';
      final p = found[key];
      final owesMe = a.type == AccountType.receivable;
      found[key] = Person(
        name: p?.name ?? a.name,
        currency: a.currency!,
        owesMe: owesMe ? (p?.owesMe ?? a) : p?.owesMe,
        iOwe: owesMe ? p?.iOwe : (p?.iOwe ?? a),
      );
    }
    return found.values.toList();
  }

  /// Each name once, for picking someone already in the book.
  static List<String> names(Iterable<BookAccount> accounts) {
    final seen = <String>{};
    return [
      for (final p in of(accounts))
        if (seen.add(personKey(p.name))) p.name,
    ];
  }
}
