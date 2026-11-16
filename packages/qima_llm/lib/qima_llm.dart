/// A small language model in a GGUF file, run on the CPU by llama.cpp, on
/// its own isolate so the app never waits on it.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

typedef _OpenC = Pointer<Void> Function(Pointer<Utf8>, Int32);
typedef _Open = Pointer<Void> Function(Pointer<Utf8>, int);
typedef _AskC = Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef _Ask = Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int);
typedef _FreeTextC = Void Function(Pointer<Utf8>);
typedef _FreeText = void Function(Pointer<Utf8>);
typedef _CloseC = Void Function(Pointer<Void>);
typedef _Close = void Function(Pointer<Void>);

/// One loaded model. Questions are answered one at a time, in order.
class QimaLlm {
  final SendPort _worker;
  final ReceivePort _replies;
  final Map<int, Completer<String?>> _waiting = {};
  int _next = 0;
  bool _closed = false;

  QimaLlm._(this._worker, this._replies) {
    _replies.listen((message) {
      if (message is (int, String?)) _waiting.remove(message.$1)?.complete(message.$2);
    });
  }

  /// The library's file name on this platform.
  static String get libraryName => Platform.isWindows
      ? 'qima_llm.dll'
      : Platform.isMacOS
          ? 'libqima_llm.dylib'
          : 'libqima_llm.so';

  /// Loads the model at [modelPath], or returns null when the library or
  /// the model can't be loaded. [library] overrides where the library is.
  static Future<QimaLlm?> open(String modelPath, {String? library, int? threads}) async {
    final cores = Platform.numberOfProcessors;
    final setup = ReceivePort();
    final replies = ReceivePort();
    try {
      await Isolate.spawn(
        _run,
        (setup.sendPort, replies.sendPort, library ?? libraryName, modelPath, threads ?? (cores ~/ 2).clamp(1, 8)),
        debugName: 'qima_llm',
      );
      final worker = await setup.first;
      if (worker is SendPort) return QimaLlm._(worker, replies);
    } catch (_) {
      // Falls through to null.
    } finally {
      setup.close();
    }
    replies.close();
    return null;
  }

  /// The model's answer to [user] after [system], held to the GBNF
  /// [grammar] when given, or null when it fails or after [close].
  Future<String?> ask({required String system, required String user, String grammar = '', int maxTokens = 256}) {
    if (_closed) return Future.value(null);
    final id = _next++;
    final done = Completer<String?>();
    _waiting[id] = done;
    _worker.send(('ask', id, system, user, grammar, maxTokens));
    return done.future;
  }

  /// Frees the model. Questions still waiting get null.
  void close() {
    if (_closed) return;
    _closed = true;
    _worker.send(('close',));
    for (final done in _waiting.values) {
      done.complete(null);
    }
    _waiting.clear();
    _replies.close();
  }
}

void _run((SendPort, SendPort, String, String, int) args) {
  final (setup, replies, library, modelPath, threads) = args;
  final DynamicLibrary lib;
  try {
    lib = DynamicLibrary.open(library);
  } catch (_) {
    setup.send(null);
    return;
  }
  final open = lib.lookupFunction<_OpenC, _Open>('qima_llm_open');
  final ask = lib.lookupFunction<_AskC, _Ask>('qima_llm_ask');
  final freeText = lib.lookupFunction<_FreeTextC, _FreeText>('qima_llm_free_text');
  final close = lib.lookupFunction<_CloseC, _Close>('qima_llm_close');

  final path = modelPath.toNativeUtf8();
  final handle = open(path, threads);
  malloc.free(path);
  if (handle == nullptr) {
    setup.send(null);
    return;
  }

  final requests = ReceivePort();
  setup.send(requests.sendPort);
  requests.listen((message) {
    if (message is (String, int, String, String, String, int)) {
      final (_, id, system, user, grammar, maxTokens) = message;
      final s = system.toNativeUtf8(), u = user.toNativeUtf8(), g = grammar.toNativeUtf8();
      String? answer;
      try {
        final out = ask(handle, s, u, g, maxTokens);
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
      replies.send((id, answer));
    } else {
      close(handle);
      requests.close();
    }
  });
}
