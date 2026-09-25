import SwiftUI
import WidgetKit

/// Qima's home-screen and lock-screen widgets. They never fetch anything
/// themselves: the app writes a snapshot to the shared App Group after each
/// refresh and reloads these timelines (see HomeWidgetService).
@main
struct QimaWidgetBundle: WidgetBundle {
    var body: some Widget {
        PriceWidget()
        PortfolioWidget()
        WatchlistWidget()
    }
}
