package com.devlabtechnologies.qima.widget

import android.content.Context
import android.content.SharedPreferences

/**
 * Per-`appWidgetId` settings for the Price and Portfolio widgets, the
 * Android equivalent of iOS's `PriceWidgetIntent` / `PortfolioWidgetIntent`.
 * Stored in its own SharedPreferences file (never the `home_widget` plugin's
 * own store, which only ever holds the single shared [Snapshot]), keyed by
 * widget id so multiple placed instances configure independently.
 *
 * A key missing entirely means "unconfigured" (placed with defaults, or
 * never configured because the OS skipped the picker): [PriceGlanceWidget]
 * falls back to the first watchlist card (and its own unit/karat/currency)
 * when [PriceConfig.assetID] is null, and [PortfolioGlanceWidget] falls
 * back to the base currency when [PortfolioConfig.currency] is null --
 * [PriceModel.resolve] / [PortfolioModel.resolve] apply those the same way
 * `.automatic` does in the iOS App Intents.
 */
object WidgetConfigStore {
    private const val PREFS_NAME = "qima_widget_config"

    private const val KEY_ASSET = "asset"
    private const val KEY_UNIT = "unit"
    private const val KEY_KARAT = "karat"
    private const val KEY_CURRENCY = "currency"
    private const val KEY_RANGE = "range"

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private fun prefixed(appWidgetId: Int, key: String) = "$appWidgetId.$key"

    data class PriceConfig(
        val assetID: String?,
        val unit: PriceUnit?,
        val karat: Int?,
        val karatIsAutomatic: Boolean,
        val currency: String?,
        val range: ChartWindow,
    )

    fun savePriceConfig(context: Context, appWidgetId: Int, config: PriceConfig) {
        prefs(context).edit().apply {
            if (config.assetID != null) putString(prefixed(appWidgetId, KEY_ASSET), config.assetID) else remove(prefixed(appWidgetId, KEY_ASSET))
            if (config.unit != null) putString(prefixed(appWidgetId, KEY_UNIT), config.unit.rawValue) else remove(prefixed(appWidgetId, KEY_UNIT))
            if (!config.karatIsAutomatic && config.karat != null) {
                putInt(prefixed(appWidgetId, KEY_KARAT), config.karat)
            } else {
                remove(prefixed(appWidgetId, KEY_KARAT))
            }
            if (config.currency != null) putString(prefixed(appWidgetId, KEY_CURRENCY), config.currency) else remove(prefixed(appWidgetId, KEY_CURRENCY))
            putString(prefixed(appWidgetId, KEY_RANGE), config.range.id)
            apply()
        }
    }

    fun loadPriceConfig(context: Context, appWidgetId: Int): PriceConfig {
        val p = prefs(context)
        val karat = if (p.contains(prefixed(appWidgetId, KEY_KARAT))) p.getInt(prefixed(appWidgetId, KEY_KARAT), 24) else null
        return PriceConfig(
            assetID = p.getString(prefixed(appWidgetId, KEY_ASSET), null),
            unit = PriceUnit.fromRawValue(p.getString(prefixed(appWidgetId, KEY_UNIT), null)),
            karat = karat,
            karatIsAutomatic = karat == null,
            currency = p.getString(prefixed(appWidgetId, KEY_CURRENCY), null),
            range = ChartWindow.values().firstOrNull { it.id == p.getString(prefixed(appWidgetId, KEY_RANGE), null) }
                ?: ChartWindow.MONTH,
        )
    }

    data class PortfolioConfig(val currency: String?, val range: ChartWindow)

    fun savePortfolioConfig(context: Context, appWidgetId: Int, config: PortfolioConfig) {
        prefs(context).edit().apply {
            if (config.currency != null) putString(prefixed(appWidgetId, KEY_CURRENCY), config.currency) else remove(prefixed(appWidgetId, KEY_CURRENCY))
            putString(prefixed(appWidgetId, KEY_RANGE), config.range.id)
            apply()
        }
    }

    fun loadPortfolioConfig(context: Context, appWidgetId: Int): PortfolioConfig {
        val p = prefs(context)
        return PortfolioConfig(
            currency = p.getString(prefixed(appWidgetId, KEY_CURRENCY), null),
            range = ChartWindow.values().firstOrNull { it.id == p.getString(prefixed(appWidgetId, KEY_RANGE), null) }
                ?: ChartWindow.ALL,
        )
    }

    /** Clears everything stored for [appWidgetId] (all keys, either config
     * kind); called from `onDeleted` so a removed/re-added widget id never
     * inherits stale settings. */
    fun clear(context: Context, appWidgetId: Int) {
        prefs(context).edit().apply {
            remove(prefixed(appWidgetId, KEY_ASSET))
            remove(prefixed(appWidgetId, KEY_UNIT))
            remove(prefixed(appWidgetId, KEY_KARAT))
            remove(prefixed(appWidgetId, KEY_CURRENCY))
            remove(prefixed(appWidgetId, KEY_RANGE))
            apply()
        }
    }
}
