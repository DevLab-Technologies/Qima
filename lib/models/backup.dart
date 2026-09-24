import 'dart:convert';

import 'package:equatable/equatable.dart';

/// On-disk shape of a Qima backup file (spec Phase 6). Versioned so a future
/// format change can still read an older file (or refuse a newer one it
/// doesn't understand) rather than guessing.
///
/// Two payload shapes share this envelope:
/// - Plain: `payload` is [BackupPayload.toJson] directly.
/// - Encrypted: `payload` is [EncryptedPayload.toJson] — the plain payload,
///   AES-256-GCM-encrypted under a key derived from the user's password via
///   PBKDF2-HMAC-SHA256.
class BackupEnvelope extends Equatable {
  static const String formatMagic = 'qima-backup';

  /// Bumped only when the envelope/payload shape changes in a way an older
  /// app couldn't read. [BackupCodec] refuses to import a file whose
  /// [version] is greater than this.
  static const int currentVersion = 1;

  final String format;
  final int version;
  final DateTime createdAt;
  final BackupAppInfo app;
  final bool encrypted;

  /// Either a [BackupPayload.toJson] map (plain) or an
  /// [EncryptedPayload.toJson] map (encrypted) — callers branch on
  /// [encrypted] to know which.
  final Map<String, dynamic> payload;

  const BackupEnvelope({
    required this.format,
    required this.version,
    required this.createdAt,
    required this.app,
    required this.encrypted,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
        'format': format,
        'version': version,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'app': app.toJson(),
        'encrypted': encrypted,
        'payload': payload,
      };

  /// Throws [FormatException] for anything structurally wrong — the caller
  /// (`BackupCodec`) turns that into a typed [BackupError].
  factory BackupEnvelope.fromJson(Map<String, dynamic> json) {
    final format = json['format'];
    if (format is! String || format != formatMagic) {
      throw const FormatException('not a Qima backup file');
    }
    final version = json['version'];
    if (version is! int) {
      throw const FormatException('missing backup version');
    }
    final createdAtRaw = json['createdAt'];
    if (createdAtRaw is! String) {
      throw const FormatException('missing createdAt');
    }
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) {
      throw const FormatException('invalid createdAt');
    }
    final appJson = json['app'];
    if (appJson is! Map<String, dynamic>) {
      throw const FormatException('missing app info');
    }
    final encrypted = json['encrypted'];
    if (encrypted is! bool) {
      throw const FormatException('missing encrypted flag');
    }
    final payload = json['payload'];
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('missing payload');
    }
    return BackupEnvelope(
      format: format,
      version: version,
      createdAt: createdAt,
      app: BackupAppInfo.fromJson(appJson),
      encrypted: encrypted,
      payload: payload,
    );
  }

  @override
  List<Object?> get props => [format, version, createdAt, app, encrypted, payload];
}

class BackupAppInfo extends Equatable {
  final String version;
  final String build;

  const BackupAppInfo({required this.version, required this.build});

  Map<String, dynamic> toJson() => {'version': version, 'build': build};

  factory BackupAppInfo.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    final build = json['build'];
    if (version is! String || build is! String) {
      throw const FormatException('invalid app info');
    }
    return BackupAppInfo(version: version, build: build);
  }

  @override
  List<Object?> get props => [version, build];
}

/// Settings included in a backup (spec Phase 6): only the ones that are
/// meaningfully "the user's data" across devices. Deliberately excludes
/// hideBalances, appLockEnabled, deliverAlertsOnThisDevice and alert runtime
/// state — all device-local by design (see `Preferences`).
class BackupSettings extends Equatable {
  final String baseCurrency;
  final String appLanguage;
  final String appearance;
  final String preferredChartRange;
  final int widgetRefreshInterval;

  const BackupSettings({
    required this.baseCurrency,
    required this.appLanguage,
    required this.appearance,
    required this.preferredChartRange,
    required this.widgetRefreshInterval,
  });

  Map<String, dynamic> toJson() => {
        'baseCurrency': baseCurrency,
        'appLanguage': appLanguage,
        'appearance': appearance,
        'preferredChartRange': preferredChartRange,
        'widgetRefreshInterval': widgetRefreshInterval,
      };

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    final baseCurrency = json['baseCurrency'];
    final appLanguage = json['appLanguage'];
    final appearance = json['appearance'];
    final preferredChartRange = json['preferredChartRange'];
    final widgetRefreshInterval = json['widgetRefreshInterval'];
    if (baseCurrency is! String ||
        appLanguage is! String ||
        appearance is! String ||
        preferredChartRange is! String ||
        widgetRefreshInterval is! int) {
      throw const FormatException('invalid settings');
    }
    return BackupSettings(
      baseCurrency: baseCurrency,
      appLanguage: appLanguage,
      appearance: appearance,
      preferredChartRange: preferredChartRange,
      widgetRefreshInterval: widgetRefreshInterval,
    );
  }

  @override
  List<Object?> get props => [baseCurrency, appLanguage, appearance, preferredChartRange, widgetRefreshInterval];
}

