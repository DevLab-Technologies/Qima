/// Stub target for the conditional import in `local_file_store.dart`.
///
/// Selected on platforms without `dart:library.io` (i.e. Web), where
/// `LocalFileStore` never actually calls into this file — it branches on
/// `kIsWeb` and uses `shared_preferences` directly instead. These bodies
/// only exist so the conditional import has something to resolve to at
/// compile time.
Future<Map<String, dynamic>?> readJson(String relativePath) async {
  throw UnsupportedError('local_file_store_stub: use LocalFileStore, not this stub, directly.');
}

Future<bool> writeJson(String relativePath, Map<String, dynamic> data) async {
  throw UnsupportedError('local_file_store_stub: use LocalFileStore, not this stub, directly.');
}

void overrideDirectoryForTesting(Object dir) {
  throw UnsupportedError('local_file_store_stub: use LocalFileStore, not this stub, directly.');
}
