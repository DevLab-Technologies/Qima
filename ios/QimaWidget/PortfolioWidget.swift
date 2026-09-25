import SwiftUI
import WidgetKit

/// The portfolio in one currency over one range, resolved from the
/// snapshot the way the app's portfolio hero computes it.
struct PortfolioModel {
    struct Row: Identifiable {
        let instrument: Snapshot.InstrumentData
        let value: Double
        let gain: Double
        let share: Double
        var id: String { instrument.id }
    }

    let snapshot: Snapshot
    let currency: String
    let range: RangeOption
    let value: Double
    let points: [ChartPoint]
    /// Change in gain (value minus cost) over the range, so money added
    /// mid-range never shows as profit.
    let gainDelta: Double?
    let gainFraction: Double?
    let rows: [Row]

    var hidden: Bool { snapshot.hideBalances }

    func money(_ amount: Double, whole: Bool = false, signed: Bool = false) -> String {
        hidden ? Format.mask : Format.money(amount, currency: currency, in: snapshot, whole: whole, signed: signed)
    }

    /// "+$2,909.30 · +6.42%", or just the percent when balances are hidden.
    var changeText: String? {
        guard let gainDelta, let gainFraction else { return nil }
        if hidden { return Format.percent(gainFraction) }
        return "\(money(gainDelta, signed: true)) · \(Format.percent(gainFraction))"
    }

    var isUp: Bool { (gainDelta ?? 0) >= 0 }

    static func resolve(_ intent: PortfolioWidgetIntent, in snapshot: Snapshot) -> PortfolioModel? {
        let portfolio = snapshot.portfolio
        guard portfolio.available, let valueUSD = portfolio.valueUSD else { return nil }

        var currency = snapshot.baseCurrency
        if let chosen = intent.currency, !chosen.isAutomatic, snapshot.currencies[chosen.id] != nil {
            currency = chosen.id
        }
        guard let liveRate = snapshot.liveRate(currency) else { return nil }

        // Value follows historical FX like the app's chart; cost is always at
        // today's rate, as on the Holdings screen.
        let samples = (portfolio.series?[intent.range.window.rawValue] ?? []).filter { $0.count == 3 }
        var points: [ChartPoint] = []
        var gains: [(value: Double, cost: Double)] = []
        for sample in samples {
            guard let rate = snapshot.rate(currency, at: sample[0]) else { continue }
            let value = sample[1] * rate
            points.append(ChartPoint(date: Date(timeIntervalSince1970: sample[0] / 1000), value: value))
            gains.append((value, sample[2] * liveRate))
        }

        // Same rule as the app's PortfolioRangeChange.from: gain change over
        // the money at work (start value plus what was invested during the
        // range); "All" starts from before the first purchase.
        var gainDelta: Double?
        var gainFraction: Double?
        if let first = gains.first, let last = gains.last {
            let start = intent.range == .all ? (value: 0.0, cost: 0.0) : first
            let delta = (last.value - last.cost) - (start.value - start.cost)
            let invested = start.value + (last.cost - start.cost)
            gainDelta = delta
            gainFraction = invested > 0 ? delta / invested : 0
        }

        let total = valueUSD
        let rows = (portfolio.holdings ?? []).compactMap { holding -> Row? in
            guard let instrument = snapshot.instrument(holding.instrumentID) else { return nil }
            return Row(
                instrument: instrument,
                value: holding.valueUSD * liveRate,
                gain: (holding.valueUSD - holding.costUSD) * liveRate,
                share: total > 0 ? holding.valueUSD / total : 0
            )
        }

        return PortfolioModel(
            snapshot: snapshot,
            currency: currency,
            range: intent.range,
            value: valueUSD * liveRate,
            points: points,
            gainDelta: gainDelta,
            gainFraction: gainFraction,
            rows: rows
        )
    }
}

enum PortfolioContent {
    case ready(PortfolioModel)
    case noData
    case noHoldings
    case placeholder
}

struct PortfolioEntry: TimelineEntry {
    let date: Date
    let content: PortfolioContent
}

struct PortfolioProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PortfolioEntry {
        PortfolioEntry(date: Date(), content: .placeholder)
    }

    func snapshot(for configuration: PortfolioWidgetIntent, in context: Context) async -> PortfolioEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: PortfolioWidgetIntent, in context: Context) async -> Timeline<PortfolioEntry> {
        let now = Date()
        return Timeline(entries: [entry(for: configuration)], policy: .after(now.addingTimeInterval(Freshness.rerenderEvery)))
    }

    private func entry(for configuration: PortfolioWidgetIntent) -> PortfolioEntry {
        guard let snapshot = Snapshot.load() else { return PortfolioEntry(date: Date(), content: .noData) }
        guard let model = PortfolioModel.resolve(configuration, in: snapshot) else {
            return PortfolioEntry(date: Date(), content: .noHoldings)
        }
        return PortfolioEntry(date: Date(), content: .ready(model))
    }
}

