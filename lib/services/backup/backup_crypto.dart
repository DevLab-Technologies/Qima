import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../../models/backup.dart';

/// AES-256-GCM + PBKDF2-HMAC-SHA256 wrapper for encrypted backups (spec
/// Phase 6). Stateless — every call takes the password fresh and never
/// stores or logs it.
///
/// The PBKDF2 pass (600,000 iterations) is deliberately run via [compute],
/// off the UI thread: at that iteration count it can take real wall-clock
/// time (hundreds of milliseconds to a few seconds depending on the device),
/// and running it inline would freeze the export/import sheet's animations
/// and gesture handling for that whole span.
class BackupCrypto {
  BackupCrypto._();

  static final Random _random = Random.secure();

  static List<int> _randomBytes(int length) => List<int>.generate(length, (_) => _random.nextInt(256));

  /// Encrypts [plainPayloadJson] (the UTF-8 JSON of a [BackupPayload]) under
  /// [password]. Generates a fresh random salt and nonce for every call, so
  /// the same payload encrypted twice with the same password never produces
  /// the same ciphertext.
  ///
  /// [iterations] defaults to the production PBKDF2 cost
  /// ([EncryptedPayload.kdfIterations], 600,000) and must never be lowered
  /// outside tests — it's written into the file's `kdf.iterations` field, so
  /// [decrypt] always uses whatever cost the file was actually encrypted
  /// with regardless of this call's default. Tests pass a much smaller value
  /// so encrypted-backup fixtures build in milliseconds instead of the real
  /// KDF's hundreds-of-milliseconds-to-seconds cost.
  static Future<EncryptedPayload> encrypt({
    required Map<String, dynamic> plainPayloadJson,
    required String password,
    int iterations = EncryptedPayload.kdfIterations,
  }) async {
    final salt = _randomBytes(EncryptedPayload.saltLength);
    final plainBytes = utf8.encode(jsonEncode(plainPayloadJson));

    final secretKey = await _deriveKey(password: password, salt: salt, iterations: iterations);
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(plainBytes, secretKey: secretKey, nonce: nonce);

    return EncryptedPayload(
      kdfIterationsUsed: iterations,
      salt: salt,
      nonce: nonce,
      // `SecretBox.concatenation()` appends the GCM tag to the ciphertext,
      // matching the "ciphertext(b64, includes GCM tag)" shape in the spec.
      ciphertext: secretBox.concatenation(nonce: false),
    );
  }

  /// Decrypts [payload] with [password]. Throws [BackupWrongPasswordError]
  /// specifically when the GCM authentication tag fails to verify (wrong
  /// password OR tampered ciphertext — GCM can't tell the two apart, which
  /// is exactly the property that makes it safe: an attacker gets no signal
  /// about which one it was).
  static Future<Map<String, dynamic>> decrypt({
    required EncryptedPayload payload,
    required String password,
  }) async {
    final secretKey = await _deriveKey(
      password: password,
      salt: payload.salt,
      iterations: payload.kdfIterationsUsed,
    );
    final algorithm = AesGcm.with256bits();
    final macLength = algorithm.macAlgorithm.macLength;
    if (payload.ciphertext.length < macLength) {
      throw BackupWrongPasswordError();
    }
    final cipherBytes = payload.ciphertext.sublist(0, payload.ciphertext.length - macLength);
    final macBytes = payload.ciphertext.sublist(payload.ciphertext.length - macLength);
    final secretBox = SecretBox(cipherBytes, nonce: payload.nonce, mac: Mac(macBytes));

    List<int> clear;
    try {
      clear = await algorithm.decrypt(secretBox, secretKey: secretKey);
    } on SecretBoxAuthenticationError {
      throw BackupWrongPasswordError();
    }

    try {
      final decoded = jsonDecode(utf8.decode(clear));
      if (decoded is! Map<String, dynamic>) throw const FormatException('not an object');
      return decoded;
    } catch (_) {
      // Decrypted successfully (so the password WAS correct) but the
      // plaintext isn't valid JSON — this is corruption, not a wrong
      // password, so it gets its own distinct error.
      throw BackupCorruptedError();
    }
  }

  static Future<SecretKey> _deriveKey({
    required String password,
    required List<int> salt,
    int iterations = EncryptedPayload.kdfIterations,
  }) {
    // `compute` spawns/reuses a background isolate; the closure and its
    // arguments must be independently constructible, hence the plain record
    // argument rather than closing over `this`.
    return compute(_deriveKeyIsolate, _KdfRequest(password: password, salt: salt, iterations: iterations));
  }
}

class _KdfRequest {
  final String password;
  final List<int> salt;
  final int iterations;

  const _KdfRequest({required this.password, required this.salt, required this.iterations});
}

/// Top-level (not a closure/method) so it can be torn off and sent to
/// [compute]'s background isolate.
Future<SecretKey> _deriveKeyIsolate(_KdfRequest request) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: request.iterations,
    bits: 256,
  );
  return pbkdf2.deriveKeyFromPassword(
    password: request.password,
    nonce: Uint8List.fromList(request.salt),
  );
}

/// Thrown by [BackupCrypto.decrypt] when the GCM tag fails to verify — the
/// password was wrong, or the ciphertext was tampered with/corrupted.
/// [BackupCodec] surfaces this as [BackupErrorKind.wrongPassword].
class BackupWrongPasswordError implements Exception {
  @override
  String toString() => 'BackupWrongPasswordError';
}

/// Thrown when decryption succeeds (the password was correct) but the
/// resulting plaintext isn't valid backup JSON.
class BackupCorruptedError implements Exception {
  @override
  String toString() => 'BackupCorruptedError';
}
