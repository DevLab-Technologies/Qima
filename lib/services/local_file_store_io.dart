import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// `dart:io`-backed JSON file storage, used on every platform except Web
/// (see `local_file_store.dart` / `local_file_store_stub.dart`).
Directory? _cachedDir;

Future<Directory> _directory() async {
  final cached = _cachedDir;
  if (cached != null) return cached;
  final dir = await getApplicationSupportDirectory();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  _cachedDir = dir;
  return dir;
}

Future<File> _fileFor(String relativePath) async {
  final dir = await _directory();
  final file = File('${dir.path}/$relativePath');
  final parent = file.parent;
  if (!await parent.exists()) {
    await parent.create(recursive: true);
  }
  return file;
}

Future<Map<String, dynamic>?> readJson(String relativePath) async {
  final file = await _fileFor(relativePath);
  if (!await file.exists()) return null;
  final contents = await file.readAsString();
  if (contents.isEmpty) return null;
  return jsonDecode(contents) as Map<String, dynamic>;
}

Future<bool> writeJson(String relativePath, Map<String, dynamic> data) async {
  final file = await _fileFor(relativePath);
  await file.writeAsString(jsonEncode(data));
  return true;
}

void overrideDirectoryForTesting(Object dir) {
  _cachedDir = dir as Directory;
}