/// The plain (unencrypted) payload contents — raw `SyncedStore` records for
/// every user collection plus [BackupSettings]. Kept as raw
/// `List<Map<String, dynamic>>` (rather than typed `Record<T>` lists) since
/// this model has no generic type parameter to decode against; callers
/// (`BackupService`) do the typed decode/merge via `SyncedStore.importRecords`.
class BackupPayload extends Equatable {
  final List<Map<String, dynamic>> watchcards;
  final List<Map<String, dynamic>> holdings;
  final List<Map<String, dynamic>> customInstruments;
  final List<Map<String, dynamic>> alerts;
  final BackupSettings settings;

  const BackupPayload({
    required this.watchcards,
    required this.holdings,
    required this.customInstruments,
    required this.alerts,
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'watchcards': watchcards,
        'holdings': holdings,
        'customInstruments': customInstruments,
        'alerts': alerts,
        'settings': settings.toJson(),
      };

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> listOf(String key) {
      final raw = json[key];
      if (raw is! List) throw FormatException('invalid $key');
      return raw.map((e) {
        if (e is! Map<String, dynamic>) throw FormatException('invalid $key entry');
        return e;
      }).toList();
    }

    final settingsJson = json['settings'];
    if (settingsJson is! Map<String, dynamic>) {
      throw const FormatException('missing settings');
    }

    return BackupPayload(
      watchcards: listOf('watchcards'),
      holdings: listOf('holdings'),
      customInstruments: listOf('customInstruments'),
      alerts: listOf('alerts'),
      settings: BackupSettings.fromJson(settingsJson),
    );
  }

  @override
  List<Object?> get props => [watchcards, holdings, customInstruments, alerts, settings];
}

/// Envelope `payload` shape when `encrypted: true` — the [BackupPayload]
/// JSON, AES-256-GCM-encrypted under a PBKDF2-HMAC-SHA256-derived key.
class EncryptedPayload extends Equatable {
  static const String kdfName = 'pbkdf2-hmac-sha256';
  static const String cipherName = 'aes-256-gcm';
  static const int kdfIterations = 600000;
  static const int saltLength = 16;
  static const int nonceLength = 12;

  final int kdfIterationsUsed;
  final List<int> salt;
  final List<int> nonce;

  /// Ciphertext bytes with the GCM authentication tag appended (the
  /// `cryptography` package's convention: `SecretBox.concatenation()`).
  final List<int> ciphertext;

  const EncryptedPayload({
    required this.kdfIterationsUsed,
    required this.salt,
    required this.nonce,
    required this.ciphertext,
  });

  Map<String, dynamic> toJson() => {
        'kdf': {
          'name': kdfName,
          'iterations': kdfIterationsUsed,
          'salt': _b64(salt),
        },
        'cipher': {
          'name': cipherName,
          'nonce': _b64(nonce),
        },
        'ciphertext': _b64(ciphertext),
      };

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    final kdf = json['kdf'];
    final cipher = json['cipher'];
    final ciphertext = json['ciphertext'];
    if (kdf is! Map<String, dynamic> || cipher is! Map<String, dynamic> || ciphertext is! String) {
      throw const FormatException('invalid encrypted payload');
    }
    final kdfName = kdf['name'];
    final iterations = kdf['iterations'];
    final salt = kdf['salt'];
    if (kdfName is! String || kdfName != EncryptedPayload.kdfName || iterations is! int || salt is! String) {
      throw const FormatException('unsupported KDF');
    }
    final cipherNameValue = cipher['name'];
    final nonce = cipher['nonce'];
    if (cipherNameValue is! String || cipherNameValue != EncryptedPayload.cipherName || nonce is! String) {
      throw const FormatException('unsupported cipher');
    }
    return EncryptedPayload(
      kdfIterationsUsed: iterations,
      salt: _unb64(salt),
      nonce: _unb64(nonce),
      ciphertext: _unb64(ciphertext),
    );
  }

  @override
  List<Object?> get props => [kdfIterationsUsed, salt, nonce, ciphertext];
}

String _b64(List<int> bytes) => base64.encode(bytes);

List<int> _unb64(String value) {
  try {
    return base64.decode(value);
  } on FormatException {
    throw const FormatException('invalid base64');
  }
}
