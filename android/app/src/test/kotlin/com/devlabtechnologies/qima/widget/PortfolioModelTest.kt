package com.devlabtechnologies.qima.widget

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * JVM unit tests for [PortfolioModel.resolve], mirroring
 * `PortfolioModel.resolve` in `PortfolioWidget.swift`: value follows
 * historical FX like the app's chart, cost is always at today's (live)
 * rate, and "All" measures gain change from zero rather than the first
 * sample.
 */
class PortfolioModelTest {

    private fun snapshotWith(baseCurrency: String, currencies: String, fxHistory: String, portfolio: String): Snapshot {
        val json = JSONObject(
            """
            {
              "version": 1,
              "updatedAt": 0,
              "hideBalances": false,
              "baseCurrency": "$baseCurrency",
              "currencies": $currencies,
              "fxHistory": $fxHistory,
              "cards": [],
              "instruments": [],
              "portfolio": $portfolio
            }
            """.trimIndent(),
        )
        return Snapshot(json)
    }

    @Test
    fun `value uses the historical rate at each sample, cost uses the live rate`() {
        val snapshot = snapshotWith(
            baseCurrency = "USD",
            currencies = """{"USD": {"rate": 1, "symbol": "$", "suffix": false}, "EGP": {"rate": 50, "symbol": "ج.م", "suffix": true}}""",
            fxHistory = """{"EGP": [[0, 47.0], [1000, 49.0]]}""",
            portfolio = """{
                "available": true,
                "valueUSD": 4000.0,
                "costUSD": 3000.0,
                "holdings": [],
                "series": {"ALL": [[0, 3500.0, 3000.0], [1000, 4000.0, 3000.0]]}
            }""",
        )
        val model = PortfolioModel.resolve(snapshot, "EGP", ChartWindow.ALL)!!

        assertEquals(3500.0 * 47.0, model.points[0].value, 1e-6)
        assertEquals(4000.0 * 49.0, model.points[1].value, 1e-6)
        // Live valuation (not a series point) uses the live rate, 50.
        assertEquals(4000.0 * 50.0, model.value, 1e-6)
    }

    @Test
    fun `gain change for a bounded range is measured from the range's first sample`() {
        val snapshot = snapshotWith(
            baseCurrency = "USD",
            currencies = """{"USD": {"rate": 1, "symbol": "$", "suffix": false}}""",
            fxHistory = "{}",
            portfolio = """{
                "available": true,
                "valueUSD": 4000.0,
                "costUSD": 3000.0,
                "holdings": [],
                "series": {"1M": [[0, 3500.0, 3000.0], [1000, 4000.0, 3000.0]]}
            }""",
        )
        val model = PortfolioModel.resolve(snapshot, null, ChartWindow.MONTH)!!

        // start gain = 3500 - 3000 = 500; end gain = 4000 - 3000 = 1000;
        // delta = 500; invested = start.value + (end.cost - start.cost) = 3500 + 0 = 3500.
        assertEquals(500.0, model.gainDelta!!, 1e-6)
        assertEquals(500.0 / 3500.0, model.gainFraction!!, 1e-9)
    }

    @Test
    fun `gain change for All starts from zero, not the first purchase`() {
        val snapshot = snapshotWith(
            baseCurrency = "USD",
            currencies = """{"USD": {"rate": 1, "symbol": "$", "suffix": false}}""",
            fxHistory = "{}",
            portfolio = """{
                "available": true,
                "valueUSD": 4000.0,
                "costUSD": 3000.0,
                "holdings": [],
                "series": {"ALL": [[0, 3500.0, 3000.0], [1000, 4000.0, 3000.0]]}
            }""",
        )
        val model = PortfolioModel.resolve(snapshot, null, ChartWindow.ALL)!!

        // start = (0, 0); end gain = 4000 - 3000 = 1000; delta = 1000;
        // invested = 0 + (3000 - 0) = 3000.
        assertEquals(1000.0, model.gainDelta!!, 1e-6)
        assertEquals(1000.0 / 3000.0, model.gainFraction!!, 1e-9)
    }

    @Test
    fun `unavailable portfolio resolves to null`() {
        val snapshot = snapshotWith(
            baseCurrency = "USD",
            currencies = """{"USD": {"rate": 1, "symbol": "$", "suffix": false}}""",
            fxHistory = "{}",
            portfolio = """{"available": false}""",
        )
        assertNull(PortfolioModel.resolve(snapshot, null, ChartWindow.ALL))
    }

    @Test
    fun `unknown currency option falls back to the base currency`() {
        val snapshot = snapshotWith(
            baseCurrency = "USD",
            currencies = """{"USD": {"rate": 1, "symbol": "$", "suffix": false}}""",
            fxHistory = "{}",
            portfolio = """{
                "available": true,
                "valueUSD": 100.0,
                "costUSD": 80.0,
                "holdings": [],
                "series": {"ALL": [[0, 100.0, 80.0]]}
            }""",
        )
        val model = PortfolioModel.resolve(snapshot, "NOTREAL", ChartWindow.ALL)!!
        assertEquals("USD", model.currency)
    }
}
