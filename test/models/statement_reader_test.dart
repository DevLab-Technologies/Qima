import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/statement_reader.dart';
import 'package:qima/models/statement_facts.dart';

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

    test('a card list: name, then the amount beside it, then the date under it', () {
      // Positions as Vision gives them for a banking app's card screen; the
      // riyal sign is read as '#'.
      DocToken t(String s, double y, double x, double h, [double w = 0.5]) => DocToken(s, x, y, w, h);
      final page = DocPage([
        t('Latest Transactions', 0.128, 0.035, 0.021),
        t('Completed', 0.196, 0.069, 0.017, 0.2),
        t('Pending', 0.196, 0.318, 0.019, 0.2),
        t('CAFE ROSE~~RIYADH~ SAU682', 0.247, 0.035, 0.017),
        t('3.50 #', 0.256, 0.842, 0.021, 0.12),
        t('03/11/2026', 0.272, 0.035, 0.015, 0.2),
        t('Bookstore Online~~Riyadh~ SAU682', 0.422, 0.035, 0.019),
        t('239.88 #', 0.43, 0.792, 0.021, 0.15),
        t('19/10/2026', 0.445, 0.035, 0.015, 0.2),
        // A name wrapped onto the amount's line.
        t('Learning*P3106613144~Gardner', 0.499, 0.035, 0.016),
        t('102.29 #', 0.514, 0.788, 0.024, 0.15),
        t('House~LEARNING.COM~2 IRL372', 0.519, 0.035, 0.018),
        t('15/10/2026', 0.542, 0.035, 0.015, 0.2),
        t('CREDIT CARD PAYMENT', 0.844, 0.035, 0.018),
        t('13,995.01 #', 0.853, 0.732, 0.023, 0.2),
        // Its first slash read as '1'.
        t('27109/2026', 0.869, 0.035, 0.015, 0.2),
        t('Market SA~~Riyadh~ SAU682', 0.922, 0.035, 0.019),
        t('#2,791.66', 0.93, 0.757, 0.022, 0.2),
        t('22/09/2026', 0.944, 0.035, 0.016, 0.2),
      ]);
      final rows = reader.readPages([page]);
      expect(rows.map((r) => r.description), [
        'CAFE ROSE RIYADH',
        'Bookstore Online Riyadh',
        'Learning*P3106613144 Gardner House LEARNING.COM 2',
        'CREDIT CARD PAYMENT',
        'Market SA Riyadh',
      ]);
      expect(rows.map((r) => r.amount.abs()), [3.50, 239.88, 102.29, 13995.01, 2791.66]);
      expect(rows.map((r) => r.date), [DateTime(2026, 11, 3), DateTime(2026, 10, 19), DateTime(2026, 10, 15), DateTime(2026, 9, 27), DateTime(2026, 9, 22)]);
      expect(rows.every((r) => !r.dateGuessed), isTrue);
    });

    test('a screenshot of bank messages: one transaction per bubble, never the limit left', () {
      List<DocToken> bubble(double y, List<String> lines) => [
            for (var i = 0; i < lines.length; i++) DocToken(lines[i], 0.08, y + i * 0.025, 0.65, 0.018),
          ];
      final page = DocPage([
        ...bubble(0.27, [
          'يرجى العلم أنه تم خصم مبلغ EGP',
          '64000.00 من حساب ********2377 عبر',
          'شبكة المدفوعات اللحظية (IPN) من خلال',
          'خدمات الإنترنت البنكية بتاريخ',
          '2026-11-03 10:14 إلى Mohsen A.. E.',
          'برقم مرجعي FT26307C783R',
          'للمزيد، يرجى الاتصال بـ 19666',
        ]),
        DocToken('Yesterday 5:53 AM', 0.38, 0.48, 0.2, 0.012),
        ...bubble(0.51, [
          'Your credit card #1016 was charged',
          'for EGP 4999.99 at CODASHOP on',
          '06/11/26 at 04:10. Available limit is',
          '34072.32 and the available',
          'international limit to use is EGP',
          '112614',
        ]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows, hasLength(2));
      expect(rows[0].amount, -64000);
      expect(rows[0].currency, 'EGP');
      expect(rows[0].date, DateTime(2026, 11, 3));
      expect(rows[0].description, 'Mohsen A.. E.');
      expect(rows[1].amount, -4999.99);
      expect(rows[1].description, 'CODASHOP');
      expect(rows[1].date, DateTime(2026, 11, 6));
    });

    test('a screenshot of a labelled bank message: the merchant line names it, the limit left is no transaction', () {
      // A made-up card message, laid out where Vision puts such lines.
      final page = DocPage(const [
        DocToken('Today 9:15 AM', 0.406, 0.033, 0.188, 0.048),
        DocToken('POS Purchase (Apple Pay)', 0.077, 0.189, 0.458, 0.072),
        DocToken('Card: Visa card XX4821', 0.079, 0.291, 0.402, 0.066),
        DocToken('Amount: SAR 27.00', 0.077, 0.405, 0.333, 0.069),
        DocToken('Merchant: Corner Cafe Riyadh', 0.079, 0.508, 0.627, 0.075),
        DocToken('In: SAUDI ARABIA', 0.074, 0.622, 0.309, 0.063),
        DocToken('Remaining limit SAR 18,450.20', 0.079, 0.723, 0.520, 0.092),
        DocToken('On: 2026-10-14 09:15:40', 0.079, 0.838, 0.436, 0.063),
      ]);
      final rows = reader.readPages([page]);
      expect(rows, hasLength(1));
      expect(rows.single.amount, -27);
      expect(rows.single.signGuessed, isFalse);
      expect(rows.single.currency, 'SAR');
      expect(rows.single.description, 'Corner Cafe Riyadh');
      expect(rows.single.date, DateTime(2026, 10, 14));
      final facts = reader.facts([page], rows);
      expect(facts.refs, contains(const StatementRef(StatementRefKind.card, '4821')));
    });

    test('a labelled bank message pasted as text: the merchant line, and the limit left before the amount', () {
      final rows = reader.readMessages(
        'POS Purchase (Apple Pay)\nCard: Visa card XX4821\nRemaining limit SAR 18,450.20\nAmount: SAR 27.00\n'
        'Merchant: Corner Cafe Riyadh\nIn: SAUDI ARABIA\nOn: 2026-10-14 09:15:40\n\n'
        'شراء عبر نقاط البيع\nبطاقة: مدى 7730\nالمبلغ: 85.50 ريال\nلدى: مخبز الحي\nالرصيد المتبقي: 2,310.00 ريال\nفي: 2026-10-12',
      );
      expect(rows, hasLength(2));
      expect(rows[0].amount, -27);
      expect(rows[0].description, 'Corner Cafe Riyadh');
      expect(rows[1].amount, -85.5);
      expect(rows[1].currency, 'SAR');
      expect(rows[1].description, 'مخبز الحي');
    });

    test('Apple Pay payments from a Wallet automation, with the amount as Shortcuts writes it', () {
      String pay(String amount) => 'Apple Pay purchase\nCard: SNB Visa\nAmount: $amount\nMerchant: Corner Cafe\nOn: 2026-10-14 09:15:40';
      for (final (amount, major, currency) in [
        ('SAR 27.00', 27.0, 'SAR'),
        ('27.00 SAR', 27.0, 'SAR'),
        ('\u200f27.00 ر.س.\u200f', 27.0, 'SAR'),
        ('\u0662\u0667\u066b\u0665\u0660 ر.س.\u200f', 27.5, 'SAR'),
        (r'$1,250.00', 1250.0, 'USD'),
        ('12,50 €', 12.5, 'EUR'),
      ]) {
        final rows = reader.readMessages(pay(amount));
        expect(rows, hasLength(1), reason: amount);
        expect((rows.single.amount, rows.single.currency, rows.single.description, rows.single.date, rows.single.signGuessed),
            (-major, currency, 'Corner Cafe', DateTime(2026, 10, 14), false),
            reason: amount);
      }
    });

    test('a Saudi bank statement: Hijri dates, and the bank\'s own text around the table', () {
      final page = DocPage([
        // The statement's own date, in Hijri, above everything.
        ...line(0.04, [('1448/04/20', 0.75, 0.15)]),
        ...line(0.07, [('Account Statement', 0.05, 0.3), ('= +', 0.5, 0.05), ('30,975.91', 0.6, 0.1)]),
        ...line(0.10, [('Date', 0.04, 0.08), ('Hijri Date', 0.14, 0.1), ('Description', 0.28, 0.2), ('Debit', 0.56, 0.08), ('Credit', 0.68, 0.08), ('Balance', 0.82, 0.1)]),
        ...line(0.13, [('2026-10-05', 0.04, 0.09), ('1448/04/13', 0.14, 0.09), ('POS PANDA RIYADH', 0.28, 0.2), ('125.50', 0.56, 0.08), ('30,850.41', 0.82, 0.1)]),
        ...line(0.16, [('2026-10-07', 0.04, 0.09), ('1448/04/15', 0.14, 0.09), ('SALARY', 0.28, 0.2), ('3,737.00', 0.68, 0.08), ('34,587.41', 0.82, 0.1)]),
        // The foot of the page: phone, register and VAT numbers, capital.
        ...line(0.85, [('scan the QR code or call 920024288', 0.28, 0.4), ('920024288', 0.56, 0.1)]),
        ...line(0.88, [('The Saudi National Bank - A Saudi Joint Stock Company, paid-up capital SAR 60,000,000,000', 0.05, 0.9)]),
        ...line(0.91, [('C.R. 4030001588', 0.56, 0.12), ('VAT 300002471110003', 0.68, 0.2)]),
        ...line(0.94, [('Under the supervision and control of The Saudi Central Bank - Licensed', 0.05, 0.6), ('3,737', 0.68, 0.08)]),
        ...line(0.97, [('Decree M/3 dated 26/12/1373', 0.05, 0.4)]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows.map((r) => r.description), ['POS PANDA RIYADH', 'SALARY']);
      expect(rows.map((r) => r.amount), [-125.50, 3737]);
      // The Gregorian column, not the Hijri one.
      expect(rows.map((r) => r.date), [DateTime(2026, 10, 5), DateTime(2026, 10, 7)]);
    });

    test('a row with only a Hijri date is converted', () {
      expect(StatementReader.hijriToGregorian(1448, 4, 20), DateTime(2026, 10, 1));
      final page = DocPage([
        ...line(0.10, [('Hijri Date', 0.04, 0.1), ('Description', 0.28, 0.2), ('Amount', 0.7, 0.1)]),
        ...line(0.13, [('20/04/1448', 0.04, 0.1), ('STC BILL', 0.28, 0.2), ('-230.00', 0.7, 0.1)]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows.single.date, DateTime(2026, 10, 1));
      expect(rows.single.amount, -230);
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

    test('an account screen: the large balance under its small label is the balance, not a transaction', () {
      // Vision's positions for an account screen: the figure is far wider
      // than its label.
      final page = DocPage(const [
        DocToken('Current account', 0.069, 0.109, 0.324, 0.016),
        DocToken('Account ending 7731', 0.069, 0.137, 0.302, 0.016),
        DocToken('Available balance', 0.066, 0.189, 0.274, 0.015),
        DocToken('25,000.00 SAR', 0.069, 0.223, 0.695, 0.049),
      ]);
      final (rows, facts) = reader.read([page]);
      expect(rows, isEmpty);
      expect(facts.closing, 25000);
      expect(facts.to, DateTime(2026, 11, 7));
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

    test('a card statement notice is no transaction, however many figures it has', () {
      const notice = 'Dear Customer\nYour Credit Card statement has been issued.\n'
          'The minimum due payable for the Credit Card ending in XX5521 is:\nSAR 98.10\n'
          'Total outstanding balance: SAR 2,410.00\nPayment due date: 04-12-2026\nSADAD number: 0160000001234567';
      expect(messageIntent(StatementReader.normalize(notice)), MessageIntent.notice);
      expect(reader.readMessages(notice), isEmpty);
    });

    test('a POS refund is money in, from the merchant, onto the card it names', () {
      const text = 'POS Refund\nTo: XX5521; Visa Credit\nAmount: SAR 35.50\nFrom: Corner Books\nIn SAUDI ARABIA\n'
          'Remaining limit SAR: 12,000.00\nOn: 2026-11-09 16:17:44';
      final row = reader.readMessages(text).single;
      expect(row.amount, 35.5);
      expect(row.signGuessed, isFalse);
      expect(row.currency, 'SAR');
      expect(row.description, 'Corner Books');
      expect(row.date, DateTime(2026, 11, 9));
      expect(reader.messageFacts(text, [row]).refs, contains(const StatementRef(StatementRefKind.card, '5521')));
    });

    test('what each message is about decides whether and which way money moved', () {
      for (final (text, intent) in [
        ('Your OTP for SAR 120.00 at NOON is 448812', MessageIntent.code),
        ('Purchase of SAR 80.00 at NOON declined: insufficient funds', MessageIntent.declined),
        ('Installment of SAR 1,500.00 deducted from account XX1234. Next due date 01-12-2026', MessageIntent.debit),
        ('Incoming transfer SAR 500.00 from Sara Ali', MessageIntent.transferIn),
        ('ATM withdrawal SAR 300.00', MessageIntent.withdrawal),
        ('تم إصدار كشف حساب البطاقة. الحد الأدنى 150.00 ريال', MessageIntent.notice),
      ]) {
        expect(messageIntent(text), intent, reason: text);
      }
      expect(reader.readMessages('Incoming transfer SAR 500.00 from Sara Ali').single.description, 'Sara Ali');
      expect(reader.readMessages('Purchase of SAR 80.00 at NOON declined: insufficient funds'), isEmpty);
    });

    test('text without an amount gives nothing', () {
      expect(reader.readMessages('Your OTP is 448812. Do not share it.'), isEmpty);
    });
  });
}
