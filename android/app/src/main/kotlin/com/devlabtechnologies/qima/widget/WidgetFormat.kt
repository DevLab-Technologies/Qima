package com.devlabtechnologies.qima.widget

import androidx.compose.ui.graphics.Color
import androidx.glance.color.ColorProvider
import org.json.JSONObject

/**
 * Small shared helpers for the Glance widgets. All money/percent/date
 * formatting is already done Dart-side (see `lib/services/home_widget_service.dart`)
 * -- these widgets are pure renderers over the JSON payload it writes, so
 * there is no formatting logic duplicated here beyond picking a trend arrow
 * glyph and clamping a color value.
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

/** Reads [key] out of [prefs] as a JSON object, or null if absent/blank/malformed. */
fun readJson(prefs: android.content.SharedPreferences, key: String): JSONObject? {
    val raw = prefs.getString(key, null) ?: return null
    if (raw.isBlank()) return null
    return try {
        JSONObject(raw)
    } catch (e: org.json.JSONException) {
        null
    }
}

/** Converts an ARGB32 int (as produced by Flutter's `Color.toARGB32()`) to a Compose [Color]. */
fun argbColor(value: Int, fallback: Color = Color(0xFFE6BA4D)): Color {
    return try {
        Color(value)
    } catch (e: Exception) {
        fallback
    }
}

fun trendArrow(isUp: Boolean): String = if (isUp) "▲" else "▼"

/** Formats a already-fractional-percent double (e.g. 0.0512 -> "5.12%"). */
fun formatPercent(percent: Double, isUp: Boolean): String {
    val sign = if (isUp) "+" else ""
    return String.format("%s%.2f%%", sign, percent)
}
