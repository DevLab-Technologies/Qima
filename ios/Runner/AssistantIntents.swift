import AppIntents
import Foundation

// Read-only answers for Siri, Shortcuts and Spotlight (v4 phase 5). They
// read the snapshot the app publishes for its widgets (Snapshot.swift) and
// price with the same rules, so an answer matches the widget and the app.
// Nothing here records: a system assistant can't show Qima's check-before-
// saving step, so recording stays in the app. A bank message sent from a
// Shortcuts automation only waits in the import inbox for that check.

/// An asset the app has a price for: watchlist cards' assets first.
@available(iOS 17.0, macOS 14.0, *)
struct AssistantAsset: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Asset")
    static let defaultQuery = AssistantAssetQuery()

    let id: String
    let name: String
    let symbol: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(symbol)")
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct AssistantAssetQuery: EntityStringQuery {
    private func all() -> [AssistantAsset] {
        guard let snapshot = Snapshot.load() else { return [] }
        let carded = snapshot.cards.map(\.instrumentID)
        let ordered = snapshot.instruments.sorted { a, b in
            (carded.firstIndex(of: a.id) ?? .max) < (carded.firstIndex(of: b.id) ?? .max)
        }
        return ordered.map { AssistantAsset(id: $0.id, name: L10n.key($0.nameKey), symbol: $0.symbol) }
    }

    func entities(for identifiers: [String]) async throws -> [AssistantAsset] {
        all().filter { identifiers.contains($0.id) }
    }

    func entities(matching string: String) async throws -> [AssistantAsset] {
        all().filter { $0.name.localizedCaseInsensitiveContains(string) || $0.symbol.localizedCaseInsensitiveContains(string) }
    }

    func suggestedEntities() async throws -> [AssistantAsset] {
        all()
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct GetPriceIntent: AppIntent {
    static let title: LocalizedStringResource = "Get a price"
    static let description = IntentDescription("Today's price of an asset, as Qima shows it.")

    @Parameter(title: "Asset")
    var asset: AssistantAsset

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let answer = Self.answer(for: asset.id)
        return .result(value: answer, dialog: IntentDialog(stringLiteral: answer))
    }

    static func answer(for instrumentID: String) -> String {
        guard let snapshot = Snapshot.load() else { return L10n.text("Open Qima once to load prices.") }
        guard let instrument = snapshot.instrument(instrumentID) else { return L10n.text("Open Qima once to load prices.") }
        let shown = snapshot.presentation(of: instrument)
        var name = L10n.key(instrument.nameKey)
        if let karat = shown.karat { name += " \(L10n.karat(karat))" }
        guard let price = snapshot.livePrice(instrument, unit: shown.unit, karat: shown.karat, currency: shown.currency) else {
            return String(format: L10n.text("Qima has no price for %@ yet."), name)
        }
        let amount = Format.money(price, currency: shown.currency, in: snapshot)
        if let unit = shown.unit.abbreviation {
            return String(format: L10n.text("%@ is %@ per %@."), name, amount, unit)
        }
        return String(format: L10n.text("%@ is %@."), name, amount)
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct GetPortfolioValueIntent: AppIntent {
    static let title: LocalizedStringResource = "Get portfolio value"
    static let description = IntentDescription("What your holdings in Qima are worth now.")

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let answer = Self.answer()
        return .result(value: answer, dialog: IntentDialog(stringLiteral: answer))
    }

    static func answer() -> String {
        guard let snapshot = Snapshot.load() else { return L10n.text("Open Qima once to load prices.") }
        // Hiding balances in the app hides them from the assistant too.
        if snapshot.hideBalances { return L10n.text("Balances are hidden in Qima.") }
        guard let worth = snapshot.portfolioValue(in: snapshot.baseCurrency) else {
            return L10n.text("There are no holdings in Qima yet.")
        }
        let value = Format.money(worth.value, currency: snapshot.baseCurrency, in: snapshot)
        let gain = Format.money(abs(worth.gain), currency: snapshot.baseCurrency, in: snapshot)
        let template = worth.gain >= 0
            ? "Your holdings are worth %@, a gain of %@ on what you paid."
            : "Your holdings are worth %@, a loss of %@ on what you paid."
        return String(format: L10n.text(template), value, gain)
    }
}

/// A bank's text message, sent by a Shortcuts automation ("When I get a
/// message from my bank, add it to Qima"). It waits in the import inbox,
/// as a shared file does, until the person checks it in the app; a message
/// with no transaction in it is dropped there.
@available(iOS 17.0, macOS 14.0, *)
struct AddBankMessageIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a bank message"
    static let description = IntentDescription("Sends a bank's text message to Qima. Nothing is added until you check it in the app.")
    static let openAppWhenRun = false

    @Parameter(title: "Message")
    var message: String

    /// The Message automation's Sender, so Qima can tell which bank (and
    /// account) the message is from.
    @Parameter(title: "Sender")
    var sender: String?

    func perform() async throws -> some IntentResult {
        try MessageInbox.add(message, sender: sender)
        return .result()
    }
}

/// One Apple Pay payment from a Shortcuts Wallet automation ("When I tap
/// any of my cards"), written as a labelled message so the same reader that
/// reads bank texts reads it, and waiting for review like one.
@available(iOS 17.0, macOS 14.0, *)
struct AddApplePayIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a Wallet payment"
    static let description = IntentDescription("Sends a card payment from a Wallet automation to Qima. Nothing is added until you check it in the app.")
    static let openAppWhenRun = false

    @Parameter(title: "Amount")
    var amount: String

    @Parameter(title: "Merchant")
    var merchant: String

    @Parameter(title: "Card")
    var card: String?

    func perform() async throws -> some IntentResult {
        try MessageInbox.add(Self.message(amount: amount, merchant: merchant, card: card, at: Date()))
        return .result()
    }

    static func message(amount: String, merchant: String, card: String?, at date: Date) -> String {
        let when = DateFormatter()
        when.locale = Locale(identifier: "en_US_POSIX")
        when.dateFormat = "yyyy-MM-dd HH:mm:ss"
        func clean(_ s: String) -> String { s.trimmingCharacters(in: .whitespacesAndNewlines) }
        var lines = ["Apple Pay purchase"]
        if let card, !clean(card).isEmpty { lines.append("Card: \(clean(card))") }
        lines.append("Amount: \(clean(amount))")
        if !clean(merchant).isEmpty { lines.append("Merchant: \(clean(merchant))") }
        lines.append("On: \(when.string(from: date))")
        return lines.joined(separator: "\n")
    }
}

