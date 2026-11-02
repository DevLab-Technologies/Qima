import AVFoundation
import Speech
#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// On-device speech to text for `PlatformDictation` (Dart). Recognition is
/// required to run on the device (`requiresOnDeviceRecognition`): a
/// language without an on-device model is reported as unsupported, and
/// audio never goes to a server.
final class DictationPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let audioEngine = AVAudioEngine()
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  private var sink: FlutterEventSink?
  private var lastText = ""

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
      result(availability(tag))
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

  private func availability(_ tag: String) -> String {
    switch SFSpeechRecognizer.authorizationStatus() {
    case .denied, .restricted: return "denied"
    default: break
    }
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .denied, .restricted: return "denied"
    default: break
    }
    return recognizer(tag) == nil ? "unsupported" : "available"
  }

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    let tag = (arguments as? [String: Any])?["locale"] as? String ?? ""
    sink = events
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
    guard let recognizer = recognizer(tag) else { return fail("unsupported") }
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.requiresOnDeviceRecognition = true
    request.shouldReportPartialResults = true
    self.request = request
    lastText = ""

    do {
      #if os(iOS)
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.record, mode: .measurement, options: .duckOthers)
      try session.setActive(true, options: .notifyOthersOnDeactivation)
      #endif
      let input = audioEngine.inputNode
      let format = input.outputFormat(forBus: 0)
      input.removeTap(onBus: 0)
      input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
        request.append(buffer)
      }
      audioEngine.prepare()
      try audioEngine.start()
    } catch {
      return fail("audio")
    }

    task = recognizer.recognitionTask(with: request) { [weak self] result, error in
      DispatchQueue.main.async {
        // A torn-down task can still call back once; it has nothing to add.
        guard let self, self.task != nil else { return }
        if let result {
          self.lastText = result.bestTranscription.formattedString
          if result.isFinal {
            self.sink?(["type": "final", "text": self.lastText])
            self.teardown()
            self.sink?(FlutterEndOfEventStream)
            return
          }
          self.sink?(["type": "partial", "text": self.lastText])
        }
        if error != nil {
          // Stopping early ends the task with an error; what was heard
          // still counts.
          self.sink?(["type": "final", "text": self.lastText])
          self.teardown()
          self.sink?(FlutterEndOfEventStream)
        }
      }
    }
  }

  /// Stops listening; the task then delivers its final result.
  private func finish() {
    guard audioEngine.isRunning else { return }
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
    request?.endAudio()
  }

  private func teardown() {
    if audioEngine.isRunning {
      audioEngine.stop()
      audioEngine.inputNode.removeTap(onBus: 0)
    }
    request?.endAudio()
    task?.cancel()
    task = nil
    request = nil
    #if os(iOS)
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    #endif
  }

  private func fail(_ code: String) {
    DispatchQueue.main.async {
      self.teardown()
      self.sink?(["type": "error", "code": code])
      self.sink?(FlutterEndOfEventStream)
    }
  }
}
