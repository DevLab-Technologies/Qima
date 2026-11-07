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
        if tokens.count < 3 || jumbled(tokens), let image = render(page) {
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
        let space = max(min(frame.height, last.frame.height) * 0.7, 3)
        let gap = frame.minX - last.frame.maxX
        // Arabic runs right to left: its next word sits to the left.
        let leftGap = last.frame.minX - frame.maxX
        let rightToLeft = isArabic(word) && isArabic(last.text)
        if sameLine && ((gap >= -1 && gap <= space) || (rightToLeft && leftGap >= -1 && leftGap <= space)) {
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

  /// Whether a page's own text can't be trusted: some PDFs store Arabic as
  /// separate letter shapes (each one a "word"), or lay labels over values
  /// so their letters interleave ("Accﻘﺎﻕ"). Figures read from such text
  /// can be wrong, so the page is read from its picture instead.
  static func jumbled(_ tokens: [[String: Any]]) -> Bool {
    let words = tokens.flatMap { (($0["t"] as? String) ?? "").split(separator: " ") }
    guard words.count >= 20 else { return false }
    func isArabic(_ u: Unicode.Scalar) -> Bool {
      (0x0600...0x06FF).contains(u.value) || (0xFB50...0xFDFF).contains(u.value) || (0xFE70...0xFEFF).contains(u.value)
    }
    func isLatin(_ u: Unicode.Scalar) -> Bool { (0x41...0x5A).contains(u.value) || (0x61...0x7A).contains(u.value) }
    var arabic = 0, single = 0, mixed = 0
    for word in words {
      let scalars = word.unicodeScalars
      let hasArabic = scalars.contains(where: isArabic)
      if hasArabic {
        arabic += 1
        if scalars.count == 1 { single += 1 }
        if scalars.contains(where: isLatin) { mixed += 1 }
      }
    }
    let lettersApart = arabic >= 20 && Double(single) / Double(arabic) > 0.3
    let interleaved = Double(mixed) / Double(words.count) > 0.015
    return lettersApart || interleaved
  }

  static func isArabic(_ text: String) -> Bool {
    text.unicodeScalars.contains { (0x0600...0x06FF).contains($0.value) || (0xFB50...0xFDFF).contains($0.value) || (0xFE70...0xFEFF).contains($0.value) }
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
  /// first turns Arabic into Latin nonsense, while Arabic first garbles
  /// Latin names and can drop the dates and figures on a line that is
  /// mostly Arabic. So a page is read Arabic first; when it has Arabic on
  /// it, it is read again Latin first and each word is taken from the
  /// reading made for its script. A page with no Arabic is read again in
  /// the app's language when that one has accents Arabic-first would miss
  /// (French, Spanish).
  static func recognizeBoxes(_ handler: VNImageRequestHandler, languages: [String]) -> [[String: Any]]? {
    let latinLanguages = languages.filter { !$0.hasPrefix("ar") }
    guard let arabic = recognizeLines(handler, ordered: ["ar-SA"] + latinLanguages) else { return nil }
    let hasArabic = arabic.contains { line in line.words.contains { isArabic(String($0.text)) } }
    let primary = languages.first ?? "en-US"
    if !hasArabic {
      if primary.hasPrefix("en") || primary.hasPrefix("ar") { return tokens(arabic.map { $0.whole }) }
      return tokens((recognizeLines(handler, ordered: languages) ?? arabic).map { $0.whole })
    }
    guard let latin = recognizeLines(handler, ordered: latinLanguages.isEmpty ? ["en-US"] : latinLanguages) else {
      return tokens(arabic.map { $0.whole })
    }
    return tokens(merged(arabic: arabic, latin: latin))
  }

  /// One line Vision read: its words with their boxes, in reading order.
  struct Line {
    var whole: (text: String, frame: CGRect)
    var words: [(text: Substring, frame: CGRect)]
  }

  /// The Arabic words and the figures of the Arabic-first reading, and the
  /// Latin words of the Latin-first reading, each group of neighbouring
  /// words kept from one reading as one token. Latin-first reading only
  /// gives a figure where Arabic-first reading has none: it misreads some
  /// decimal points, while Arabic-first reading drops a line's figures
  /// when the line is mostly Arabic.
  static func merged(arabic: [Line], latin: [Line]) -> [(text: String, frame: CGRect)] {
    var out: [(text: String, frame: CGRect)] = []
    var words: [CGRect] = []
    var figures: [CGRect] = []
    for line in arabic {
      groups(line.words.map { word in
        let figure = isFigure(word.text)
        if figure { figures.append(word.frame) }
        if readableArabic(word.text) { words.append(word.frame) }
        return (word, figure || readableArabic(word.text))
      }, into: &out)
    }
    for line in latin {
      groups(line.words.map { word in
        let taken = isFigure(word.text)
          ? figures.contains { overlap($0, word.frame) > 0.3 }
          : words.contains { overlap($0, word.frame) > 0.3 }
        return (word, !taken)
      }, into: &out)
    }
    return out
  }

  /// A date, an amount or a number: digits and marks, no letters.
  static func isFigure(_ word: Substring) -> Bool {
    word.contains { $0.isNumber } && !word.contains { $0.isLetter }
  }

  /// Runs of kept words, each run one token.
  private static func groups(_ words: [((text: Substring, frame: CGRect), Bool)], into out: inout [(text: String, frame: CGRect)]) {
    var run: [(text: Substring, frame: CGRect)] = []
    func flush() {
      guard let first = run.first else { return }
      out.append((run.map { String($0.text) }.joined(separator: " "), run.dropFirst().reduce(first.frame) { $0.union($1.frame) }))
      run = []
    }
    for (word, keep) in words {
      if keep { run.append(word) } else { flush() }
    }
    flush()
  }

  /// How much of the smaller box the two share.
  private static func overlap(_ a: CGRect, _ b: CGRect) -> CGFloat {
    let shared = a.intersection(b)
    guard !shared.isNull else { return 0 }
    let smaller = min(a.width * a.height, b.width * b.height)
    return smaller > 0 ? shared.width * shared.height / smaller : 0
  }

  /// An Arabic word read as one: Arabic letters (or Arabic digits), no
  /// Latin letters, and not the dotted fragments Arabic-first reading
  /// makes of a Latin name.
  static func readableArabic(_ word: Substring) -> Bool {
    var arabic = 0, latin = 0, marks = 0
    for u in word.unicodeScalars {
      if (0x0600...0x06FF).contains(u.value) || (0xFB50...0xFDFF).contains(u.value) || (0xFE70...0xFEFF).contains(u.value) {
        arabic += 1
      } else if CharacterSet.letters.contains(u) {
        latin += 1
      } else if !CharacterSet.decimalDigits.contains(u) {
        marks += 1
      }
    }
    return arabic >= 2 && latin == 0 && marks <= 1
  }

  private static func tokens(_ runs: [(text: String, frame: CGRect)]) -> [[String: Any]] {
    runs.map { run in
      ["t": run.text, "x": Double(run.frame.minX), "y": Double(run.frame.minY), "w": Double(run.frame.width), "h": Double(run.frame.height)]
    }
  }

  /// Vision's lines in the given language order, boxes flipped to a top
  /// left origin, each with its words placed.
  private static func recognizeLines(_ handler: VNImageRequestHandler, ordered languages: [String]) -> [Line]? {
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
    func flipped(_ b: CGRect) -> CGRect { CGRect(x: b.minX, y: 1 - b.maxY, width: b.width, height: b.height) }
    return (request.results ?? []).compactMap { observation in
      guard let candidate = observation.topCandidates(1).first else { return nil }
      let text = candidate.string
      let whole = flipped(observation.boundingBox)
      var words: [(text: Substring, frame: CGRect)] = []
      var index = text.startIndex
      while index < text.endIndex {
        guard let start = text[index...].firstIndex(where: { !$0.isWhitespace }) else { break }
        let end = text[start...].firstIndex(where: { $0.isWhitespace }) ?? text.endIndex
        let box = (try? candidate.boundingBox(for: start..<end))?.boundingBox
        words.append((text[start..<end], box.map(flipped) ?? whole))
        index = end
      }
      return Line(whole: (text, whole), words: words)
    }
  }
}
