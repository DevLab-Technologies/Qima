package com.devlabtechnologies.qima.widget

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * JVM unit tests for [PriceModel.resolve] against a hand-built [Snapshot],
 * covering the conversion rules `WidgetSnapshot`'s doc comment calls out:
 * unit multiplier, karat purity, the FX rate at a point in time, and
 * range-scoped change (first point to last of the chosen range). These
 * numbers must match `lib/services/price_converter.dart` and
 * `ios/QimaWidget/PriceWidget.swift` exactly.
 */
class PriceModelTest {

    private fun snapshotWith(
        baseCurrency: String = "USD",
        currencies: String = """{"USD": {"rate": 1, "symbol": "$", "suffix": false}}""",
        fxHistory: String = "{}",
        cards: String = "[]",
        instruments: String,
        portfolio: String = """{"available": false}""",
    ): Snapshot {
        val json = JSONObject(
            """
            {
              "version": 1,
              "updatedAt": 0,
              "hideBalances": false,
              "baseCurrency": "$baseCurrency",
              "currencies": $currencies,
              "fxHistory": $fxHistory,
              "cards": $cards,
              "instruments": $instruments,
              "portfolio": $portfolio
            }
            """.trimIndent(),
        )
        // `Snapshot.load` reads from SharedPreferences (Android-only, not
        // available under a plain JVM unit test), so tests build a Snapshot
        // directly from the same JSON shape instead.
        return Snapshot(json)
    }

    private val goldInstrument = """
        [{
          "id": "metal.XAU",
          "symbol": "XAU",
          "nameKey": "asset.gold",
          "assetClass": "metal",
          "units": ["troyOunce", "gram", "kilogram"],
          "karats": [24, 22, 21, 18],
          "latest": 2000.0,
          "latestAt": 1000.0,
          "series": {
            "1D": [[0, 1900.0], [1000, 2000.0]],
            "1M": [[0, 1800.0], [500, 1900.0], [1000, 2000.0]]
          }
        }]
    """.trimIndent()

    @Test
    fun `troy ounce price at karat 24 uses the live rate and full purity`() {
        val snapshot = snapshotWith(instruments = goldInstrument)
        val model = PriceModel.resolve(
            snapshot = snapshot,
            assetID = "instrument:metal.XAU",
            unitOption = PriceUnit.TROY_OUNCE,
            karatOption = 24,
            karatIsAutomatic = false,
            currencyOption = "USD",
            range = ChartWindow.DAY,
        )
        assertNotNull(model)
        assertEquals(2000.0, model!!.price, 1e-9)
    }

    @Test
    fun `gram conversion divides by grams-per-troy-ounce exactly`() {
        val snapshot = snapshotWith(instruments = goldInstrument)
        val model = PriceModel.resolve(
            snapshot = snapshot,
            assetID = "instrument:metal.XAU",
            unitOption = PriceUnit.GRAM,
            karatOption = 24,
            karatIsAutomatic = false,
            currencyOption = "USD",
            range = ChartWindow.DAY,
        )
        val expected = 2000.0 * (1.0 / PriceUnit.GRAMS_PER_TROY_OUNCE)
        assertEquals(expected, model!!.price, 1e-9)
    }

    @Test
    fun `kilogram is exactly 1000 times the gram price`() {
        val snapshot = snapshotWith(instruments = goldInstrument)
        val gram = PriceModel.resolve(
            snapshot, "instrument:metal.XAU", PriceUnit.GRAM, 24, false, "USD", ChartWindow.DAY,
        )!!
        val kilogram = PriceModel.resolve(
            snapshot, "instrument:metal.XAU", PriceUnit.KILOGRAM, 24, false, "USD", ChartWindow.DAY,
        )!!
        assertEquals(kilogram.price, gram.price * 1000, 1e-6)
    }

    @Test
    fun `karat purity scales the price by karat over 24`() {
        val snapshot = snapshotWith(instruments = goldInstrument)
        val k24 = PriceModel.resolve(snapshot, "instrument:metal.XAU", PriceUnit.TROY_OUNCE, 24, false, "USD", ChartWindow.DAY)!!
        val k18 = PriceModel.resolve(snapshot, "instrument:metal.XAU", PriceUnit.TROY_OUNCE, 18, false, "USD", ChartWindow.DAY)!!
        assertEquals(k24.price * (18.0 / 24.0), k18.price, 1e-9)
    }

