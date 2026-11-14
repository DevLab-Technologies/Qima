import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif
#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// Apple's on-device Foundation Models for `PlatformAiAssistProvider`
/// (Dart), v4 phase 6. Only `SystemLanguageModel.default`, which runs on
/// the device, is used — never a server model. The model labels words and
/// rewords sentences; Dart checks everything it returns before use.
final class OnDeviceModelPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
    let messenger = registrar.messenger()
    #else
    let messenger = registrar.messenger
    #endif
    let channel = FlutterMethodChannel(name: "com.devlabtechnologies.qima/ai", binaryMessenger: messenger)
    registrar.addMethodCallDelegate(OnDeviceModelPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    let locale = Locale(identifier: args["locale"] as? String ?? "en")
    #if canImport(FoundationModels)
    if #available(iOS 26.0, macOS 26.0, *) {
      switch call.method {
      case "availability":
        result(Model.status(locale))
      case "labelTransaction":
        let text = args["text"] as? String ?? ""
        Task { result(await Model.label(text, locale: locale)) }
      case "phrase":
        let sentence = args["sentence"] as? String ?? ""
        Task { result(await Model.phrase(sentence, locale: locale)) }
      case "labelStatementLines":
        let lines = args["lines"] as? [String] ?? []
        Task { result(await Model.labelLines(lines, locale: locale)) }
      case "readMessage":
        let text = args["text"] as? String ?? ""
        Task { result(await Model.readMessage(text)) }
      default:
        result(FlutterMethodNotImplemented)
      }
      return
    }
    #endif
    result(call.method == "availability" ? "unsupported" : nil)
  }
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, *)
private enum Model {
  static var model: SystemLanguageModel { .default }

  static func status(_ locale: Locale) -> String {
    switch model.availability {
    case .available:
      return model.supportsLocale(locale) ? "ready" : "unsupportedLanguage"
    case .unavailable(.appleIntelligenceNotEnabled):
      return "turnedOff"
    case .unavailable(.modelNotReady):
      return "notReady"
    default:
      return "unsupported"
    }
  }

  static var ready: Bool { model.availability == .available }

  /// The words of a purchase, each copied exactly from the text.
  @Generable
  struct Labels {
    @Guide(description: "The exact words saying it was bought or sold, or empty")
    var kind: String
    @Guide(description: "The exact words naming what was bought or sold: a metal, coin, stock or currency, or empty")
    var instrument: String
    @Guide(description: "The exact digits for how much was bought or sold, or empty")
    var quantity: String
    @Guide(description: "The exact word for the unit of the quantity, such as grams or ounces, or empty")
    var unit: String
    @Guide(description: "The exact words for the gold karat, such as 21K, or empty")
    var karat: String
    @Guide(description: "The exact words for the price of one unit, with its currency if written, or empty")
    var unitPrice: String
    @Guide(description: "The exact words for the total paid or received, with its currency if written, or empty")
    var total: String
    @Guide(description: "The exact word or symbol for the currency, or empty")
    var currency: String
    @Guide(description: "The exact words for the date, or empty")
    var date: String
  }

  static func label(_ text: String, locale: Locale) async -> [String: String]? {
    guard ready, model.supportsLocale(locale), !text.isEmpty else { return nil }
    let session = LanguageModelSession(
      model: model,
      instructions: """
        You label the parts of a short note about buying or selling an asset. \
        Copy words exactly as they appear in the note. Never change, convert, \
        compute or invent a number. Leave a part empty when the note doesn't say it.
        """
    )
    do {
      let labels = try await session.respond(to: text, generating: Labels.self).content
      return [
        "kind": labels.kind, "instrument": labels.instrument, "quantity": labels.quantity,
        "unit": labels.unit, "karat": labels.karat, "unitPrice": labels.unitPrice,
        "total": labels.total, "currency": labels.currency, "date": labels.date,
      ]
    } catch {
      return nil
    }
  }

  /// What one line of a statement is, and for a transaction the words
  /// naming who was paid, copied from the line.
  @Generable
  struct LineLabel {
    @Guide(description: "The number in square brackets at the start of the line")
    var line: Int
    @Guide(description: "What the line is", .anyOf(["transaction", "opening balance", "closing balance", "account", "other"]))
    var kind: String
    @Guide(description: "For a transaction: the exact words naming the merchant, person or purpose, copied from the line. Otherwise empty.")
    var name: String
  }

