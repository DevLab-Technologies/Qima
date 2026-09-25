import AppIntents
import WidgetKit

// MARK: - Asset

/// A watchlist card (its unit, karat and currency come with it) or any other
/// instrument the app has prices for, such as one only held in Holdings.
struct AssetEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Asset")
    static let defaultQuery = AssetQuery()

    static let cardPrefix = "card:"
    static let instrumentPrefix = "instrument:"

    let id: String
    let title: String
    let subtitle: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(subtitle)")
    }

    static func card(_ card: Snapshot.Card, _ instrument: Snapshot.InstrumentData) -> AssetEntity {
        let unit = PriceUnit(rawValue: card.unit)
        let parts = [unit?.abbreviation, card.currency, card.karat.map(L10n.karat)].compactMap { $0 }
        return AssetEntity(id: cardPrefix + card.id, title: L10n.key(instrument.nameKey), subtitle: parts.joined(separator: " · "))
    }

    static func instrument(_ instrument: Snapshot.InstrumentData) -> AssetEntity {
        AssetEntity(id: instrumentPrefix + instrument.id, title: L10n.key(instrument.nameKey), subtitle: instrument.symbol)
    }
}

struct AssetQuery: EntityStringQuery {
    private func sections() -> (cards: [AssetEntity], others: [AssetEntity]) {
        guard let snapshot = Snapshot.load() else { return ([], []) }
        let cards = snapshot.cards.compactMap { card in
            snapshot.instrument(card.instrumentID).map { AssetEntity.card(card, $0) }
        }
        let carded = Set(snapshot.cards.map(\.instrumentID))
        let others = snapshot.instruments.filter { !carded.contains($0.id) }.map(AssetEntity.instrument)
        return (cards, others)
    }

    func entities(for identifiers: [AssetEntity.ID]) async throws -> [AssetEntity] {
        let (cards, others) = sections()
        return (cards + others).filter { identifiers.contains($0.id) }
    }

    func entities(matching string: String) async throws -> IntentItemCollection<AssetEntity> {
        collection { $0.title.localizedCaseInsensitiveContains(string) || $0.subtitle.localizedCaseInsensitiveContains(string) }
    }

    func suggestedEntities() async throws -> IntentItemCollection<AssetEntity> {
        collection { _ in true }
    }

    /// Watchlist cards first, then everything else, as in the app's picker.
    private func collection(_ include: (AssetEntity) -> Bool) -> IntentItemCollection<AssetEntity> {
        let (allCards, allOthers) = sections()
        let cards = allCards.filter(include)
        let others = allOthers.filter(include)
        var collection: [IntentItemSection<AssetEntity>] = []
        if !cards.isEmpty { collection.append(IntentItemSection("Your watchlist", items: cards.map { IntentItem($0) })) }
        if !others.isEmpty { collection.append(IntentItemSection("Other assets", items: others.map { IntentItem($0) })) }
        return IntentItemCollection(sections: collection)
    }

    func defaultResult() async -> AssetEntity? {
        sections().cards.first
    }
}

// MARK: - Currency

/// A currency code, or "same as the watchlist card / base currency".
struct CurrencyEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Currency")
    static let defaultQuery = CurrencyQuery()
    static let automaticID = "auto"

    let id: String

    var isAutomatic: Bool { id == Self.automaticID }

    var displayRepresentation: DisplayRepresentation {
        if isAutomatic { return DisplayRepresentation(title: "Automatic", subtitle: "Watchlist or base currency") }
        let name = Locale.current.localizedString(forCurrencyCode: id) ?? id
        return DisplayRepresentation(title: "\(id)", subtitle: "\(name)")
    }
}

struct CurrencyQuery: EntityStringQuery {
    private func all() -> [CurrencyEntity] {
        guard let snapshot = Snapshot.load() else { return [CurrencyEntity(id: CurrencyEntity.automaticID)] }
        // The currencies the user already works in first, then the rest A–Z.
        var ordered = [snapshot.baseCurrency] + snapshot.cards.map(\.currency)
        ordered += snapshot.currencies.keys.sorted()
        var seen = Set<String>()
        let codes = ordered.filter { snapshot.currencies[$0] != nil && seen.insert($0).inserted }
        return [CurrencyEntity(id: CurrencyEntity.automaticID)] + codes.map(CurrencyEntity.init)
    }

