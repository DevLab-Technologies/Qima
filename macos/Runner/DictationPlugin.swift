import AVFoundation
import Speech
#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// On-device speech to text for `PlatformDictation` (Dart). Audio never
/// goes to a server.
///
/// On iOS and macOS 26 it uses SpeechAnalyzer: Apple's newer
/// SpeechTranscriber model where it covers the language (far more accurate
/// on real speech), else the DictationTranscriber model, which unlike
/// SFSpeechRecognizer keeps what was said before a pause. A model that
/// isn't downloaded yet is fetched in the background while SFSpeechRecognizer
/// (`requiresOnDeviceRecognition`) serves; earlier systems only use that.
/// A language with neither is reported as unsupported.
final class DictationPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let audioEngine = AVAudioEngine()
  private var sink: FlutterEventSink?
  private var tag = ""
  private var lastText = ""
  /// Set once stop arrives, including while a model is still being chosen.
  private var stopRequested = false

  // SFSpeechRecognizer session.
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?

  /// The SpeechAnalyzer session (`AnalyzerSession`), untyped so this class
  /// stays available before iOS and macOS 26.
  private var analyzer: AnyObject?

  static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
    let messenger = registrar.messenger()
    #else
    let messenger = registrar.messenger
    #endif
    let instance = DictationPlugin()
    let methods = FlutterMethodChannel(name: "com.devlabtechnologies.qima/dictation", binaryMessenger: messenger)
    registrar.addMethodCallDelegate(instance, channel: methods)
    FlutterEventChannel(name: "com.devlabtechnologies.qima/dictation/events", binaryMessenger: messenger)
      .setStreamHandler(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "availability":
      let tag = (call.arguments as? [String: Any])?["locale"] as? String ?? ""
      Task { @MainActor in result(await self.availability(tag)) }
    case "stop":
      finish()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func recognizer(_ tag: String) -> SFSpeechRecognizer? {
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: tag)),
          recognizer.supportsOnDeviceRecognition else { return nil }
    return recognizer
  }

  private func availability(_ tag: String) async -> String {
    switch SFSpeechRecognizer.authorizationStatus() {
    case .denied, .restricted: return "denied"
    default: break
    }
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .denied, .restricted: return "denied"
    default: break
    }
    if #available(iOS 26, macOS 26, *), await AnalyzerModel.best(for: tag) != nil { return "available" }
    return recognizer(tag) == nil ? "unsupported" : "available"
  }

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    let tag = (arguments as? [String: Any])?["locale"] as? String ?? ""
    sink = events
    stopRequested = false
    SFSpeechRecognizer.requestAuthorization { status in
      guard status == .authorized else { return self.fail("denied") }
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
          guard granted else { return self.fail("denied") }
          self.start(tag)
        }
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    teardown()
    sink = nil
    return nil
  }

  // MARK: Recognition

  private func start(_ tag: String) {
    self.tag = tag
    lastText = ""
    // Stopped while the permission prompts were up.
    if stopRequested { return end() }
    guard #available(iOS 26, macOS 26, *) else { return startRecognizer(tag) }
    Task { @MainActor in
      // Without an SFSpeechRecognizer to fall back on, wait for the download.
      let model = await AnalyzerModel.best(for: tag)
      let ready = await model?.prepare(waitForDownload: recognizer(tag) == nil) ?? false
      guard sink != nil else { return }
      if stopRequested { return end() }
      if let model, ready { startAnalyzer(model) } else { startRecognizer(tag) }
    }
  }

  private func startRecognizer(_ tag: String) {
    guard let recognizer = recognizer(tag) else { return fail("unsupported") }
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.requiresOnDeviceRecognition = true
    request.shouldReportPartialResults = true
    self.request = request

    do {
      try startAudio { buffer in request.append(buffer) }
    } catch {
      return fail("audio")
    }

    task = recognizer.recognitionTask(with: request) { [weak self] result, error in
      DispatchQueue.main.async {
        // A torn-down task can still call back once; it has nothing to add.
        guard let self, self.task != nil else { return }
        if let result {
          self.lastText = result.bestTranscription.formattedString
          if result.isFinal { return self.end() }
          self.sink?(["type": "partial", "text": self.lastText])
        }
        // Stopping early ends the task with an error; what was heard
        // still counts.
        if error != nil { self.end() }
      }
    }
  }

  @available(iOS 26, macOS 26, *)
  private func startAnalyzer(_ model: AnalyzerModel) {
    let session = AnalyzerSession(
      model: model,
      onText: { [weak self] text in
        guard let self, self.analyzer != nil else { return }
        self.lastText = text
        self.sink?(["type": "partial", "text": text])
      },
      onEnd: { [weak self] failed in
        guard let self, self.analyzer != nil else { return }
        if failed && self.lastText.isEmpty && !self.stopRequested { return self.fallBack() }
        self.end()
      }
    )
    analyzer = session
    Task { @MainActor in
      do {
        try await session.start()
        guard analyzer === session else { return }
        try startAudio { buffer in session.append(buffer) }
      } catch {
        guard analyzer === session else { return }
        fallBack()
      }
    }
  }

  /// SpeechAnalyzer failed before hearing anything (a model that reports
  /// itself installed can still be missing): carry on with SFSpeechRecognizer.
  @available(iOS 26, macOS 26, *)
  private func fallBack() {
    stopAudio()
    (analyzer as? AnalyzerSession)?.cancel()
    analyzer = nil
    startRecognizer(tag)
  }

  private func startAudio(_ tap: @escaping (AVAudioPCMBuffer) -> Void) throws {
    #if os(iOS)
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.record, mode: .measurement, options: .duckOthers)
    try session.setActive(true, options: .notifyOthersOnDeactivation)
    #endif
    let input = audioEngine.inputNode
    let format = input.outputFormat(forBus: 0)
    input.removeTap(onBus: 0)
    input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in tap(buffer) }
    audioEngine.prepare()
    try audioEngine.start()
  }

  /// Stops listening; the session then delivers its final result.
  private func finish() {
    stopRequested = true
    if request == nil && analyzer == nil { return }
    stopAudio()
    request?.endAudio()
    if #available(iOS 26, macOS 26, *) { (analyzer as? AnalyzerSession)?.finish() }
  }

  private func stopAudio() {
    guard audioEngine.isRunning else { return }
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
  }

  private func teardown() {
    stopAudio()
    request?.endAudio()
    task?.cancel()
    task = nil
    request = nil
    if #available(iOS 26, macOS 26, *) { (analyzer as? AnalyzerSession)?.cancel() }
    analyzer = nil
    #if os(iOS)
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    #endif
  }

  /// Sends what was heard as the final text and ends the stream.
  private func end() {
    teardown()
    sink?(["type": "final", "text": lastText])
    sink?(FlutterEndOfEventStream)
  }

  private func fail(_ code: String) {
    DispatchQueue.main.async {
      self.teardown()
      self.sink?(["type": "error", "code": code])
      self.sink?(FlutterEndOfEventStream)
    }
  }
}

