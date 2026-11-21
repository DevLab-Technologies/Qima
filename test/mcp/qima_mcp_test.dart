import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/mcp/mcp_server.dart';
import 'package:qima/mcp/qima_tools.dart';
import 'package:qima/mcp/snapshot_location.dart';
import 'package:qima/models/ai_snapshot.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/entry_builder.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/services/ai_apps.dart';

BookAccount own(String id, String name, AccountType type, [String ccy = 'SAR']) =>
    BookAccount(id: id, name: name, side: AccountSide.own, type: type, currency: ccy);

final rajhi = own('rajhi', 'Al Rajhi', AccountType.debit).copyWith(note: 'IBAN SA00 1234', statementRefs: const ['4421']);
final cib = own('cib', 'CIB', AccountType.debit, 'EGP');
final land = own('land', 'Land', AccountType.asset);
final faisal = own('faisal', 'Faisal', AccountType.receivable);
final visa = BookAccount(id: 'visa', name: 'Visa', side: AccountSide.owe, type: AccountType.credit, currency: 'SAR', creditLimit: 1000000);
final dining = BookAccount(id: 'dining', name: 'Dining', side: AccountSide.spending, type: AccountType.category);
final groceries = BookAccount(id: 'groceries', name: 'Groceries', side: AccountSide.spending, type: AccountType.category);
final salary = BookAccount(id: 'salary', name: 'Salary', side: AccountSide.income, type: AccountType.category);
final old = own('old', 'Old wallet', AccountType.cash).copyWith(archived: true);

final rates = FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13}, updatedAt: DateTime.utc(2026, 11, 14, 6));
final now = DateTime(2026, 11, 14, 12);

int sar(num major) => MinorUnits.fromMajor(major, 'SAR');
int egp(num major) => MinorUnits.fromMajor(major, 'EGP');

AiSnapshot snapshot({double? holdingsValue = 2500}) {
  var n = 0;
  final b = EntryBuilder(baseCurrency: 'SAR', rates: rates, newId: () => 'e${++n}');
  final entries = <BookEntry>[
    b.opening(rajhi, sar(10000), DateTime(2026, 10, 1)),
    b.opening(cib, egp(1300), DateTime(2026, 10, 1)),
    b.opening(land, sar(50000), DateTime(2026, 10, 1)),
    b.opening(visa, sar(400), DateTime(2026, 10, 1)),
    b.income(rajhi, salary, sar(8000), DateTime(2026, 11, 1), merchant: 'Employer'),
    b.spend(rajhi, groceries, sar(300), DateTime(2026, 11, 3), merchant: 'Panda'),
    b.spend(visa, dining, sar(120), DateTime(2026, 11, 10), merchant: 'Al Baik'),
    b.spend(rajhi, dining, sar(50), DateTime(2026, 10, 20), merchant: 'Kudu'),
    b.transfer(rajhi, faisal, sar(500), DateTime(2026, 11, 5)),
  ];
  final withRaw = [
    for (final e in entries) e.merchant == 'Panda' ? e.copyWith(rawMerchant: 'POS PANDA 4421 RIYADH') : e,
  ];
  return AiSnapshot.build(
    now: now,
    baseCurrency: 'SAR',
    rates: rates,
    accounts: [rajhi, cib, land, faisal, visa, dining, groceries, salary, old],
    entries: withRaw,
    planned: [
      RecurringPayment(id: 'p1', name: 'Netflix', amount: sar(45), fromAccountId: 'visa', categoryId: 'dining', start: DateTime(2026, 11, 20)),
    ],
    settings: MoneySettings(budgets: {'dining': sar(1000), 'groceries': sar(2000)}, categoryRules: const {'panda': 'groceries'}),
    holdingsValue: holdingsValue,
    holdings: const [AiHolding(symbol: 'XAU', assetClass: 'metal', value: 2500, cost: 2000)],
  );
}

Map<String, dynamic> run(String tool, [Map<String, dynamic> args = const {}, AiSnapshot? s]) =>
    QimaTools.named(tool)!.run(s ?? snapshot(), args, now);

