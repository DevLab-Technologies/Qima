/// A small language model in a GGUF file, run on the CPU by llama.cpp, on
/// its own isolate so the app never waits on it.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

typedef _CpuOkC = Int32 Function();
typedef _CpuOk = int Function();
typedef _OpenC = Pointer<Void> Function(Pointer<Utf8>, Int32);
typedef _Open = Pointer<Void> Function(Pointer<Utf8>, int);
typedef _AskC = Pointer<Utf8> Function(Pointer<Void>, Int32, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef _Ask = Pointer<Utf8> Function(Pointer<Void>, int, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int);
typedef _CancelC = Void Function(Pointer<Void>, Int32);
typedef _Cancel = void Function(Pointer<Void>, int);
typedef _FreeTextC = Void Function(Pointer<Utf8>);
typedef _FreeText = void Function(Pointer<Utf8>);
typedef _CloseC = Void Function(Pointer<Void>);
typedef _Close = void Function(Pointer<Void>);

/// One loaded model. Questions are answered one at a time, in order.
class QimaLlm {
  final SendPort _worker;
  final ReceivePort _events;
  final Pointer<Void> _handle;
  final _Cancel _cancel;
  final Map<int, Completer<String?>> _waiting = {};
  int _next = 0;
  bool _closed = false;

  QimaLlm._(this._worker, this._events, this._handle, this._cancel);

  /// The model library's file name on this platform.
  static String get libraryName => _fileName('qima_llm');

  /// The CPU check's library, built beside the model library.
  static String get cpuLibraryName => _fileName('qima_cpu');

  static String _fileName(String base) => Platform.isWindows
      ? '$base.dll'
      : Platform.isMacOS
          ? 'lib$base.dylib'
          : 'lib$base.so';

  /// Whether this CPU runs the instructions the model library is built
  /// with. False when the check can't be loaded. [library] overrides where
  /// the check's library is.
  static bool cpuSupported({String? library}) {
    try {
      final ok = DynamicLibrary.open(library ?? cpuLibraryName).lookupFunction<_CpuOkC, _CpuOk>('qima_cpu_ok');
      return ok() == 1;
    } catch (_) {
      return false;
    }
  }

  /// [name] in the folder of [library], or [name] alone for the system to
  /// find when [library] is a bare name too.
  static String _beside(String? library, String name) {
    if (library == null || !library.contains(RegExp(r'[/\\]'))) return name;
    return '${File(library).parent.path}${Platform.pathSeparator}$name';
  }

  /// Loads the model at [modelPath], or returns null when this CPU can't
  /// run it or the library or the model can't be loaded. [library]
  /// overrides where the library is; the CPU check is looked for beside it.
  static Future<QimaLlm?> open(String modelPath, {String? library, int? threads}) async {
    final path = library ?? libraryName;
    if (!cpuSupported(library: _beside(library, cpuLibraryName))) return null;
    final _Cancel cancel;
    try {
      cancel = DynamicLibrary.open(path).lookupFunction<_CancelC, _Cancel>('qima_llm_cancel');
    } catch (_) {
      return null;
    }

    // Everything from the worker comes here: its port and handle once the
    // model is loaded, then answers, and null (exit) or a list (error) when
    // it ends.
    final events = ReceivePort();
    final ready = Completer<(SendPort, int)?>();
    QimaLlm? llm;
    events.listen((message) {
      if (message is (SendPort, int)) {
        if (!ready.isCompleted) ready.complete(message);
      } else if (message is (int, String?)) {
        llm?._waiting.remove(message.$1)?.complete(message.$2);
      } else if (!ready.isCompleted) {
        ready.complete(null);
      } else {
        llm?._ended();
      }
    });
    final cores = Platform.numberOfProcessors;
    try {
      await Isolate.spawn(
        _run,
        (events.sendPort, path, modelPath, threads ?? (cores ~/ 2).clamp(1, 8)),
        onExit: events.sendPort,
        onError: events.sendPort,
        debugName: 'qima_llm',
      );
    } catch (_) {
      events.close();
      return null;
    }
    final setup = await ready.future;
    if (setup == null) {
      events.close();
      return null;
    }
    return llm = QimaLlm._(setup.$1, events, Pointer<Void>.fromAddress(setup.$2), cancel);
  }

  /// The model's answer to [user] after [system], held to the GBNF
  /// [grammar] when given, or null when it fails, after [close], or when
  /// [timeout] passes first, which also stops the model working on it.
  Future<String?> ask({
    required String system,
    required String user,
    String grammar = '',
    int maxTokens = 256,
    Duration? timeout,
  }) {
    if (_closed) return Future.value(null);
    final id = _next++;
    final done = Completer<String?>();
    _waiting[id] = done;
    _worker.send(('ask', id, system, user, grammar, maxTokens));
    if (timeout == null) return done.future;
    return done.future.timeout(timeout, onTimeout: () {
      _waiting.remove(id);
      if (!_closed) _cancel(_handle, id);
      return null;
    });
  }

  /// Frees the model, stopping the question it's working on. Questions
  /// still waiting get null.
  void close() {
    if (_closed) return;
    // The handle is freed by the worker after this, so it's never used here
    // again.
    if (_next > 0) _cancel(_handle, _next - 1);
    _worker.send(('close',));
    _ended();
  }

  void _ended() {
    _closed = true;
    for (final done in _waiting.values) {
      done.complete(null);
    }
    _waiting.clear();
    _events.close();
  }
}

void _run((SendPort, String, String, int) args) {
  final (events, library, modelPath, threads) = args;
  // A throw here ends the isolate, which open() hears as a failed load.
  final lib = DynamicLibrary.open(library);
  final open = lib.lookupFunction<_OpenC, _Open>('qima_llm_open');
  final ask = lib.lookupFunction<_AskC, _Ask>('qima_llm_ask');
  final freeText = lib.lookupFunction<_FreeTextC, _FreeText>('qima_llm_free_text');
  final close = lib.lookupFunction<_CloseC, _Close>('qima_llm_close');

  final path = modelPath.toNativeUtf8();
  final handle = open(path, threads);
  malloc.free(path);
  if (handle == nullptr) return;

  final requests = ReceivePort();
  events.send((requests.sendPort, handle.address));
  requests.listen((message) {
    if (message is (String, int, String, String, String, int)) {
      final (_, id, system, user, grammar, maxTokens) = message;
      final s = system.toNativeUtf8(), u = user.toNativeUtf8(), g = grammar.toNativeUtf8();
      String? answer;
      try {
        final out = ask(handle, id, s, u, g, maxTokens);
        if (out != nullptr) {
          final length = out.length;
          answer = utf8.decode(out.cast<Uint8>().asTypedList(length), allowMalformed: true);
          freeText(out);
        }
      } finally {
        malloc
          ..free(s)
          ..free(u)
          ..free(g);
      }
      events.send((id, answer));
    } else {
      close(handle);
      requests.close();
    }
  });
}
