import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/import_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/categorizer.dart';
import 'package:qima/models/import_plan.dart';
import 'package:qima/models/message_shape.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/statement_facts.dart';
import 'package:qima/models/statement_reader.dart';
import 'package:qima/models/transaction_capture.dart';
import 'package:qima/services/ai_assist_provider.dart';
import 'package:qima/services/book_store.dart';
import 'package:qima/services/csv/xlsx_reader.dart';
import 'package:qima/services/import/import_inbox_io.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/text_recognition_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rates = FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13}, updatedAt: DateTime.utc(2026, 11, 7));
int sar(num major) => MinorUnits.fromMajor(major, 'SAR');

/// Vision and PDFKit stand-in: every PDF or image reads as [pages].
class FakeRecognition implements TextRecognitionService {
  List<DocPage>? pages;
  final read = <String>[];
  FakeRecognition(this.pages);

  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<List<String>?> recognize(String imagePath, List<String> languageTags) async => null;
  @override
  Future<List<DocPage>?> readDocument(String path, List<String> languageTags) async {
    read.add(path);
    return pages;
  }
}

List<DocToken> line(double y, List<(String, double, double)> cells) => [for (final (t, x, w) in cells) DocToken(t, x, y, w, 0.02)];

/// A minimal .xlsx: shared strings, one sheet, a date style on column A.
List<int> xlsx(List<List<Object>> rows) {
  final strings = <String>[];
  int sid(String s) {
    final i = strings.indexOf(s);
    if (i >= 0) return i;
    strings.add(s);
    return strings.length - 1;
  }

  final sheet = StringBuffer('<?xml version="1.0"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>');
  for (var r = 0; r < rows.length; r++) {
    sheet.write('<row r="${r + 1}">');
    for (var c = 0; c < rows[r].length; c++) {
      final ref = '${String.fromCharCode(65 + c)}${r + 1}';
      final v = rows[r][c];
      if (v is String) {
        sheet.write('<c r="$ref" t="s"><v>${sid(v)}</v></c>');
      } else if (v is DateTime) {
        final serial = v.difference(DateTime.utc(1899, 12, 30)).inDays;
        sheet.write('<c r="$ref" s="1"><v>$serial</v></c>');
      } else {
        sheet.write('<c r="$ref"><v>$v</v></c>');
      }
    }
    sheet.write('</row>');
  }
  sheet.write('</sheetData></worksheet>');
  final shared = '<?xml version="1.0"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '${strings.map((s) => '<si><t>${const HtmlEscape().convert(s)}</t></si>').join()}</sst>';
  const styles = '<?xml version="1.0"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<cellXfs count="2"><xf numFmtId="0"/><xf numFmtId="14"/></cellXfs></styleSheet>';
  final archive = Archive()
    ..addFile(ArchiveFile.string('xl/worksheets/sheet1.xml', sheet.toString()))
    ..addFile(ArchiveFile.string('xl/sharedStrings.xml', shared))
    ..addFile(ArchiveFile.string('xl/styles.xml', styles));
  return ZipEncoder().encode(archive);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late BookStore store;
  late MoneyCubit money;
  late FolderInbox inbox;
  late FakeRecognition recognition;
  late ImportCubit importer;
  var ids = 0;

  final bank = BookAccount(id: 'rajhi', name: 'Al Rajhi', side: AccountSide.own, type: AccountType.debit, currency: 'SAR');
  final card = BookAccount(id: 'visa', name: 'Visa', side: AccountSide.owe, type: AccountType.credit, currency: 'SAR');
  final egp = BookAccount(id: 'cib', name: 'CIB', side: AccountSide.own, type: AccountType.debit, currency: 'EGP');

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qima_import');
    LocalFileStore.overrideDirectoryForTesting(dir);
    SharedPreferences.setMockInitialValues({});
    store = BookStore();
    ids = 0;
    money = MoneyCubit(store: store, baseCurrency: () => 'SAR', rates: () => rates, newId: () => 'id${++ids}', now: () => DateTime(2026, 11, 7));
    await money.load();
    final shared = Directory('${dir.path}/shared')..createSync();
    final own = Directory('${dir.path}/own')..createSync();
    inbox = FolderInbox(folders: [own, shared]);
    recognition = FakeRecognition(null);
    importer = ImportCubit(inbox: inbox, recognition: recognition, wasImported: money.wasImported, languages: () => const ['en-US']);
  });

  tearDown(() async {
    await importer.close();
    await money.close();
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  /// What the share extension writes: a folder with the file and meta.json.
  Future<void> share(String name, List<int> bytes, {DateTime? at, String? kind}) async {
    final folder = Directory('${dir.path}/shared/${++ids}-shared')..createSync();
    File('${folder.path}/$name').writeAsBytesSync(bytes);
    File('${folder.path}/meta.json').writeAsStringSync(jsonEncode({
      'name': name,
      'receivedAt': (at ?? DateTime(2026, 11, 7, 12).add(Duration(seconds: ids))).toUtc().toIso8601String(),
      'kind': ?kind,
    }));
  }

  group('the inbox and reading', () {
    test('a shared CSV, an Excel file and a PDF are read; a half-written folder is not', () async {
      await share('statement.csv', utf8.encode('Date,Description,Amount\n2026-11-03,PANDA,-642.10\n2026-11-01,Salary,18000\n'));
      await share('export.xlsx', xlsx([
        ['Date', 'Details', 'Debit', 'Credit'],
        [DateTime.utc(2026, 11, 4), 'STC', 300, ''],
      ]));
      recognition.pages = [DocPage(line(0.1, [('05/11/2026 ALBAIK', 0.05, 0.5), ('45.00 SAR-', 0.7, 0.2)]))];
      await share('scan.pdf', [37, 80, 68, 70]);
      Directory('${dir.path}/shared/.half').createSync();

      await importer.checkInbox();
      final items = importer.state.items;
      expect(items.map((i) => i.file.name), ['statement.csv', 'export.xlsx', 'scan.pdf']);
      expect(items.every((i) => i.status == ImportStatus.read), isTrue);
      expect(items[0].rows.map((r) => r.amount), [-642.10, 18000]);
      expect(items[1].rows.single.amount, -300);
      expect(items[1].rows.single.date, DateTime(2026, 11, 4));
      expect(items[2].rows.single.description, 'ALBAIK');
      expect(recognition.read, hasLength(1));
      expect(importer.state.rowCount, 4);
    });

    test('a shared bank message becomes one row; an unknown file type says so', () async {
      await share('message.txt', utf8.encode('Purchase of SAR 89.00 at JARIR on 06/11/26'));
      await share('notes.docx', [1, 2, 3]);
      await importer.checkInbox();
      expect(importer.state.items[0].rows.single.amount, -89);
      expect(importer.state.items[1].status, ImportStatus.unsupported);
    });

    test('bank messages read by Qima: one with no transaction, or seen before, is dropped unseen', () async {
      final purchase = utf8.encode('Purchase of SAR 89.00 at JARIR on 06/11/26');
      await share('Bank message.txt', purchase, kind: 'message');
      await share('Bank message.txt', utf8.encode('Your SAR balance statement is ready in the app'), kind: 'message');
      await share('Bank message.txt', purchase, kind: 'message');
      await importer.checkInbox();
      final item = importer.state.items.single;
      expect(item.file.message, isTrue);
      expect(item.rows.single.amount, -89);
      expect(await inbox.pending(), hasLength(1));
    });

    test('the same file shared twice, or imported before, is skipped', () async {
      final bytes = utf8.encode('Date,Description,Amount\n2026-11-03,PANDA,-642.10\n');
      await share('a.csv', bytes);
      await share('b.csv', bytes);
      await importer.checkInbox();
      expect(importer.state.items.map((i) => i.status), [ImportStatus.read, ImportStatus.alreadyImported]);

      await money.markImported([importer.state.items.first.hash!]);
      await importer.remove(importer.state.items.map((i) => i.id));
      await share('c.csv', bytes);
      await importer.checkInbox();
      expect(importer.state.items.single.status, ImportStatus.alreadyImported);
    });

    test('files picked in the app go through the inbox; removing deletes them', () async {
      await importer.addFiles([('picked.csv', utf8.encode('Date,Description,Amount\n2026-11-03,PANDA,-1.00\n'))]);
      expect(importer.state.items.single.rows, hasLength(1));
      expect(await inbox.pending(), hasLength(1));
      await importer.remove([importer.state.items.single.id]);
      expect(await inbox.pending(), isEmpty);
      expect(importer.state.isEmpty, isTrue);
    });

    test('Excel dates and shared strings', () {
      final rows = XlsxReader.read(xlsx([
        ['Date', 'Description', 'Amount'],
        [DateTime.utc(2026, 11, 3), 'بنده', -642.1],
      ]))!;
      expect(rows[1], ['2026-11-03', 'بنده', '-642.1']);
      expect(XlsxReader.read([1, 2, 3]), isNull);
    });
  });

  group('planning against the book', () {
    test('the account is guessed from the currency the rows are in', () {
      final rows = [StatementRow(date: DateTime(2026, 11, 3), description: 'x', amount: -1, currency: 'EGP')];
      expect(ImportPlanner.guessAccount([card, bank, egp], rows, const []), egp);
      expect(ImportPlanner.guessAccount([card, bank], const [], const []), bank);
      expect(ImportPlanner.guessAccount(const [], rows, const []), isNull);
    });

    test('duplicates of the book, repeats across files and other currencies start unticked', () async {
      await money.addAccount(bank, opening: sar(10000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      await money.saveEntry(money.builder.spend(bank, cats['category.groceries']!, sar(642.10), DateTime(2026, 11, 2), merchant: 'Panda'));
      final panda = StatementRow(date: DateTime(2026, 11, 3), description: 'PANDA RIYADH', amount: -642.10, currency: 'SAR');
      final coffee = StatementRow(date: DateTime(2026, 11, 4), description: 'Starbucks', amount: -23);
      final usd = StatementRow(date: DateTime(2026, 11, 4), description: 'Amazon', amount: -10, currency: 'USD');
      final plan = ImportPlanner.plan(files: [('f1', [panda, coffee, usd]), ('f2', [coffee])], account: bank, book: money.state.book);
      expect(plan.map((c) => c.flag), [ImportFlag.inBook, null, ImportFlag.otherCurrency, ImportFlag.repeated]);
      // The merchant's last category wins over the keyword list.
      expect(plan[0].categoryId, 'category.groceries');
      expect(plan[1].categoryId, 'category.dining');
      expect(plan.map((c) => c.key), ['f1:0', 'f1:1', 'f1:2', 'f2:0']);
    });

    test('a refund of the same amount is not a duplicate of the purchase', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      await money.saveEntry(money.builder.spend(bank, cats['category.shopping']!, sar(150), DateTime(2026, 11, 2), merchant: 'Jarir'));
      final refund = StatementRow(date: DateTime(2026, 11, 3), description: 'JARIR BOOKSTORE', amount: 150);
      expect(ImportPlanner.plan(files: [('f', [refund])], account: bank, book: money.state.book).single.flag, isNull);
    });

    test('two equal charges with one in the book: only one is a duplicate', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      await money.saveEntry(money.builder.spend(bank, cats['category.dining']!, sar(18), DateTime(2026, 11, 2), merchant: 'Corner Cafe'));
      final a = StatementRow(date: DateTime(2026, 11, 2), description: 'CORNER CAFE', amount: -18);
      final b = StatementRow(date: DateTime(2026, 11, 2), description: 'CORNER CAFE', amount: -18);
      final plan = ImportPlanner.plan(files: [('f', [a, b])], account: bank, book: money.state.book);
      expect(plan.map((c) => c.flag), [ImportFlag.inBook, null]);
    });

    test('the same amount from another merchant is for the person to check', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      await money.saveEntry(money.builder.spend(bank, cats['category.dining']!, sar(40), DateTime(2026, 11, 2), merchant: 'Corner Cafe'));
      final row = StatementRow(date: DateTime(2026, 11, 2), description: 'PETROL STATION 12', amount: -40);
      final c = ImportPlanner.plan(files: [('f', [row])], account: bank, book: money.state.book).single;
      expect(c.flag, ImportFlag.maybeInBook);
      expect(c.suggested, isFalse);
      expect(c.match?.merchant, 'Corner Cafe');
    });

    test('a row from another merchant never takes the entry from the row that is really it', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      await money.saveEntry(money.builder.spend(bank, cats['category.dining']!, sar(40), DateTime(2026, 11, 2), merchant: 'Corner Cafe'));
      final petrol = StatementRow(date: DateTime(2026, 11, 2), description: 'PETROL STATION', amount: -40);
      final cafe = StatementRow(date: DateTime(2026, 11, 2), description: 'CORNER CAFE', amount: -40);
      final plan = ImportPlanner.plan(files: [('f', [petrol, cafe])], account: bank, book: money.state.book);
      expect(plan.map((c) => c.flag), [null, ImportFlag.inBook]);
    });

    test('equal rows in one file are kept; only an earlier file makes a row a repeat', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final r = StatementRow(date: DateTime(2026, 11, 4), description: 'Taxi', amount: -25);
      final plan = ImportPlanner.plan(files: [('f1', [r, r]), ('f2', [r, r, r])], account: bank, book: money.state.book);
      expect(plan.map((c) => c.flag), [null, null, ImportFlag.repeated, ImportFlag.repeated, null]);
    });

    test('a row can be a transfer or a card payment, which the other statement then finds', () async {
      await money.addAccount(bank, opening: sar(5000), openedOn: DateTime(2026, 10, 1));
      await money.addAccount(card);
      final row = StatementRow(date: DateTime(2026, 11, 5), description: 'CARD PAYMENT', amount: -1200);
      expect(ImportPlanner.counterparts(money.state.book.accounts.values, bank), [card]);
      final e = ImportPlanner.entryFor(builder: money.builder, account: bank, category: card, row: row, isIn: false);
      expect(e.template, EntryTemplate.cardPayment);
      await money.importEntries([e]);
      expect(money.state.book.balanceOf(bank.id), sar(3800));
      // Nothing is spending or income.
      expect(money.state.book.spending(from: DateTime(2026, 11), to: DateTime(2026, 12)), isEmpty);
      // The card's own statement shows the payment coming in: already there.
      final onCard = StatementRow(date: DateTime(2026, 11, 6), description: 'PAYMENT RECEIVED', amount: 1200);
      expect(ImportPlanner.plan(files: [('c', [onCard])], account: card, book: money.state.book).single.flag, ImportFlag.inBook);
    });

    test('categories: the person\'s rule, then their usual choice, then known names, then Uncategorized', () async {
      await money.addAccount(bank, opening: sar(100), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      await money.saveEntry(money.builder.spend(bank, cats['category.health']!, sar(5), DateTime(2026, 11, 1), merchant: 'Carrefour Express'));
      CategoryGuess guess(String text, {bool isIn = false, Map<String, String> rules = const {}}) =>
          ImportPlanner.guessCategory(text, isIn: isIn, categorizer: Categorizer(money.state.book, rules: rules));
      expect(guess('CARREFOUR EXPRESS OLAYA').categoryId, 'category.health');
      expect(guess('CARREFOUR EXPRESS OLAYA').source, CategorySource.history);
      expect(guess('Uber trip').categoryId, 'category.transport');
      expect(guess('ستاربكس العليا').categoryId, 'category.dining');
      expect(guess('راتب شهر نوفمبر', isIn: true).categoryId, 'category.salary');
      // Nothing places it: Uncategorized, not Other.
      expect(guess('Something').categoryId, SystemAccount.uncategorized.id);
      expect(guess('Something').sure, isFalse);
      expect(guess('Something', isIn: true).categoryId, SystemAccount.uncategorizedIncome.id);
      // A rule the person taught beats their history.
      expect(guess('Carrefour Express', rules: {'out:carrefour express': 'category.groceries'}).source, CategorySource.rule);
      expect(guess('Carrefour Express', rules: {'out:carrefour express': 'category.groceries'}).categoryId, 'category.groceries');
    });

    test('their usual choice wins over one odd entry, and reference codes don\'t split a payee', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      final b = money.builder;
      await money.saveEntry(b.spend(bank, cats['category.dining']!, sar(5), DateTime(2026, 10, 1), merchant: 'FT26101AB1 - PayeeName Sara'));
      await money.saveEntry(b.spend(bank, cats['category.dining']!, sar(5), DateTime(2026, 10, 8), merchant: 'FT26108CD2 - PayeeName Sara'));
      await money.saveEntry(b.spend(bank, cats['category.home']!, sar(5), DateTime(2026, 10, 9), merchant: 'FT26109EF3 - PayeeName Sara'));
      final guess = ImportPlanner.guessCategory('FT26312Q1LQJ - PayeeName Sara', isIn: false, categorizer: Categorizer(money.state.book));
      expect(guess.categoryId, 'category.dining');
    });

    test('merchant keys drop codes, numbers, masks, labels and the country', () {
      expect(Categorizer.merchantKey('FT26312Q1LQJ - PayeeName احمد'), 'احمد');
      expect(Categorizer.merchantKey('PANDA RIYADH 4412'), 'panda riyadh');
      expect(Categorizer.merchantKey('Panda Riyadh SAU'), 'panda riyadh');
      expect(Categorizer.merchantKey('SLACK T0BL3BUVA94 SLACK.COM USA'), 'slack slackcom');
      expect(Categorizer.merchantKey('Mohamed M..... S.......'), 'mohamed');
      expect(Categorizer.merchantKey('PayerMobNo:00201062270277'), '');
    });
  });

  group('bank messages', () {
    ImportSource msg(String id, StatementRow row, {String? sender, List<StatementRef> refs = const []}) =>
        (id: id, message: true, sender: sender, rows: [row], facts: StatementFacts(refs: refs));
    final buy = StatementRow(date: DateTime(2026, 11, 6), description: 'CORNER CAFE', amount: -18, currency: 'SAR');

    test('each message finds its own account; statements stay together', () {
      final named = card.copyWith(statementRefs: ['card:7712']);
      final placed = ImportPlanner.accountsFor(
        files: [
          msg('a', buy, refs: const [StatementRef(StatementRefKind.card, '7712')]),
          msg('b', buy, sender: 'Home Bank'),
          msg('c', buy),
          (id: 's1', message: false, sender: null, rows: [buy], facts: const StatementFacts(refs: [StatementRef(StatementRefKind.card, '7712')])),
          (id: 's2', message: false, sender: null, rows: [buy], facts: StatementFacts.none),
        ],
        accounts: [bank, named, egp],
        entries: const [],
        senders: {'homebank': 'cib'},
      );
      expect(placed['a'], (account: named, named: true));
      expect(placed['b'], (account: egp, named: true));
      // Nothing names it: the usual guess, not sure.
      expect(placed['c'], (account: bank, named: false));
      expect(placed['s1']!.account, named);
      expect(placed['s2']!.account, named);
    });

    test('the person\'s own pick wins', () {
      final placed = ImportPlanner.accountsFor(files: [msg('a', buy)], accounts: [bank, egp], entries: const [], chosen: {'a': 'cib'});
      expect(placed['a']!.account, egp);
    });

    test('only messages that name their account and need no checking are added on their own', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      await money.addAccount(card, opening: 0, openedOn: DateTime(2026, 10, 1));
      final book = money.state.book;
      final sure = ImportPlanner.sureMessages(
        files: [
          msg('sure', buy, sender: 'Home Bank'),
          msg('noSender', buy),
          msg('guessed', buy.copyWith(signGuessed: true), sender: 'Home Bank'),
          msg('usd', buy.copyWith(currency: 'USD'), sender: 'Home Bank'),
        ],
        accounts: money.state.balanceAccounts,
        book: book,
        builder: money.builder,
        senders: {'homebank': 'rajhi'},
      );
      expect(sure.map((s) => s.fileId), ['sure']);
      expect(sure.single.entry.lines.any((l) => l.accountId == 'rajhi' && l.amount == -sar(18)), isTrue);
    });

    test('a message already in the book is not added again', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      await money.saveEntry(money.builder.spend(bank, cats['category.dining']!, sar(18), DateTime(2026, 11, 6), merchant: 'Corner Cafe'));
      final sure = ImportPlanner.sureMessages(
        files: [msg('m', buy, sender: 'Home Bank')],
        accounts: money.state.balanceAccounts,
        book: money.state.book,
        builder: money.builder,
        senders: {'homebank': 'rajhi'},
      );
      expect(sure, isEmpty);
    });

    test('a message on its own is read with what the model says it is about', () async {
      await importer.close();
      importer = ImportCubit(
          inbox: inbox, recognition: recognition, wasImported: money.wasImported, languages: () => const ['en-US'], assist: () => _MessageModel());
      await share('Bank message.txt', utf8.encode('ACME: 120.00 SAR left your account for DUNE GYM'), kind: 'message');
      await importer.checkInbox();
      final row = importer.state.items.single.rows.single;
      expect(row.amount, -120);
      expect(row.description, 'DUNE GYM');
    });

    test('a message keeps who sent it, and settings keep what was learned', () async {
      final folder = Directory('${dir.path}/shared/sms')..createSync();
      File('${folder.path}/Bank message.txt').writeAsStringSync('Purchase of SAR 18.00 at CORNER CAFE');
      File('${folder.path}/meta.json').writeAsStringSync(jsonEncode({
        'name': 'Bank message.txt', 'receivedAt': DateTime.utc(2026, 11, 7).toIso8601String(), 'kind': 'message', 'sender': ' Home Bank ',
      }));
      expect((await inbox.pending()).single.sender, 'Home Bank');

      await money.learnMessages(senders: {'homebank': 'rajhi'}, shapes: const [MessageShape(sender: 'homebank', amountBefore: ['of'], direction: -1)]);
      final again = MoneySettings.fromJson(money.state.settings.toJson());
      expect(again.messageSenders, {'homebank': 'rajhi'});
      expect(again.messageShapes.single.amountBefore, ['of']);
    });
  });

  group('to categorize', () {
    test('uncategorized entries group by merchant, one choice sorts the group and is remembered', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      final b = money.builder;
      final un = cats[SystemAccount.uncategorized.id]!;
      await money.saveEntry(b.spend(bank, un, sar(10), DateTime(2026, 10, 2), merchant: 'FT26AA01 - PayeeName Gym Club'));
      await money.saveEntry(b.spend(bank, un, sar(10), DateTime(2026, 11, 2), merchant: 'FT26AA02 - PayeeName Gym Club'));
      await money.saveEntry(b.spend(bank, un, sar(3), DateTime(2026, 11, 3), merchant: 'Kiosk'));
      final groups = money.state.uncategorized;
      expect(groups.map((g) => g.key), ['gym club', 'kiosk']);
      expect(groups.first.entries, hasLength(2));

      await money.categorize([for (final e in groups.first.entries) e.id], 'category.health', ruleKey: groups.first.ruleKey);
      expect(money.state.uncategorized.map((g) => g.key), ['kiosk']);
      expect(money.state.settings.categoryRules, {'out:gym club': 'category.health'});
      expect(money.state.book.balanceOf('category.health'), sar(20));
      // The next import from the club goes straight to Health.
      final next = ImportPlanner.guessCategory('FT26AA03 - PayeeName Gym Club',
          isIn: false, categorizer: Categorizer(money.state.book, rules: money.state.settings.categoryRules));
      expect(next.categoryId, 'category.health');

      await money.forgetCategory('out:gym club');
      expect(money.state.settings.categoryRules, isEmpty);
      // The rules survive a round trip through storage.
      final s = money.state.settings.copyWith(categoryRules: {'in:acme': 'category.salary'});
      expect(MoneySettings.fromJson(s.toJson()).categoryRules, {'in:acme': 'category.salary'});
    });
  });

  group('adding to the book', () {
    test('spends, income and refunds are added in one go and the file is remembered', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      final b = money.builder;
      StatementRow r(String d, double a) => StatementRow(date: DateTime(2026, 11, 3), description: d, amount: a, detail: 'POS 1');
      final entries = [
        ImportPlanner.entryFor(builder: b, account: bank, category: cats['category.groceries']!, row: r('PANDA', -642.10), isIn: false),
        ImportPlanner.entryFor(builder: b, account: bank, category: cats['category.salary']!, row: r('Salary', 18000), isIn: true),
        ImportPlanner.entryFor(builder: b, account: bank, category: cats['category.shopping']!, row: r('Refund NOON', 99), isIn: true),
      ];
      expect(entries.map((e) => e.template), [EntryTemplate.spend, EntryTemplate.income, EntryTemplate.refund]);
      expect(entries.every((e) => e.source == EntrySource.import), isTrue);
      expect(entries.first.rawMerchant, 'PANDA · POS 1');
      await money.importEntries(entries, fileHashes: ['abc']);
      expect(money.state.book.balanceOf('rajhi'), sar(1000 - 642.10 + 18000 + 99));
      expect(money.wasImported('abc'), isTrue);

      // Kept after a reload.
      final again = MoneyCubit(store: store, baseCurrency: () => 'SAR', rates: () => rates);
      await again.load();
      expect(again.state.entries.where((e) => e.source == EntrySource.import), hasLength(3));
      expect(again.wasImported('abc'), isTrue);
      await again.close();
    });

    test('an entry the book refuses saves nothing', () async {
      await money.addAccount(bank, opening: sar(1000), openedOn: DateTime(2026, 10, 1));
      final cats = money.state.book.accounts;
      final good = ImportPlanner.entryFor(
          builder: money.builder, account: bank, category: cats['category.groceries']!, row: StatementRow(date: DateTime(2026, 11, 3), description: 'A', amount: -1), isIn: false);
      final bad = good.copyWith(lines: [good.lines.first]);
      final before = money.state.entries.length;
      await expectLater(money.importEntries([good.copyWith(), bad], fileHashes: ['h']), throwsA(isA<BookRejected>()));
      expect(money.state.entries, hasLength(before));
      expect(money.wasImported('h'), isFalse);
    });
  });
}

/// An on-device model that reads one made-up message.
class _MessageModel implements AiAssistProvider {
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<ModelStatus> status(String localeTag) async => ModelStatus.ready;
  @override
  Future<CaptureSpans?> labelTransaction(String text, String localeTag) async => null;
  @override
  Future<String?> phrase(String sentence, String localeTag) async => null;
  @override
  Future<List<LineLabel>?> labelStatementLines(List<String> lines, String localeTag) async => null;
  @override
  Future<List<PageStructure>?> structurePages(String path, List<DocPage> pages, String localeTag) async => null;
  @override
  Future<MessageLabels?> readMessage(String text, String localeTag) async =>
      const MessageLabels(intent: MessageIntent.debit, amount: '120.00 SAR', name: 'DUNE GYM');
}
