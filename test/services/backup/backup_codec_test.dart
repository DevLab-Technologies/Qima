import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/backup.dart';
import 'package:qima/services/backup/backup_codec.dart';

BackupPayload _payload() => const BackupPayload(
      watchcards: [
        {
          'item': {'id': 'c1', 'instrumentID': 'metal.XAU', 'currency': 'USD', 'unit': 'troyOunce', 'karat': null},
          'order': 0.0,
          'updatedAt': '2026-01-01T00:00:00.000Z',
          'deleted': false,
        },
      ],
      holdings: [],
      customInstruments: [],
      alerts: [],
      settings: BackupSettings(
        baseCurrency: 'USD',
        appLanguage: 'system',
        appearance: 'system',
        preferredChartRange: 'month1',
        widgetRefreshInterval: 15,
      ),
    );

const _app = BackupAppInfo(version: '1.2.0', build: '42');

void main() {
  final l10n = AppLocalizationsEn();

  group('plain round trip', () {
    test('encodes and decodes back to the same payload', () async {
      final json = BackupCodec.encodePlain(payload: _payload(), app: _app);
      final envelope = BackupCodec.parseEnvelope(json);

      expect(envelope.encrypted, isFalse);
      expect(envelope.app.version, '1.2.0');
      expect(envelope.app.build, '42');

      final decoded = await BackupCodec.decodePayload(envelope);
      expect(decoded.watchcards, _payload().watchcards);
      expect(decoded.settings.baseCurrency, 'USD');
    });
  });

  group('encrypted round trip', () {
    test('encodes and decodes back to the same payload with the right password', () async {
      final json = await BackupCodec.encodeEncrypted(payload: _payload(), app: _app, password: 'correct horse');
      final envelope = BackupCodec.parseEnvelope(json);

      expect(envelope.encrypted, isTrue);

      final decoded = await BackupCodec.decodePayload(envelope, password: 'correct horse');
      expect(decoded.watchcards, _payload().watchcards);
    });

    test('wrong password fails with BackupErrorKind.wrongPassword', () async {
      final json = await BackupCodec.encodeEncrypted(payload: _payload(), app: _app, password: 'correct horse');
      final envelope = BackupCodec.parseEnvelope(json);

      await expectLater(
        () => BackupCodec.decodePayload(envelope, password: 'wrong password'),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.wrongPassword)),
      );
    });

    test('empty password fails with BackupErrorKind.wrongPassword', () async {
      final json = await BackupCodec.encodeEncrypted(payload: _payload(), app: _app, password: 'correct horse');
      final envelope = BackupCodec.parseEnvelope(json);

      await expectLater(
        () => BackupCodec.decodePayload(envelope, password: ''),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.wrongPassword)),
      );
    });

    test('tampered ciphertext fails with BackupErrorKind.wrongPassword (GCM tag mismatch)', () async {
      final json = await BackupCodec.encodeEncrypted(payload: _payload(), app: _app, password: 'correct horse');
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final payload = decoded['payload'] as Map<String, dynamic>;
      // Flip one character of the base64 ciphertext.
      final ciphertext = payload['ciphertext'] as String;
      final flipped = (ciphertext[0] == 'A' ? 'B' : 'A') + ciphertext.substring(1);
      payload['ciphertext'] = flipped;
      final tamperedJson = jsonEncode(decoded);

      final envelope = BackupCodec.parseEnvelope(tamperedJson);
      await expectLater(
        () => BackupCodec.decodePayload(envelope, password: 'correct horse'),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.wrongPassword)),
      );
    });

    test('different encryptions of the same payload produce different ciphertext', () async {
      final json1 = await BackupCodec.encodeEncrypted(payload: _payload(), app: _app, password: 'pw');
      final json2 = await BackupCodec.encodeEncrypted(payload: _payload(), app: _app, password: 'pw');
      final e1 = jsonDecode(json1)['payload']['ciphertext'];
      final e2 = jsonDecode(json2)['payload']['ciphertext'];
      expect(e1, isNot(equals(e2)));
    });
  });

  group('format errors', () {
    test('non-JSON input fails with BackupErrorKind.notQimaFile', () {
      expect(
        () => BackupCodec.parseEnvelope('not json at all'),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.notQimaFile)),
      );
    });

    test('CSV input fails with BackupErrorKind.notQimaFile', () {
      const csv = 'Instrument,Symbol,Quantity\nGold,XAU,1';
      expect(
        () => BackupCodec.parseEnvelope(csv),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.notQimaFile)),
      );
    });

    test('valid JSON missing the format marker fails with BackupErrorKind.notQimaFile', () {
      final json = jsonEncode({'foo': 'bar'});
      expect(
        () => BackupCodec.parseEnvelope(json),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.notQimaFile)),
      );
    });

    test('a foreign JSON file with the wrong format string fails with BackupErrorKind.notQimaFile', () {
      final json = jsonEncode({
        'format': 'some-other-app-backup',
        'version': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'app': {'version': '1.0', 'build': '1'},
        'encrypted': false,
        'payload': {},
      });
      expect(
        () => BackupCodec.parseEnvelope(json),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.notQimaFile)),
      );
    });

    test('newer version fails with BackupErrorKind.newerVersion', () {
      final json = jsonEncode({
        'format': 'qima-backup',
        'version': BackupEnvelope.currentVersion + 1,
        'createdAt': DateTime.now().toIso8601String(),
        'app': {'version': '9.9.9', 'build': '999'},
        'encrypted': false,
        'payload': {},
      });
      expect(
        () => BackupCodec.parseEnvelope(json),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.newerVersion)),
      );
    });

    test('missing required fields in the payload fails with BackupErrorKind.corrupted', () async {
      final json = jsonEncode({
        'format': 'qima-backup',
        'version': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'app': {'version': '1.0', 'build': '1'},
        'encrypted': false,
        'payload': {'watchcards': []}, // missing holdings/customInstruments/alerts/settings
      });
      final envelope = BackupCodec.parseEnvelope(json);
      await expectLater(
        () => BackupCodec.decodePayload(envelope),
        throwsA(isA<BackupError>().having((e) => e.kind, 'kind', BackupErrorKind.corrupted)),
      );
    });

    test('every error kind resolves to a distinct, non-empty localized message', () {
      final messages = BackupErrorKind.values.map((kind) => BackupError(kind).message(l10n)).toSet();
      expect(messages.length, BackupErrorKind.values.length);
      expect(messages.every((m) => m.isNotEmpty), isTrue);
    });
  });
}
