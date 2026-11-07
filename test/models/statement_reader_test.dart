import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/statement_reader.dart';

/// A line of cells at [y], each cell (text, x, width).
List<DocToken> line(double y, List<(String, double, double)> cells, {double h = 0.012}) =>
    [for (final (t, x, w) in cells) DocToken(t, x, y, w, h)];

void main() {
  final reader = StatementReader(received: DateTime(2026, 11, 7, 14));

  group('statement PDF tables', () {
    test('columns come from the header row', () {
      final page = DocPage([
        ...line(0.10, [('Date', 0.05, 0.08), ('Description', 0.18, 0.2), ('Debit', 0.55, 0.08), ('Credit', 0.68, 0.08), ('Balance', 0.82, 0.1)]),
        ...line(0.13, [('Opening balance', 0.18, 0.2), ('22,020.35', 0.82, 0.1)]),
        ...line(0.16, [('01/11/2026', 0.05, 0.1), ('SALARY NOV', 0.18, 0.2), ('18,000.00', 0.68, 0.1), ('40,020.35', 0.82, 0.1)]),
        ...line(0.19, [('03/11/2026', 0.05, 0.1), ('PANDA RIYADH', 0.18, 0.2), ('642.10', 0.55, 0.08), ('39,378.25', 0.82, 0.1)]),
        // A second line of the description, under it.
        ...line(0.205, [('POS 4412', 0.18, 0.1)]),
        // A whole number in the debit column is still money.
        ...line(0.23, [('04/11/2026', 0.05, 0.1), ('STC BILL', 0.18, 0.2), ('300', 0.55, 0.08), ('39,078.25', 0.82, 0.1)]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows, hasLength(3));
      expect(rows[0].description, 'SALARY NOV');
      expect(rows[0].amount, 18000);
      expect(rows[0].date, DateTime(2026, 11, 1));
      expect(rows[0].signGuessed, isFalse);
      expect(rows[1].description, 'PANDA RIYADH');
      expect(rows[1].detail, 'POS 4412');
      expect(rows[1].amount, -642.10);
      expect(rows[1].balance, 39378.25);
      expect(rows[2].amount, -300);
    });

    test('without a header, the running balance gives each sign, newest first too', () {
      final page = DocPage([
        ...line(0.10, [('05/11/2026 TRANSFER FROM KHALID 1,000.00 40,378.25', 0.05, 0.9)]),
        ...line(0.13, [('03/11/2026 PANDA RIYADH 642.10 39,378.25', 0.05, 0.9)]),
        ...line(0.16, [('01/11/2026 SALARY 18,000.00 40,020.35', 0.05, 0.9)]),
        ...line(0.19, [('30/10/2026 ALBAIK 45.00 22,020.35', 0.05, 0.9)]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows.map((r) => r.amount), [1000, -642.10, 18000, -45]);
      expect(rows.take(3).every((r) => !r.signGuessed), isTrue);
      expect(rows[1].description, 'PANDA RIYADH');
    });

    test('reference numbers, masked cards and times are never money', () {
      final page = DocPage([
        ...line(0.1, [('03/11/2026 10:42 Card ****1234 Ref 884512397 PANDA', 0.05, 0.6), ('SAR 642.10-', 0.7, 0.2)]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows, hasLength(1));
      expect(rows.single.amount, -642.10);
      expect(rows.single.currency, 'SAR');
      expect(rows.single.description, contains('PANDA'));
      expect(rows.single.description, isNot(contains('10:42')));
    });

    test('month-first dates are recognised from a day over 12', () {
      final page = DocPage([
        ...line(0.1, [('11/02/2026 AMAZON 25.99', 0.05, 0.9)]),
        ...line(0.13, [('11/23/2026 UBER 12.40', 0.05, 0.9)]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows[0].date, DateTime(2026, 11, 2));
      expect(rows[1].date, DateTime(2026, 11, 23));
    });

    test('parentheses and DR mean money out, CR money in', () {
      final page = DocPage([
        ...line(0.1, [('02 Nov 2026', 0.05, 0.1), ('Fee', 0.2, 0.2), ('(15.00)', 0.7, 0.1)]),
        ...line(0.13, [('02 Nov 2026', 0.05, 0.1), ('Refund NOON', 0.2, 0.2), ('99.00 CR', 0.7, 0.1)]),
        ...line(0.16, [('02 Nov 2026', 0.05, 0.1), ('JARIR', 0.2, 0.2), ('250.00 DR', 0.7, 0.1)]),
      ]);
      expect(reader.readPages([page]).map((r) => r.amount), [-15, 99, -250]);
    });

    test('a decimal comma is read as one', () {
      final page = DocPage(line(0.1, [('03.11.2026', 0.05, 0.1), ('LIDL', 0.2, 0.2), ('-1.234,56 EUR', 0.7, 0.2)]));
      final row = reader.readPages([page]).single;
      expect(row.amount, -1234.56);
      expect(row.currency, 'EUR');
      expect(row.date, DateTime(2026, 11, 3));
    });
  });

  group('real output of the native reader (PDFKit and Vision)', () {
    // The same statement as a PDF with a text layer and as a scan, read by
    // DocumentReader in TextRecognitionPlugin.swift.
    List<DocPage> fixture(String name) => [
          for (final p in jsonDecode(File('test/fixtures/statements/$name').readAsStringSync()) as List)
            DocPage([for (final t in (p as Map)['tokens'] as List) DocToken.fromJson(t as Map)]),
        ];
    const expected = [18000.0, -642.10, -300.0, -38.75, 1000.0, -86.40];

    for (final name in ['text_layer_pdf.json', 'scanned_pdf.json']) {
      test(name, () {
        final rows = reader.readPages(fixture(name));
        expect(rows.map((r) => r.amount), expected);
        expect(rows.first.description, 'SALARY NOVEMBER 2026');
        expect(rows.last.description, 'AL NAHDI PHARMACY 112');
        expect(rows.map((r) => r.date.day), [1, 2, 3, 4, 5, 6]);
        expect(rows.every((r) => !r.signGuessed), isTrue);
      });
    }
  });

  group('screenshots of a banking app', () {
    test('rows under a date heading, amount on the right', () {
      final page = DocPage([
        ...line(0.10, [('Today', 0.05, 0.15)], h: 0.02),
        ...line(0.14, [('Panda', 0.12, 0.2), ('-642.10 SAR', 0.70, 0.25)], h: 0.025),
        ...line(0.17, [('Groceries · 10:42', 0.12, 0.3)], h: 0.02),
        ...line(0.22, [('Yesterday', 0.05, 0.15)], h: 0.02),
        ...line(0.26, [('Salary', 0.12, 0.2), ('+18,000.00 SAR', 0.65, 0.3)], h: 0.025),
        ...line(0.31, [('3 Nov', 0.05, 0.15)], h: 0.02),
        ...line(0.35, [('Al Baik', 0.12, 0.2), ('SAR 45.00', 0.70, 0.25)], h: 0.025),
      ]);
      final rows = reader.readPages([page]);
      expect(rows, hasLength(3));
      expect(rows[0].description, 'Panda');
      expect(rows[0].date, DateTime(2026, 11, 7));
      expect(rows[0].amount, -642.10);
      expect(rows[1].description, 'Salary');
      expect(rows[1].date, DateTime(2026, 11, 6));
      expect(rows[1].amount, 18000);
      expect(rows[2].date, DateTime(2026, 11, 3));
      // No sign shown: assumed money out, and flagged.
      expect(rows[2].amount, -45);
      expect(rows[2].signGuessed, isTrue);
    });

    test('Arabic: Arabic digits, months and currency', () {
      final page = DocPage([
        ...line(0.10, [('اليوم', 0.75, 0.15)], h: 0.02),
        ...line(0.14, [('٦٤٢٫١٠- ر.س', 0.05, 0.25), ('بنده', 0.7, 0.2)], h: 0.025),
        ...line(0.20, [('٣ نوفمبر ٢٠٢٦', 0.7, 0.25)], h: 0.02),
        ...line(0.24, [('١٨٬٠٠٠٫٠٠ ر.س', 0.05, 0.25), ('راتب شهر نوفمبر', 0.6, 0.35)], h: 0.025),
      ]);
      final rows = reader.readPages([page]);
      expect(rows, hasLength(2));
      expect(rows[0].amount, -642.10);
      expect(rows[0].currency, 'SAR');
      expect(rows[0].date, DateTime(2026, 11, 7));
      expect(rows[1].date, DateTime(2026, 11, 3));
      // "راتب" is salary.
      expect(rows[1].amount, 18000);
      expect(rows[1].signGuessed, isTrue);
    });

    test('Vision output for an Arabic banking app screenshot, as returned', () {
      // As VNRecognizeTextRequest returned it (Arabic first): the "·" read
      // as a zero, the Arabic decimal mark as a comma.
      final page = DocPage(const [
        DocToken('العمليات', 0.738, 0.086, 0.211, 0.029),
        DocToken('اليوم', 0.877, 0.147, 0.066, 0.019),
        DocToken('بنده للتجزئة', 0.738, 0.179, 0.199, 0.022),
        DocToken('شتريات ١٠:٤٢٠ ص', 0.719, 0.208, 0.211, 0.016),
        DocToken('ستاربكس العليا', 0.678, 0.249, 0.259, 0.023),
        DocToken('مطاعم ٨:١٥٠ ص', 0.744, 0.278, 0.192, 0.016),
        DocToken('أمس', 0.874, 0.328, 0.073, 0.020),
        DocToken('حوالة واردة من خالد', 0.599, 0.363, 0.341, 0.020),
        DocToken('٣ نوفمبر ٢٠٢٦', 0.763, 0.419, 0.177, 0.016),
        DocToken('أوبر', 0.874, 0.449, 0.073, 0.023),
        DocToken('٦٤٢,١٠- ر.س', 0.050, 0.182, 0.208, 0.021),
        DocToken('٢٣,٠٠- ر.س', 0.054, 0.251, 0.196, 0.019),
        DocToken('+١,٠٠٠,٠٠ ر.س', 0.044, 0.366, 0.230, 0.019),
        DocToken('٣٨,٧٥- ر.س', 0.044, 0.453, 0.224, 0.020),
      ]);
      final rows = reader.readPages([page]);
      expect(rows.map((r) => r.description), ['بنده للتجزئة', 'ستاربكس العليا', 'حوالة واردة من خالد', 'أوبر']);
      expect(rows.map((r) => r.amount), [-642.10, -23, 1000, -38.75]);
      expect(rows.map((r) => r.date), [DateTime(2026, 11, 7), DateTime(2026, 11, 7), DateTime(2026, 11, 6), DateTime(2026, 11, 3)]);
      expect(rows.every((r) => r.currency == 'SAR' && !r.signGuessed), isTrue);
    });

    test('a merchant on one line and its amount alone on the next', () {
      final page = DocPage([
        ...line(0.10, [('Starbucks Olaya', 0.1, 0.4)], h: 0.02),
        ...line(0.13, [('-23.00 SAR', 0.1, 0.2)], h: 0.02),
      ]);
      final row = reader.readPages([page]).single;
      expect(row.description, 'Starbucks Olaya');
      expect(row.amount, -23);
      expect(row.dateGuessed, isTrue);
    });
  });

  group('CSV and Excel', () {
    test('an amount column with signs', () {
      final rows = reader.readPages([
        DocPage.fromTable([
          ['Date', 'Description', 'Amount', 'Currency'],
          ['2026-11-03', 'PANDA', '-642.10', 'SAR'],
          ['2026-11-01', 'Salary', '18000', 'SAR'],
        ]),
      ]);
      expect(rows.map((r) => r.amount), [-642.10, 18000]);
      expect(rows.map((r) => r.description), ['PANDA', 'Salary']);
      expect(rows.first.date, DateTime(2026, 11, 3));
    });

    test('debit and credit columns in Arabic', () {
      final rows = reader.readPages([
        DocPage.fromTable([
          ['التاريخ', 'البيان', 'مدين', 'دائن', 'الرصيد'],
          ['03/11/2026', 'بنده', '642.10', '', '39378.25'],
          ['01/11/2026', 'راتب', '', '18000', '40020.35'],
        ]),
      ]);
      expect(rows.map((r) => r.amount), [-642.10, 18000]);
      expect(rows.every((r) => !r.signGuessed), isTrue);
    });
  });

  group('bank messages', () {
    test('an English purchase SMS', () {
      final row = reader.readMessages('Purchase of SAR 642.10 at PANDA RIYADH on 03/11/26 10:42. Available balance SAR 21,378.25').single;
      expect(row.amount, -642.10);
      expect(row.currency, 'SAR');
      expect(row.description, 'PANDA RIYADH');
      expect(row.date, DateTime(2026, 11, 3));
      expect(row.signGuessed, isFalse);
    });

    test('an Arabic purchase SMS and a deposit, two messages', () {
      final rows = reader.readMessages('شراء بمبلغ 45.00 ر.س لدى STARBUCKS بتاريخ 2026-11-05\n\nإيداع راتب 18,000.00 ر.س');
      expect(rows, hasLength(2));
      expect(rows[0].amount, -45);
      expect(rows[0].description, 'STARBUCKS');
      expect(rows[0].date, DateTime(2026, 11, 5));
      expect(rows[1].amount, 18000);
    });

    test('text without an amount gives nothing', () {
      expect(reader.readMessages('Your OTP is 448812. Do not share it.'), isEmpty);
    });
  });
}
