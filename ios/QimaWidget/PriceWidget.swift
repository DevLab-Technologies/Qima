import SwiftUI
import WidgetKit

/// One configured price widget, resolved against the latest snapshot.
struct PriceModel {
    let snapshot: Snapshot
    let instrument: Snapshot.InstrumentData
    let currency: String
    let unit: PriceUnit
    let karat: Int?
    let range: RangeOption
    let price: Double
    let points: [ChartPoint]
    let change: Change?
    let updatedAt: Date?

    var isStale: Bool {
        guard let updatedAt else { return true }
        return Date().timeIntervalSince(updatedAt) > Freshness.staleAfter
    }

    var title: String {
        let name = L10n.key(instrument.nameKey)
        return karat.map { "\(name) \(L10n.karat($0))" } ?? name
    }

    /// "g · EGP", or just the currency for per-unit prices.
    var subtitle: String {
        [unit.abbreviation, currency].compactMap { $0 }.joined(separator: " · ")
    }

    func money(_ amount: Double, whole: Bool = false) -> String {
        Format.money(amount, currency: currency, in: snapshot, whole: whole)
    }

    /// Applies the widget's settings on top of the picked card (or, for an
    /// instrument without a card, the app's base currency and default
    /// unit). Nil when the asset is gone or can't be priced in the currency.
    static func resolve(_ intent: PriceWidgetIntent, in snapshot: Snapshot) -> PriceModel? {
        let assetID = intent.asset?.id
            ?? snapshot.cards.first.map { AssetEntity.cardPrefix + $0.id }
        guard let assetID else { return nil }
        return resolve(
            assetID: assetID,
            unit: intent.unit,
            karat: intent.karat,
            currency: intent.currency,
            range: intent.range,
            in: snapshot
        )
    }

    /// One asset ("card:<id>" or "instrument:<id>") priced with the given
    /// overrides; `.automatic` / nil keep the card's own settings.
    static func resolve(
        assetID: String,
        unit unitOption: UnitOption = .automatic,
        karat karatOption: KaratOption = .automatic,
        currency currencyOption: CurrencyEntity?,
        range: RangeOption,
        in snapshot: Snapshot
    ) -> PriceModel? {
        let card: Snapshot.Card?
        let instrumentID: String
        if assetID.hasPrefix(AssetEntity.cardPrefix) {
            card = snapshot.card(String(assetID.dropFirst(AssetEntity.cardPrefix.count)))
            guard let card else { return nil }
            instrumentID = card.instrumentID
        } else {
            card = nil
            instrumentID = String(assetID.dropFirst(AssetEntity.instrumentPrefix.count))
        }
        guard let instrument = snapshot.instrument(instrumentID) else { return nil }

        var unit = card.flatMap { PriceUnit(rawValue: $0.unit) }
            ?? instrument.units.first.flatMap(PriceUnit.init(rawValue:)) ?? .each
        if unitOption != .automatic, instrument.units.contains(unitOption.rawValue),
           let chosen = PriceUnit(rawValue: unitOption.rawValue) {
            unit = chosen
        }

        let karat = instrument.karats.isEmpty ? nil : (karatOption.karat ?? card?.karat)
        let purity = Double(karat ?? 24) / 24

        var currency = card?.currency ?? snapshot.baseCurrency
        if let chosen = currencyOption, !chosen.isAutomatic, snapshot.currencies[chosen.id] != nil {
            currency = chosen.id
        }

        guard let latest = instrument.latest, let liveRate = snapshot.liveRate(currency) else { return nil }
        let factor = unit.multiplier * purity
        let points = (instrument.series[range.window.rawValue] ?? []).compactMap { sample -> ChartPoint? in
            guard sample.count == 2, let rate = snapshot.rate(currency, at: sample[0]) else { return nil }
            return ChartPoint(date: Date(timeIntervalSince1970: sample[0] / 1000), value: sample[1] * rate * factor)
        }

        return PriceModel(
            snapshot: snapshot,
            instrument: instrument,
            currency: currency,
            unit: unit,
            karat: karat,
            range: range,
            price: latest * liveRate * factor,
            points: points,
            change: Change(points),
            updatedAt: instrument.latestAt.map { Date(timeIntervalSince1970: $0 / 1000) }
        )
    }
}

enum PriceContent {
    case ready(PriceModel)
    case noData
    case noAsset
    case placeholder
}

struct PriceEntry: TimelineEntry {
    let date: Date
    let content: PriceContent
}

struct PriceProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PriceEntry {
        PriceEntry(date: Date(), content: .placeholder)
    }

    func snapshot(for configuration: PriceWidgetIntent, in context: Context) async -> PriceEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: PriceWidgetIntent, in context: Context) async -> Timeline<PriceEntry> {
        let now = Date()
        return Timeline(entries: [entry(for: configuration)], policy: .after(now.addingTimeInterval(Freshness.rerenderEvery)))
    }

    private func entry(for configuration: PriceWidgetIntent) -> PriceEntry {
        guard let snapshot = Snapshot.load() else { return PriceEntry(date: Date(), content: .noData) }
        guard let model = PriceModel.resolve(configuration, in: snapshot) else {
            return PriceEntry(date: Date(), content: snapshot.cards.isEmpty && snapshot.instruments.isEmpty ? .noData : .noAsset)
        }
        return PriceEntry(date: Date(), content: .ready(model))
    }
}