    func entities(for identifiers: [CurrencyEntity.ID]) async throws -> [CurrencyEntity] {
        identifiers.map(CurrencyEntity.init)
    }

    func entities(matching string: String) async throws -> [CurrencyEntity] {
        all().filter {
            !$0.isAutomatic && ($0.id.localizedCaseInsensitiveContains(string) ||
                (Locale.current.localizedString(forCurrencyCode: $0.id) ?? "").localizedCaseInsensitiveContains(string))
        }
    }

    func suggestedEntities() async throws -> [CurrencyEntity] { all() }

    func defaultResult() async -> CurrencyEntity? { CurrencyEntity(id: CurrencyEntity.automaticID) }
}

// MARK: - Options

enum UnitOption: String, AppEnum {
    case automatic, troyOunce, gram, kilogram

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Unit")
    static let caseDisplayRepresentations: [UnitOption: DisplayRepresentation] = [
        .automatic: "Automatic",
        .troyOunce: "Troy ounce",
        .gram: "Gram",
        .kilogram: "Kilogram",
    ]
}

enum KaratOption: String, AppEnum {
    case automatic, k24, k22, k21, k18

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Karat")
    static let caseDisplayRepresentations: [KaratOption: DisplayRepresentation] = [
        .automatic: "Automatic",
        .k24: "24K",
        .k22: "22K",
        .k21: "21K",
        .k18: "18K",
    ]

    var karat: Int? {
        switch self {
        case .automatic: return nil
        case .k24: return 24
        case .k22: return 22
        case .k21: return 21
        case .k18: return 18
        }
    }
}

enum RangeOption: String, AppEnum {
    case day, week, month, quarter, year, all

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Chart range")
    static let caseDisplayRepresentations: [RangeOption: DisplayRepresentation] = [
        .day: "1 day",
        .week: "1 week",
        .month: "1 month",
        .quarter: "3 months",
        .year: "1 year",
        .all: "All time",
    ]

    var window: ChartWindow {
        switch self {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        case .quarter: return .quarter
        case .year: return .year
        case .all: return .all
        }
    }

    /// Short label beside a change figure, e.g. "1M".
    var shortLabel: String {
        switch self {
        case .day: return L10n.key("range.1D")
        case .week: return L10n.key("range.1W")
        case .month: return L10n.key("range.1M")
        case .quarter: return L10n.key("range.3M")
        case .year: return L10n.key("range.1Y")
        case .all: return L10n.key("range.all")
        }
    }

    /// Heading above a larger chart, e.g. "Past month".
    var heading: String {
        switch self {
        case .day: return L10n.text("Past day")
        case .week: return L10n.text("Past week")
        case .month: return L10n.text("Past month")
        case .quarter: return L10n.text("Past 3 months")
        case .year: return L10n.text("Past year")
        case .all: return L10n.text("All time")
        }
    }
}

// MARK: - Intents

struct PriceWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Price"
    static let description = IntentDescription("Follow one asset in the unit, karat and currency you choose.")

    @Parameter(title: "Asset")
    var asset: AssetEntity?

    @Parameter(title: "Unit", default: .automatic)
    var unit: UnitOption

    @Parameter(title: "Karat", default: .automatic)
    var karat: KaratOption

    @Parameter(title: "Currency")
    var currency: CurrencyEntity?

    @Parameter(title: "Chart range", default: .month)
    var range: RangeOption
}

struct PortfolioWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Portfolio"
    static let description = IntentDescription("Your holdings' value and gain.")

    @Parameter(title: "Currency")
    var currency: CurrencyEntity?

    @Parameter(title: "Chart range", default: .all)
    var range: RangeOption
}

struct WatchlistWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Watchlist"
    static let description = IntentDescription("Your watchlist at a glance.")

    /// Empty means every watchlist card, in watchlist order.
    @Parameter(title: "Assets", size: [.systemSmall: 3, .systemMedium: 3, .systemLarge: 7])
    var assets: [AssetEntity]?

    @Parameter(title: "Chart range", default: .day)
    var range: RangeOption

    @Parameter(title: "Currency")
    var currency: CurrencyEntity?
}
