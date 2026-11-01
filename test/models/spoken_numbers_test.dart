import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/spoken_numbers.dart';

void main() {
  String d(String s) => SpokenNumbers.toDigits(s);

  group('English', () {
    test('compound numbers', () {
      expect(d('twenty one grams of gold'), '21 grams of gold');
      expect(d('four thousand one hundred pounds'), '4100 pounds');
      expect(d('two hundred and fifty'), '250');
      expect(d('three hundred thousand'), '300000');
    });

    test('halves', () {
      expect(d('two and a half ounces'), '2.5 ounces');
    });

    test('other words and digits are untouched', () {
      expect(d('bought 20 g of gold at 4,100 EGP'), 'bought 20 g of gold at 4,100 EGP');
      expect(d('gold and silver'), 'gold and silver');
      expect(d('twenty and silver'), '20 and silver');
    });
  });

  group('Arabic', () {
    test('units joined by و', () {
      expect(d('اشتريت واحد وعشرين جرام ذهب'), 'اشتريت 21 جرام ذهب');
      expect(d('عيار واحد و عشرين'), 'عيار 21');
    });

    test('hundreds and thousands', () {
      expect(d('بسعر أربعة آلاف ومية'), 'بسعر 4100');
      expect(d('ألف وخمسمية جنيه'), '1500 جنيه');
      expect(d('ألفين جنيه'), '2000 جنيه');
      expect(d('ميتين جرام'), '200 جرام');
    });

    test('a half', () {
      expect(d('اتنين ونص جرام'), '2.5 جرام');
    });

    test('spelling variants fold', () {
      expect(d('ثلاثة جرام'), '3 جرام');
      expect(d('ثلاثه جرام'), '3 جرام');
      expect(d('إثنين'), '2');
    });

    test('ordinary words stay', () {
      expect(d('بعت ذهب اليوم'), 'بعت ذهب اليوم');
    });
  });
}