struct PriceWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PriceEntry

    var body: some View {
        switch entry.content {
        case .ready(let model):
            switch family {
            case .systemMedium: PriceMediumView(model: model)
            #if os(iOS)
            case .accessoryInline: PriceInlineView(model: model)
            case .accessoryCircular: PriceCircularView(model: model)
            case .accessoryRectangular: PriceRectangularView(model: model)
            #endif
            default: PriceSmallView(model: model)
            }
        case .noData:
            message(icon: "arrow.clockwise", text: L10n.text("Open Qima to load prices"))
        case .noAsset:
            message(icon: "square.and.pencil", text: L10n.text("Edit the widget to pick an asset"))
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

private struct PriceHeader: View {
    let model: PriceModel

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: Palette.icon(model.instrument))
                .font(.qima(15))
                .foregroundStyle(Palette.accent(model.instrument))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 0) {
                Text(model.title).font(.qima(12, .semibold)).lineLimit(1)
                Text(model.subtitle).font(.qima(9)).foregroundStyle(.secondary).lineLimit(1)
            }
        }
    }
}

private struct ChangeLine: View {
    let model: PriceModel

    var body: some View {
        HStack(spacing: 4) {
            if let change = model.change {
                (Text("\(Format.arrow(change.isUp)) \(Format.percent(change.fraction))")
                    .foregroundStyle(Palette.trend(change.isUp))
                    + Text(" \(model.range.shortLabel)").foregroundStyle(.secondary))
                    .font(.qima(11, .semibold))
            }
            if model.isStale {
                FreshnessLabel(updatedAt: model.updatedAt, isStale: true)
                    .font(.qima(10, .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

struct PriceSmallView: View {
    let model: PriceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            PriceHeader(model: model)
            Spacer(minLength: 6)
            Text(model.money(model.price))
                .font(.qima(20, .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            ChangeLine(model: model)
            Sparkline(points: model.points, color: Palette.trend(model.change?.isUp ?? true))
                .frame(height: 34)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PriceMediumView: View {
    let model: PriceModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                PriceHeader(model: model)
                Spacer(minLength: 6)
                Text(model.money(model.price))
                    .font(.qima(22, .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                ChangeLine(model: model)
                Spacer(minLength: 6)
                FreshnessLabel(updatedAt: model.updatedAt, isStale: false)
                    .font(.qima(9))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 128, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(model.range.heading).font(.qima(10, .semibold)).foregroundStyle(.secondary)
                    Spacer(minLength: 4)
                    if let high = model.points.map(\.value).max(), let low = model.points.map(\.value).min() {
                        Text(String(format: L10n.text("H %@ · L %@"), model.money(high, whole: true), model.money(low, whole: true)))
                            .font(.qima(9))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                Sparkline(points: model.points, color: Palette.trend(model.change?.isUp ?? true))
            }
        }
    }
}

struct PriceInlineView: View {
    let model: PriceModel

    var body: some View {
        if let change = model.change {
            Text("\(Format.arrow(change.isUp)) \(model.title) \(model.money(model.price, whole: true)) \(Format.percent(change.fraction))")
        } else {
            Text("\(model.title) \(model.money(model.price, whole: true))")
        }
    }
}

struct PriceCircularView: View {
    let model: PriceModel

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(model.instrument.symbol)
                    .font(.qima(10, .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let change = model.change {
                    Text(Format.percent(change.fraction, digits: 1).replacingOccurrences(of: "%", with: ""))
                        .font(.qima(15, .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
            .padding(4)
        }
    }
}

struct PriceRectangularView: View {
    let model: PriceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(model.title).font(.qima(13, .semibold)).lineLimit(1)
            Text(model.money(model.price)).font(.qima(17, .bold)).lineLimit(1).minimumScaleFactor(0.6)
            if let change = model.change {
                Text("\(Format.arrow(change.isUp)) \(Format.percent(change.fraction)) \(model.range.shortLabel)")
                    .font(.qima(12))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension WidgetFamily {
    var isAccessory: Bool {
        #if os(iOS)
        return self == .accessoryInline || self == .accessoryCircular || self == .accessoryRectangular
        #else
        return false
        #endif
    }
}

struct PriceWidget: Widget {
    /// Matches `HomeWidgetService.iOSPriceKind` in the app.
    static let kind = "PriceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: PriceWidgetIntent.self, provider: PriceProvider()) { entry in
            PriceWidgetView(entry: entry).qimaBackground()
        }
        .configurationDisplayName(L10n.text("Price"))
        .description(L10n.text("Follow one asset in the unit, karat and currency you choose."))
        .supportedFamilies(Self.families)
    }

    #if os(iOS)
    private static let families: [WidgetFamily] = [
        .systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular,
    ]
    #else
    private static let families: [WidgetFamily] = [.systemSmall, .systemMedium]
    #endif
}
