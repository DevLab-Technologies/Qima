import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qima/models/statement_facts.dart';
import 'package:qima/models/statement_reader.dart';
import 'package:qima/services/ai_assist_provider.dart';
import 'package:qima/services/desktop_model.dart';
import 'package:qima_llm/qima_llm.dart';

void main() {
  final bytes = utf8.encode('not a real model, only bytes to download. ' * 50);
  final good = DesktopModelFile(
    name: 'test.gguf',
    url: Uri.parse('https://models.test/test.gguf'),
    size: bytes.length,
    sha256: sha256.convert(bytes).toString(),
  );

  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('qima_desktop_model'));
  tearDown(() => dir.deleteSync(recursive: true));

  File at(String name) => File('${dir.path}${Platform.pathSeparator}models${Platform.pathSeparator}$name');

  /// A server that sends [body] (or what's left of it after a Range), and
  /// records the Range asked for.
  (http.Client Function(), List<String?>) server(List<int> body, {bool ranges = true}) {
    final asked = <String?>[];
    http.Client client() => MockClient.streaming((request, _) async {
          final range = request.headers['Range'];
          asked.add(range);
          final from = range == null ? 0 : int.parse(range.substring(6, range.length - 1));
          if (ranges && from > 0) return http.StreamedResponse(Stream.value(body.sublist(from)), 206);
          return http.StreamedResponse(Stream.value(body), 200);
        });
    return (client, asked);
  }

  DesktopModel model(http.Client Function() client, {DesktopModelFile? file, Duration stall = const Duration(seconds: 60)}) =>
      DesktopModel(
          file: file ?? good, directory: () async => dir, client: client, open: (_) async => null, cpu: () => true, stall: stall);

  /// A server that sends the first [sent] bytes and then nothing more,
  /// without closing.
  http.Client Function() stalling(int sent) => () => MockClient.streaming((request, _) async {
        final body = StreamController<List<int>>()..add(bytes.sublist(0, sent));
        return http.StreamedResponse(body.stream, 200);
      });

  test('asking for the status starts the download, and the checked file makes it ready', () async {
    final (client, asked) = server(bytes);
    final m = model(client);
    expect(await m.status(), ModelStatus.notReady);
    await m.download();
    expect(asked, [null]);
    expect(at('test.gguf').readAsBytesSync(), bytes);
    expect(at('test.gguf.part').existsSync(), isFalse);
    expect(await m.status(), ModelStatus.ready);
  });

  test('a file that does not match its hash is thrown away and never used', () async {
    final (client, _) = server(bytes);
    final m = model(client, file: DesktopModelFile(name: 'test.gguf', url: good.url, size: good.size, sha256: '0' * 64));
    await m.download();
    expect(at('test.gguf').existsSync(), isFalse);
    expect(at('test.gguf.part').existsSync(), isFalse);
    expect(await m.downloaded, isFalse);
  });

  test('a download cut short carries on from where it stopped', () async {
    at('test.gguf.part')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes.sublist(0, 700));
    final (client, asked) = server(bytes);
    await model(client).download();
    expect(asked, ['bytes=700-']);
    expect(at('test.gguf').readAsBytesSync(), bytes);
  });

  test('a server that ignores the range starts the file again', () async {
    at('test.gguf.part')
      ..createSync(recursive: true)
      ..writeAsBytesSync(List.filled(700, 7));
    final (client, _) = server(bytes, ranges: false);
    await model(client).download();
    expect(at('test.gguf').readAsBytesSync(), bytes);
  });

  test('a failed download leaves nothing usable and is tried again on the next ask', () async {
    var calls = 0;
    final m = model(() => MockClient((_) async {
          calls++;
          return http.Response('busy', 503);
        }));
    expect(await m.status(), ModelStatus.notReady);
    await m.download();
    expect(await m.downloaded, isFalse);
    await m.status();
    await m.download();
    expect(calls, 2);
  });

  test('a part that is all here (closed before the rename) is checked and used, not asked for again', () async {
    at('test.gguf.part')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    final (client, asked) = server(bytes);
    final m = model(client);
    await m.download();
    expect(asked, isEmpty);
    expect(at('test.gguf').readAsBytesSync(), bytes);
    expect(await m.status(), ModelStatus.ready);
  });

  test('a download that stops sending is given up, and carries on from there next time', () async {
    final m = model(stalling(700), stall: const Duration(milliseconds: 50));
    await m.download();
    expect(at('test.gguf.part').lengthSync(), 700);
    expect(await m.downloaded, isFalse);
  });

  test('stopping ends the download and keeps what came for next time', () async {
    final m = model(stalling(700));
    final running = m.download();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    m.stop();
    await running.timeout(const Duration(seconds: 2));
    expect(at('test.gguf.part').lengthSync(), 700);
  });

  test('on a CPU that cannot run the model nothing is downloaded and it says so', () async {
    final (client, asked) = server(bytes);
    final m = DesktopModel(file: good, directory: () async => dir, client: client, open: (_) async => null, cpu: () => false);
    expect(await m.status(), ModelStatus.unsupported);
    await Future<void>.delayed(Duration.zero);
    expect(asked, isEmpty);
    expect(await m.ask(system: 's', user: 'u'), isNull);
  });

  test('a model that failed to load is tried again only after a while', () async {
    final (client, _) = server(bytes);
    var opened = 0;
    DesktopModel failing(Duration retry) => DesktopModel(
        file: good, directory: () async => dir, client: client, cpu: () => true, retry: retry, open: (_) async {
          opened++;
          return null;
        });
    final m = failing(const Duration(minutes: 5));
    await m.download();
    expect(await m.ask(system: 's', user: 'u'), isNull);
    expect(await m.ask(system: 's', user: 'u'), isNull);
    expect(opened, 1);
    expect(await m.status(), ModelStatus.ready);

    final soon = failing(Duration.zero);
    expect(await soon.ask(system: 's', user: 'u'), isNull);
    expect(await soon.ask(system: 's', user: 'u'), isNull);
    expect(opened, 3);
  });

  test('a load that never finishes does not hold the question past its time', () async {
    final (client, _) = server(bytes);
    final m = DesktopModel(
        file: good, directory: () async => dir, client: client, cpu: () => true, open: (_) => Completer<QimaLlm?>().future);
    await m.download();
    expect(await m.ask(system: 's', user: 'u', timeout: const Duration(milliseconds: 50)), isNull);
  });

  test('nothing is asked before the file is here', () async {
    var opened = 0;
    final m = DesktopModel(file: good, directory: () async => dir, cpu: () => true, open: (_) async {
      opened++;
      return null;
    });
    expect(await m.ask(system: 's', user: 'u'), isNull);
    expect(opened, 0);
  });

  group('the answer', () {
    test('is read from the JSON the model wrote, with anything around it ignored', () {
      final map = DesktopAiAssistProvider.messageLabels(
          'Sure: { "amount": "SAR 45.50", "balance": "", "name": "LEMON MART", "intent": "purchase" } done');
      expect(MessageLabels.fromMap(map!), const MessageLabels(intent: MessageIntent.purchase, amount: 'SAR 45.50', name: 'LEMON MART'));
      expect(DesktopAiAssistProvider.messageLabels('no json here'), isNull);
      expect(DesktopAiAssistProvider.messageLabels('{"amount": '), isNull);
    });

    test('can only name an intent the reader knows', () {
      for (final intent in MessageIntent.values) {
        expect(DesktopAiAssistProvider.messageGrammar, contains('"\\"" ('), reason: 'intent rule');
        expect(DesktopAiAssistProvider.messageGrammar, contains('"${intent.name}"'));
      }
    });
  });
}
