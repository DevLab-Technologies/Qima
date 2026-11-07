import Foundation
import PDFKit
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
    case "readDocument":
      guard let path = args["path"] as? String else { return result(nil) }
      let languages = args["languages"] as? [String] ?? ["en-US"]
      DispatchQueue.global(qos: .userInitiated).async {
        let pages = DocumentReader.read(URL(fileURLWithPath: path), languages: languages)
        DispatchQueue.main.async { result(pages) }
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
  static func recognize(_ url: URL, languages: [String]) -> [String]? {
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

/// Reads a statement for the import: each page's text with where it sits,
/// in page fractions from the top left (`DocToken` in Dart). A PDF's own
/// text is used where it has some; a scanned page, a screenshot or a photo
/// is read with Vision. Nothing leaves the device.
enum DocumentReader {
  static let maxPages = 40

  static func read(_ url: URL, languages: [String]) -> [[String: Any]]? {
    if url.pathExtension.lowercased() == "pdf" {
      guard let document = PDFDocument(url: url) else { return nil }
      if document.isLocked { return nil }
      var pages: [[String: Any]] = []
      for index in 0..<min(document.pageCount, maxPages) {
        guard let page = document.page(at: index) else { continue }
        var tokens = textLayer(page)
        if tokens.count < 3, let image = render(page) {
          tokens = recognizeBoxes(VNImageRequestHandler(cgImage: image, options: [:]), languages: languages) ?? []
        }
        pages.append(["tokens": tokens])
      }
      return pages
    }
    guard let tokens = recognizeBoxes(VNImageRequestHandler(url: url, options: [:]), languages: languages) else { return nil }
    return [["tokens": tokens]]
  }

  /// The page's text in runs: each word placed by its own selection (whose
  /// ranges line up with `page.string`, unlike `characterBounds(at:)` in
  /// some PDFs), then neighbours on one line joined when the gap between
  /// them is about a space, so table columns stay apart.
  static func textLayer(_ page: PDFPage) -> [[String: Any]] {
    guard let text = page.string, !text.isEmpty else { return [] }
    let box = page.bounds(for: .mediaBox)
    guard box.width > 0, box.height > 0 else { return [] }
    let ns = text as NSString
    guard let words = try? NSRegularExpression(pattern: "\\S+") else { return [] }

    var runs: [(text: String, frame: CGRect)] = []
    for match in words.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
      guard let selection = page.selection(for: match.range) else { continue }
      let frame = selection.bounds(for: page)
      guard !frame.isEmpty else { continue }
      let word = ns.substring(with: match.range)
      if let last = runs.last {
        let sameLine = abs(frame.midY - last.frame.midY) <= max(frame.height, last.frame.height) * 0.5
        let gap = frame.minX - last.frame.maxX
        if sameLine && gap >= -1 && gap <= max(min(frame.height, last.frame.height) * 0.7, 3) {
          runs[runs.count - 1] = (last.text + " " + word, last.frame.union(frame))
          continue
        }
      }
      runs.append((word, frame))
    }
    return runs.map { run in
      [
        "t": run.text,
        "x": Double((run.frame.minX - box.minX) / box.width),
        "y": Double((box.maxY - run.frame.maxY) / box.height),
        "w": Double(run.frame.width / box.width),
        "h": Double(run.frame.height / box.height),
      ]
    }
  }

  /// A scanned page drawn at twice its size for Vision.
  static func render(_ page: PDFPage) -> CGImage? {
    let box = page.bounds(for: .mediaBox)
    let scale: CGFloat = min(2.5, 2400 / max(box.width, box.height, 1))
    let size = CGSize(width: box.width * scale, height: box.height * scale)
    #if os(iOS)
    return page.thumbnail(of: size, for: .mediaBox).cgImage
    #else
    var rect = CGRect(origin: .zero, size: size)
    return page.thumbnail(of: size, for: .mediaBox).cgImage(forProposedRect: &rect, context: nil, hints: nil)
    #endif
  }

  /// Vision's lines with their boxes, flipped to a top left origin.
  ///
  /// Vision reads in the script of the first language it is given: English
  /// first turns Arabic into Latin nonsense, while Arabic first still reads
  /// Latin statements well. So Arabic goes first; a page with no Arabic on
  /// it is read again in the app's language when that one has accents
  /// Arabic-first would miss (French, Spanish).
  static func recognizeBoxes(_ handler: VNImageRequestHandler, languages: [String]) -> [[String: Any]]? {
    let arabicFirst = ["ar-SA"] + languages.filter { !$0.hasPrefix("ar") }
    guard let first = recognizeBoxes(handler, ordered: arabicFirst) else { return nil }
    let primary = languages.first ?? "en-US"
    let hasArabic = first.contains { ($0["t"] as? String)?.unicodeScalars.contains { (0x0600...0x06FF).contains($0.value) } ?? false }
    if hasArabic || primary.hasPrefix("en") || primary.hasPrefix("ar") { return first }
    return recognizeBoxes(handler, ordered: languages) ?? first
  }

  private static func recognizeBoxes(_ handler: VNImageRequestHandler, ordered languages: [String]) -> [[String: Any]]? {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
    let supported = (try? request.supportedRecognitionLanguages()) ?? []
    var wanted: [String] = []
    for tag in languages + ["en-US"] {
      let language = tag.split(separator: "-").first.map(String.init) ?? tag
      let match = supported.first { $0 == tag } ?? supported.first { $0.hasPrefix(language) }
      if let match, !wanted.contains(match) { wanted.append(match) }
    }
    if !wanted.isEmpty { request.recognitionLanguages = wanted }
    if #available(iOS 16.0, macOS 13.0, *) {
      request.automaticallyDetectsLanguage = wanted.isEmpty
    }
    do {
      try handler.perform([request])
    } catch {
      return nil
    }
    return (request.results ?? []).compactMap { observation in
      guard let text = observation.topCandidates(1).first?.string else { return nil }
      let b = observation.boundingBox
      return ["t": text, "x": Double(b.minX), "y": Double(1 - b.maxY), "w": Double(b.width), "h": Double(b.height)]
    }
  }
}