void main() {
  group('AiSnapshot', () {
    test('leaves out account numbers, notes, raw merchant text and learned rules', () {
      final text = jsonEncode(snapshot().toJson());
      expect(text, isNot(contains('4421')));
      expect(text, isNot(contains('IBAN')));
      expect(text, isNot(contains('POS PANDA')));
      expect(text, isNot(contains('categoryRules')));
      expect(text, contains('Panda'));
    });

    test('reads back what it wrote', () {
      final s = snapshot();
      final back = AiSnapshot.fromJson(jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>);
      expect(back.accounts, s.accounts);
      expect(back.entries, s.entries);
      expect(back.planned, s.planned);
      expect(back.budgets, s.budgets);
      expect(back.holdingsValue, 2500);
      expect(back.rates, s.rates);
    });

    test('refuses a snapshot from a newer Qima', () {
      final json = snapshot().toJson()..['schema'] = AiSnapshot.schema + 1;
      expect(() => AiSnapshot.fromJson(json), throwsFormatException);
    });
  });

  group('tools', () {
    test('net worth matches the balance sheet and includes holdings', () {
      final r = run('get_net_worth');
      // Rajhi 10000 + 8000 - 300 - 50 - 500 = 17150; CIB 1300 EGP = 100; Faisal 500;
      // Land 50000; holdings 2500. Visa 400 + 120 = 520.
      expect(r['groups'], {
        'holdings': 2500.0,
        'cash_and_bank': 17250.0,
        'owed_to_you': 500.0,
        'assets': 50000.0,
        'credit_cards': 520.0,
        'loans': 0.0,
        'you_owe': 0.0,
      });
      expect(r['net_worth'], 17250 + 500 + 50000 + 2500 - 520);
      expect(r['currency'], 'SAR');
      expect(r['saved_by_qima_at'], now.toUtc().toIso8601String());
    });

    test('net worth says when holding prices were missing', () {
      final r = run('get_net_worth', const {}, snapshot(holdingsValue: null));
      expect(r['groups']['holdings'], 0.0);
      expect(r['holdings_note'], contains('had not loaded'));
    });

    test('net worth on an earlier day', () {
      final r = run('get_net_worth', {'as_of': '2026-10-31'});
      // Before November: Rajhi 10000 - 50, CIB 100, Land 50000, Visa 400.
      expect(r['groups']['cash_and_bank'], 10050.0);
      expect(r['groups']['credit_cards'], 400.0);
      expect(r['holdings_note'], contains('not on 2026-10-31'));
    });

    test('accounts hide categories and archived ones unless asked', () {
      final names = [for (final a in run('list_accounts')['accounts'] as List) a['name']];
      expect(names, containsAll(['Al Rajhi', 'CIB', 'Land', 'Faisal', 'Visa']));
      expect(names, isNot(contains('Dining')));
      expect(names, isNot(contains('Old wallet')));
      expect(names, isNot(contains('Opening balances')));

      final all = run('list_accounts', {'include_categories': true, 'include_archived': true})['accounts'] as List;
      final dining = all.firstWhere((a) => a['name'] == 'Dining');
      expect(dining['type'], 'spending_category');
      expect(dining['all_time_total'], {'SAR': 170.0});
      expect(all.any((a) => a['name'] == 'Old wallet'), isTrue);
      final visa = all.firstWhere((a) => a['name'] == 'Visa');
      expect(visa['balance'], 520.0);
      expect(visa['credit_limit'], 10000.0);
    });

    test('transactions filter by account name, text and dates, newest first', () {
      final r = run('list_transactions', {'account': 'dining'});
      expect([for (final t in r['transactions'] as List) t['merchant']], ['Al Baik', 'Kudu']);

      final panda = run('list_transactions', {'text': 'panda'})['transactions'] as List;
      expect(panda.single['lines'], unorderedEquals([
        {'account': 'Al Rajhi', 'account_id': 'rajhi', 'change': -300.0, 'currency': 'SAR'},
        {'account': 'Groceries', 'account_id': 'groceries', 'change': 300.0, 'currency': 'SAR'},
      ]));

      final nov = run('list_transactions', {'from': '2026-11-01', 'to': '2026-11-05'});
      expect(nov['count'], 3);
      final limited = run('list_transactions', {'limit': 2});
      expect(limited['count'], 9);
      expect(limited['returned'], 2);
      expect((limited['transactions'] as List).first['merchant'], 'Al Baik');
    });

    test('transactions explain bad input', () {
      expect(() => run('list_transactions', {'from': '2026-13-01'}), throwsA(isA<ToolInputError>()));
      expect(() => run('list_transactions', {'from': '2026-11-05', 'to': '2026-11-01'}), throwsA(isA<ToolInputError>()));
      expect(() => run('list_transactions', {'account': 'nobody'}), throwsA(isA<ToolInputError>()));
      expect(() => run('list_transactions', {'kind': 'heist'}), throwsA(isA<ToolInputError>()));
      expect(() => run('list_transactions', {'limit': 0}), throwsA(isA<ToolInputError>()));
    });

    test('spending for this month counts the budget and planned payments still due', () {
      final r = run('get_spending');
      expect(r['month'], '2026-11');
      expect(r['spent'], 420.0);
      expect(r['income'], 8000.0);
      expect(r['by_category'], [
        {'category': 'Groceries', 'spent': 300.0, 'budget': 2000.0},
        {'category': 'Dining', 'spent': 120.0, 'budget': 1000.0},
      ]);
      expect(r['budget'], 3000.0);
      expect(r['planned_still_to_pay'], 45.0);
      expect(r['left_to_spend'], 3000 - 420 - 45);
    });

    test('spending for an earlier month has no planned payments', () {
      final r = run('get_spending', {'month': '2026-10'});
      expect(r['spent'], 50.0);
      expect(r.containsKey('planned_still_to_pay'), isFalse);
      expect(() => run('get_spending', {'month': '2026-1'}), throwsA(isA<ToolInputError>()));
    });

    test('planned payments, people and holdings', () {
      final planned = run('list_planned_payments')['planned_payments'] as List;
      expect(planned.single, containsPair('next_due', '2026-11-20'));
      expect(planned.single, containsPair('amount', 45.0));
      expect(planned.single, containsPair('account', 'Visa'));

      expect(run('list_people')['people'], [
        {'name': 'Faisal', 'currency': 'SAR', 'balance': 500.0},
      ]);

      final h = run('list_holdings');
      expect(h['total_value'], 2500.0);
      expect((h['holdings'] as List).single['gain'], 500.0);
    });
  });

  group('McpServer', () {
    McpServer server({AiSnapshot Function()? load}) =>
        McpServer(loadSnapshot: load ?? snapshot, version: 'test', clock: () => now);

    Map<String, dynamic> call(McpServer s, Map<String, dynamic> message) =>
        jsonDecode(s.handleLine(jsonEncode(message))!) as Map<String, dynamic>;

    test('initializes with the version the client asks for when it knows it', () {
      final r = call(server(), {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {'protocolVersion': '2025-03-26', 'capabilities': {}, 'clientInfo': {'name': 'x', 'version': '1'}},
      });
      expect(r['result']['protocolVersion'], '2025-03-26');
      expect(r['result']['capabilities'], {'tools': {'listChanged': false}});
      expect(r['result']['serverInfo']['name'], 'qima');

      final unknown = call(server(), {'jsonrpc': '2.0', 'id': 2, 'method': 'initialize', 'params': {'protocolVersion': '1999-01-01'}});
      expect(unknown['result']['protocolVersion'], McpServer.protocolVersions.first);
    });

    test('notifications get no reply', () {
      expect(server().handleLine(jsonEncode({'jsonrpc': '2.0', 'method': 'notifications/initialized'})), isNull);
      expect(server().handleLine('   '), isNull);
    });

    test('lists every tool as read-only', () {
      final tools = call(server(), {'jsonrpc': '2.0', 'id': 1, 'method': 'tools/list'})['result']['tools'] as List;
      expect([for (final t in tools) t['name']], [for (final t in QimaTools.all) t.name]);
      for (final t in tools) {
        expect(t['annotations']['readOnlyHint'], isTrue);
        expect(t['inputSchema']['type'], 'object');
      }
    });

    test('calls a tool and returns text and structured content', () {
      final r = call(server(), {
        'jsonrpc': '2.0',
        'id': 'a',
        'method': 'tools/call',
        'params': {'name': 'get_net_worth', 'arguments': {}},
      });
      expect(r['id'], 'a');
      expect(r['result']['isError'], isFalse);
      expect(r['result']['structuredContent']['currency'], 'SAR');
      expect(jsonDecode(r['result']['content'][0]['text'] as String)['currency'], 'SAR');
    });

    test('bad tool input and a missing snapshot are tool errors the model can read', () {
      final bad = call(server(), {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'tools/call',
        'params': {'name': 'get_spending', 'arguments': {'month': 'May'}},
      });
      expect(bad['result']['isError'], isTrue);
      expect(bad['result']['content'][0]['text'], contains('YYYY-MM'));

      final off = call(server(load: () => throw const SnapshotUnavailable('Turn it on.')), {
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': 'list_people'},
      });
      expect(off['result']['isError'], isTrue);
      expect(off['result']['content'][0]['text'], 'Turn it on.');
    });

    test('protocol errors', () {
      expect(jsonDecode(server().handleLine('{nope')!)['error']['code'], -32700);
      expect(call(server(), {'jsonrpc': '2.0', 'id': 1, 'method': 'resources/list'})['error']['code'], -32601);
      expect(call(server(), {'jsonrpc': '2.0', 'id': 1, 'method': 'tools/call', 'params': {'name': 'drop_tables'}})['error']['code'], -32602);
      expect(call(server(), {'id': 1, 'method': 'ping'})['error']['code'], -32600);
      expect(call(server(), {'jsonrpc': '2.0', 'id': 1, 'method': 'ping'})['result'], isEmpty);
    });
  });

  group('SnapshotLocation', () {
    test('default paths per desktop system', () {
      expect(SnapshotLocation.defaultPath(os: 'macos', environment: {'HOME': '/Users/a'}),
          '/Users/a/Library/Group Containers/ZS3A435WC2.com.devlabtechnologies.qima/qima-ai-snapshot.json');
      expect(
          SnapshotLocation.defaultPath(os: 'macos', environment: {'HOME': '/Users/a/Library/Containers/com.devlabtechnologies.qima.mcp/Data'}),
          '/Users/a/Library/Group Containers/ZS3A435WC2.com.devlabtechnologies.qima/qima-ai-snapshot.json');
      expect(SnapshotLocation.defaultPath(os: 'windows', environment: {'APPDATA': r'C:\Users\a\AppData\Roaming'}),
          r'C:\Users\a\AppData\Roaming\DevLab Technologies\Qima\qima-ai-snapshot.json');
      expect(SnapshotLocation.defaultPath(os: 'linux', environment: {'HOME': '/home/a'}),
          '/home/a/.local/share/com.devlabtechnologies.qima/qima-ai-snapshot.json');
      expect(SnapshotLocation.defaultPath(os: 'linux', environment: {'HOME': '/home/a', 'XDG_DATA_HOME': '/data'}),
          '/data/com.devlabtechnologies.qima/qima-ai-snapshot.json');
      expect(SnapshotLocation.defaultPath(os: 'ios', environment: const {}), isNull);
    });

    test('reads a written snapshot and explains a missing one', () {
      final dir = Directory.systemTemp.createTempSync('qima_mcp');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = '${dir.path}/${SnapshotLocation.fileName}';
      expect(() => SnapshotLocation.read(path), throwsA(isA<SnapshotUnavailable>()));
      File(path).writeAsStringSync(jsonEncode(snapshot().toJson()));
      expect(SnapshotLocation.read(path).baseCurrency, 'SAR');
    });
  });

  test('the config an AI app needs names the helper and the snapshot', () {
    final config = jsonDecode(AiApps.config(helper: '/Apps/qima-mcp', snapshot: '/data/qima-ai-snapshot.json'));
    expect(config, {
      'mcpServers': {
        'qima': {
          'command': '/Apps/qima-mcp',
          'args': ['--snapshot', '/data/qima-ai-snapshot.json'],
        },
      },
    });
  });
}
