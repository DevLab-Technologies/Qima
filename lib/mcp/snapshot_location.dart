import 'dart:convert';
import 'dart:io';

import '../models/ai_snapshot.dart';
import 'mcp_server.dart';

/// Where Qima's desktop app keeps the copy it shares with AI apps, and how
/// the `qima-mcp` helper reads it. The app writes the same path it puts in
/// the config it shows the person, so the default here is only a fallback
/// for a helper started without `--snapshot`.
abstract final class SnapshotLocation {
  static const String fileName = 'qima-ai-snapshot.json';

  /// The macOS App Group the app, its widget and the helper share. Must
  /// match `WidgetBridgePlugin.appGroup` and the entitlements.
  static const String macAppGroup = 'ZS3A435WC2.com.devlabtechnologies.qima';

  /// The default path for this computer, or null where Qima has no desktop
  /// app.
  static String? defaultPath({Map<String, String>? environment, String? os}) {
    final env = environment ?? Platform.environment;
    switch (os ?? Platform.operatingSystem) {
      case 'macos':
        final home = _realHome(env['HOME']);
        return home == null ? null : '$home/Library/Group Containers/$macAppGroup/$fileName';
      case 'windows':
        final appData = env['APPDATA'];
        return appData == null ? null : '$appData\\DevLab Technologies\\Qima\\$fileName';
      case 'linux':
        final home = env['HOME'];
        final data = env['XDG_DATA_HOME'] ?? (home == null ? null : '$home/.local/share');
        return data == null ? null : '$data/com.devlabtechnologies.qima/$fileName';
      default:
        return null;
    }
  }

  /// A sandboxed process sees its own container as HOME; the group
  /// container lives under the real one.
  static String? _realHome(String? home) {
    if (home == null) return null;
    final at = home.indexOf('/Library/Containers/');
    return at < 0 ? home : home.substring(0, at);
  }

  /// Reads the snapshot at [path], or explains why it can't.
  static AiSnapshot read(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw const SnapshotUnavailable(
        'Qima is not sharing its books with AI apps on this computer. In Qima, open Settings, then AI apps, '
        'and turn on "Let AI apps read Qima". Qima must be opened once after that.',
      );
    }
    final String text;
    try {
      text = file.readAsStringSync();
    } on FileSystemException catch (e) {
      throw SnapshotUnavailable('Qima\'s shared copy could not be opened (${e.osError?.message ?? e.message}).');
    }
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) throw const FormatException('not a JSON object');
    return AiSnapshot.fromJson(decoded);
  }
}
