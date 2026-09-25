import Charts
import SwiftUI
import WidgetKit

/// Line + fading area chart without axes, scaled to the data's own range.
struct Sparkline: View {
    let points: [ChartPoint]
    let color: Color

    var body: some View {
        if points.count < 2 {
            Color.clear
        } else {
            let values = points.map(\.value)
            let low = values.min() ?? 0
            let high = values.max() ?? 0
            // A flat series still needs a non-empty domain to draw its line.
            let pad = high > low ? (high - low) * 0.08 : max(abs(high) * 0.01, 1)
            Chart(points) { point in
                AreaMark(
                    x: .value("Time", point.date),
                    yStart: .value("Floor", low - pad),
                    yEnd: .value("Value", point.value)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(colors: [color.opacity(0.32), color.opacity(0)], startPoint: .top, endPoint: .bottom)
                )
                LineMark(x: .value("Time", point.date), y: .value("Value", point.value))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .chartYScale(domain: (low - pad)...(high + pad))
            .widgetAccentable()
        }
    }
}

/// Centered explanation shown instead of numbers (no data yet, nothing
/// picked, no holdings).
struct MessageView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Palette.brand)
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Grey bars standing in for content while the first snapshot loads.
struct PlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            bar(width: 70, height: 10)
            bar(width: 44, height: 8)
            Spacer(minLength: 0)
            bar(width: 100, height: 18)
            bar(width: 54, height: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4).fill(Palette.track).frame(width: width, height: height)
    }
}

/// "Updated 14:32", or a cloud-slash and "3h ago" once the prices are old.
struct FreshnessLabel: View {
    let updatedAt: Date?
    let isStale: Bool

    var body: some View {
        if let updatedAt {
            if isStale {
                Label {
                    Text(updatedAt.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)))
                } icon: {
                    Image(systemName: "icloud.slash")
                }
                .labelStyle(.titleAndIcon)
            } else {
                Text(String(format: L10n.text("Updated %@"), updatedAt.formatted(date: .omitted, time: .shortened)))
            }
        }
    }
}

enum Freshness {
    /// Prices older than this read as stale on the widget.
    static let staleAfter: TimeInterval = 2 * 60 * 60

    /// How often a timeline re-renders on its own (relative times, stale
    /// markers); new numbers arrive when the app reloads the widgets.
    static let rerenderEvery: TimeInterval = 30 * 60
}
