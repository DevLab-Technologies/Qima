import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/message_shape.dart';
import 'package:qima/models/statement_facts.dart';
import 'package:qima/models/statement_reader.dart';

// Every message here is made up: no real bank's wording, card or amount.
void main() {
  final reader = StatementReader(received: DateTime(2026, 11, 14, 9));

  group('learned shapes', () {
    const first = 'Card 9921 used\nSAR 75.00\nMAX SPORTS JEDDAH\nBal SAR 1,200.00';
    const next = 'Card 9921 used\nSAR 12.50\nBLUE CAFE\nBal SAR 1,187.50';

    MessageShape learnFirst() => MessageShape.learn(
          text: first,
          sender: 'ACME-Bank',
          corrected: StatementRow(date: DateTime(2026, 11, 14), description: 'MAX SPORTS JEDDAH', amount: -75),
          reader: reader,
        )!;

    test('a corrected message teaches how its sender writes the next one', () {
      final shape = learnFirst();
      final rows = reader.readMessages(next);
      final row = MessageShape.read([shape], 'acme bank', next, rows, reader)!;
      expect(row.amount, -12.5);
      expect(row.currency, 'SAR');
      expect(row.description, 'BLUE CAFE');
      expect(row.signGuessed, isFalse);
    });

    test('a shape only reads its own sender, and only a message like the one it came from', () {
      final shape = learnFirst();
      expect(MessageShape.read([shape], 'Other Bank', next, reader.readMessages(next), reader), isNull);
      const different = 'Transfer received\nFrom SARA ALI\nSAR 300.00';
      expect(MessageShape.read([shape], 'ACME-Bank', different, reader.readMessages(different), reader), isNull);
    });

    test('an amount the message does not hold teaches nothing', () {
      final shape = MessageShape.learn(
        text: first,
        sender: 'ACME-Bank',
        corrected: StatementRow(date: DateTime(2026, 11, 14), description: 'MAX SPORTS JEDDAH', amount: -76),
        reader: reader,
      );
      expect(shape, isNull);
    });

    test('shapes survive a save, and a newer one replaces the one it reads the same as', () {
      final shape = learnFirst();
      expect(MessageShape.fromJson(shape.toJson()), shape);
      final income = MessageShape(sender: shape.sender, amountBefore: shape.amountBefore, direction: 1);
      final merged = MessageShape.merge([shape], [income]);
      expect(merged, [income]);
    });

    test('senders are one key however they are written', () {
      expect(senderKey(' ACME-Bank '), senderKey('acme bank'));
      expect(senderKey('+966 55 000 0000'), senderKey('96655 0000000'));
      expect(senderKey(null), '');
    });
  });

  group('the model reads what a message is about', () {
    test('a notice the rules read as money is kept for the person, unticked', () {
      const text = 'Your card statement is out. Amount SAR 410.00 debited by autopay on the due date.';
      final rows = reader.readMessages(text);
      expect(rows, hasLength(1));
      final out = reader.withMessageLabels(text, rows, const MessageLabels(intent: MessageIntent.notice));
      expect(out.single.doubtful, isTrue);
    });

    test('the amount comes from the words the model copied, never from the model', () {
      const text = 'Balance SAR 2,000.00 after purchase SAR 40.00 at LEMON MART';
      final rows = [StatementRow(date: DateTime(2026, 11, 14), description: 'LEMON MART', amount: -2000, currency: 'SAR')];
      final out = reader.withMessageLabels(
          text, rows, const MessageLabels(intent: MessageIntent.purchase, amount: 'SAR 40.00', balance: 'SAR 2,000.00', name: 'LEMON MART'));
      expect(out.single.amount, -40);

      // Words that aren't in the message drop the model's reading.
      final made = reader.withMessageLabels(text, rows, const MessageLabels(intent: MessageIntent.purchase, amount: 'SAR 45.00'));
      expect(made, rows);
    });

    test('a message the rules missed becomes a row from the copied words', () {
      const text = 'ACME: 120.00 SAR left your account for DUNE GYM';
      final out = reader.withMessageLabels(text, const [], const MessageLabels(intent: MessageIntent.debit, amount: '120.00 SAR', name: 'DUNE GYM'));
      expect(out.single.amount, -120);
      expect(out.single.description, 'DUNE GYM');
      expect(out.single.signGuessed, isFalse);
    });

    test('a name the message does not hold is ignored', () {
      const text = 'Spent SAR 9.00 at ** 4471';
      final rows = [StatementRow(date: DateTime(2026, 11, 14), description: '', amount: -9, currency: 'SAR')];
      final out = reader.withMessageLabels(text, rows, const MessageLabels(intent: MessageIntent.purchase, amount: 'SAR 9.00', name: 'Coffee Corner'));
      expect(out.single.description, '');
    });

    test('when the model and the words disagree on the direction, the person decides', () {
      const text = 'Refund SAR 20.00 from PAPER HOUSE';
      final rows = reader.readMessages(text);
      expect(rows.single.amount, 20);
      final out = reader.withMessageLabels(text, rows, const MessageLabels(intent: MessageIntent.purchase, amount: 'SAR 20.00'));
      expect(out.single.amount, 20);
      expect(out.single.signGuessed, isTrue);
    });

    test('model labels parse only names the reader knows', () {
      expect(MessageLabels.fromMap({'intent': 'purchase', 'amount': 'SAR 1.00', 'name': 'Shop 24'}),
          const MessageLabels(intent: MessageIntent.purchase, amount: 'SAR 1.00', name: 'Shop'));
      expect(MessageLabels.fromMap({'intent': 'teleport'}), isNull);
    });
  });
}