    @Test
    fun `automatic karat falls back to the card's own karat`() {
        val snapshot = snapshotWith(
            instruments = goldInstrument,
            cards = """[{"id": "c1", "instrumentID": "metal.XAU", "currency": "USD", "unit": "gram", "karat": 21}]""",
        )
        val model = PriceModel.resolve(
            snapshot = snapshot,
            assetID = "card:c1",
            unitOption = null,
            karatOption = null,
            karatIsAutomatic = true,
            currencyOption = null,
            range = ChartWindow.DAY,
        )
        assertEquals(21, model!!.karat)
        assertEquals(PriceUnit.GRAM, model.unit)
    }

    @Test
    fun `rate at a point in time uses the most recent FX sample at or before it`() {
        // EGP history: 47 at t=0, 48 at t=500, 49 at t=1000; USD amounts
        // scale by whichever sample is current at each series point's time.
        val snapshot = snapshotWith(
            currencies = """{
                "USD": {"rate": 1, "symbol": "${'$'}", "suffix": false},
                "EGP": {"rate": 50, "symbol": "ج.م", "suffix": true}
            }""",
            fxHistory = """{"EGP": [[0, 47.0], [500, 48.0], [1000, 49.0]]}""",
            instruments = goldInstrument,
        )
        val model = PriceModel.resolve(
            snapshot = snapshot,
            assetID = "instrument:metal.XAU",
            unitOption = PriceUnit.TROY_OUNCE,
            karatOption = 24,
            karatIsAutomatic = false,
            currencyOption = "EGP",
            range = ChartWindow.MONTH,
        )!!
        // Points at t=0/500/1000 use EGP rate 47/48/49 respectively (an
        // exact sample match, not the live rate 50).
        assertEquals(1800.0 * 47.0, model.points[0].value, 1e-6)
        assertEquals(1900.0 * 48.0, model.points[1].value, 1e-6)
        assertEquals(2000.0 * 49.0, model.points[2].value, 1e-6)
        // The live price (not a series point) uses the LIVE rate, 50.
        assertEquals(2000.0 * 50.0, model.price, 1e-6)
    }

    @Test
    fun `rate before the earliest sample holds the earliest sample flat`() {
        val snapshot = snapshotWith(
            currencies = """{"USD": {"rate": 1, "symbol": "${'$'}", "suffix": false}, "EGP": {"rate": 50, "symbol": "ج.م", "suffix": true}}""",
            fxHistory = """{"EGP": [[500, 48.0], [1000, 49.0]]}""",
            instruments = goldInstrument,
        )
        assertEquals(48.0, snapshot.rate("EGP", 0.0)!!, 1e-9)
        assertEquals(48.0, snapshot.rate("EGP", 500.0)!!, 1e-9)
        assertEquals(49.0, snapshot.rate("EGP", 1000.0)!!, 1e-9)
        assertEquals(49.0, snapshot.rate("EGP", 5000.0)!!, 1e-9, )
    }

    @Test
    fun `range-scoped change is first point to last point of the chosen range, not all-time`() {
        val snapshot = snapshotWith(instruments = goldInstrument)
        val day = PriceModel.resolve(snapshot, "instrument:metal.XAU", PriceUnit.TROY_OUNCE, 24, false, "USD", ChartWindow.DAY)!!
        val month = PriceModel.resolve(snapshot, "instrument:metal.XAU", PriceUnit.TROY_OUNCE, 24, false, "USD", ChartWindow.MONTH)!!

        // 1D series is [1900, 2000] -> +5.26%; 1M series is [1800, 2000] -> +11.11%.
        assertEquals((2000.0 - 1900.0) / 1900.0, day.change!!.fraction, 1e-9)
        assertEquals((2000.0 - 1800.0) / 1800.0, month.change!!.fraction, 1e-9)
    }

    @Test
    fun `unsupported unit falls back to the instrument's default unit`() {
        val snapshot = snapshotWith(instruments = goldInstrument)
        val model = PriceModel.resolve(
            snapshot = snapshot,
            assetID = "instrument:metal.XAU",
            unitOption = PriceUnit.EACH, // not in this instrument's supported units
            karatOption = 24,
            karatIsAutomatic = false,
            currencyOption = "USD",
            range = ChartWindow.DAY,
        )!!
        assertEquals(PriceUnit.TROY_OUNCE, model.unit)
    }

    @Test
    fun `unknown asset id resolves to null`() {
        val snapshot = snapshotWith(instruments = goldInstrument)
        val model = PriceModel.resolve(
            snapshot = snapshot,
            assetID = "instrument:does-not-exist",
            unitOption = null,
            karatOption = null,
            karatIsAutomatic = true,
            currencyOption = null,
            range = ChartWindow.DAY,
        )
        assertNull(model)
    }
}
