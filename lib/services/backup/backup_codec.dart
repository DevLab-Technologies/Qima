import 'dart:convert';

import '../../l10n/app_localizations.dart';
import '../../models/backup.dart';
import 'backup_crypto.dart';

/// The distinct ways decoding/importing a backup file can fail (spec Phase
/// 6). Kept as a closed enum (rather than raw exception text) so the UI can
/// show a localized, specific message for each — "wrong password" and
/// "not a Qima file" need very different copy and next steps.
enum BackupErrorKind {
  /// The file isn't JSON, or doesn't have the `qima-backup` format marker.
  notQimaFile,

  /// `version` is newer than this app understands ([BackupEnvelope.currentVersion]).
  newerVersion,

  /// Encrypted backup, wrong password (or a tampered/corrupted ciphertext —
  /// AES-GCM can't distinguish the two, which is the point).
  wrongPassword,

  /// Valid envelope/JSON shape but the payload itself doesn't parse (a
  /// truncated file, a hand-edited field with the wrong type, etc.).
  corrupted,
}

class BackupError implements Exception {
  final BackupErrorKind kind;

  const BackupError(this.kind);

  /// Localized, user-facing message. Never includes the raw exception
  /// text — that's for `debugPrint`, not the user.
  String message(AppLocalizations l10n) {
    switch (kind) {
      case BackupErrorKind.notQimaFile:
        return l10n.backupErrorNotQimaFile;
      case BackupErrorKind.newerVersion:
        return l10n.backupErrorNewerVersion;
      case BackupErrorKind.wrongPassword:
        return l10n.backupErrorWrongPassword;
      case BackupErrorKind.corrupted:
        return l10n.backupErrorCorrupted;
    }
  }

  @override
  String toString() => 'BackupError($kind)';
}

/// Encodes/decodes the backup JSON envelope (spec Phase 6
/// `lib/models/backup.dart` format) and, for encrypted backups, the
/// AES-GCM/PBKDF2 payload via [BackupCrypto]. Pure codec layer — no file
/// I/O, no store access; see `backup_service.dart` for orchestration.
class BackupCodec {
  BackupCodec._();

  /// Builds the final JSON string for a plain (unencrypted) backup.
  static String encodePlain({
    required BackupPayload payload,
    required BackupAppInfo app,
    DateTime? createdAt,
  }) {
    final envelope = BackupEnvelope(
      format: BackupEnvelope.formatMagic,
      version: BackupEnvelope.currentVersion,
      createdAt: createdAt ?? DateTime.now(),
      app: app,
      encrypted: false,
      payload: payload.toJson(),
    );
    return const JsonEncoder.withIndent('  ').convert(envelope.toJson());
  }

  /// Builds the final JSON string for a password-protected backup. The KDF
  /// pass runs off the UI thread — see [BackupCrypto.encrypt].
  static Future<String> encodeEncrypted({
    required BackupPayload payload,
    required BackupAppInfo app,
    required String password,
    DateTime? createdAt,
  }) async {
    final encryptedPayload = await BackupCrypto.encrypt(
      plainPayloadJson: payload.toJson(),
      password: password,
    );
    final envelope = BackupEnvelope(
      format: BackupEnvelope.formatMagic,
      version: BackupEnvelope.currentVersion,
      createdAt: createdAt ?? DateTime.now(),
      app: app,
      encrypted: true,
      payload: encryptedPayload.toJson(),
    );
    return const JsonEncoder.withIndent('  ').convert(envelope.toJson());
  }

  /// Parses [raw] into a [BackupEnvelope] without decrypting/decoding the
  /// payload yet — enough to show the import-preview file card (name,
  /// created date, app version, whether a password is needed) before the
  /// user commits to anything.
  static BackupEnvelope parseEnvelope(String raw) {
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) throw const FormatException('not an object');
      json = decoded;
    } on FormatException {
      throw const BackupError(BackupErrorKind.notQimaFile);
    }

    final BackupEnvelope envelope;
    try {
      envelope = BackupEnvelope.fromJson(json);
    } on FormatException {
      throw const BackupError(BackupErrorKind.notQimaFile);
    }

    if (envelope.version > BackupEnvelope.currentVersion) {
      throw const BackupError(BackupErrorKind.newerVersion);
    }

    return envelope;
  }

  /// Fully decodes [envelope]'s payload into a [BackupPayload] — decrypting
  /// first if [BackupEnvelope.encrypted]. [password] is required (and used)
  /// only for encrypted backups; never logged, never persisted.
  ///
  /// Never partially applies anything to the app's stores — this is pure
  /// parsing. The caller (`BackupService.importFromEnvelope`) only touches a
  /// store once this returns successfully, so a failure here (wrong
  /// password, corrupted payload) leaves every store untouched.
  static Future<BackupPayload> decodePayload(BackupEnvelope envelope, {String? password}) async {
    Map<String, dynamic> plainJson;
    if (envelope.encrypted) {
      if (password == null || password.isEmpty) {
        throw const BackupError(BackupErrorKind.wrongPassword);
      }
      final EncryptedPayload encryptedPayload;
      try {
        encryptedPayload = EncryptedPayload.fromJson(envelope.payload);
      } on FormatException {
        throw const BackupError(BackupErrorKind.corrupted);
      }
      try {
        plainJson = await BackupCrypto.decrypt(payload: encryptedPayload, password: password);
      } on BackupWrongPasswordError {
        throw const BackupError(BackupErrorKind.wrongPassword);
      } on BackupCorruptedError {
        throw const BackupError(BackupErrorKind.corrupted);
      }
    } else {
      plainJson = envelope.payload;
    }

    try {
      return BackupPayload.fromJson(plainJson);
    } on FormatException {
      throw const BackupError(BackupErrorKind.corrupted);
    } on TypeError {
      throw const BackupError(BackupErrorKind.corrupted);
    }
  }
}
