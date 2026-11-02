import Foundation
import Vision
#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// On-device text recognition for `PlatformTextRecognition` (Dart), v4
/// phase 7: Apple's Vision reads a receipt photo's lines on the device,
/// and the phase 1 parser takes it from there.
final class TextRecognitionPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
    let messenger = registrar.messenger()
    #else
    let messenger = registrar.messenger
    #endif
    let channel = FlutterMethodChannel(name: "com.devlabtechnologies.qima/text_recognition", binaryMessenger: messenger)
    registrar.addMethodCallDelegate(TextRecognitionPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "isAvailable":
      result(true)
    case "recognize":
      guard let path = args["path"] as? String else { return result(nil) }
      let languages = args["languages"] as? [String] ?? ["en-US"]
      DispatchQueue.global(qos: .userInitiated).async {
        let url = URL(fileURLWithPath: path)
        let lines = Self.recognize(url, languages: languages)
        Self.discardIfCopy(url)
        DispatchQueue.main.async { result(lines) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Deletes the photo once read when it is the picker's copy in this app's
  /// temporary folder, so no receipt is kept. A file the user chose from
  /// their own folders (macOS) is left alone.
  private static func discardIfCopy(_ url: URL) {
    let temporary = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().path
    let file = url.resolvingSymlinksInPath().path
    guard file.hasPrefix(temporary + "/") else { return }
    try? FileManager.default.removeItem(at: url)
  }

  /// The image's lines of text, top to bottom, or nil if it can't be read.
  private static func recognize(_ url: URL, languages: [String]) -> [String]? {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    // Only languages this device's recognizer has, app language first.
    let supported = (try? request.supportedRecognitionLanguages()) ?? []
    var wanted: [String] = []
    for tag in languages {
      let language = tag.split(separator: "-").first.map(String.init) ?? tag
      let match = supported.first { $0 == tag } ?? supported.first { $0.hasPrefix(language) }
      if let match, !wanted.contains(match) { wanted.append(match) }
    }
    if !wanted.isEmpty { request.recognitionLanguages = wanted }
    if #available(iOS 16.0, macOS 13.0, *) {
      request.automaticallyDetectsLanguage = wanted.isEmpty
    }

    let handler = VNImageRequestHandler(url: url, options: [:])
    do {
      try handler.perform([request])
    } catch {
      return nil
    }
    let observations = (request.results ?? []).sorted { $0.boundingBox.maxY > $1.boundingBox.maxY }
    return observations.compactMap { $0.topCandidates(1).first?.string }
  }
}
