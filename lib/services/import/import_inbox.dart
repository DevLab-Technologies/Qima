import 'package:equatable/equatable.dart';

import 'import_inbox_stub.dart' if (dart.library.io) 'import_inbox_io.dart' as impl;

/// A file waiting to be imported: shared with Share › Qima, or picked in
/// the app. It stays in the inbox until it is imported or discarded, so a
/// batch survives the app being closed while it is read.
class ImportFile extends Equatable {
  final String id;
  final String name;
  final DateTime receivedAt;

  /// On disk, for readers that take a path (PDFs and images).
  final String path;

  /// A bank's text message that arrived on its own (an Android SMS, or a
  /// Shortcuts automation on iOS) rather than a file the person chose: one
  /// with no transaction in it, such as a one-time code, is dropped unseen.
  final bool message;

  /// Who sent [message]: the SMS sender's name or number, or what a
  /// Shortcuts automation passed. Null when not known.
  final String? sender;

  const ImportFile({required this.id, required this.name, required this.receivedAt, required this.path, this.message = false, this.sender});

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  @override
  List<Object?> get props => [id, name, receivedAt, path, message, sender];
}

abstract class ImportInbox {
  /// Every file waiting, oldest first.
  Future<List<ImportFile>> pending();

  Future<List<int>> bytes(ImportFile file);

  /// Puts a file picked in the app into the inbox.
  Future<ImportFile?> add(String name, List<int> bytes, {DateTime? receivedAt});

  Future<void> remove(String id);
}

/// The inbox on this device: Share › Qima's folder in the app group (iOS)
/// and Qima's own folder for files picked in the app. None on the web.
ImportInbox createImportInbox() => impl.createImportInbox();
