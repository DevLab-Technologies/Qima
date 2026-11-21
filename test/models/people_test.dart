import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/book.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/people.dart';

void main() {
  test('the same name however it was typed', () {
    expect(personKey('  Faisal   Ali '), personKey('faisal ali'));
    expect(personKey('أحمد'), personKey('احمد'));
    expect(personKey('مصطفى'), personKey('مصطفي'));
    expect(personKey('فاطمة'), personKey('فاطمه'));
    expect(personKey('مُحَمَّد'), personKey('محمد'));
    expect(personKey('Faisal'), isNot(personKey('Fahad')));
  });

  test('one person, lent to and borrowed from, nets out; another currency is its own', () {
    BookAccount person(String id, String name, AccountType type, String ccy) =>
        BookAccount(id: id, name: name, side: type == AccountType.receivable ? AccountSide.own : AccountSide.owe, type: type, currency: ccy);
    final bank = BookAccount(id: 'bank', name: 'Bank', side: AccountSide.own, type: AccountType.debit, currency: 'SAR');
    final lent = person('p1', 'Faisal', AccountType.receivable, 'SAR');
    final borrowed = person('p2', 'faisal', AccountType.payable, 'SAR');
    final usd = person('p3', 'Faisal', AccountType.receivable, 'USD');
    final other = person('p4', 'Khalid', AccountType.payable, 'SAR');
    final people = Person.of([bank, lent, borrowed, usd, other]);
    expect(people.map((p) => (p.name, p.currency, p.accounts.length)), [('Faisal', 'SAR', 2), ('Faisal', 'USD', 1), ('Khalid', 'SAR', 1)]);
    final book = Book([bank, lent, borrowed], [
      BookEntry(id: 'e1', date: DateTime(2026, 10, 1), template: EntryTemplate.lent, baseCurrency: 'SAR', lines: const [
        EntryLine(accountId: 'bank', amount: -300000, currency: 'SAR', baseAmount: -300000),
        EntryLine(accountId: 'p1', amount: 300000, currency: 'SAR', baseAmount: 300000),
      ]),
      BookEntry(id: 'e2', date: DateTime(2026, 10, 5), template: EntryTemplate.borrowed, baseCurrency: 'SAR', lines: const [
        EntryLine(accountId: 'bank', amount: 50000, currency: 'SAR', baseAmount: 50000),
        EntryLine(accountId: 'p2', amount: -50000, currency: 'SAR', baseAmount: -50000),
      ]),
    ]);
    expect(people.first.net(book), 250000);
    expect(Person.names([lent, borrowed, usd, other]), ['Faisal', 'Khalid']);
  });
}