/// The SpeechAnalyzer model for a language.
@available(iOS 26, macOS 26, *)
private enum AnalyzerModel {
  case speech(SpeechTranscriber)
  case dictation(DictationTranscriber)

  /// SpeechTranscriber where it covers [tag]'s language, else
  /// DictationTranscriber; nil when neither does. `supportedLocale` alone
  /// isn't enough: it maps Arabic to ar_SA for SpeechTranscriber, which has
  /// no Arabic model.
  static func best(for tag: String) async -> AnalyzerModel? {
    let locale = Locale(identifier: tag)
    if SpeechTranscriber.isAvailable,
       let match = await SpeechTranscriber.supportedLocale(equivalentTo: locale),
       await SpeechTranscriber.supportedLocales.contains(where: { $0.identifier(.bcp47) == match.identifier(.bcp47) }) {
      return .speech(SpeechTranscriber(
        locale: match, transcriptionOptions: [], reportingOptions: [.volatileResults], attributeOptions: []))
    }
    if let match = await DictationTranscriber.supportedLocale(equivalentTo: locale),
       await DictationTranscriber.supportedLocales.contains(where: { $0.identifier(.bcp47) == match.identifier(.bcp47) }) {
      return .dictation(DictationTranscriber(locale: match, preset: .progressiveShortDictation))
    }
    return nil
  }

