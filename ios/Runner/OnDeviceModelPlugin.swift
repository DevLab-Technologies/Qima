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
