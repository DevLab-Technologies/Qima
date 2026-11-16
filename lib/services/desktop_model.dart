import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:qima_llm/qima_llm.dart';

import '../models/statement_facts.dart';
import '../models/statement_reader.dart';
import '../models/transaction_capture.dart';
import 'ai_assist_provider.dart';

/// The provider on Windows and Linux; null elsewhere.
AiAssistProvider? desktopAiAssist() => DesktopModel.supported ? DesktopAiAssistProvider() : null;

bool get desktopModelSupported => DesktopModel.supported;

/// The open model Qima runs on Windows and Linux, which have no on-device
/// model of their own: one GGUF file, pinned by revision and checked by its
/// SHA-256 before it's used.
class DesktopModelFile {
  final String name;
  final Uri url;
  final int size;
  final String sha256;

  const DesktopModelFile({required this.name, required this.url, required this.size, required this.sha256});

  /// Qwen2.5 1.5B Instruct (Apache 2.0), 4-bit, from Qwen's own repository.
  static final qwen = DesktopModelFile(
    name: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
    url: Uri.parse('https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/'
        '91cad51170dc346986eccefdc2dd33a9da36ead9/qwen2.5-1.5b-instruct-q4_k_m.gguf'),
    size: 1117320736,
    sha256: '6a1a2eb6d15622bf3c96857206351ba97e1af16c30d7a74ee38970e434e9407e',
  );
}

/// Opens a downloaded model file; [QimaLlm.open] outside tests.
typedef ModelOpener = Future<QimaLlm?> Function(String path);

/// The model file on disk: downloaded once, the first time it's asked for,
/// then loaded when a question comes and freed when none has come for a
/// while. Nothing is sent anywhere; the only network use is the download.
class DesktopModel {
  final DesktopModelFile file;
  final Future<Directory> Function() _directory;
  final http.Client Function() _client;
  final ModelOpener _open;
  final bool Function() _cpu;

  /// How long the model stays loaded with no question.
  final Duration idle;

  /// How long the download may go without a byte before it's given up and
  /// tried again on the next ask.
  final Duration stall;

  /// How long after a failed load the model is tried again.
  final Duration retry;

  DesktopModel({
    DesktopModelFile? file,
    Future<Directory> Function()? directory,
    http.Client Function()? client,
    ModelOpener? open,
    bool Function()? cpu,
    this.idle = const Duration(minutes: 3),
    this.stall = const Duration(seconds: 60),
    this.retry = const Duration(minutes: 5),
  })  : file = file ?? DesktopModelFile.qwen,
        _directory = directory ?? getApplicationSupportDirectory,
        _client = client ?? http.Client.new,
        _open = open ?? QimaLlm.open,
        _cpu = cpu ?? QimaLlm.cpuSupported;

