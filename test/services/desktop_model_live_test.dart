import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/statement_reader.dart';
import 'package:qima/services/desktop_model.dart';
import 'package:qima_llm/qima_llm.dart';

// Runs the real model on made-up bank messages (no real bank's wording, card
// or amount). Skipped unless QIMA_LLM_LIB names a built qima_llm library
// (with qima_cpu beside it) and QIMA_LLM_MODEL the downloaded model file
// (DesktopModelFile.qwen).
void main() {
  final lib = Platform.environment['QIMA_LLM_LIB'];
  final modelPath = Platform.environment['QIMA_LLM_MODEL'];
  final skip = lib == null || modelPath == null ? 'set QIMA_LLM_LIB and QIMA_LLM_MODEL' : false;

  const messages = <(String, MessageIntent, double?)>[
    ('Purchase of SAR 45.50 at LEMON MART with card **4471. Balance SAR 1,204.10', MessageIntent.purchase, -45.5),
    ('تم خصم 120.00 ريال من حسابك لصالح نادي الكثبان. الرصيد المتاح 980.00 ريال', MessageIntent.debit, -120),
    ('Your OTP is 482913. Do not share it with anyone.', MessageIntent.code, null),
    ('Transfer received SAR 300.00 from SARA ALI', MessageIntent.transferIn, 300),
    ('Your card statement is ready. Minimum due SAR 410.00 by 25/11', MessageIntent.notice, null),
    ('Payment of AED 89.00 at PAPER HOUSE was declined, insufficient funds', MessageIntent.declined, null),
    ('ATM withdrawal EGP 2,000.00 at Garden Branch. Avl bal EGP 5,430.25', MessageIntent.withdrawal, -2000),
    ('استرداد مبلغ 75.00 ر.س من متجر الورق', MessageIntent.refund, 75),
    ('Salary credited KWD 850.000 to account ***12. Balance KWD 1,320.500', MessageIntent.deposit, 850),
    ('تحويل صادر بمبلغ 500 جنيه إلى محمد علي', MessageIntent.transferOut, -500),
    ('Annual card fee USD 25.00 charged to your card', MessageIntent.fee, -25),
  ];

  test('the model reads made-up bank messages, and the reader keeps only what the message holds', () async {
    // The pinned file, where DesktopModel looks for it.
    final dir = Directory.systemTemp.createTempSync('qima_live_model');
    addTearDown(() => dir.deleteSync(recursive: true));
    Link('${dir.path}/models/${DesktopModelFile.qwen.name}').createSync(File(modelPath!).absolute.path, recursive: true);
    final cpu = '${File(lib!).parent.path}${Platform.pathSeparator}${QimaLlm.cpuLibraryName}';
    final model = DesktopModel(
        directory: () async => dir, cpu: () => QimaLlm.cpuSupported(library: cpu), open: (path) => QimaLlm.open(path, library: lib));
    addTearDown(model.close);
    final provider = DesktopAiAssistProvider(model: model);
    expect(await provider.isAvailable(), isTrue, reason: 'QIMA_LLM_MODEL must be the pinned model file');

    final reader = StatementReader(received: DateTime(2026, 11, 14, 9));
    var intents = 0, amounts = 0;
    for (final (text, intent, amount) in messages) {
      final clock = Stopwatch()..start();
      final labels = await provider.readMessage(text, 'en');
      expect(labels, isNotNull, reason: text);
      final rows = reader.withMessageLabels(text, reader.readMessages(text), labels!);
      final got = rows.where((r) => !r.doubtful).map((r) => r.amount).firstOrNull;
      if (labels.intent == intent) intents++;
      if (got == amount) amounts++;
      // ignore: avoid_print
      print('${clock.elapsedMilliseconds}ms ${labels.intent?.name} (want ${intent.name}) "${labels.amount}" '
          '"${labels.name}" -> $got (want $amount)');
    }
    // ignore: avoid_print
    print('intents $intents/${messages.length}, amounts $amounts/${messages.length}');
    expect(amounts, messages.length);
    expect(intents, greaterThanOrEqualTo(messages.length - 2));
  }, skip: skip, timeout: const Timeout(Duration(minutes: 5)));
}
