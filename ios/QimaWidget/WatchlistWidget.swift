import SwiftUI
import WidgetKit

/// The watchlist (or the cards picked for this widget), each priced exactly
/// as the Price widget prices it.
struct WatchlistModel {
    let rows: [PriceModel]
    let range: RangeOption

    /// The freshest price among the rows.
    var updatedAt: Date? { rows.compactMap(\.updatedAt).max() }

    var isStale: Bool {
        guard let updatedAt else { return true }
        return Date().timeIntervalSince(updatedAt) > Freshness.staleAfter
    }

    /// How many rows each size shows (matches the intent's size limits).
    static func capacity(_ family: WidgetFamily) -> Int {
        family == .systemLarge ? 7 : 3
    }

    static func resolve(_ intent: WatchlistWidgetIntent, family: WidgetFamily, in snapshot: Snapshot) -> WatchlistModel {
        let chosen = (intent.assets ?? []).map(\.id)
        let ids = chosen.isEmpty ? snapshot.cards.map { AssetEntity.cardPrefix + $0.id } : chosen
        let rows = ids.lazy
            .compactMap { PriceModel.resolve(assetID: $0, currency: intent.currency, range: intent.range, in: snapshot) }
            .prefix(capacity(family))
        return WatchlistModel(rows: Array(rows), range: intent.range)
    }
}

enum WatchlistContent {
    case ready(WatchlistModel)
    case noData
    case placeholder
}

struct WatchlistEntry: TimelineEntry {
    let date: Date
    let content: WatchlistContent
}

struct WatchlistProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WatchlistEntry {
        WatchlistEntry(date: Date(), content: .placeholder)
    }

    func snapshot(for configuration: WatchlistWidgetIntent, in context: Context) async -> WatchlistEntry {
        entry(for: configuration, family: context.family)
    }

    func timeline(for configuration: WatchlistWidgetIntent, in context: Context) async -> Timeline<WatchlistEntry> {
        let now = Date()
        return Timeline(
            entries: [entry(for: configuration, family: context.family)],
            policy: .after(now.addingTimeInterval(Freshness.rerenderEvery))
        )
    }

    private func entry(for configuration: WatchlistWidgetIntent, family: WidgetFamily) -> WatchlistEntry {
        guard let snapshot = Snapshot.load() else { return WatchlistEntry(date: Date(), content: .noData) }
        let model = WatchlistModel.resolve(configuration, family: family, in: snapshot)
        return WatchlistEntry(date: Date(), content: model.rows.isEmpty ? .noData : .ready(model))
    }
}

struct WatchlistWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchlistEntry

    var body: some View {
        switch entry.content {
        case .ready(let model):
            switch family {
            case .systemSmall: WatchlistSmallView(model: model)
            case .systemLarge: WatchlistListView(model: model, large: true)
            default: WatchlistListView(model: model, large: false)
            }
        case .noData:
            MessageView(icon: "list.bullet", message: L10n.text("Add assets in Qima to see them here"))
        case .placeholder:
            PlaceholderView()
        }
    }
}

/// "1D · Updated 14:32", or the stale marker once prices are old.
private struct WatchlistFooter: View {
    let model: WatchlistModel

    var body: some View {
        HStack(spacing: 4) {
            if model.isStale {
                FreshnessLabel(updatedAt: model.updatedAt, isStale: true)
            } else {
                Text(model.range.shortLabel)
                if model.updatedAt != nil {
                    Text("·")
                    FreshnessLabel(updatedAt: model.updatedAt, isStale: false)
                }
            }
        }
        .font(.qima(10))
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
}

/// ▲0.84% / ▼0.62%: the arrow carries the direction, so it survives the
/// monochrome and tinted widget renderings.
private struct TrendFigure: View {
    let change: Change?
    let size: CGFloat

    var body: some View {
        if let change {
            Text("\(Format.arrow(change.isUp))\(Format.percent(abs(change.fraction)).dropFirst())")
                .font(.qima(size, .semibold))
                .foregroundStyle(Palette.trend(change.isUp))
                .lineLimit(1)
        }
    }
}

private struct WatchlistRow: View {
    let row: PriceModel

    /// "g · EGP", or "BTC · USD" for assets priced per unit.
    private var subtitle: String {
        "\(row.unit.abbreviation ?? row.instrument.symbol) · \(row.currency)"
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Palette.accent(row.instrument).opacity(0.18))
                Image(systemName: Palette.icon(row.instrument))
                    .font(.qima(13, .semibold))
                    .foregroundStyle(Palette.accent(row.instrument))
            }
            .frame(width: 26, height: 26)
            .widgetAccentable()

            VStack(alignment: .leading, spacing: 1) {
                Text(row.title).font(.qima(13, .semibold)).lineLimit(1)
                Text(subtitle).font(.qima(10)).foregroundStyle(.secondary).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Sparkline(points: row.points, color: Palette.trend(row.change?.isUp ?? true))
                .frame(width: 48, height: 22)

            VStack(alignment: .trailing, spacing: 1) {
                Text(row.money(row.price))
                    .font(.qima(13, .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                TrendFigure(change: row.change, size: 10)
            }
            .frame(width: 84, alignment: .trailing)
        }
    }
}

struct WatchlistListView: View {
    let model: WatchlistModel
    let large: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if large {
                HStack {
                    Text(L10n.text("Watchlist")).font(.qima(12, .semibold)).foregroundStyle(.secondary)
                    Spacer(minLength: 4)
                    WatchlistFooter(model: model)
                }
                .padding(.bottom, 8)
            }
            // A full list spreads evenly over the widget; a shorter one keeps
            // the rows' natural spacing from the top instead of drifting apart.
            let full = model.rows.count >= WatchlistModel.capacity(large ? .systemLarge : .systemMedium)
            VStack(spacing: full ? 0 : 10) {
                ForEach(Array(model.rows.enumerated()), id: \.offset) { index, row in
                    if full && index > 0 { Spacer(minLength: 2) }
                    WatchlistRow(row: row)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            if !large {
                WatchlistFooter(model: model).padding(.top, 6)
            }
        }
    }
}

struct WatchlistSmallView: View {
    let model: WatchlistModel

    /// The stale footer takes one row's space, as in the design.
    private var rows: ArraySlice<PriceModel> { model.rows.prefix(model.isStale ? 2 : 3) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Divider().opacity(0.5)
                }
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text(row.karat.map { "\(row.instrument.symbol) \(L10n.karat($0))" } ?? row.instrument.symbol)
                            .font(.qima(11, .semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer(minLength: 2)
                        TrendFigure(change: row.change, size: 10)
                    }
                    Text(row.money(row.price))
                        .font(.qima(15, .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxHeight: .infinity)
            }
            if model.isStale {
                WatchlistFooter(model: model)
            }
        }
    }
}

struct WatchlistWidget: Widget {
    /// Matches `HomeWidgetService.iOSWatchlistKind` in the app.
    static let kind = "WatchlistWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: WatchlistWidgetIntent.self, provider: WatchlistProvider()) { entry in
            WatchlistWidgetView(entry: entry).qimaBackground()
        }
        .configurationDisplayName(L10n.text("Watchlist"))
        .description(L10n.text("Your watchlist at a glance."))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
