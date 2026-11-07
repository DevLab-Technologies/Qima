import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/statement_facts.dart';
import '../models/statement_reader.dart';
import '../services/ai_assist_provider.dart';
import '../services/import/import_inbox.dart';
import '../services/import/statement_files.dart';
import '../services/text_recognition_service.dart';

enum ImportStatus {
  waiting,
  reading,
  read,

  /// The same file was imported before.
  alreadyImported,

  /// Not a kind of file Qima reads.
  unsupported,

  /// Couldn't be opened or read.
  unreadable,
}

class ImportItem extends Equatable {
  final ImportFile file;
  final ImportStatus status;
  final List<StatementRow> rows;

  /// What the file says about itself: balances, account, period.
  final StatementFacts facts;
  final String? hash;

  const ImportItem(this.file, {this.status = ImportStatus.waiting, this.rows = const [], this.facts = StatementFacts.none, this.hash});

  String get id => file.id;
  bool get done => status != ImportStatus.waiting && status != ImportStatus.reading;

  ImportItem copyWith({ImportStatus? status, List<StatementRow>? rows, StatementFacts? facts, String? hash}) =>
      ImportItem(file, status: status ?? this.status, rows: rows ?? this.rows, facts: facts ?? this.facts, hash: hash ?? this.hash);

  @override
  List<Object?> get props => [file, status, rows, facts, hash];
}

class ImportState extends Equatable {
  final List<ImportItem> items;

  const ImportState({this.items = const []});

  bool get isEmpty => items.isEmpty;
  bool get reading => items.any((i) => !i.done);
  int get rowCount => items.fold(0, (n, i) => n + i.rows.length);

  @override
  List<Object?> get props => [items];
}

/// Reads what was shared to Qima (or picked in the app) in the background,
/// one file at a time, while the person keeps using the app. Files stay in
/// the inbox until they are imported or discarded on the review screen.
class ImportCubit extends Cubit<ImportState> {
  final ImportInbox inbox;
  final StatementFiles files;

  /// Whether a file with this SHA-256 was imported before.
  final bool Function(String hash) wasImported;

  /// The languages to read images in.
  final List<String> Function() languages;

  bool _running = false;
  bool _again = false;

  ImportCubit({
    required this.inbox,
    required TextRecognitionService recognition,
    required this.wasImported,
    required this.languages,
    AiAssistProvider Function()? assist,
  })  : files = StatementFiles(recognition: recognition, inbox: inbox, assist: assist ?? (() => const NullAiAssistProvider())),
        super(const ImportState());

  /// Picks up anything new in the inbox and reads it. Safe to call often
  /// (on launch and whenever the app comes back to the front).
  Future<void> checkInbox() async {
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    try {
      do {
        _again = false;
        await _pass();
      } while (_again && !isClosed);
    } finally {
      _running = false;
    }
  }

  Future<void> _pass() async {
    final pending = await inbox.pending();
    if (isClosed) return;
    final known = {for (final i in state.items) i.id};
    final stillThere = {for (final f in pending) f.id};
    final items = [
      for (final i in state.items)
        if (stillThere.contains(i.id)) i,
      for (final f in pending)
        if (!known.contains(f.id)) ImportItem(f),
    ];
    if (!listEquals(items, state.items)) emit(ImportState(items: items));

    for (final item in items.where((i) => i.status == ImportStatus.waiting)) {
      if (isClosed) return;
      _update(item.copyWith(status: ImportStatus.reading));
      ImportItem result;
      try {
        final bytes = await inbox.bytes(item.file);
        final hash = sha256.convert(bytes).toString();
        final duplicate = state.items.any((i) => i.id != item.id && i.hash == hash);
        if (wasImported(hash) || duplicate) {
          result = item.copyWith(status: ImportStatus.alreadyImported, hash: hash);
        } else {
          final read = await files.read(item.file, languages: languages());
          result = item.copyWith(
            hash: hash,
            rows: read.rows,
            facts: read.facts,
            status: switch (read.outcome) {
              ReadOutcome.read => ImportStatus.read,
              ReadOutcome.unsupported => ImportStatus.unsupported,
              ReadOutcome.unreadable => ImportStatus.unreadable,
            },
          );
        }
      } catch (e) {
        debugPrint('Import: ${item.file.name}: $e');
        result = item.copyWith(status: ImportStatus.unreadable);
      }
      if (isClosed) return;
      // A message that arrived on its own and holds no transaction (a
      // one-time code, an offer) or was seen before goes without a word.
      final nothing = result.status == ImportStatus.alreadyImported ||
          (result.status == ImportStatus.read && result.rows.isEmpty && result.facts.closing == null);
      if (item.file.message && nothing) {
        await inbox.remove(item.id);
        if (isClosed) return;
        emit(ImportState(items: [for (final i in state.items) if (i.id != item.id) i]));
        continue;
      }
      _update(result);
    }
  }

  void _update(ImportItem item) {
    if (!state.items.any((i) => i.id == item.id)) return;
    emit(ImportState(items: [for (final i in state.items) i.id == item.id ? item : i]));
  }

  /// Files picked in the app go through the same inbox.
  Future<void> addFiles(List<(String name, List<int> bytes)> picked) async {
    for (final (name, bytes) in picked) {
      await inbox.add(name, bytes);
    }
    await checkInbox();
  }

  /// Takes files out of the inbox: after their rows are imported, or when
  /// the person discards them.
  Future<void> remove(Iterable<String> ids) async {
    final set = ids.toSet();
    for (final id in set) {
      await inbox.remove(id);
    }
    if (isClosed) return;
    emit(ImportState(items: [for (final i in state.items) if (!set.contains(i.id)) i]));
  }
}

/// The import cubit when the app provides one; screens shown on their own
/// (tests, previews) work without it.
ImportCubit? maybeImportCubit(BuildContext context) {
  try {
    return context.read<ImportCubit>();
  } on ProviderNotFoundException {
    return null;
  }
}
