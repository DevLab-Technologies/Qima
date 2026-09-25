import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Strings. Model keys the app shares with the widget ("asset.gold",
/// "unit.abbr.gram") are generated from the app's ARB files by
/// tool/generate_widget_strings.py; widget-only strings are keyed by their
/// English text.
enum L10n {
    /// Resolves a dotted app key ("asset.gold" → "assetGold"). An unknown
    /// key comes back as-is, which is right for custom tickers: their
    /// `nameKey` is the literal name the user typed.
    static func key(_ dotted: String) -> String {
        let parts = dotted.split(separator: ".").map(String.init)
        guard let head = parts.first else { return dotted }
        let camel = head + parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
        return Bundle.main.localizedString(forKey: camel, value: dotted, table: nil)
    }

    static func text(_ english: String) -> String {
        Bundle.main.localizedString(forKey: english, value: english, table: nil)
    }

    static func karat(_ karat: Int) -> String { key("karat.short.\(karat)") }
}

/// Number formatting that matches the app's `Money` type: magnitude-banded
/// decimals, Western digits, and each currency's own symbol and placement.
enum Format {
    static let mask = "••••••"

    private static func number(_ value: Double, digits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private static func fractionDigits(_ magnitude: Double) -> Int {
        if magnitude == 0 { return 2 }
        if magnitude < 1 { return 6 }
        if magnitude < 10 { return 4 }
        return 2
    }

    /// "$1,234.56", "1,234.56 ج.م". [whole] drops the decimals from 1,000 up,
    /// for the narrow lock-screen accessories.
    static func money(_ amount: Double, currency: String, in snapshot: Snapshot, whole: Bool = false, signed: Bool = false) -> String {
        let magnitude = abs(amount)
        let digits = whole && magnitude >= 1000 ? 0 : fractionDigits(magnitude)
        let body = number(magnitude, digits: digits)
        let sign = amount < 0 ? "-" : (signed ? "+" : "")
        let info = snapshot.currencies[currency]
        let raw = info?.symbol ?? currency
        let isArabic = raw.unicodeScalars.contains { (0x0590...0x08FF).contains($0.value) }
        let symbol = isArabic ? "\u{2068}\(raw)\u{2069}" : raw
        if info?.suffix == true {
            return "\(sign)\(body)\u{00A0}\(symbol)"
        }
        let endsWithLetter = raw.last.map { $0.isLetter } ?? false
        return "\(sign)\(symbol)\(endsWithLetter ? "\u{00A0}" : "")\(body)"
    }

    /// "+0.61%" / "-2.30%".
    static func percent(_ fraction: Double, digits: Int = 2) -> String {
        let value = fraction * 100
        return "\(value >= 0 ? "+" : "-")\(number(abs(value), digits: digits))%"
    }

    static func arrow(_ isUp: Bool) -> String { isUp ? "▲" : "▼" }
}

/// Qima DS tokens (lib/theme/qima_colors.dart), dark and light.
enum Palette {
    static let up = dynamic(light: 0x166B2E, dark: 0x30D158)
    static let down = dynamic(light: 0xB42A26, dark: 0xFF6B61)
    static let brand = dynamic(light: 0xA87B14, dark: 0xE6BA4D)
    static let surfaceTop = dynamic(light: 0xFFFFFF, dark: 0x1F2229)
    static let surfaceBottom = dynamic(light: 0xFAFAFC, dark: 0x191B21)
    static let track = dynamic(light: 0xEAECF0, dark: 0x2B2F39)

    static func trend(_ isUp: Bool) -> Color { isUp ? up : down }

    static func accent(_ instrument: Snapshot.InstrumentData) -> Color {
        switch instrument.assetClass {
        case "metal":
            switch instrument.symbol {
            case "XAG": return dynamic(light: 0x8A8D93, dark: 0xC7C7C7)
            case "XPT", "XPD": return dynamic(light: 0x6F93B8, dark: 0xA9C4DD)
            default: return brand
            }
        case "crypto": return dynamic(light: 0xE0761A, dark: 0xF28C33)
        case "fiat": return dynamic(light: 0x1597A8, dark: 0x3FB8C9)
        case "indices": return dynamic(light: 0x7447C9, dark: 0x9975E0)
        default: return dynamic(light: 0x4A6FDB, dark: 0x6B8CEB)
        }
    }

    /// The SF Symbol the app uses for each asset class.
    static func icon(_ instrument: Snapshot.InstrumentData) -> String {
        switch instrument.assetClass {
        case "metal": return "circle.hexagongrid.fill"
        case "crypto": return "bitcoinsign.circle.fill"
        case "stock": return "chart.line.uptrend.xyaxis"
        case "indices": return "chart.bar.xaxis"
        default: return "dollarsign.circle.fill"
        }
    }

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        func components(_ hex: UInt32) -> (CGFloat, CGFloat, CGFloat) {
            (CGFloat((hex >> 16) & 0xFF) / 255, CGFloat((hex >> 8) & 0xFF) / 255, CGFloat(hex & 0xFF) / 255)
        }
        #if canImport(UIKit)
        return Color(UIColor { traits in
            let (r, g, b) = components(traits.userInterfaceStyle == .dark ? dark : light)
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        })
        #else
        return Color(NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let (r, g, b) = components(isDark ? dark : light)
            return NSColor(red: r, green: g, blue: b, alpha: 1)
        })
        #endif
    }
}

extension View {
    /// The card surface every Qima widget sits on.
    func qimaBackground() -> some View {
        containerBackground(for: .widget) {
            LinearGradient(colors: [Palette.surfaceTop, Palette.surfaceBottom], startPoint: .top, endPoint: .bottom)
        }
    }
}
