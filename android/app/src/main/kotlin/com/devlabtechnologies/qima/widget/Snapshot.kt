package com.devlabtechnologies.qima.widget

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * The data the app publishes for widgets (`WidgetSnapshot` in
 * `lib/services/widget_snapshot.dart`), Kotlin port of `Snapshot.swift`.
 * Prices are canonical USD per troy ounce (or per unit); every conversion
 * below mirrors the app's `PriceConverter` / `PortfolioHistory` rules so a
 * widget and the app never disagree on a number.
 */
class Snapshot(private val json: JSONObject) {

    companion object {
        const val STORAGE_KEY = "widget_snapshot"
        const val SUPPORTED_VERSION = 1

        /** SharedPreferences file `home_widget`'s Dart API writes to
         * (`HomeWidget.saveWidgetData`). `HomeWidgetPlugin.PREFERENCES`
         * holds the same literal but is `internal` to the plugin, so this
         * app module can't reference it directly. */
        private const val HOME_WIDGET_PREFS = "HomeWidgetPreferences"

        /** The last snapshot the app wrote, or null before the first one (or
         * if it was written by an app version this widget can't read). */
        fun load(context: Context): Snapshot? {
            val prefs = context.getSharedPreferences(HOME_WIDGET_PREFS, Context.MODE_PRIVATE)
            val raw = prefs.getString(STORAGE_KEY, null) ?: return null
            if (raw.isBlank()) return null
            return try {
                val obj = JSONObject(raw)
                if (obj.optInt("version", -1) != SUPPORTED_VERSION) null else Snapshot(obj)
            } catch (e: org.json.JSONException) {
                null
            }
        }
    }

    val hideBalances: Boolean get() = json.optBoolean("hideBalances", false)
    val baseCurrency: String get() = json.optString("baseCurrency", "USD")

    data class CurrencyInfo(val rate: Double, val symbol: String, val suffix: Boolean)

    private val currencies: Map<String, CurrencyInfo> by lazy {
        val obj = json.optJSONObject("currencies") ?: JSONObject()
        obj.keys().asSequence().associateWith { code ->
            val info = obj.getJSONObject(code)
            CurrencyInfo(info.optDouble("rate", 1.0), info.optString("symbol", code), info.optBoolean("suffix", false))
        }
    }

    fun currency(code: String): CurrencyInfo? = currencies[code]

    val currencyCodes: List<String> get() = currencies.keys.sorted()

    data class Card(val id: String, val instrumentID: String, val currency: String, val unit: String, val karat: Int?)

    val cards: List<Card> by lazy {
        val array = json.optJSONArray("cards") ?: JSONArray()
        (0 until array.length()).map { i ->
            val obj = array.getJSONObject(i)
            Card(
                id = obj.getString("id"),
                instrumentID = obj.getString("instrumentID"),
                currency = obj.getString("currency"),
                unit = obj.getString("unit"),
                karat = if (obj.isNull("karat")) null else obj.optInt("karat"),
            )
        }
    }

    fun card(id: String): Card? = cards.firstOrNull { it.id == id }

    data class InstrumentData(
        val id: String,
        val symbol: String,
        val nameKey: String,
        val assetClass: String,
        val units: List<String>,
        val karats: List<Int>,
        val latest: Double?,
        val latestAt: Double?,
        val series: Map<String, List<DoubleArray>>,
    )

    val instruments: List<InstrumentData> by lazy {
        val array = json.optJSONArray("instruments") ?: JSONArray()
        (0 until array.length()).map { i ->
            val obj = array.getJSONObject(i)
            val unitsArray = obj.optJSONArray("units") ?: JSONArray()
            val units = (0 until unitsArray.length()).map { unitsArray.getString(it) }
            val karatsArray = obj.optJSONArray("karats") ?: JSONArray()
            val karats = (0 until karatsArray.length()).map { karatsArray.getInt(it) }
            val seriesObj = obj.optJSONObject("series") ?: JSONObject()
            val series = seriesObj.keys().asSequence().associateWith { rangeKey ->
                val points = seriesObj.getJSONArray(rangeKey)
                (0 until points.length()).map { p ->
                    val point = points.getJSONArray(p)
                    doubleArrayOf(point.getDouble(0), point.getDouble(1))
                }
            }
            InstrumentData(
                id = obj.getString("id"),
                symbol = obj.optString("symbol", ""),
                nameKey = obj.optString("nameKey", ""),
                assetClass = obj.optString("assetClass", ""),
                units = units,
                karats = karats,
                latest = if (obj.isNull("latest")) null else obj.optDouble("latest"),
                latestAt = if (obj.isNull("latestAt")) null else obj.optDouble("latestAt"),
                series = series,
            )
        }
    }

