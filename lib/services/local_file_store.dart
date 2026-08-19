import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import 'local_file_store_stub.dart' if (dart.library.io) 'local_file_store_io.dart' as io_store;

/// Resolves the storage backend used to mirror what would be an App Group
/// container on Apple platforms. There is no real "app group" concept
/// outside iOS/macOS, so non-Apple platforms fall back to a local-only
/// store — the important property (app + widget + watch reading the same
/// storage) is preserved on platforms that DO have a shared container by
/// swapping this resolver for a platform-channel implementation later.
///
/// `dart:io`'s `File`/`Directory` don't exist on Flutter Web, so every
/// read/write there is backed by `shared_preferences` instead (which itself
/// is backed by browser storage on web, and by a plist/file on native
/// platforms — but native platforms use the `dart:io` JSON-file path below
/// for parity with the original app's actual file-based persistence).
class LocalFileStore {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _webPrefs() async {
    final cached = _prefs;
    if (cached != null) return cached;
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs;
  }

  static String _webKey(String relativePath) => 'qima_file::$relativePath';

  /// Reads and JSON-decodes [relativePath], returning null if the file
  /// doesn't exist or fails to parse.
  static Future<Map<String, dynamic>?> readJson(String relativePath) async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs();
        final contents = prefs.getString(_webKey(relativePath));
        if (contents == null || contents.isEmpty) return null;
        return jsonDecode(contents) as Map<String, dynamic>;
      }
      return await io_store.readJson(relativePath);
    } catch (_) {
      return null;
    }
  }

  /// Writes [data] as JSON to [relativePath]. Returns whether the write
  /// actually reached the backing store.
  static Future<bool> writeJson(String relativePath, Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs();
        return await prefs.setString(_webKey(relativePath), jsonEncode(data));
      }
      return await io_store.writeJson(relativePath, data);
    } catch (_) {
      return false;
    }
  }

  /// Only used for tests: allows pointing at a temp directory (native) or
  /// resetting the cached prefs handle (web, via `SharedPreferences`'s own
  /// `setMockInitialValues` in the test itself).
  static void overrideDirectoryForTesting(Object dir) {
    if (!kIsWeb) {
      io_store.overrideDirectoryForTesting(dir);
    }
  }
}
