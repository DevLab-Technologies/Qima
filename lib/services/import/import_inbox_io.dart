import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'import_inbox.dart';

ImportInbox createImportInbox() => FolderInbox();

/// Folders of `<id>/<file>` plus `<id>/meta.json` (`name`, `receivedAt`).
/// The share extension writes the same layout and renames a folder into
/// place only once it is complete; folders starting with a dot are still
/// being written.
class FolderInbox implements ImportInbox {
  static const _channel = MethodChannel('com.devlabtechnologies.qima/share_inbox');

  /// For tests: the folders to use instead of the app's.
  final List<Directory>? folders;

  FolderInbox({this.folders});

  Future<Directory> _own() async {
    final f = folders;
    if (f != null) return f.first;
    final dir = Directory('${(await getApplicationSupportDirectory()).path}/import_inbox');
    await dir.create(recursive: true);
    return dir;
  }

  Future<List<Directory>> _all() async {
    final f = folders;
    if (f != null) return f;
    final out = [await _own()];
    if (!kIsWeb && Platform.isIOS) {
      try {
        final shared = await _channel.invokeMethod<String>('inboxPath');
        if (shared != null) out.add(Directory(shared));
      } on MissingPluginException {
        // Tests and platforms without the share extension.
      } on PlatformException catch (e) {
        debugPrint('ShareInbox: $e');
      }
    }
    return out;
  }

  @override
  Future<List<ImportFile>> pending() async {
    final files = <ImportFile>[];
    for (final root in await _all()) {
      if (!await root.exists()) continue;
      await for (final entity in root.list()) {
        if (entity is! Directory) continue;
        final id = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
        if (id.startsWith('.')) continue;
        final meta = File('${entity.path}/meta.json');
        try {
          final json = jsonDecode(await meta.readAsString()) as Map<String, dynamic>;
          final name = json['name'] as String;
          final file = File('${entity.path}/$name');
          if (!await file.exists()) continue;
          files.add(ImportFile(
            id: id,
            name: name,
            receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '')?.toLocal() ?? (await meta.lastModified()),
            path: file.path,
          ));
        } catch (e) {
          debugPrint('ImportInbox: skipping $id: $e');
        }
      }
    }
    files.sort((a, b) {
      final byTime = a.receivedAt.compareTo(b.receivedAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return files;
  }

  @override
  Future<List<int>> bytes(ImportFile file) => File(file.path).readAsBytes();

  @override
  Future<ImportFile?> add(String name, List<int> bytes, {DateTime? receivedAt}) async {
    final root = await _own();
    final id = const Uuid().v4();
    final safe = name.replaceAll(RegExp(r'[/\\:]'), '-');
    final staging = Directory('${root.path}/.$id');
    await staging.create(recursive: true);
    final at = receivedAt ?? DateTime.now();
    await File('${staging.path}/$safe').writeAsBytes(bytes, flush: true);
    await File('${staging.path}/meta.json').writeAsString(jsonEncode({'name': safe, 'receivedAt': at.toUtc().toIso8601String()}));
    final done = await staging.rename('${root.path}/$id');
    return ImportFile(id: id, name: safe, receivedAt: at, path: '${done.path}/$safe');
  }

  @override
  Future<void> remove(String id) async {
    for (final root in await _all()) {
      final dir = Directory('${root.path}/$id');
      if (await dir.exists()) await dir.delete(recursive: true);
    }
  }
}
