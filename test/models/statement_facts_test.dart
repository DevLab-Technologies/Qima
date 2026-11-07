import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/book.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/entry_builder.dart';
import 'package:qima/models/import_plan.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/statement_facts.dart';
import 'package:qima/models/statement_reader.dart';

/// A line of cells at [y], each cell (text, x, width).
List<DocToken> line(double y, List<(String, double, double)> cells, {double h = 0.012}) =>
    [for (final (t, x, w) in cells) DocToken(t, x, y, w, h)];

void main() {
  final reader = StatementReader(received: DateTime(2026, 12, 2, 10));

  // A made-up statement: header facts, then a table that opens and closes
  // with the bank's balance lines.
  DocPage statement({bool withBalances = true}) => DocPage([
        ...line(0.03, [('Statement period 01/11/2026 - 30/11/2026', 0.05, 0.5)]),
        ...line(0.05, [('IBAN SA03 8000 0000 6080 1016 7519', 0.05, 0.5)]),
        ...line(0.10, [('Date', 0.05, 0.08), ('Description', 0.18, 0.2), ('Debit', 0.55, 0.08), ('Credit', 0.68, 0.08), ('Balance', 0.82, 0.1)]),
        if (withBalances) ...line(0.13, [('Opening balance', 0.18, 0.2), ('22,020.35', 0.82, 0.1)]),
        ...line(0.16, [('01/11/2026', 0.05, 0.1), ('SALARY NOV', 0.18, 0.2), ('18,000.00', 0.68, 0.1), ('40,020.35', 0.82, 0.1)]),
        ...line(0.19, [('03/11/2026', 0.05, 0.1), ('PANDA RIYADH', 0.18, 0.2), ('642.10', 0.55, 0.08), ('39,378.25', 0.82, 0.1)]),
        ...line(0.22, [('04/11/2026', 0.05, 0.1), ('STC BILL', 0.18, 0.2), ('300.00', 0.55, 0.08), ('39,078.25', 0.82, 0.1)]),
        if (withBalances) ...line(0.25, [('Closing balance', 0.18, 0.2), ('39,078.25', 0.82, 0.1)]),
      ]);

  group('what a statement says about itself', () {
    test('balances, IBAN and period are read, and the rows add up', () {
      final pages = [statement()];
      final rows = reader.readPages(pages);
      expect(rows, hasLength(3), reason: 'balance lines are not transactions');
      final facts = reader.facts(pages, rows);
      expect(facts.opening, 22020.35);
      expect(facts.closing, 39078.25);
      expect(facts.openingWorkedOut, isFalse);
      expect(facts.refs, [const StatementRef(StatementRefKind.iban, '7519')]);
      expect(facts.from, DateTime(2026, 11, 1));
      expect(facts.to, DateTime(2026, 11, 30));
      final check = Reconciliation.of(facts, rows)!;
      expect(check.addsUp, isTrue);
      expect(check.owed, isFalse);
    });

    test('a missed row shows as a gap', () {
      final pages = [statement()];
      final rows = reader.readPages(pages);
      final check = Reconciliation.of(reader.facts(pages, rows), rows.sublist(0, 2))!;
      expect(check.addsUp, isFalse);
      expect(check.gap, -300);
    });

    test('without balance lines, the running balance gives them, which proves nothing', () {
      final pages = [statement(withBalances: false)];
      final rows = reader.readPages(pages);
      final facts = reader.facts(pages, rows);
      expect(facts.opening, closeTo(22020.35, 0.001));
      expect(facts.closing, 39078.25);
      expect(facts.openingWorkedOut && facts.closingWorkedOut, isTrue);
      expect(Reconciliation.of(facts, rows), isNull);
    });

    test('a label over its value, a masked card, and an owed balance', () {
      final page = DocPage([
        ...line(0.05, [('Card number 4847 **** **** 4417', 0.05, 0.5)]),
        ...line(0.10, [('Previous balance', 0.05, 0.2), ('New balance', 0.55, 0.2)]),
        ...line(0.125, [('1,000.00', 0.07, 0.12), ('1,250.00', 0.57, 0.12)]),
      ]);
      final rows = [
        StatementRow(date: DateTime(2026, 11, 3), description: 'Coffee', amount: -50),
        StatementRow(date: DateTime(2026, 11, 4), description: 'Books', amount: -200),
      ];
      final facts = reader.facts([page], rows);
      expect(facts.refs, [const StatementRef(StatementRefKind.card, '4417')]);
      expect(facts.opening, 1000);
      expect(facts.closing, 1250);
      // A card statement counts what is owed: spending raises it.
      final check = Reconciliation.of(facts, rows)!;
      expect(check.addsUp, isTrue);
      expect(check.owed, isTrue);
    });

    test('a transfer line with two dates is not the statement period', () {
      final page = DocPage([
        ...line(0.10, [('Date', 0.05, 0.08), ('Description', 0.18, 0.2), ('Amount', 0.7, 0.1)]),
        ...line(0.13, [('01/11/2026', 0.05, 0.1), ('Transfer from Sara to savings 02/11/2026', 0.18, 0.4), ('500.00', 0.7, 0.1)]),
      ]);
      final facts = reader.facts([page], reader.readPages([page]));
      expect(facts.from, isNull);
    });

    test('an invalid IBAN-looking number is not taken', () {
      final page = DocPage(line(0.05, [('IBAN SA04 8000 0000 6080 1016 7519', 0.05, 0.5)]));
      expect(reader.facts([page], const []).refs, isEmpty);
    });

    test('a bank message: the card and the balance after', () {
      const text = 'Purchase of SAR 45.00 at CAFE ROSE with card ending 4417. Available balance SAR 1,955.00';
      final rows = reader.readMessages(text);
      final facts = reader.messageFacts(text, rows);
      expect(facts.refs, contains(const StatementRef(StatementRefKind.card, '4417')));
      expect(facts.closing, 1955);
      expect(facts.closingAvailable, isTrue);
    });
  });

  group('labels from the on-device model', () {
    test('only checked against the line: names copied from it, balance rows kept but doubted', () {
      final page = DocPage([
        ...line(0.10, [('Date', 0.05, 0.08), ('Description', 0.18, 0.3), ('Amount', 0.7, 0.1)]),
        ...line(0.13, [('01/11/2026', 0.05, 0.1), ('POS 4412 PANDA RIYADH SA', 0.18, 0.3), ('-642.10', 0.7, 0.1)]),
        ...line(0.16, [('02/11/2026', 0.05, 0.1), ('Balance as of today', 0.18, 0.3), ('9,000.00', 0.7, 0.1)]),
        ...line(0.19, [('03/11/2026', 0.05, 0.1), ('STC BILL 5521', 0.18, 0.3), ('-300.00', 0.7, 0.1)]),
      ]);
      final pages = [page];
      final rows = reader.readPages(pages);
      expect(rows, hasLength(3));
      final lines = reader.lineTexts(pages);
      expect(lines[rows[0].line!], contains('PANDA'));
      final labels = [
        LineLabel(rows[0].line!, LineKind.transaction, 'PANDA RIYADH'),
        LineLabel(rows[1].line!, LineKind.closing),
        // A name that isn't on the line is not used.
        LineLabel(rows[2].line!, LineKind.transaction, 'Saudi Telecom'),
        // Out of range: ignored.
        const LineLabel(99, LineKind.opening),
      ];
      final (labelled, facts) = reader.withLabels(rows, StatementFacts.none, lines, labels);
      expect(labelled[0].description, 'PANDA RIYADH');
      expect(labelled[0].amount, -642.10, reason: 'the model never changes a figure');
      expect(labelled[1].doubtful, isTrue);
      expect(labelled[1].amount, rows[1].amount);
      expect(labelled[2].description, rows[2].description);
      expect(facts.closing, 9000);
      expect(facts.closingWorkedOut, isFalse);
    });

    test('a balance the statement printed is not replaced', () {
      final rows = [StatementRow(date: DateTime(2026, 11, 1), description: 'X', amount: -1, line: 0)];
      const lines = ['Closing balance 50.00'];
      final (_, facts) = reader.withLabels(rows, const StatementFacts(closing: 75), lines, const [LineLabel(0, LineKind.closing)]);
      expect(facts.closing, 75);
    });

    test('the model gives labels as maps; unknown kinds are dropped', () {
      expect(LineLabel.fromMap({'line': 3, 'kind': 'opening balance', 'name': ' '}), const LineLabel(3, LineKind.opening));
      expect(LineLabel.fromMap({'line': 3, 'kind': 'fee'}), isNull);
      expect(LineLabel.fromMap({'line': '3', 'kind': 'other'}), isNull);
    });
  });

  group('importing a statement into an account', () {
    final bank = BookAccount(id: 'rajhi', name: 'Al Rajhi', side: AccountSide.own, type: AccountType.debit, currency: 'SAR');
    final card = BookAccount(
        id: 'visa', name: 'Visa', side: AccountSide.owe, type: AccountType.credit, currency: 'SAR', statementRefs: const ['card:4417']);
    var n = 0;
    final builder = EntryBuilder(
        baseCurrency: 'SAR', rates: FXRates(base: 'SAR', rates: const {'SAR': 1}, updatedAt: DateTime(2026)), newId: () => 'e${n++}');

    test('a known card number picks its account over a bank', () {
      expect(ImportPlanner.guessAccount([bank, card], const [], const []), bank);
      expect(ImportPlanner.guessAccount([bank, card], const [], const [], refs: const [StatementRef(StatementRefKind.card, '4417')]), card);
    });

    test('a row the model doubts starts unticked', () {
      final rows = [StatementRow(date: DateTime(2026, 11, 1), description: 'Closing balance', amount: 900, doubtful: true)];
      final plan = ImportPlanner.plan(files: [('f', rows)], account: bank, book: Book([bank], const []));
      expect(plan.single.flag, ImportFlag.notTransaction);
      expect(plan.single.suggested, isFalse);
    });

    test('a new account gets an opening balance; one with history a correction', () {
      final rows = [StatementRow(date: DateTime(2026, 11, 3), description: 'PANDA', amount: -100)];
      final balance = ImportPlanner.statementBalance([(const StatementFacts(closing: 900, currency: 'SAR'), rows)], bank)!;
      expect(balance.date, DateTime(2026, 11, 3));
      final category = Book([bank], const []).accounts['category.other'] ??
          const BookAccount(id: 'category.other', name: 'Other', side: AccountSide.spending, type: AccountType.category);
      final spend = builder.spend(bank, category, 10000, DateTime(2026, 11, 3));

      final fresh = ImportPlanner.balanceEntry(builder: builder, book: Book([bank, category], const []), account: bank, added: [spend], balance: balance)!;
      expect(fresh.template, EntryTemplate.opening);
      expect(fresh.lines.firstWhere((l) => l.accountId == bank.id).amount, 100000, reason: '1,000 before the 100 spent');

      final earlier = builder.opening(bank, 50000, DateTime(2026, 10, 1));
      final fix = ImportPlanner.balanceEntry(
          builder: builder, book: Book([bank, category], [earlier]), account: bank, added: [spend], balance: balance)!;
      expect(fix.template, EntryTemplate.adjustment);
      expect(fix.date, DateTime(2026, 11, 3));
      expect(fix.lines.firstWhere((l) => l.accountId == bank.id).amount, 50000);
      expect(fix.lines.firstWhere((l) => l.accountId == SystemAccount.openingBalances.id).amount, -50000, reason: 'never spending or income');

      final agreeing = builder.opening(bank, 100000, DateTime(2026, 10, 1));
      expect(
          ImportPlanner.balanceEntry(builder: builder, book: Book([bank, category], [agreeing]), account: bank, added: [spend], balance: balance),
          isNull);
    });

    test('a card is never brought to its available balance, the credit left', () {
      final facts = StatementFacts(closing: 8000, closingAvailable: true, to: DateTime(2026, 11, 30));
      expect(ImportPlanner.statementBalance([(facts, const <StatementRow>[])], card), isNull);
      expect(ImportPlanner.statementBalance([(facts, const <StatementRow>[])], bank)?.closing, 8000);
    });

    test('a balance in another currency is not offered', () {
      expect(ImportPlanner.statementBalance([(StatementFacts(closing: 5, currency: 'USD', to: DateTime(2026)), const <StatementRow>[])], bank), isNull);
    });

    test('a card balance is what is owed', () {
      final owed = BookAccount(id: 'c', name: 'Card', side: AccountSide.owe, type: AccountType.credit, currency: 'SAR');
      final e = builder.balanceTo(owed, tracked: 0, statement: 125000, date: DateTime(2026, 11, 30))!;
      final book = Book([owed], [e]);
      expect(book.balanceOf(owed.id), 125000);
    });

    test('numbers are remembered only when the files agree', () {
      const a = StatementFacts(refs: [StatementRef(StatementRefKind.card, '4417')]);
      const b = StatementFacts(refs: [StatementRef(StatementRefKind.card, '9001')]);
      expect(ImportPlanner.refsToKeep([a, StatementFacts.none, a]), ['card:4417']);
      expect(ImportPlanner.refsToKeep([a, b]), isEmpty);
      expect(ImportPlanner.refsToKeep(const [StatementFacts.none]), isEmpty);
    });

    test('an account keeps its statement numbers', () {
      final back = BookAccount.fromJson(card.toJson());
      expect(back.statementRefs, ['card:4417']);
      expect(BookAccount.fromJson(bank.toJson()).statementRefs, isEmpty);
      expect(StatementRef.fromKey('card:4417'), const StatementRef(StatementRefKind.card, '4417'));
      expect(StatementRef.fromKey('card:44'), isNull);
    });
  });

  group('documents as banks and billers really make them', () {
    test('Arabic stored as letter shapes reads as plain letters', () {
      expect(StatementReader.normalize('ﺍﻝﺭﺹﻱﺩ ﺍﻝﺱﺍﺏﻕ'), 'الرصيد السابق');
      expect(StatementReader.normalize('ﻻ'), 'لا');
      final page = DocPage(line(0.05, [('ﺍﻝﺭﺹﻱﺩ ﺍﻝﺱﺍﺏﻕ 1,500.00', 0.05, 0.4)]));
      expect(reader.facts([page], const []).opening, 1500);
    });

    // A made-up statement laid out like a Saudi bank's: a bilingual header,
    // the summary above the table, and two rows whose figure the PDF
    // reports in the wrong place (a wide box reaching the debit column).
    List<DocPage> bilingual() => [
          DocPage([
            ...line(0.03, [('Account Number 12345678901234', 0.05, 0.5)]),
            ...line(0.05, [('Account Type & Currency Current account ريال سعودي', 0.05, 0.6)]),
            ...line(0.07, [('01/09/2026', 0.6, 0.08), ('30/09/2026', 0.75, 0.08)]),
            ...line(0.10, [('End Balance', 0.05, 0.1), ('Starting Balance', 0.7, 0.12)]),
            ...line(0.115, [('880.00', 0.05, 0.06), ('1,000.00', 0.7, 0.07)]),
            ...line(0.20, [
              ('Balance', 0.05, 0.05), ('الرصيد', 0.12, 0.035), ('Debit', 0.17, 0.035), ('المدين', 0.22, 0.03),
              ('Credit', 0.27, 0.04), ('الدائن', 0.32, 0.03), ('Description', 0.37, 0.08), ('Date', 0.86, 0.03),
            ]),
            ...line(0.24, [('990.00', 0.108, 0.05), ('10.00', 0.235, 0.025), ('MONTHLY FEE', 0.44, 0.18), ('01/09/2026', 0.887, 0.057)]),
            ...line(0.27, [('988.50', 0.143, 0.114), ('VAT', 0.7, 0.05), ('01/09/2026', 0.887, 0.057)]),
            ...line(0.30, [('1,188.50', 0.103, 0.055), ('200.00', 0.33, 0.03), ('SALARY', 0.44, 0.1), ('05/09/2026', 0.887, 0.057)]),
            ...line(0.33, [('1,088.50', 0.103, 0.055), ('100.00', 0.23, 0.03), ('CARD PAYMENT', 0.44, 0.15), ('10/09/2026', 0.887, 0.057)]),
            ...line(0.345, [('************4417', 0.44, 0.15)]),
            ...line(0.38, [('1,073.50', 0.103, 0.055), ('15.00', 0.235, 0.025), ('COFFEE', 0.44, 0.1), ('12/09/2026', 0.887, 0.057)]),
            ...line(0.41, [('1,078.50', 0.103, 0.055), ('5.00', 0.335, 0.025), ('REFUND', 0.44, 0.1), ('14/09/2026', 0.887, 0.057)]),
            ...line(0.44, [('880.00', 0.143, 0.114), ('TRANSFER OUT', 0.44, 0.15), ('20/09/2026', 0.887, 0.057)]),
          ]),
        ];

    test('figures in the wrong place are put right by the running balance', () {
      final (rows, facts) = reader.read(bilingual());
      expect(rows.map((r) => r.amount), [-10, -1.5, 200, -100, -15, 5, -198.5]);
      expect(rows[1].balance, 988.5);
      expect(facts.opening, 1000);
      expect(facts.closing, 880);
      expect(Reconciliation.of(facts, rows)!.addsUp, isTrue);
    });

    test('the account, period and currency come from above the table, not a card paid in it', () {
      final (_, facts) = reader.read(bilingual());
      expect(facts.refs, [const StatementRef(StatementRefKind.account, '1234')]);
      expect(facts.from, DateTime(2026, 9, 1));
      expect(facts.to, DateTime(2026, 9, 30));
      expect(facts.currency, 'SAR');
    });

    test('a transfer confirmation is one transaction, from the account it names', () {
      DocToken t(String s, double y, double x, [double w = 0.25]) => DocToken(s, x, y, w, 0.012);
      final page = DocPage([
        t('Transaction Details', 0.03, 0.1),
        t('Date & Time', 0.15, 0.08), t('12/09/2026 10:15:00', 0.15, 0.4),
        t('Reference Number', 0.18, 0.08), t('20260912000000001', 0.18, 0.4),
        t('Savings Account Transfer', 0.24, 0.08), t('تحويل إلى حساب التوفير', 0.24, 0.67),
        t('From', 0.30, 0.08, 0.05),
        t('Account', 0.32, 0.08, 0.08), t('99887766554433', 0.32, 0.41),
        t('Debit Amount', 0.35, 0.08), t('1,250.00', 0.35, 0.44, 0.1),
        t('Total Amount', 0.45, 0.08), t('1,250.00', 0.45, 0.44, 0.1),
        t('To', 0.50, 0.08, 0.05),
        t('Account', 0.53, 0.08, 0.08), t('11223344556677', 0.53, 0.41),
        t('Credit Amount', 0.59, 0.08), t('1,250.00', 0.59, 0.45, 0.1),
      ]);
      final (rows, facts) = reader.read([page]);
      expect(rows, hasLength(1));
      expect(rows.single.description, 'Savings Account Transfer');
      expect(rows.single.detail, 'تحويل إلى حساب التوفير');
      expect(rows.single.amount, -1250);
      expect(rows.single.date, DateTime(2026, 9, 12));
      expect(rows.single.signGuessed, isFalse);
      expect(facts.refs, [const StatementRef(StatementRefKind.account, '4433')]);
      expect(facts.opening, isNull);
    });

    test('a bill: its total outvotes a figure misread beside one label, and the invoice date is its day', () {
      DocToken t(String s, double y, double x, [double w = 0.12]) => DocToken(s, x, y, w, 0.012);
      final pages = [
        DocPage([
          t('فاتورة ضريبية مبسطة', 0.13, 0.75, 0.15),
          t('لاستهلاك الكهرباء', 0.15, 0.58, 0.15),
          // Two label and value pairs on one line, right to left.
          t('المبلغ المطلوب سداده:', 0.34, 0.34, 0.12), t('٣١', 0.345, 0.79, 0.02), t('عدد الأيام:', 0.345, 0.88, 0.08),
          t('٤٥٦.٧٨', 0.37, 0.39, 0.05),
          t('٤٥٦.٧٨', 0.52, 0.12, 0.05), t('إجمالي الفاتورة:', 0.52, 0.21, 0.1),
        ]),
        DocPage([
          t('SIMPLIFIED TAX INVOICE', 0.10, 0.05, 0.3),
          t('Period Start 21-07-2026 Account Number: 3000111222 Invoice Date: 20-08-2026', 0.20, 0.05, 0.9),
          t('Number of Days 31 Amount Due:', 0.25, 0.05, 0.5),
          t('Total Consumption 900.00 K.W.H 456.78', 0.265, 0.05, 0.5),
          t('Previous Balance: 0.00', 0.30, 0.05, 0.3),
          t('Total Amount: 456.78', 0.33, 0.05, 0.3),
        ]),
      ];
      final (rows, facts) = reader.read(pages);
      expect(rows, hasLength(1));
      expect(rows.single.amount, -456.78);
      expect(rows.single.date, DateTime(2026, 8, 20));
      expect(rows.single.description, startsWith('فاتورة ضريبية مبسطة'));
      expect(facts.opening, isNull, reason: "a bill's previous balance is the biller's, not the account's");
      expect(facts.refs, isEmpty, reason: "the biller's account number is not one of the person's");
    });

    test('a short list with a total under it keeps its rows', () {
      final page = DocPage([
        ...line(0.05, [('Card payment history', 0.05, 0.4)]),
        ...line(0.10, [('03/09/2026', 0.05, 0.1), ('CAFE ONE', 0.2, 0.3), ('-12.00', 0.8, 0.1)]),
        ...line(0.13, [('03/09/2026', 0.05, 0.1), ('BOOK SHOP', 0.2, 0.3), ('-30.00', 0.8, 0.1)]),
        ...line(0.18, [('Total: 42.00', 0.6, 0.3)]),
      ]);
      expect(reader.read([page]).$1.map((r) => r.amount), [-12, -30]);
    });

    test('a document with no money in it gives nothing', () {
      final page = DocPage([
        ...line(0.03, [('Liability Determination Report', 0.05, 0.4)]),
        ...line(0.06, [('Case Number RD0000000001', 0.05, 0.4)]),
        ...line(0.09, [('15/10/2026 23:13:48 Case Registration Time', 0.05, 0.5)]),
        ...line(0.12, [('Party (1) Party (2)', 0.05, 0.4)]),
        ...line(0.15, [('Expiry Date 08/11/2026', 0.05, 0.4)]),
      ]);
      expect(reader.read([page]).$1, isEmpty);
    });
  });

}
