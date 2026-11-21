import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/spoken_entry.dart';

/// Sentences as people say them, against a book whose accounts are named
/// the way people name them: mostly in English, a few in Arabic.
void main() {
  const accounts = {
    'rahalah': 'ENBD Rahalah',
    'rajhi': 'Al Rajhi current',
    'snb': 'SNB',
    'alinma': 'Alinma',
    'stc': 'STC Bank',
    'cash': 'Cash',
    'wallet': 'Wallet',
    'cib': 'CIB EGP Debit',
    'cibcard': 'CIB Credit Card',
    'misr': 'Banque Misr',
    'riyad': 'Riyad Bank',
    'tabby': 'تابي',
  };
  const categories = {'groceries': 'Groceries', 'dining': 'Dining', 'transport': 'Transport', 'bills': 'Bills', 'salary': 'Salary'};

  // sentence, kind, amount, merchant, accounts, days ago
  const cases = <(String, SpokenKind?, String?, String?, List<String>, int?)>[
    // Gulf Arabic
    ('صرفت 45 ريال في هرفي من الراجحي', SpokenKind.spend, '45', 'هرفي', ['rajhi'], null),
    ('دفعت ١٢٠ بكارت رحالة في جرير', SpokenKind.spend, '120', 'جرير', ['rahalah'], null),
    ('اشتريت قهوة ب 18 ريال من ستاربكس بالكاش', SpokenKind.spend, '18', 'ستاربكس', ['cash'], null),
    ('حولت 2000 من الراجحي للإنماء', SpokenKind.transfer, '2000', null, ['rajhi', 'alinma'], null),
    ('استلمت الراتب ١٥٠٠٠ في الأهلي', SpokenKind.income, '15000', null, ['snb'], null),
    ('دفعت فاتورة الكهرباء ٣٢٠ من stc bank', SpokenKind.spend, '320', null, ['stc'], null),
    ('صرفت مية وخمسين ريال في بنده امس', SpokenKind.spend, '150', 'بنده', [], 1),
    ('دفعت ٢٣٠ بتابي في نون', SpokenKind.spend, '230', 'نون', ['tabby'], null),
    ('اشتريت او صرفت ٨٩٩ ريال في بندة امبارح من حساب من كارت راحلة', SpokenKind.spend, '899', 'بندة', ['rahalah'], 1),
    ('دفعت ٦٠ في الدانوب بفيزا الرياض', SpokenKind.spend, '60', 'الدانوب', ['riyad'], null),
    // Egyptian Arabic
    ('دفعت ٣٥٠ جنيه في كارفور من سي آي بي', SpokenKind.spend, '350', 'كارفور', ['cib'], null),
    ('صرفت ٨٠ جنيه في أوبر امبارح بالمحفظة', SpokenKind.spend, '80', 'أوبر', ['wallet'], 1),
    ('حولت ٥٠٠٠ من بنك مصر لسي اي بي', SpokenKind.transfer, '5000', null, ['misr', 'cib'], null),
    ('قبضت المرتب ٢٢ ألف في بنك مصر', SpokenKind.income, '22000', null, ['misr'], null),
    ('اشتريت ب 450 جنيه من كارفور من CIB Debit', SpokenKind.spend, '450', 'كارفور', ['cib'], null),
    ('شريت ب4 مية وخمسين جنيه من كارفور Cib Depot', SpokenKind.spend, '450', 'كارفور', ['cib'], null),
    ('اشتريت بأربعمية وخمسين جنيه من كارفور من سي اي بي ديبت', SpokenKind.spend, '450', 'كارفور', ['cib'], null),
    ('دفعت ١٢٠٠ في زارا بالكريدت كارد بتاع سي اي بي', SpokenKind.spend, '1200', 'زارا', ['cibcard'], null),
    ('دفعت ٢ ألف و٥٠٠ في ايكيا', SpokenKind.spend, '2500', 'ايكيا', [], null),
    // English
    ('Paid 230 at Jarir with Rahalah card', SpokenKind.spend, '230', 'Jarir', ['rahalah'], null),
    ('spent 60 riyals on dining at Al Baik using cash', SpokenKind.spend, '60', 'Al Baik', ['cash'], null),
    ('transferred 500 from Rajhi to SNB', SpokenKind.transfer, '500', null, ['rajhi', 'snb'], null),
    ('I spent 899 Saudi riyal in Panda yesterday from my ENBD card', SpokenKind.spend, '899', 'Panda', ['rahalah'], 1),
    ('got paid 18,500 into Alinma', SpokenKind.income, '18500', null, ['alinma'], null),
    ('bought groceries for 312.75 at Tamimi with STC', SpokenKind.spend, '312.75', 'Tamimi', ['stc'], null),
    // Mixed, as people speak
    ('صرفت 75 في McDonalds بالـ Rahalah', SpokenKind.spend, '75', 'McDonalds', ['rahalah'], null),
    ('paid 40 في بنده من الراجحي', SpokenKind.spend, '40', 'بنده', ['rajhi'], null),
    ('استلمت ٣ آلاف من الشغل الاضافي في الإنماء', SpokenKind.income, '3000', 'الشغل الاضافي', ['alinma'], null),
    ('received 18 thousand in SNB', SpokenKind.income, '18000', null, ['snb'], null),
    ('received a 2.5k bonus in Rajhi', SpokenKind.income, '2500', null, ['rajhi'], null),
    ('دفعت ٤٥ بالكاش في البيك', SpokenKind.spend, '45', 'البيك', ['cash'], null),
    ('صرفت ١١٠ في بنده بالمحفظه', SpokenKind.spend, '110', 'بنده', ['wallet'], null),
    // Nothing that names an account
    ('صرفت ٥٠ ريال اليوم', SpokenKind.spend, '50', null, [], null),
    ('دفعت ٣٠٠ في المطعم', SpokenKind.spend, '300', 'المطعم', [], null),
    ('Spent 40 at Starbucks', SpokenKind.spend, '40', 'Starbucks', [], null),
    ('اشتريت هدوم ب ٤٠٠ من سنتربوينت', SpokenKind.spend, '400', 'سنتربوينت', [], null),
    ('دفعت ٩٠ في صيدلية النهدي', SpokenKind.spend, '90', 'صيدلية النهدي', [], null),
    ('صرفت ٢٥٠ في محطة البنزين', SpokenKind.spend, '250', 'محطة البنزين', [], null),
    ('paid 15 for parking', SpokenKind.spend, '15', null, [], null),
  ];

  final misses = <String>[];
  for (final (said, kind, amount, merchant, ids, daysAgo) in cases) {
    test(said, () {
      final e = SpokenEntry.parse(said, accounts: accounts, categories: categories);
      final got = '${e.kind?.name} | ${e.amount} | ${e.merchant} | ${e.accountIds} | ${e.daysAgo}';
      final want = '${kind?.name} | $amount | $merchant | $ids | $daysAgo';
      if (got != want) misses.add('$said\n   want $want\n   got  $got');
      expect(got, want);
    });
  }
  tearDownAll(() {
    // ignore: avoid_print
    if (misses.isNotEmpty) print('\n${misses.length} of ${cases.length} missed:\n${misses.join('\n')}');
  });
}
