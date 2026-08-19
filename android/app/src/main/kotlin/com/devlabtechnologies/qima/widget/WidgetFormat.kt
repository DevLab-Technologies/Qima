package com.devlabtechnologies.qima.widget

import androidx.compose.ui.graphics.Color
import org.json.JSONObject

/**
 * Small shared helpers for the Glance widgets. All money/percent/date
 * formatting is already done Dart-side (see `lib/services/home_widget_service.dart`)
 * -- these widgets are pure renderers over the JSON payload it writes, so
 * there is no formatting logic duplicated here beyond picking a trend arrow
 * glyph and clamping a color value.
 */

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
