import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:file_selector/file_selector.dart' show XTypeGroup, getSaveLocation, openFile;
import 'package:flutter/foundation.dart' show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../models/backup.dart';
import '../../models/chart_range.dart';
import '../../models/custom_instrument.dart';
import '../../models/holding.dart';
import '../../models/price_alert.dart';
import '../../models/syncable.dart';
import '../../models/watch_card.dart';
import '../alerts_store.dart';
import '../custom_instrument_store.dart';
import '../holdings_store.dart';
import '../preferences.dart';
import '../synced_store.dart';
import '../watchlist_store.dart';
import 'backup_codec.dart';
import 'holdings_csv.dart';

/// One collection's before/after live-item counts, used to build the
/// "+3 added · 2 updated · 0 removed" diff line on the import preview screen.
class BackupDiff {
  final int added;
  final int updated;
  final int removed;

  const BackupDiff({required this.added, required this.updated, required this.removed});

  static const empty = BackupDiff(added: 0, updated: 0, removed: 0);

  BackupDiff operator +(BackupDiff other) => BackupDiff(
        added: added + other.added,
        updated: updated + other.updated,
        removed: removed + other.removed,
      );

  bool get isEmpty => added == 0 && updated == 0 && removed == 0;
}

/// Summary shown on the import-preview screen before the user commits.
class BackupPreview {
  final BackupEnvelope envelope;
  final BackupPayload payload;
  final BackupDiff mergeDiff;
  final BackupDiff replaceDiff;

  const BackupPreview({
    required this.envelope,
    required this.payload,
    required this.mergeDiff,
    required this.replaceDiff,
  });

  int get cardCount => payload.watchcards.length;

  int get lotCount => payload.holdings.length;

  int get customTickerCount => payload.customInstruments.length;
}

/// Whether an import replaces everything on this device or merges
/// last-write-wins per item — mirrors `SyncedStore.importRecords(replace:)`.
enum BackupImportMode { merge, replace }

/// Orchestrates building, exporting and importing Qima backups (spec Phase
/// 6): the seam between [BackupCodec]/[HoldingsCsv] (pure encode/decode) and
/// the app's actual stores/preferences.
///
/// Import is atomic in the sense that matters here:
/// [BackupCodec.decodePayload] fully validates, decrypts and parses the
/// ENTIRE file before this class touches a single store — see [import]. If
/// parsing/decryption fails, nothing about the app's data has changed. Once
/// parsing succeeds, each collection's `SyncedStore.importRecords` call is
/// itself an atomic read-merge-write against that one store's file, so a
/// mid-import crash can leave later collections un-imported but never
/// leaves any single collection half-written.
class BackupService {
  final WatchlistStore watchlistStore;
  final HoldingsStore holdingsStore;
  final CustomInstrumentStore customInstrumentStore;
  final AlertsStore alertsStore;
  final Preferences preferences;

  BackupService({
    required this.watchlistStore,
    required this.holdingsStore,
    required this.customInstrumentStore,
    required this.alertsStore,
    required this.preferences,
  });

  static const String _lastBackupAtKey = 'backup.lastBackupAt';
  static const String _reminderEnabledKey = 'backup.reminderEnabled';
  static const String _reminderNotifiedAtKey = 'backup.reminderNotifiedAt';
  static const String _dataChangedSinceBackupKey = 'backup.dataChangedSinceLastBackup';

  // -------------------------------------------------------------------
  // Building the payload
  // -------------------------------------------------------------------