  var module: any LocaleDependentSpeechModule {
    switch self {
    case .speech(let transcriber): transcriber
    case .dictation(let transcriber): transcriber
    }
  }

  /// Whether the model is on the device. When it isn't, downloads it, and
  /// waits for that only when [waitForDownload].
  func prepare(waitForDownload: Bool) async -> Bool {
    let module = module
    if let locale = module.selectedLocales.first { _ = try? await AssetInventory.reserve(locale: locale) }
    if await AssetInventory.status(forModules: [module]) == .installed { return true }
    let download = Task.detached {
      if let request = try await AssetInventory.assetInstallationRequest(supporting: [module]) {
        try await request.downloadAndInstall()
      }
    }
    guard waitForDownload else { return false }
    return (try? await download.value) != nil
  }

  /// Each result's text and whether it is final (no longer revised).
  func results() -> AsyncThrowingStream<(String, Bool), Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        do {
          switch self {
          case .speech(let transcriber):
            for try await result in transcriber.results {
              continuation.yield((String(result.text.characters), result.isFinal))
            }
          case .dictation(let transcriber):
            for try await result in transcriber.results {
              continuation.yield((String(result.text.characters), result.isFinal))
            }
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }
}

/// One SpeechAnalyzer dictation: mic buffers in, the text so far out on the
/// main thread, then [onEnd] once the analyzer has finished, with whether it
/// failed.
@available(iOS 26, macOS 26, *)
private final class AnalyzerSession {
  private let model: AnalyzerModel
  private let analyzer: SpeechAnalyzer
  private let input: AsyncStream<AnalyzerInput>
  private let feed: AsyncStream<AnalyzerInput>.Continuation
  private let onText: (String) -> Void
  private let onEnd: (Bool) -> Void
  private var format: AVAudioFormat?
  private var converter: AVAudioConverter?
  private var results: Task<Void, Never>?

  init(model: AnalyzerModel, onText: @escaping (String) -> Void, onEnd: @escaping (Bool) -> Void) {
    self.model = model
    self.onText = onText
    self.onEnd = onEnd
    analyzer = SpeechAnalyzer(modules: [model.module])
    (input, feed) = AsyncStream<AnalyzerInput>.makeStream()
  }

  func start() async throws {
    format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [model.module])
    let stream = model.results()
    results = Task { @MainActor [onText, onEnd] in
      // Final results are settled and kept; the volatile one after them is
      // replaced by each update.
      var settled = ""
      var failed = false
      do {
        for try await (text, isFinal) in stream {
          if isFinal { settled += text }
          onText((isFinal ? settled : settled + text).trimmingCharacters(in: .whitespaces))
        }
      } catch {
        // Ended early; what was heard still counts.
        failed = true
      }
      onEnd(failed)
    }
    try await analyzer.start(inputSequence: input)
  }

  /// Called on the audio thread with each mic buffer, converted to the
  /// format the model wants.
  func append(_ buffer: AVAudioPCMBuffer) {
    guard let format, buffer.format != format else {
      feed.yield(AnalyzerInput(buffer: buffer))
      return
    }
    if converter == nil { converter = AVAudioConverter(from: buffer.format, to: format) }
    let ratio = format.sampleRate / buffer.format.sampleRate
    guard let converter,
          let converted = AVAudioPCMBuffer(
            pcmFormat: format, frameCapacity: AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 1)
    else { return }
    var consumed = false
    var error: NSError?
    converter.convert(to: converted, error: &error) { _, status in
      if consumed {
        status.pointee = .noDataNow
        return nil
      }
      consumed = true
      status.pointee = .haveData
      return buffer
    }
    if error == nil, converted.frameLength > 0 { feed.yield(AnalyzerInput(buffer: converted)) }
  }

  /// No more audio: the analyzer settles what it heard, then the results end.
  func finish() {
    feed.finish()
    Task { [analyzer] in try? await analyzer.finalizeAndFinishThroughEndOfInput() }
  }

  func cancel() {
    feed.finish()
    results?.cancel()
    Task { [analyzer] in await analyzer.cancelAndFinishNow() }
  }
}
