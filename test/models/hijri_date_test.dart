import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/hijri_date.dart';

void main() {
  group('HijriDate', () {
    test('converts known Umm al-Qura dates both ways', () {
      // 1 Ramadan 1446 began on 1 March 2025; 1 Muharram 1447 on 26 June 2025.
      expect(HijriDate.fromGregorian(DateTime(2025, 3, 1)), const HijriDate(1446, 9, 1));
      expect(HijriDate.fromGregorian(DateTime(2025, 6, 26)), const HijriDate(1447, 1, 1));
      expect(const HijriDate(1446, 9, 1).toGregorian(), DateTime(2025, 3, 1));
      expect(const HijriDate(1447, 1, 1).toGregorian(), DateTime(2025, 6, 26));
    });

    test('ignores the time of day', () {
      expect(HijriDate.fromGregorian(DateTime(2025, 3, 1, 23, 59)), const HijriDate(1446, 9, 1));
    });

    test('returns null outside the table instead of throwing', () {
      expect(HijriDate.fromGregorian(DateTime(1900, 1, 1)), isNull);
      expect(HijriDate.fromGregorian(DateTime(2090, 1, 1)), isNull);
      expect(HijriDate.daysInMonth(1600, 1), isNull);
      expect(const HijriDate(1600, 1, 1).toGregorian(), isNull);
    });

    test('validates month lengths', () {
      for (var m = 1; m <= 12; m++) {
        final length = HijriDate.daysInMonth(1446, m)!;
        expect(length, anyOf(29, 30));
        expect(HijriDate(1446, m, length).isValid, isTrue);
        expect(HijriDate(1446, m, length + 1).isValid, isFalse);
      }
      expect(const HijriDate(1446, 13, 1).isValid, isFalse);
      expect(const HijriDate(1446, 1, 0).isValid, isFalse);
    });

    test('addYears clamps a 30th to the last day of a 29-day month', () {
      // Find a month that has 30 days one year and 29 the next.
      for (var m = 1; m <= 12; m++) {
        if (HijriDate.daysInMonth(1446, m) == 30 && HijriDate.daysInMonth(1447, m) == 29) {
          expect(HijriDate(1446, m, 30).addYears(1), HijriDate(1447, m, 29));
          return;
        }
      }
      fail('no 30→29 month pair found between 1446 and 1447');
    });

    test('a Hijri year is about 354 days', () {
      final start = const HijriDate(1446, 9, 12).toGregorian()!;
      final next = const HijriDate(1446, 9, 12).addYears(1)!.toGregorian()!;
      expect(next.difference(start).inDays, inInclusiveRange(354, 355));
    });

    test('orders chronologically', () {
      final dates = [const HijriDate(1447, 1, 1), const HijriDate(1446, 12, 30), const HijriDate(1446, 9, 1)]..sort();
      expect(dates.first, const HijriDate(1446, 9, 1));
      expect(dates.last, const HijriDate(1447, 1, 1));
    });
  });
}