  /// Windows and Linux; macOS uses Apple's model instead.
  static bool get supported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux);

  /// Whether this CPU can run the model, asked once. When it can't, nothing
  /// is downloaded.
  late final bool _runsHere = _cpu();

  Future<void>? _download;
  Future<QimaLlm?>? _loading;
  QimaLlm? _llm;
  Timer? _unload;
  int _asking = 0;
  bool _ready = false;

  /// When the model last failed to load; it isn't tried again until
  /// [retry] has passed.
  DateTime? _failedAt;

  /// Set by [stop]: the running download's client and how to end its read.
  http.Client? _active;
  void Function()? _endRead;
  bool _stopping = false;

  Future<File> _path(String suffix) async {
    final dir = Directory('${(await _directory()).path}${Platform.pathSeparator}models');
    await dir.create(recursive: true);
    return File('${dir.path}${Platform.pathSeparator}${file.name}$suffix');
  }

  /// Whether the checked file is on disk. A file only gets its final name
  /// after its hash matched.
  Future<bool> get downloaded async {
    if (_ready) return true;
    final f = await _path('');
    return _ready = await f.exists() && await f.length() == file.size;
  }

  /// ready once the file is here, notReady while it downloads (started
  /// here when it isn't), unsupported when this CPU can't run it.
  Future<ModelStatus> status() async {
    if (!_runsHere) return ModelStatus.unsupported;
    if (await downloaded) return ModelStatus.ready;
    unawaited(download());
    return ModelStatus.notReady;
  }

  /// Downloads the file, carrying on from a part left by an earlier try.
  /// One download at a time; a failed one is tried again on the next ask.
  Future<void> download() => _download ??= _fetch().whenComplete(() => _download = null);

  /// Stops a running download, keeping what came for next time, and frees
  /// the model: the person turned it off.
  void stop() {
    _stopping = true;
    _endRead?.call();
    _active?.close();
    close();
  }

  Future<void> _fetch() async {
    _stopping = false;
    final part = await _path('.part');
    final client = _active = _client();
    try {
      var have = await part.exists() ? await part.length() : 0;
      if (have > file.size) {
        await part.delete();
        have = 0;
      }
      final hash = _Sha256Sink();
      final digest = sha256.startChunkedConversion(hash);

      // A part that's all here (the app closed before the rename) is only
      // checked; asking for more would get a 416.
      if (have < file.size) {
        final request = http.Request('GET', file.url);
        if (have > 0) request.headers['Range'] = 'bytes=$have-';
        final response = await client.send(request).timeout(stall);
        if (_stopping) return;
        final resumed = response.statusCode == 206 && have > 0;
        if (response.statusCode != 200 && !resumed) {
          throw HttpException('model download: ${response.statusCode}', uri: file.url);
        }
        if (!resumed) have = 0;
        if (have > 0) await part.openRead().forEach(digest.add);
        if (_stopping) return;
        final sink = part.openWrite(mode: resumed ? FileMode.append : FileMode.write);
        try {
          have = await _receive(response.stream, sink, digest, have);
        } finally {
          await sink.close();
        }
        if (have != file.size) return; // Cut short; carried on next time.
      } else {
        await part.openRead().forEach(digest.add);
      }
      digest.close();

      if (hash.value.toString() != file.sha256) {
        await part.delete();
        throw const FormatException('model download does not match its hash');
      }
      await part.rename((await _path('')).path);
    } catch (e) {
      debugPrint('DesktopModel: $e');
    } finally {
      _active = null;
      _endRead = null;
      client.close();
    }
  }

  /// Writes [body] to [sink] and [digest] after the [have] bytes already
  /// there, and returns the new count. Ends with an error when no byte
  /// comes for [stall], when the file grows past its size, or on [stop].
  Future<int> _receive(Stream<List<int>> body, IOSink sink, Sink<List<int>> digest, int have) {
    final done = Completer<int>();
    late final StreamSubscription<List<int>> read;
    void fail(Object error) {
      read.cancel();
      if (!done.isCompleted) done.completeError(error);
    }

    read = body.timeout(stall).listen(
      (chunk) {
        have += chunk.length;
        if (have > file.size) return fail(const FormatException('model download is longer than expected'));
        digest.add(chunk);
        sink.add(chunk);
      },
      onError: fail,
      onDone: () {
        if (!done.isCompleted) done.complete(have);
      },
    );
    _endRead = () => fail(const HttpException('model download stopped'));
    return done.future;
  }

  /// [system] then [user] to the model, or null when it isn't downloaded,
  /// can't load, fails, or takes longer than [timeout] to load or to answer.
  Future<String?> ask({
    required String system,
    required String user,
    String grammar = '',
    int maxTokens = 256,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _asking++;
    _unload?.cancel();
    try {
      final llm = await _loaded().timeout(timeout, onTimeout: () => null);
      if (llm == null) return null;
      return await llm.ask(system: system, user: user, grammar: grammar, maxTokens: maxTokens, timeout: timeout);
    } finally {
      // Freed only once no question is waiting.
      if (--_asking == 0) _unload = Timer(idle, close);
    }
  }

  Future<QimaLlm?> _loaded() async {
    if (_llm != null) return _llm;
    if (!_runsHere || !await downloaded) return null;
    final failed = _failedAt;
    if (failed != null && DateTime.now().difference(failed) < retry) return null;
    return _loading ??= () async {
      QimaLlm? llm;
      try {
        llm = await _open((await _path('')).path);
      } catch (e) {
        debugPrint('DesktopModel: $e');
      }
      _loading = null;
      _llm = llm;
      _failedAt = llm == null ? DateTime.now() : null;
      return llm;
    }();
  }

  /// Frees the model's memory; it loads again on the next question.
  void close() {
    _unload?.cancel();
    _llm?.close();
    _llm = null;
  }
}