  @Generable
  struct LineLabels {
    var lines: [LineLabel]
  }

  /// Labels statement lines a page at a time (the model reads a few
  /// thousand words at once). Returns one map per labelled line, or nil
  /// when the model can't help.
  static func labelLines(_ lines: [String], locale: Locale) async -> [[String: Any]]? {
    guard ready, !lines.isEmpty else { return nil }
    let instructions = """
      You label the lines of a bank or card statement, a banking app screen or bank messages. \
      For each numbered line say what it is: a transaction (money that moved, with its amount), the opening balance, \
      the closing balance, the account or card number, or other (headings, the bank's name and address, terms, totals, limits). \
      For a transaction copy the merchant, person or purpose exactly as written. Never change, compute or invent a number.
      """
    var out: [[String: Any]] = []
    let size = 30
    var start = 0
    while start < lines.count {
      let end = min(start + size, lines.count)
      let prompt = (start..<end).map { "[\($0)] \(lines[$0].prefix(160))" }.joined(separator: "\n")
      // A fresh session per page keeps each prompt inside the context.
      let session = LanguageModelSession(model: model, instructions: instructions)
      do {
        let labels = try await session.respond(to: prompt, generating: LineLabels.self).content
        for l in labels.lines where l.line >= start && l.line < end {
          out.append(["line": l.line, "kind": l.kind, "name": l.name])
        }
      } catch {
        return out.isEmpty ? nil : out
      }
      start = end
    }
    return out
  }

  /// What one bank message is about, with the exact words of its figures.
  @Generable
  struct MessageReading {
    @Guide(
      description: "What happened",
      .anyOf(["purchase", "refund", "withdrawal", "transferOut", "transferIn", "deposit", "fee", "debit", "unknown", "notice", "code", "declined"])
    )
    var intent: String
    @Guide(description: "The exact words of the amount that moved, with its currency if written, copied from the message. Empty if none moved.")
    var amount: String
    @Guide(description: "The exact words of the balance or limit left after it, copied from the message, or empty")
    var balance: String
    @Guide(description: "The exact words naming the merchant or person on the other side, copied from the message, never the person's own card or account. Empty if not said.")
    var name: String
  }

  /// Reads a bank message's intent and points at its words. Any language;
  /// Dart checks every copied word against the message.
  static func readMessage(_ text: String) async -> [String: String]? {
    guard ready, !text.isEmpty else { return nil }
    let session = LanguageModelSession(
      model: model,
      instructions: """
        You read one text message from a bank, in any language. Say what happened: \
        a purchase, a refund, cash taken out (withdrawal), a transfer sent (transferOut) or received (transferIn), \
        a deposit or salary, a bank fee, another debit, money that moved in an unclear direction (unknown), \
        or nothing moved: a statement or due-date notice, a one-time code, or a declined payment. \
        Copy the words of the amount, the balance left and the other side exactly as written. \
        Never change, convert, compute or invent a number.
        """
    )
    do {
      let r = try await session.respond(to: String(text.prefix(1200)), generating: MessageReading.self).content
      return ["intent": r.intent, "amount": r.amount, "balance": r.balance, "name": r.name]
    } catch {
      return nil
    }
  }

  static func phrase(_ sentence: String, locale: Locale) async -> String? {
    guard ready, model.supportsLocale(locale), !sentence.isEmpty else { return nil }
    let language = Locale(identifier: "en").localizedString(forLanguageCode: locale.language.languageCode?.identifier ?? "en") ?? "English"
    let session = LanguageModelSession(
      model: model,
      instructions: """
        You reword a short summary of someone's own investments so it reads \
        naturally in \(language). Keep every number, amount, percentage and \
        asset name exactly as written. Do not add any number. Do not give \
        advice, opinions, predictions or recommendations. Reply with the \
        reworded summary only.
        """
    )
    do {
      return try await session.respond(to: sentence).content
    } catch {
      return nil
    }
  }
}
#endif