struct PortfolioWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PortfolioEntry

    var body: some View {
        switch entry.content {
        case .ready(let model):
            switch family {
            #if os(iOS)
            case .accessoryRectangular: PortfolioRectangularView(model: model)
            #endif
            case .systemLarge: PortfolioLargeView(model: model)
            default: PortfolioSummaryView(model: model, wide: family == .systemMedium)
            }
        case .noData:
            message(icon: "arrow.clockwise", text: L10n.text("Open Qima to load prices"))
        case .noHoldings:
            message(icon: "plus.circle", text: L10n.text("Add holdings in Qima to see your portfolio"))
        case .placeholder:
            if family.isAccessory { Text("—") } else { PlaceholderView() }
        }
    }

    @ViewBuilder
    private func message(icon: String, text: String) -> some View {
        if family.isAccessory {
            Image(systemName: icon)
        } else {
            MessageView(icon: icon, message: text)
        }
    }
}

private struct PortfolioHeader: View {
    let model: PortfolioModel
    var showsScope = false

    var body: some View {
        HStack(spacing: 4) {
            Text(L10n.key("portfolio.title")).font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
            if model.hidden {
                Image(systemName: "eye.slash").font(.system(size: 10)).foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            if showsScope {
                Text("\(model.currency) · \(model.range.heading)").font(.system(size: 10)).foregroundStyle(.secondary)
            }
        }
    }
}

private struct PortfolioChange: View {
    let model: PortfolioModel

    var body: some View {
        if let text = model.changeText {
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Palette.trend(model.isUp))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

struct PortfolioSummaryView: View {
    let model: PortfolioModel
    let wide: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            PortfolioHeader(model: model, showsScope: wide)
            Spacer(minLength: 6)
            Text(model.money(model.value))
                .font(.system(size: wide ? 24 : 20, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .privacySensitive()
            PortfolioChange(model: model)
            Sparkline(points: model.points, color: Palette.brand)
                .frame(height: wide ? 44 : 34)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PortfolioLargeView: View {
    let model: PortfolioModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            PortfolioHeader(model: model, showsScope: true)
            Text(model.money(model.value))
                .font(.system(size: 26, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .privacySensitive()
            PortfolioChange(model: model)
            Sparkline(points: model.points, color: Palette.brand)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 4)
            AllocationBar(rows: model.rows)
                .frame(height: 4)
                .padding(.bottom, 6)
            ForEach(model.rows.prefix(4)) { row in
                HStack(spacing: 8) {
                    Image(systemName: Palette.icon(row.instrument))
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.accent(row.instrument))
                        .widgetAccentable()
                    VStack(alignment: .leading, spacing: 0) {
                        Text(L10n.key(row.instrument.nameKey)).font(.system(size: 12, weight: .semibold)).lineLimit(1)
                        Text(Format.percent(row.share, digits: 1).replacingOccurrences(of: "+", with: ""))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 4)
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(model.money(row.value)).font(.system(size: 12, weight: .semibold)).lineLimit(1).privacySensitive()
                        if !model.hidden {
                            Text(model.money(row.gain, signed: true))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Palette.trend(row.gain >= 0))
                                .lineLimit(1)
                                .privacySensitive()
                        }
                    }
                }
            }
        }
    }
}

/// One segment per holding, in its asset colour, sized by share of value.
private struct AllocationBar: View {
    let rows: [PortfolioModel.Row]

    var body: some View {
        GeometryReader { geometry in
            let gaps = CGFloat(max(rows.count - 1, 0)) * 2
            HStack(spacing: 2) {
                ForEach(rows) { row in
                    Capsule()
                        .fill(Palette.accent(row.instrument))
                        .frame(width: max((geometry.size.width - gaps) * row.share, 2))
                }
            }
        }
        .widgetAccentable()
    }
}

struct PortfolioRectangularView: View {
    let model: PortfolioModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.key("portfolio.title")).font(.system(size: 13, weight: .semibold)).lineLimit(1)
            Text(model.money(model.value, whole: true))
                .font(.system(size: 17, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .privacySensitive()
            if let fraction = model.gainFraction {
                Text("\(Format.arrow(model.isUp)) \(Format.percent(fraction)) \(model.range.shortLabel)")
                    .font(.system(size: 12))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PortfolioWidget: Widget {
    /// Matches `HomeWidgetService.iOSPortfolioKind` in the app.
    static let kind = "PortfolioWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: PortfolioWidgetIntent.self, provider: PortfolioProvider()) { entry in
            PortfolioWidgetView(entry: entry).qimaBackground()
        }
        .configurationDisplayName(L10n.text("Portfolio"))
        .description(L10n.text("Your holdings' value and gain."))
        .supportedFamilies(Self.families)
    }

    #if os(iOS)
    private static let families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular]
    #else
    private static let families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
    #endif
}
