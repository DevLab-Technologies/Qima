import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/spoken_entry.dart';

void main() {
  const accounts = {'rajhi': 'Al Rajhi current account', 'wallet': 'Wallet', 'visa': 'Visa Signature', 'snb': 'SNB savings', 'ahli': 'حساب الأهلي'};
  const categories = {'category.groceries': 'Groceries', 'category.dining': 'Dining', 'category.salary': 'Salary', 'ar.groceries': 'بقالة'};
  SpokenEntry read(String s) => SpokenEntry.parse(s, accounts: accounts, categories: categories);

  test('a spend: amount, merchant, the card and the day, all as said', () {
    final e = read('Spent 45.50 at Panda with Visa yesterday');
    expect(e.kind, SpokenKind.spend);
    expect(e.amount, '45.50');
    expect(e.merchant, 'Panda');
    expect(e.accountIds, ['visa']);
    expect(e.daysAgo, 1);
  });

  test('"in" a shop, as recognizers often hear it', () {
    final e = read('I spent 899 Saudi riyal in Panda for groceries today with SNB');
    expect(e.amount, '899');
    expect(e.merchant, 'Panda');
    expect(e.categoryId, 'category.groceries');
    expect(e.accountIds, ['snb']);
  });

  test('Arabic speech names accounts written in English, and the shop keeps its spelling', () {
    final e = read('اشتريت ب ٨٩٩ ريال في بندة امبارح من كارت الراجحي');
    expect(e.amount, '899');
    expect(e.merchant, 'بندة');
    expect(e.accountIds, ['rajhi']);
    expect(e.daysAgo, 1);
    expect(read('دفعت ٥٠ بالفيزا').accountIds, ['visa']);
    // "حساب الأهلي" is written in Arabic, so it wins over SNB's other name.
    expect(read('حولت ١٠٠٠ من الاهلي للراجحي').accountIds, ['ahli', 'rajhi']);
  });

  test('any name said in the other script, by its sound', () {
    const mine = {'rahalah': 'ENBD Rahalah', 'snb': 'SNB', 'cash': 'Cash'};
    final e = SpokenEntry.parse('اشتريت او صرفت ٨٩٩ ريال في بندة امبارح من حساب من كارت راحلة', accounts: mine);
    expect(e.accountIds, ['rahalah']);
    expect(e.merchant, 'بندة');
    expect(SpokenEntry.parse('دفعت ١٠٠ من الكاش', accounts: mine).accountIds, ['cash']);
    // Words that only share a letter or two never match.
    expect(SpokenEntry.parse('صرفت ٥٠ ريال اليوم', accounts: mine).accountIds, isEmpty);
  });

  test('English speech names an account written in Arabic', () {
    final e = SpokenEntry.parse('spent 20 with Ahli on Rajhi card', accounts: const {'ahli': 'حساب الأهلي', 'rajhi': 'بطاقة الراجحي'});
    expect(e.accountIds, ['ahli', 'rajhi']);
  });

  test('a category said outright, and number words', () {
    final e = read('paid twenty one riyals on groceries at Danube');
    expect(e.amount, '21');
    expect(e.categoryId, 'category.groceries');
    expect(e.merchant, 'Danube');
  });

  test('income and a transfer between two accounts, in the order said', () {
    final income = read('received my salary 18,000 in Al Rajhi');
    expect(income.kind, SpokenKind.income);
    expect(income.amount, '18000');
    expect(income.accountIds, ['rajhi']);
    expect(read('got paid 300').kind, SpokenKind.income);

    final move = read('transferred 2,500 from SNB to my wallet');
    expect(move.kind, SpokenKind.transfer);
    expect(move.amount, '2500');
    expect(move.accountIds, ['snb', 'wallet']);
    expect(move.merchant, isNull);
  });

  test('Arabic: digits or words, an account said without "account", and the day before yesterday', () {
    final e = read('دفعت ٨٩ ريال في جرير من الاهلي قبل أمس');
    expect(e.kind, SpokenKind.spend);
    expect(e.amount, '89');
    expect(e.merchant, 'جرير');
    expect(e.accountIds, ['ahli']);
    expect(e.daysAgo, 2);

    final words = read('صرفت خمسين على بقالة');
    expect(words.amount, '50');
    expect(words.categoryId, 'ar.groceries');
    expect(read('استلمت الراتب').kind, SpokenKind.income);
    expect(SpokenEntry.parse('دفعت 45 في بنده بالفيزا', accounts: const {'visa': 'فيزا'}).accountIds, ['visa']);
    expect(SpokenEntry.parse('دفعت 45 في بنده بالفيزا', accounts: const {'visa': 'فيزا'}).merchant, 'بنده');
  });

  test('French and Spanish', () {
    final fr = read("J'ai payé 12,5 chez Carrefour hier");
    expect(fr.kind, SpokenKind.spend);
    expect(fr.amount, '12.5');
    expect(fr.merchant, 'Carrefour');
    expect(fr.daysAgo, 1);
    final es = read('gasté 30 en Mercadona con Visa');
    expect(es.amount, '30');
    expect(es.merchant, 'Mercadona');
    expect(es.accountIds, ['visa']);
  });

  test('nothing said that it knows leaves everything as it was', () {
    expect(read('hello there').isEmpty, isTrue);
    expect(read('1,250.75 at the bakery').amount, '1250.75');
    expect(read('1,250.75 at the bakery').merchant, 'The Bakery');
  });
}
