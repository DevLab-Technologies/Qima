import 'dart:async';

/// A minimal async mutex: serializes access to a critical section. Dart has
/// no actors, so this stands in for the Swift `actor`-based
/// `FXHistoryWriter` serialization described in spec §2.2.
class Mutex {
  Future<void> _tail = Future.value();

  /// Runs [action] exclusively with respect to any other call currently
  /// queued on this mutex, returning its result.
  Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<void>();
    final previousTail = _tail;
    _tail = completer.future;
    return previousTail.then((_) async {
      try {
        return await action();
      } finally {
        completer.complete();
      }
    });
  }
}
