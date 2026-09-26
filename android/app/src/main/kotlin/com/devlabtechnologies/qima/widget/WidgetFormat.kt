package com.devlabtechnologies.qima.widget

import androidx.compose.ui.graphics.Color
import androidx.glance.color.ColorProvider
import java.util.Locale
import kotlin.math.abs

/**
 * Small shared helpers for the Glance widgets: day/night color tokens,
 * money/percent formatting and the per-asset-class accent color, ported
 * from `Style.swift`'s `Palette` / `Format` so a widget's numbers and
 * colors match the app and iOS exactly (see [Snapshot], [PriceModel],
 * [PortfolioModel]).
 */

/**
 * Day/night color pairs for the Glance widgets, ported from the same
 * `QimaColors` tokens as the Flutter app (`lib/theme/qima_colors.dart`,
 * spec Figma "Qima DS"). Home-screen widgets follow the OS's own day/night
 * setting rather than the in-app Appearance override (there is no running
 * Flutter UI hosting them to read that preference from), so each token is a
 * `ColorProvider(day, night)` pair and Glance itself picks the right one at
 * render time.
 */
object QimaWidgetColors {
    val surfaceTop = ColorProvider(day = Color(0xFFFFFFFF), night = Color(0xFF1F2229))
    val textPrimary = ColorProvider(day = Color(0xFF111318), night = Color(0xFFFFFFFF))

    // textSecondary/textTertiary are approximated as flat colors rather than
    // an alpha blend over each mode's surface (RemoteViews/Glance text has
    // no reliable "blend over parent" primitive), tuned to read close to the
    // same weight as the app's white@60%/white@52% and #111318@70%/@60%.
    val textSecondary = ColorProvider(day = Color(0xFF4B4E55), night = Color(0xB3FFFFFF))
    val textTertiary = ColorProvider(day = Color(0xFF6B6E75), night = Color(0x85FFFFFF))
    val up = ColorProvider(day = Color(0xFF166B2E), night = Color(0xFF30D158))
    val down = ColorProvider(day = Color(0xFFB42A26), night = Color(0xFFFF6B61))
}

/** Ported from `Palette` in `Style.swift`: one accent color per asset class
 * (and per metal symbol), used for the leading dot and sparkline color. */
object InstrumentPalette {
    private val brand = Color(0xFFE6BA4D)

    fun accent(instrument: Snapshot.InstrumentData): Color = when (instrument.assetClass) {
        "metal" -> when (instrument.symbol) {
            "XAG" -> Color(0xFFC7C7C7)
            "XPT", "XPD" -> Color(0xFFA9C4DD)
            else -> brand
        }
        "crypto" -> Color(0xFFF28C33)
        "fiat" -> Color(0xFF3FB8C9)
        "indices" -> Color(0xFF9975E0)
        else -> Color(0xFF6B8CEB)
    }
}

/** Number/money formatting ported from `Format` in `Style.swift`, matching
 * the app's `Money` type: magnitude-banded decimals, Western digits, and
 * each currency's own fallback symbol and placement (Glance renders with
 * system fonts, which on older OS versions have no glyph for the Saudi
 * Riyal sign -- the iOS extension bundles the app's fonts and can use the
 * real one instead). */
object MoneyFormat {
    private fun fractionDigits(magnitude: Double): Int = when {
        magnitude == 0.0 -> 2
        magnitude < 1 -> 6
        magnitude < 10 -> 4
        else -> 2
    }

    private fun number(value: Double, digits: Int): String =
        String.format(Locale.US, "%,.${digits}f", value)

    /** "$1,234.56", "1,234.56 ج.م". [signed] adds a leading "+" for a
     * positive amount (e.g. a portfolio gain), matching `Format.money`'s
     * `signed` parameter in `Style.swift`. */
    fun format(amount: Double, currency: String, snapshot: Snapshot, whole: Boolean = false, signed: Boolean = false): String {
        val magnitude = abs(amount)
        val digits = if (whole && magnitude >= 1000) 0 else fractionDigits(magnitude)
        val body = number(magnitude, digits)
        val sign = if (amount < 0) "-" else if (signed) "+" else ""
        val info = snapshot.currency(currency)
        val symbol = info?.symbol ?: currency
        return if (info?.suffix == true) {
            "$sign$body $symbol"
        } else {
            val endsWithLetter = symbol.lastOrNull()?.isLetter() ?: false
            "$sign$symbol${if (endsWithLetter) " " else ""}$body"
        }
    }
}

fun trendArrow(isUp: Boolean): String = if (isUp) "▲" else "▼"

/** Formats a already-fractional-percent double (e.g. 5.12 -> "+5.12%"). */
fun formatPercent(percent: Double, isUp: Boolean): String {
    val sign = if (isUp) "+" else ""
    return String.format(Locale.US, "%s%.2f%%", sign, percent)
}
