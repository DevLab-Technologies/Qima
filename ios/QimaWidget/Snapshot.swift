import Foundation

/// The data the app publishes for widgets (`WidgetSnapshot` in
/// lib/services/widget_snapshot.dart). Prices are canonical USD per troy
/// ounce (or per unit); every conversion below mirrors the app's
/// `PriceConverter` / `PortfolioHistory` rules so a widget and the app never
/// disagree on a number.
struct Snapshot: Decodable {
    /// Shared with the app (its entitlements). macOS uses a team-prefixed
    /// group, which every macOS version accepts without a consent prompt.
    #if os(macOS)
    static let appGroup = "ZS3A435WC2.com.devlabtechnologies.qima"
    #else
    static let appGroup = "group.com.devlabtechnologies.qima"
    #endif
    static let storageKey = "widget_snapshot"
    static let supportedVersion = 1

    let version: Int
    let updatedAt: Double
    let hideBalances: Bool
    let baseCurrency: String
    let currencies: [String: CurrencyInfo]
    let fxHistory: [String: [[Double]]]
    let cards: [Card]
    let instruments: [InstrumentData]
    let portfolio: Portfolio

    struct CurrencyInfo: Decodable {
        let rate: Double
        let symbol: String
        let suffix: Bool
    }

    struct Card: Decodable {
        let id: String
        let instrumentID: String
        let currency: String
        let unit: String
        let karat: Int?
    }

    struct InstrumentData: Decodable {
        let id: String
        let symbol: String
        let nameKey: String
        let assetClass: String
        let units: [String]
        let karats: [Int]
        let latest: Double?
        let latestAt: Double?
        let series: [String: [[Double]]]
    }

    struct Portfolio: Decodable {
        let available: Bool
        let valueUSD: Double?
        let costUSD: Double?
        let holdings: [Holding]?
        let series: [String: [[Double]]]?
    }

    struct Holding: Decodable {
        let instrumentID: String
        let valueUSD: Double
        let costUSD: Double
    }

    /// The last snapshot the app wrote, or nil before the first one (or if
    /// it was written by an app version this extension can't read).
    static func load() -> Snapshot? {
        guard let json = UserDefaults(suiteName: appGroup)?.string(forKey: storageKey),
              let data = json.data(using: .utf8),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data),
              snapshot.version == supportedVersion
        else { return nil }
        return snapshot
    }

    func instrument(_ id: String) -> InstrumentData? {
        instruments.first { $0.id == id }
    }

    func card(_ id: String) -> Card? {
        cards.first { $0.id == id }
    }

    /// Live rate: display units per 1 USD.
    func liveRate(_ currency: String) -> Double? {
        currency == "USD" ? 1 : currencies[currency]?.rate
    }

    /// Rate at [time] (ms): USD is 1; otherwise the most recent history
    /// sample at or before the time (the earliest sample for older times);
    /// with no history, the live rate — `PriceConverter.points`' rule.
    func rate(_ currency: String, at time: Double) -> Double? {
        if currency == "USD" { return 1 }
        guard let samples = fxHistory[currency], let first = samples.first else {
            return liveRate(currency)
        }
        var chosen = first[1]
        for sample in samples {
            if sample[0] <= time { chosen = sample[1] } else { break }
        }
        return chosen
    }
}

enum PriceUnit: String {
    case troyOunce, gram, kilogram, each

    static let gramsPerTroyOunce = 31.1034768

    var multiplier: Double {
        switch self {
        case .troyOunce, .each: return 1
        case .gram: return 1 / Self.gramsPerTroyOunce
        case .kilogram: return 1000 * (1 / Self.gramsPerTroyOunce)
        }
    }

    /// Abbreviation shown after an amount, e.g. "g"; nil for per-unit prices.
    var abbreviation: String? {
        switch self {
        case .troyOunce: return L10n.key("unit.abbr.troyOunce")
        case .gram: return L10n.key("unit.abbr.gram")
        case .kilogram: return L10n.key("unit.abbr.kilogram")
        case .each: return nil
        }
    }
}

enum ChartWindow: String, CaseIterable {
    case day = "1D", week = "1W", month = "1M", quarter = "3M", year = "1Y", all = "ALL"
}

struct ChartPoint: Identifiable {
    let date: Date
    let value: Double
    var id: Date { date }
}

/// A range-scoped change, first point to last (spec §8.12: never an
/// all-time figure next to a bounded chart).
struct Change {
    let absolute: Double
    let fraction: Double
    var isUp: Bool { fraction >= 0 }

    init?(_ points: [ChartPoint]) {
        guard points.count >= 2, let first = points.first?.value, let last = points.last?.value, first != 0 else {
            return nil
        }
        absolute = last - first
        fraction = (last - first) / first
    }
}