class _Sha256Sink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}

/// The on-device model on Windows and Linux: [DesktopModel]. It reads bank
/// messages, as Gemini Nano does on Android; the rest is left to the rules.
class DesktopAiAssistProvider implements AiAssistProvider, StoppableModel {
  final DesktopModel model;

  DesktopAiAssistProvider({DesktopModel? model}) : model = model ?? DesktopModel();

  @override
  Future<ModelStatus> status(String localeTag) => model.status();

  @override
  Future<bool> isAvailable() async => await model.status() == ModelStatus.ready;

  @override
  void stop() => model.stop();

  @override
  Future<MessageLabels?> readMessage(String text, String localeTag) async {
    if (text.trim().isEmpty) return null;
    final answer = await model.ask(
      system: messageSystem,
      user: messageUser(text),
      grammar: messageGrammar,
      maxTokens: 160,
    );
    if (answer == null) return null;
    final labels = messageLabels(answer);
    return labels == null ? null : MessageLabels.fromMap(labels);
  }

  @override
  Future<CaptureSpans?> labelTransaction(String text, String localeTag) async => null;

  @override
  Future<String?> phrase(String sentence, String localeTag) async => null;

  @override
  Future<List<LineLabel>?> labelStatementLines(List<String> lines, String localeTag) async => null;

  @override
  Future<List<PageStructure>?> structurePages(String path, List<DocPage> pages, String localeTag) async => null;

  /// The Apple and Android models' question, with the intent asked for
  /// last: a small model names it better once it has copied the words.
  static const messageSystem =
      'You read one text message from a bank, in any language. Say what happened: a purchase, a refund, '
      'cash taken out (withdrawal), a transfer sent (transferOut) or received (transferIn), a deposit or salary, '
      'a bank fee, another debit, money that moved in an unclear direction (unknown), or nothing moved: '
      'a statement or due-date notice, a one-time code (code), or a declined payment (declined).\n'
      'Copy the words of the amount, the balance left and the other side exactly as written. '
      'Never change, convert, compute or invent a number.\n'
      'Answer with one JSON object: "amount", the exact words of the amount that moved with its currency if '
      'written, or ""; "balance", the exact words of the balance or limit left after it, or ""; "name", the exact '
      'words naming the merchant or person on the other side, never the person\'s own card or account, or ""; '
      'then "intent".';

  static String messageUser(String text) => 'Message:\n${text.length > 1200 ? text.substring(0, 1200) : text}';

  /// The answer's shape, so a small model can only answer in it.
  static final messageGrammar = '''
root ::= "{" ws "\\"amount\\":" ws text "," ws "\\"balance\\":" ws text "," ws "\\"name\\":" ws text "," ws "\\"intent\\":" ws intent ws "}"
intent ::= "\\"" (${MessageIntent.values.map((i) => '"${i.name}"').join(' | ')}) "\\""
text ::= "\\"" char{0,80} "\\""
char ::= [^"\\\\\\x00-\\x1F] | "\\\\" ["\\\\/nt]
ws ::= [ \\n]{0,2}
''';

  /// The model's JSON as the channel's map; null when it isn't JSON.
  static Map<String, String>? messageLabels(String answer) {
    final start = answer.indexOf('{');
    final end = answer.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final json = jsonDecode(answer.substring(start, end + 1));
      if (json is! Map) return null;
      return {
        for (final key in const ['intent', 'amount', 'balance', 'name'])
          key: json[key] is String ? (json[key] as String).trim() : '',
      };
    } on FormatException {
      return null;
    }
  }
}