    fun instrument(id: String): InstrumentData? = instruments.firstOrNull { it.id == id }

    data class Holding(val instrumentID: String, val valueUSD: Double, val costUSD: Double)

    data class Portfolio(
        val available: Boolean,
        val valueUSD: Double?,
        val costUSD: Double?,
        val holdings: List<Holding>?,
        val series: Map<String, List<DoubleArray>>?,
    )

    val portfolio: Portfolio by lazy {
        val obj = json.optJSONObject("portfolio") ?: JSONObject()
        val available = obj.optBoolean("available", false)
        if (!available) {
            return@lazy Portfolio(false, null, null, null, null)
        }
        val holdingsArray = obj.optJSONArray("holdings") ?: JSONArray()
        val holdings = (0 until holdingsArray.length()).map { i ->
            val h = holdingsArray.getJSONObject(i)
            Holding(h.getString("instrumentID"), h.getDouble("valueUSD"), h.getDouble("costUSD"))
        }
        val seriesObj = obj.optJSONObject("series") ?: JSONObject()
        val series = seriesObj.keys().asSequence().associateWith { rangeKey ->
            val points = seriesObj.getJSONArray(rangeKey)
            (0 until points.length()).map { p ->
                val point = points.getJSONArray(p)
                doubleArrayOf(point.getDouble(0), point.getDouble(1), point.getDouble(2))
            }
        }
        Portfolio(
            available = true,
            valueUSD = obj.optDouble("valueUSD"),
            costUSD = obj.optDouble("costUSD"),
            holdings = holdings,
            series = series,
        )
    }

    /** Live rate: display units per 1 USD. */
    fun liveRate(currency: String): Double? = if (currency == "USD") 1.0 else currencies[currency]?.rate

    private val fxHistory: Map<String, List<DoubleArray>> by lazy {
        val obj = json.optJSONObject("fxHistory") ?: JSONObject()
        obj.keys().asSequence().associateWith { code ->
            val points = obj.getJSONArray(code)
            (0 until points.length()).map { p ->
                val point = points.getJSONArray(p)
                doubleArrayOf(point.getDouble(0), point.getDouble(1))
            }
        }
    }

    /**
     * Rate at [time] (ms): USD is 1; otherwise the most recent history
     * sample at or before the time (the earliest sample for older times);
     * with no history, the live rate -- `PriceConverter.points`' rule.
     */
    fun rate(currency: String, time: Double): Double? {
        if (currency == "USD") return 1.0
        val samples = fxHistory[currency]
        if (samples.isNullOrEmpty()) return liveRate(currency)
        var chosen = samples.first()[1]
        for (sample in samples) {
            if (sample[0] <= time) chosen = sample[1] else break
        }
        return chosen
    }
}

/** Unit a price can be expressed in, matching `PriceUnit` (asset.dart / Snapshot.swift). */
enum class PriceUnit(val rawValue: String) {
    TROY_OUNCE("troyOunce"),
    GRAM("gram"),
    KILOGRAM("kilogram"),
    EACH("each");

    companion object {
        const val GRAMS_PER_TROY_OUNCE = 31.1034768

        fun fromRawValue(value: String?): PriceUnit? = values().firstOrNull { it.rawValue == value }
    }

    val multiplier: Double
        get() = when (this) {
            TROY_OUNCE, EACH -> 1.0
            GRAM -> 1.0 / GRAMS_PER_TROY_OUNCE
            KILOGRAM -> 1000.0 * (1.0 / GRAMS_PER_TROY_OUNCE)
        }
}

/** Selectable chart windows, matching `WidgetSnapshot.ranges` / `ChartWindow`. */
enum class ChartWindow(val id: String) {
    DAY("1D"), WEEK("1W"), MONTH("1M"), QUARTER("3M"), YEAR("1Y"), ALL("ALL");
}

data class ChartPoint(val timeMillis: Double, val value: Double)

/**
 * A range-scoped change, first point to last (spec §8.12: never an all-time
 * figure next to a bounded chart).
 */
class Change private constructor(val absolute: Double, val fraction: Double) {
    val isUp: Boolean get() = fraction >= 0

    companion object {
        fun from(points: List<ChartPoint>): Change? {
            if (points.size < 2) return null
            val first = points.first().value
            val last = points.last().value
            if (first == 0.0) return null
            return Change(last - first, (last - first) / first)
        }
    }
}
