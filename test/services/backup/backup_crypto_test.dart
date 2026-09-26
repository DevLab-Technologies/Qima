import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/backup.dart';
import 'package:qima/services/backup/backup_crypto.dart';

/// [BackupCrypto.encrypt]'s [iterations] parameter exists purely so tests
/// elsewhere (encrypted-backup fixtures in widget/service tests) can avoid
/// paying the real ~600,000-iteration PBKDF2 cost on every run — see that
/// method's doc comment. This file is the one place that still proves the
/// PRODUCTION default (what every real export actually uses) is exactly
/// [EncryptedPayload.kdfIterations], and exercises a real round trip at a
/// deliberately low cost so the crypto logic itself (not the KDF's cost) is
/// what's under test.
void main() {
  test('encrypt() defaults to the production 600,000-iteration KDF cost when unspecified', () async {
    final payload = await BackupCrypto.encrypt(plainPayloadJson: const {'k': 'v'}, password: 'pw');
    expect(payload.kdfIterationsUsed, 600000);
    expect(payload.kdfIterationsUsed, EncryptedPayload.kdfIterations);
  });

  group('round trip at a low test iteration count', () {
    test('decrypts back to the original payload with the right password', () async {
      const plain = {'a': 1, 'b': 'two', 'c': true};
      final encrypted = await BackupCrypto.encrypt(plainPayloadJson: plain, password: 'correct horse', iterations: 10);
      expect(encrypted.kdfIterationsUsed, 10);

      final decrypted = await BackupCrypto.decrypt(payload: encrypted, password: 'correct horse');
      expect(decrypted, plain);
    });

    test('throws BackupWrongPasswordError for the wrong password', () async {
      final encrypted = await BackupCrypto.encrypt(
        plainPayloadJson: const {'a': 1},
        password: 'correct horse',
        iterations: 10,
      );

      await expectLater(
        () => BackupCrypto.decrypt(payload: encrypted, password: 'wrong'),
        throwsA(isA<BackupWrongPasswordError>()),
      );
    });

    test('decode reads the iterations the file was actually encrypted with, not any caller default', () async {
      // Simulates an OLDER real backup file encrypted at the full production
      // cost being decrypted by code that (in tests) defaults its OWN
      // encrypt calls to a low count — decrypt must still use whatever
      // `kdfIterationsUsed` says, never a hardcoded/default value.
      final encrypted = await BackupCrypto.encrypt(
        plainPayloadJson: const {'a': 1},
        password: 'pw',
        iterations: EncryptedPayload.kdfIterations,
      );
      expect(encrypted.kdfIterationsUsed, EncryptedPayload.kdfIterations);

      final decrypted = await BackupCrypto.decrypt(payload: encrypted, password: 'pw');
      expect(decrypted, {'a': 1});
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
