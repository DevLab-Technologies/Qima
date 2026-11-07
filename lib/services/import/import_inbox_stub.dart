import 'import_inbox.dart';

ImportInbox createImportInbox() => _NoInbox();

class _NoInbox implements ImportInbox {
  @override
  Future<List<ImportFile>> pending() async => const [];

  @override
  Future<List<int>> bytes(ImportFile file) async => const [];

  @override
  Future<ImportFile?> add(String name, List<int> bytes, {DateTime? receivedAt}) async => null;

  @override
  Future<void> remove(String id) async {}
}