  /// [BackupAppInfo.version]/[.build] are informational only — shown on the
  /// import-preview file card, never used for any version comparison (that's
  /// [BackupEnvelope.version], a separate integer) — so a failure reading
  /// the platform's package info (missing plugin binding in a unit test,
  /// some unexpected platform quirk) falls back to empty strings rather than
  /// failing the whole export.
  Future<BackupAppInfo> _appInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return BackupAppInfo(version: info.version, build: info.buildNumber);
    } catch (e, st) {
      debugPrint('BackupService: PackageInfo.fromPlatform failed: $e\n$st');
      return const BackupAppInfo(version: '', build: '');
    }
  }

  /// Reads every collection's raw [SyncedStore] records (metadata and
  /// tombstones intact) plus the syncable settings subset, straight from the
  /// stores — never from in-memory `AppState`, so an export always reflects
  /// what's actually on disk.
  Future<BackupPayload> buildPayload() async {
    final cardsRecords = await watchlistStore.exportRecords();
    final lotsRecords = await holdingsStore.exportRecords();
    final customRecords = await customInstrumentStore.exportRecords();
    final alertsRecords = await alertsStore.exportRecords();

    final settings = BackupSettings(
      baseCurrency: await preferences.baseCurrency,
      appLanguage: (await preferences.appLanguage).name,
      appearance: (await preferences.appearance).name,
      preferredChartRange: preferences.preferredChartRange.name,
      widgetRefreshInterval: (await preferences.widgetRefreshInterval).rawValue,
    );

    return BackupPayload(
      watchcards: cardsRecords.map((r) => r.toJson()).toList(),
      holdings: lotsRecords.map((r) => r.toJson()).toList(),
      customInstruments: customRecords.map((r) => r.toJson()).toList(),
      alerts: alertsRecords.map((r) => r.toJson()).toList(),
      settings: settings,
    );
  }

  // -------------------------------------------------------------------
  // Export
  // -------------------------------------------------------------------

  String _jsonFilename(DateTime at) => 'qima-backup-${DateFormat('yyyy-MM-dd').format(at)}.json';

  String _csvFilename(DateTime at) => 'qima-holdings-${DateFormat('yyyy-MM-dd').format(at)}.csv';

  /// Builds the full backup JSON, optionally password-protected. Does not
  /// write/share anything — see [exportJson] for that.
  Future<String> buildJson({String? password}) async {
    final payload = await buildPayload();
    final app = await _appInfo();
    if (password == null || password.isEmpty) {
      return BackupCodec.encodePlain(payload: payload, app: app);
    }
    return BackupCodec.encodeEncrypted(payload: payload, app: app, password: password);
  }

  /// Exports the full backup: shares it on mobile (with an iPad popover
  /// anchor via [sharePositionOrigin]), shows a save dialog on
  /// desktop/native, or triggers a download on Web. Records
  /// [lastBackupAt]/clears the "data changed since backup" flag on success.
  ///
  /// Returns whether the export actually completed — `false` if the user
  /// cancelled the share sheet/save dialog, which is not an error.
  Future<bool> exportJson({String? password, Rect? sharePositionOrigin}) async {
    final now = DateTime.now();
    final json = await buildJson(password: password);
    final bytes = Uint8List.fromList(json.codeUnits);
    final filename = _jsonFilename(now);

    final completed = await _deliverFile(
      bytes: bytes,
      filename: filename,
      mimeType: 'application/json',
      sharePositionOrigin: sharePositionOrigin,
    );
    if (completed) {
      await setLastBackupAt(now);
      await setDataChangedSinceLastBackup(false);
    }
    return completed;
  }

  /// Exports the holdings CSV (spec Phase 6) — export-only, never counted
  /// toward [lastBackupAt] (only a full JSON backup counts as "backed up").
  Future<bool> exportHoldingsCsv({
    required List<HoldingLot> lots,
    required AppLocalizations l10n,
    Rect? sharePositionOrigin,
  }) async {
    final now = DateTime.now();
    final bytes = HoldingsCsv.bytes(lots, l10n);
    final filename = _csvFilename(now);
    return _deliverFile(
      bytes: Uint8List.fromList(bytes),
      filename: filename,
      mimeType: 'text/csv',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<bool> _deliverFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    Rect? sharePositionOrigin,
  }) async {
    if (kIsWeb) {
      // `share_plus`'s `ShareParams(downloadFallbackEnabled: true)` triggers
      // a browser download automatically when the Web Share API isn't
      // available (which is the common case on desktop browsers), so Web
      // reuses the same share call as mobile rather than a separate path.
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: mimeType, name: filename)],
          fileNameOverrides: [filename],
          downloadFallbackEnabled: true,
        ),
      );
      return result.status != ShareResultStatus.dismissed;
    }

    if (_isDesktop) {
      final location = await getSaveLocation(suggestedName: filename);
      if (location == null) return false;
      final file = XFile.fromData(bytes, mimeType: mimeType, name: filename);
      await file.saveTo(location.path);
      return true;
    }

    // Mobile (iOS/Android): the OS share sheet. `sharePositionOrigin` gives
    // the popover an anchor on iPad — without it, sharing crashes on iPad
    // (UIActivityViewController requires a source rect there since it isn't
    // presented full-screen).
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mimeType, name: filename)],
        fileNameOverrides: [filename],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
    return result.status != ShareResultStatus.dismissed && result.status != ShareResultStatus.unavailable;
  }

  bool get _isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  // -------------------------------------------------------------------
  // Import
  // -------------------------------------------------------------------

  /// Opens the OS file picker restricted to `.json`, returning the picked
  /// file's raw text, or null if the user cancelled. Deliberately reads via
  /// `XFile.readAsString()` rather than assuming a `dart:io` path exists —
  /// Web's `file_selector` implementation only ever provides an in-memory
  /// blob.
  Future<PickedBackupFile?> pickBackupFile() async {
    final typeGroup = XTypeGroup(label: 'Qima backup', extensions: ['json'], mimeTypes: ['application/json']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return null;
    final raw = await file.readAsString();
    return PickedBackupFile(name: file.name, raw: raw);
  }

  /// Parses [raw] into a [BackupEnvelope] — throws [BackupError] for a
  /// malformed/unsupported file. Doesn't decrypt/decode the payload yet
  /// (that needs a password for an encrypted backup) or touch any store.
  BackupEnvelope parseEnvelope(String raw) => BackupCodec.parseEnvelope(raw);

  /// Fully decodes [envelope] (decrypting with [password] if needed) and
  /// computes BOTH modes' diffs against the current on-disk state, without
  /// writing anything — the import-preview screen calls this to show counts
  /// (and update them live when the user flips Merge/Replace) before tapping
  /// Restore.
  Future<BackupPreview> preview(BackupEnvelope envelope, {String? password}) async {
    final payload = await BackupCodec.decodePayload(envelope, password: password);

    final cardRecords = _decodeRecords(payload.watchcards, WatchCard.fromJson);
    final lotRecords = _decodeRecords(payload.holdings, HoldingLot.fromJson);
    final customRecords = _decodeRecords(payload.customInstruments, CustomInstrument.fromJson);
    final alertRecords = _decodeRecords(payload.alerts, PriceAlert.fromJson);

    final mergeDiff = await _diff(
      cardRecords: cardRecords,
      lotRecords: lotRecords,
      customRecords: customRecords,
      alertRecords: alertRecords,
      mode: BackupImportMode.merge,
    );
    final replaceDiff = await _diff(
      cardRecords: cardRecords,
      lotRecords: lotRecords,
      customRecords: customRecords,
      alertRecords: alertRecords,
      mode: BackupImportMode.replace,
    );

    return BackupPreview(envelope: envelope, payload: payload, mergeDiff: mergeDiff, replaceDiff: replaceDiff);
  }

  List<Record<T>> _decodeRecords<T extends Syncable>(
    List<Map<String, dynamic>> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    try {
      return json.map((e) => Record.fromJson<T>(e, itemFromJson)).toList();
    } catch (_) {
      throw const BackupError(BackupErrorKind.corrupted);
    }
  }

  Future<BackupDiff> _diff({
    required List<Record<WatchCard>> cardRecords,
    required List<Record<HoldingLot>> lotRecords,
    required List<Record<CustomInstrument>> customRecords,
    required List<Record<PriceAlert>> alertRecords,
    required BackupImportMode mode,
  }) async {
    final cards = await watchlistStore.exportRecords();
    final lots = await holdingsStore.exportRecords();
    final customs = await customInstrumentStore.exportRecords();
    final alerts = await alertsStore.exportRecords();

    return _diffRecords(cards, cardRecords, mode) +
        _diffRecords(lots, lotRecords, mode) +
        _diffRecords(customs, customRecords, mode) +
        _diffRecords(alerts, alertRecords, mode);
  }

  /// Simulates [SyncedStore.importRecords]' outcome against the CURRENT live
  /// (non-deleted) items, purely to compute a diff — no store is touched
  /// here. Mirrors the exact same merge/tombstone rules `SyncedStore` itself
  /// applies, so the preview's counts always match what Restore will
  /// actually do.
  BackupDiff _diffRecords<T extends Syncable>(
    List<Record<T>> existing,
    List<Record<T>> imported,
    BackupImportMode mode,
  ) {
    final existingLiveIds = {for (final r in existing) if (!r.deleted) r.item.id: r};
    final importedById = {for (final r in imported) r.item.id: r};

    int added = 0;
    int updated = 0;
    int removed = 0;

    if (mode == BackupImportMode.merge) {
      // Last-write-wins per id: an imported record only takes effect if it's
      // newer than the existing one (or there's no existing one at all).
      for (final entry in importedById.entries) {
        final current = existingLiveIds[entry.key];
        if (current == null) {
          if (!entry.value.deleted) added++;
        } else if (entry.value.updatedAt.isAfter(current.updatedAt)) {
          if (entry.value.deleted) {
            removed++;
          } else {
            updated++;
          }
        }
      }
    } else {
      // Replace: every existing live item not re-added by the import is
      // removed; every imported live item is added/updated.
      for (final id in existingLiveIds.keys) {
        if (!importedById.containsKey(id) || importedById[id]!.deleted) {
          removed++;
        }
      }
      for (final entry in importedById.entries) {
        if (entry.value.deleted) continue;
        if (existingLiveIds.containsKey(entry.key)) {
          updated++;
        } else {
          added++;
        }
      }
    }

    return BackupDiff(added: added, updated: updated, removed: removed);
  }

  /// Applies [payload] to every store in [mode] — the only place that
  /// actually mutates persisted data during an import. Settings are only
  /// applied in `replace` mode (spec: Merge folds collections via
  /// last-write-wins but a settings VALUE has no natural "merge", so
  /// importing it only makes sense when the user explicitly chose to
  /// replace this device's state).
  Future<void> import(BackupPayload payload, {required BackupImportMode mode}) async {
    final replace = mode == BackupImportMode.replace;

    final cardRecords = _decodeRecords(payload.watchcards, WatchCard.fromJson);
    final lotRecords = _decodeRecords(payload.holdings, HoldingLot.fromJson);
    final customRecords = _decodeRecords(payload.customInstruments, CustomInstrument.fromJson);
    final alertRecords = _decodeRecords(payload.alerts, PriceAlert.fromJson);

    await watchlistStore.importRecords(cardRecords, replace: replace);
    await holdingsStore.importRecords(lotRecords, replace: replace);
    await customInstrumentStore.importRecords(customRecords, replace: replace);
    await alertsStore.importRecords(alertRecords, replace: replace);

    if (replace) {
      await _applySettings(payload.settings);
    }
  }

  Future<void> _applySettings(BackupSettings settings) async {
    await preferences.setBaseCurrency(settings.baseCurrency);
    final language = AppLanguage.fromRawValue(settings.appLanguage);
    await preferences.setAppLanguage(language);
    final appearance = Appearance.fromRawValue(settings.appearance);
    await preferences.setAppearance(appearance);
    ChartRange? range;
    for (final candidate in ChartRange.values) {
      if (candidate.name == settings.preferredChartRange) {
        range = candidate;
        break;
      }
    }
    if (range != null && !range.isExtended) {
      await preferences.setPreferredChartRange(range);
    }
    final interval = WidgetRefreshInterval.fromRawValue(settings.widgetRefreshInterval);
    await preferences.setWidgetRefreshInterval(interval);
  }

  // -------------------------------------------------------------------
  // Reminder / last-backup tracking (local-only, see Preferences)
  // -------------------------------------------------------------------

  DateTime? get lastBackupAt {
    final raw = preferences.local.getString(_lastBackupAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastBackupAt(DateTime value) async {
    await preferences.local.setString(_lastBackupAtKey, value.toUtc().toIso8601String());
  }

  bool get reminderEnabled => preferences.local.getBool(_reminderEnabledKey) ?? true;

  Future<void> setReminderEnabled(bool value) async {
    await preferences.local.setBool(_reminderEnabledKey, value);
  }

  /// Set whenever ANY user collection mutates (watchlist/holdings/custom
  /// tickers/alerts) — see `AppCubit`'s wiring — and cleared on a successful
  /// full JSON export. The reminder only fires if data actually changed
  /// since the last backup, not merely because 30 days elapsed on a
  /// portfolio that hasn't moved.
  bool get dataChangedSinceLastBackup => preferences.local.getBool(_dataChangedSinceBackupKey) ?? false;

  Future<void> setDataChangedSinceLastBackup(bool value) async {
    await preferences.local.setBool(_dataChangedSinceBackupKey, value);
  }

  /// Whether the in-app reminder card (Settings/Backup) and the background
  /// task's reminder notification should fire, per spec Phase 6: reminder
  /// on, more than 30 days since the last backup (or never backed up), and
  /// data has changed since.
  bool isReminderDue({DateTime? now}) {
    if (!reminderEnabled) return false;
    if (!dataChangedSinceLastBackup) return false;
    final last = lastBackupAt;
    if (last == null) return true;
    final effectiveNow = now ?? DateTime.now();
    return effectiveNow.difference(last) > const Duration(days: 30);
  }

  /// The last time the background task actually posted the reminder
  /// notification — used to cap it at most once per 30 days even if the
  /// background task runs more often than that (spec Phase 6).
  DateTime? get reminderNotifiedAt {
    final raw = preferences.local.getString(_reminderNotifiedAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setReminderNotifiedAt(DateTime value) async {
    await preferences.local.setString(_reminderNotifiedAtKey, value.toUtc().toIso8601String());
  }

  /// Whether the background task should post the reminder notification now:
  /// [isReminderDue] AND it hasn't already notified within the last 30 days.
  bool shouldNotifyReminder({DateTime? now}) {
    if (!isReminderDue(now: now)) return false;
    final lastNotified = reminderNotifiedAt;
    if (lastNotified == null) return true;
    final effectiveNow = now ?? DateTime.now();
    return effectiveNow.difference(lastNotified) > const Duration(days: 30);
  }
}

class PickedBackupFile {
  final String name;
  final String raw;

  const PickedBackupFile({required this.name, required this.raw});

  bool get looksLikeCsv => name.toLowerCase().endsWith('.csv');
}
