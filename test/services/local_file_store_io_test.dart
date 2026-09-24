import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/services/local_file_store_io.dart' as io_store;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_local_file_store_test');
    io_store.overrideDirectoryForTesting(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('writeJson atomic write', () {
    test('writes content readable back via readJson, with no leftover .tmp file', () async {
      final ok = await io_store.writeJson('atomic.json', {'a': 1});
      expect(ok, isTrue);

      final file = File('${tempDir.path}/atomic.json');
      final tmp = File('${tempDir.path}/atomic.json.tmp');
      expect(await file.exists(), isTrue);
      expect(await tmp.exists(), isFalse);

      final read = await io_store.readJson('atomic.json');
      expect(read, {'a': 1});
    });

    test('a second write fully replaces prior content rather than appending', () async {
      await io_store.writeJson('atomic.json', {'a': 1});
      await io_store.writeJson('atomic.json', {'b': 2});

      final read = await io_store.readJson('atomic.json');
      expect(read, {'b': 2});

      final tmp = File('${tempDir.path}/atomic.json.tmp');
      expect(await tmp.exists(), isFalse);
    });
  });
}
