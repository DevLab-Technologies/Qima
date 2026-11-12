import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/statement_reader.dart';

List<DocToken> line(
  double y,
  List<(String, double, double)> cells, {
  double h = 0.012,
}) => [for (final (t, x, w) in cells) DocToken(t, x, y, w, h)];

void main() {
  final reader = StatementReader(received: DateTime(2026, 11, 12));

  test(
    'a card statement marks refunds and payments with a trailing minus: money in',
    () {
      final page = DocPage([
        ...line(0.10, [
          ('B/F AS OF 10/09/26', 0.3, 0.2),
          ('68,695.04', 0.8, 0.1),
        ]),
        ...line(0.13, [
          ('15-SEP-26', 0.05, 0.08),
          ('16-SEP-26', 0.15, 0.08),
          ('LOCAL E-COMM SHOP ONE', 0.3, 0.3),
          ('102.29', 0.8, 0.08),
        ]),
        ...line(0.16, [
          ('17-SEP-26', 0.05, 0.08),
          ('18-SEP-26', 0.15, 0.08),
          ('LOCAL PURCH CAFE TWO', 0.3, 0.3),
          ('61.58', 0.8, 0.08),
        ]),
        ...line(0.19, [
          ('20-SEP-26', 0.05, 0.08),
          ('22-SEP-26', 0.15, 0.08),
          ('LOCAL E-COMM STORE', 0.3, 0.3),
          ('2,687.99', 0.8, 0.08),
        ]),
        ...line(0.22, [
          ('02-OCT-26', 0.05, 0.08),
          ('04-OCT-26', 0.15, 0.08),
          ('INT. ECOMM. RET STORE', 0.3, 0.3),
          ('3,075.00-', 0.8, 0.08),
        ]),
        ...line(0.25, [
          ('09-OCT-26', 0.05, 0.08),
          ('10-OCT-26', 0.15, 0.08),
          ('LOCAL E-COMM FOOD', 0.3, 0.3),
          ('6.00', 0.8, 0.08),
        ]),
        ...line(0.28, [
          ('27-SEP-26', 0.05, 0.08),
          ('27-SEP-26', 0.15, 0.08),
          ('BRANCH PAY CREDIT CARD PAYMENT', 0.3, 0.3),
          ('13,995.01-', 0.8, 0.08),
        ]),
        ...line(0.31, [
          ('INSTALLMENT DUE THIS MONTH', 0.3, 0.3),
          ('1,460.50', 0.8, 0.08),
        ]),
      ]);
      final (rows, _) = reader.read([page]);
      final kept = rows.where((r) => !r.doubtful).toList();
      expect(kept.map((r) => r.amount), [
        -102.29,
        -61.58,
        -2687.99,
        3075.0,
        -6.0,
        13995.01,
      ]);
    },
  );

  test('a lone date line under a card-list row does not shift later rows', () {
    DocToken t(String s, double y, double x, [double w = 0.5]) =>
        DocToken(s, x, y, w, 0.018);
    final page = DocPage([
      t('SHOP A~~Riyadh~ SAU682', 0.15, 0.03),
      t('1,650.00', 0.17, 0.76, 0.15),
      t('23/10/2026', 0.197, 0.03, 0.2),
      t('SHOP B~~Riyadh~ SAU682', 0.25, 0.03),
      t('239.88', 0.258, 0.79, 0.12),
      t('19/10/2026', 0.273, 0.03, 0.2),
      // The amount of this row was not read.
      t('SHOP C~~riyadh~ SAU682', 0.42, 0.03),
      t('09/10/2026', 0.447, 0.03, 0.2),
      t('SHOP D~~Riyadh~ SAU682', 0.50, 0.03),
      t('3,075.00', 0.51, 0.76, 0.15),
      t('02/10/2026', 0.523, 0.03, 0.2),
      t('SHOP E~~Riyadh~ SAU682', 0.575, 0.03),
      t('19.36', 0.595, 0.81, 0.1),
      t('25/09/2026', 0.62, 0.03, 0.2),
    ]);
    final rows = reader.readPages([page]);
    expect(rows.map((r) => r.date), [
      DateTime(2026, 10, 23),
      DateTime(2026, 10, 19),
      DateTime(2026, 10, 2),
      DateTime(2026, 9, 25),
    ]);
  });

  test(
    'a table with no column names: debit and credit columns come from the balance',
    () {
      final page = DocPage([
        ...line(0.10, [
          ('31DEC25', 0.03, 0.06),
          ('OPENING BALANCE', 0.2, 0.2),
          ('4,121.37', 0.85, 0.08),
        ]),
        ...line(0.13, [
          ('05JAN26', 0.03, 0.06),
          ('Internet Transfer To Own AC', 0.2, 0.25),
          ('47,560.00', 0.72, 0.08),
        ]),
        ...line(0.16, [
          ('05JAN26', 0.03, 0.06),
          ('MASTER DIR PAYMENT FT26005', 0.2, 0.25),
          ('13,335.16', 0.55, 0.08),
          ('38,346.21', 0.85, 0.08),
        ]),
        ...line(0.19, [
          ('06JAN26', 0.03, 0.06),
          ('Internet Transfer To Own AC', 0.2, 0.25),
          ('51,975.00', 0.72, 0.08),
        ]),
        ...line(0.22, [
          ('06JAN26', 0.03, 0.06),
          ('IPN Fund Transfer Online', 0.2, 0.25),
          ('51,995.00', 0.55, 0.08),
        ]),
        ...line(0.25, [
          ('06JAN26', 0.03, 0.06),
          ('IPN Fund Transfer Online', 0.2, 0.25),
          ('30,020.00', 0.55, 0.08),
        ]),
        ...line(0.28, [
          ('06JAN26', 0.03, 0.06),
          ('Payment of Interest MM25', 0.2, 0.25),
          ('1,152.08', 0.72, 0.08),
          ('9,458.29', 0.85, 0.08),
        ]),
        ...line(0.31, [
          ('08JAN26', 0.03, 0.06),
          ('IPN Outward Payee', 0.2, 0.25),
          ('500.50', 0.55, 0.08),
        ]),
        ...line(0.34, [
          ('08JAN26', 0.03, 0.06),
          ('IPN Inward', 0.2, 0.25),
          ('38,000.00', 0.72, 0.08),
          ('46,957.79', 0.85, 0.08),
        ]),
        ...line(0.37, [
          ('11JAN26', 0.03, 0.06),
          ('IPN Fund Transfer Online', 0.2, 0.25),
          ('750.75', 0.55, 0.08),
        ]),
        ...line(0.40, [
          ('11JAN26', 0.03, 0.06),
          ('IPN Fund Transfer Online', 0.2, 0.25),
          ('3,003.00', 0.55, 0.08),
          ('43,204.04', 0.85, 0.08),
        ]),
      ]);
      final rows = reader.readPages([page]);
      expect(rows.map((r) => r.amount), [
        47560,
        -13335.16,
        51975,
        -51995,
        -30020,
        1152.08,
        -500.50,
        38000,
        -750.75,
        -3003,
      ]);
    },
  );

  test(
    'bank messages: a declined payment is no transaction; money sent to your account is money in',
    () {
      expect(
        reader.readMessages(
          'The transaction from SHOP on your credit card ending 4321 for EGP 9749.99 was declined.',
        ),
        isEmpty,
      );
      expect(
        reader.readMessages(
          'لقد تم رفض المعاملة من SHOP على بطاقتكم الائتمانية المنتهية بـ4321 بقيمة EGP 9749.99',
        ),
        isEmpty,
      );
      final rows = reader.readMessages(
        'يرجى العلم انه تم تنفيذ تحويل لحظي بمبلغ 3365.00 جم إلى حسابك المنتهي بـ ****4321 من فلان بتاريخ 01-11-2026 04:35',
      );
      expect(rows.single.amount, 3365.0);
    },
  );

  test(
    'a message whose amount was cut off gives no row, not its remaining limit',
    () {
      expect(
        reader.readMessages(
          'Merchant: Sukkar Wave\nIn: SAUDI ARABIA\nRemaining limit SAR 32,829.34\nOn: 2026-10-30 17:33:51',
        ),
        isEmpty,
      );
    },
  );
}
