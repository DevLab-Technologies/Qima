import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../blocs/app_cubit.dart';
import '../blocs/money_cubit.dart';
import '../mcp/snapshot_location.dart';
import '../models/ai_snapshot.dart';

/// "Let AI apps read Qima" on the desktop: while it is on, Qima keeps a
/// copy of the books ([AiSnapshot], private fields left out) where the
/// `qima-mcp` helper can read it, and an AI app that runs the helper can
/// answer questions about the person's money. The helper never sees Qima's
/// own files, and turning this off deletes the copy.
///
/// The setting is per computer and never syncs: sharing with an AI app on
/// one Mac shouldn't turn it on for another.
class AiApps {
  static const String _enabledKey = 'aiAppsEnabled';
  static const Duration _settle = Duration(seconds: 2);
  static const MethodChannel _macBridge = MethodChannel('com.devlabtechnologies.qima/widgets');

  final AppCubit app;
  final MoneyCubit money;

  /// Whether sharing is on; the settings section listens to it.
  final ValueNotifier<bool> enabled = ValueNotifier(false);

  StreamSubscription<Object?>? _appSub;
  StreamSubscription<Object?>? _moneySub;
  Timer? _pending;
  String? _lastWritten;

  /// Writes and deletes run one after another, so turning sharing off
  /// can't race a write that is still finishing.
  Future<void> _queue = Future.value();
  Future<String?>? _path;

  AiApps({required this.app, required this.money});

  /// Desktop systems with a helper build: macOS, Windows and Linux.
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Reads the setting and starts keeping the copy current. Call once the
  /// app has loaded its preferences.
  void start() {
    if (!supported) return;
    enabled.value = app.preferences.local.getBool(_enabledKey) ?? false;
    _appSub = app.stream.listen((_) => _schedule());
    _moneySub = money.stream.listen((_) => _schedule());
    if (enabled.value) _schedule();
  }

  Future<void> dispose() async {
    _pending?.cancel();
    await _appSub?.cancel();
    await _moneySub?.cancel();
    enabled.dispose();
  }

  Future<void> setEnabled(bool value) async {
    if (!supported) return;
    await app.preferences.local.setBool(_enabledKey, value);
    enabled.value = value;
    _pending?.cancel();
    if (value) {
      await writeNow();
    } else {
      await _serial(_delete);
    }
  }

  Future<void> _delete() async {
    _lastWritten = null;
    final path = await snapshotPath();
    if (path == null) return;
    try {
      await File(path).delete();
    } on PathNotFoundException {
      // Nothing shared yet.
    } on FileSystemException catch (e) {
      debugPrint('AiApps: could not remove the shared copy: ${e.message}');
    }
  }

  /// A step that failed never holds up the ones after it: turning sharing
  /// off must still delete the copy.
  Future<void> _serial(Future<void> Function() step) => _queue = _queue.then((_) => step(), onError: (_) => step());

  /// Where the copy lives on this computer: the App Group container on a
  /// Mac App Store build (its sandboxed helper shares that group), else the
  /// app's support folder, which an unsandboxed helper can read.
  Future<String?> snapshotPath() => _path ??= () async {
        if (!supported) return null;
        try {
          if (defaultTargetPlatform == TargetPlatform.macOS) {
            final group = await _macBridge.invokeMethod<String>('groupContainerPath');
            if (group != null && _writable(group)) return '$group/${SnapshotLocation.fileName}';
          }
          final dir = await getApplicationSupportDirectory();
          return '${dir.path}${Platform.pathSeparator}${SnapshotLocation.fileName}';
        } catch (_) {
          // Asked again next time rather than remembered as failed.
          _path = null;
          rethrow;
        }
      }();

  /// Builds without the App Group entitlement get a group path they may not
  /// write to; try before trusting it.
  static bool _writable(String dir) {
    try {
      Directory(dir).createSync(recursive: true);
      File('$dir/.qima-write-check')
        ..writeAsStringSync('')
        ..deleteSync();
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// The helper shipped beside the app, or null when this build has none
  /// (a `flutter run` that skipped it).
  static String? helperPath() {
    if (!supported) return null;
    final exe = File(Platform.resolvedExecutable);
    final dir = exe.parent.path;
    final path = switch (defaultTargetPlatform) {
      // Qima.app/Contents/MacOS/Qima → Contents/Helpers/QimaMCP.app (a
      // bundle so the sandboxed helper has a bundle id; see embed_macos.sh).
      TargetPlatform.macOS => '${exe.parent.parent.path}/Helpers/QimaMCP.app/Contents/MacOS/qima-mcp',
      TargetPlatform.windows => '$dir\\qima-mcp.exe',
      _ => '$dir/qima-mcp',
    };
    return File(path).existsSync() ? path : null;
  }

  /// The `mcpServers` entry an AI app needs, as Claude Desktop reads it.
  static String config({required String helper, required String snapshot}) =>
      const JsonEncoder.withIndent('  ').convert({
        'mcpServers': {
          'qima': {
            'command': helper,
            'args': ['--snapshot', snapshot],
          },
        },
      });

  void _schedule() {
    // At most one write per [_settle]: prices tick often, and resetting the
    // timer on every tick could put the write off indefinitely.
    if (!enabled.value || (_pending?.isActive ?? false)) return;
    _pending = Timer(_settle, () => unawaited(writeNow()));
  }

  /// Writes the copy now if the books are loaded and something changed.
  Future<void> writeNow() => _serial(_write);

  Future<void> _write() async {
    if (!enabled.value || !app.state.initialized || !money.state.loaded) return;
    final snapshot = _build();
    final body = snapshot.toJson()..remove('writtenAt');
    final key = jsonEncode(body);
    if (key == _lastWritten) return;
    final path = await snapshotPath();
    if (path == null) return;
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      // Atomic, as LocalFileStore writes: the helper never reads half a file.
      final tmp = File('$path.tmp');
      await tmp.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
      await tmp.rename(path);
      _lastWritten = key;
    } on FileSystemException catch (e) {
      debugPrint('AiApps: could not write the shared copy: ${e.message}');
    }
  }

  AiSnapshot _build() {
    final s = app.state;
    final m = money.state;
    final held = app.heldInstruments;
    return AiSnapshot.build(
      now: DateTime.now(),
      baseCurrency: s.baseCurrency,
      rates: s.rates,
      accounts: m.accounts,
      entries: m.entries,
      planned: m.recurring,
      settings: m.settings,
      // No lots is a real zero; lots without prices yet are unknown.
      holdingsValue: s.lots.isEmpty ? 0 : app.portfolioValuation?.value.amount,
      holdings: [
        for (final h in held)
          AiHolding(
            symbol: h.instrument.symbol,
            assetClass: h.instrument.assetClass.name,
            value: h.valuation.value.amount,
            cost: h.valuation.cost.amount,
          ),
      ],
    );
  }
}