/// The share extension's inbox layout (`ShareViewController`): a folder per
/// item, written under a dotted name and renamed once complete.
enum MessageInbox {
    struct Unavailable: Error {}

    static func add(_ text: String, sender: String? = nil, at date: Date = Date()) throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.devlabtechnologies.qima") else {
            throw Unavailable()
        }
        let inbox = container.appendingPathComponent("ImportInbox", isDirectory: true)
        let id = UUID().uuidString
        let staging = inbox.appendingPathComponent(".\(id)", isDirectory: true)
        try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true)
        let name = "Bank message.txt"
        try Data(trimmed.utf8).write(to: staging.appendingPathComponent(name))
        var meta: [String: Any] = ["name": name, "receivedAt": ISO8601DateFormatter().string(from: date), "kind": "message"]
        if let from = sender?.trimmingCharacters(in: .whitespacesAndNewlines), !from.isEmpty { meta["sender"] = from }
        try JSONSerialization.data(withJSONObject: meta).write(to: staging.appendingPathComponent("meta.json"))
        try FileManager.default.moveItem(at: staging, to: inbox.appendingPathComponent(id, isDirectory: true))
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct QimaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetPortfolioValueIntent(),
            phrases: [
                "What's my \(.applicationName) portfolio worth",
                "\(.applicationName) portfolio value",
            ],
            shortTitle: "Portfolio value",
            systemImageName: "chart.pie"
        )
        AppShortcut(
            intent: GetPriceIntent(),
            phrases: [
                "Get a price in \(.applicationName)",
                "\(.applicationName) price of \(\.$asset)",
            ],
            shortTitle: "Price",
            systemImageName: "chart.line.uptrend.xyaxis"
        )
        AppShortcut(
            intent: AddBankMessageIntent(),
            phrases: ["Add a bank message to \(.applicationName)"],
            shortTitle: "Bank message",
            systemImageName: "message"
        )
        AppShortcut(
            intent: AddApplePayIntent(),
            phrases: ["Add a Wallet payment to \(.applicationName)"],
            shortTitle: "Wallet payment",
            systemImageName: "wallet.pass"
        )
    }
}
