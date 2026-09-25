package com.devlabtechnologies.qima.widget

import android.content.Context

/**
 * Resolves widget strings by name at runtime, Kotlin equivalent of
 * `L10n.key` / `L10n.karat` in `Style.swift`. Model names the widget shares
 * with the app ("asset.gold", "unit.abbr.gram") are generated from the
 * app's ARB files by `tool/generate_widget_strings.py`; every name this
 * resolves is listed in `res/raw/keep.xml` so release resource shrinking
 * never strips one out from under a lookup that only happens at runtime.
 */
object WidgetStrings {
    /**
     * Resolves a dotted app key ("asset.gold" -> R.string.assetGold). An
     * unknown key comes back as-is, which is right for custom tickers:
     * their `nameKey` is the literal name the user typed.
     */
    fun key(context: Context, dotted: String): String {
        val parts = dotted.split(".")
        val head = parts.firstOrNull() ?: return dotted
        val camel = head + parts.drop(1).joinToString("") { it.replaceFirstChar(Char::uppercase) }
        val id = context.resources.getIdentifier(camel, "string", context.packageName)
        return if (id != 0) context.getString(id) else dotted
    }

    /** "24K" / "٢٤ قيراط" for [karat]. */
    fun karat(context: Context, karat: Int): String = key(context, "karat.short.$karat")

    /** "Troy ounce" / "Gram" / "Kilogram" / "Each" for [unit], matching
     * `PriceUnit.labelKey` (`unit.$name`) in `asset.dart`. */
    fun unitLabel(context: Context, unit: PriceUnit): String = key(context, "unit.${unit.rawValue}")

    /** Abbreviation shown after an amount, e.g. "g"; null for per-unit
     * prices, matching `PriceUnit.abbreviation` in `Snapshot.swift`. */
    fun unitAbbreviation(context: Context, unit: PriceUnit): String? = when (unit) {
        PriceUnit.TROY_OUNCE -> key(context, "unit.abbr.troyOunce")
        PriceUnit.GRAM -> key(context, "unit.abbr.gram")
        PriceUnit.KILOGRAM -> key(context, "unit.abbr.kilogram")
        PriceUnit.EACH -> null
    }

    /** Short label beside a change figure, e.g. "1M". */
    fun rangeShortLabel(context: Context, range: ChartWindow): String = key(context, "range.${range.id}")

    /** Heading above a larger chart, e.g. "Past month". */
    fun rangeHeading(context: Context, range: ChartWindow): String {
        val name = when (range) {
            ChartWindow.DAY -> "widgetPastDay"
            ChartWindow.WEEK -> "widgetPastWeek"
            ChartWindow.MONTH -> "widgetPastMonth"
            ChartWindow.QUARTER -> "widgetPast3Months"
            ChartWindow.YEAR -> "widgetPastYear"
            ChartWindow.ALL -> "widgetAllTime"
        }
        return resolveNamed(context, name)
    }

    /** "Automatic" / "1 day" / etc. picker option label from its
     * `tool/widget_strings.json` slug. */
    fun widgetOnly(context: Context, name: String): String = resolveNamed(context, name)

    private fun resolveNamed(context: Context, name: String): String {
        val id = context.resources.getIdentifier(name, "string", context.packageName)
        return if (id != 0) context.getString(id) else name
    }
}
