package com.devlabtechnologies.qima

import com.devlabtechnologies.qima.widget.PriceUnit
import com.devlabtechnologies.qima.widget.Snapshot
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * JVM unit tests for [AssistantAnswers], the Android side of the read-only
 * assistant answers. They must read like `AssistantIntents.swift`'s: priced
 * as the app shows the asset, and nothing about balances while they're
 * hidden.
 */
class AssistantAnswersTest {

    /** The English templates from `tool/widget_strings.json`, positional like the generated resources. */
    private val phrases = object : AssistantAnswers.Phrases {
        private val templates = mapOf(
            R.string.widgetOpenQimaOnceToLoadPrices to "Open Qima once to load prices.",
            R.string.widgetBalancesAreHiddenInQima to "Balances are hidden in Qima.",
            R.string.widgetThereAreNoHoldingsInQimaYet to "There are no holdings in Qima yet.",
            R.string.widgetYourHoldingsAreWorthAGainOfOnWhatYouPaid to "Your holdings are worth %1\$s, a gain of %2\$s on what you paid.",
            R.string.widgetYourHoldingsAreWorthALossOfOnWhatYouPaid to "Your holdings are worth %1\$s, a loss of %2\$s on what you paid.",
            R.string.widgetQimaHasNoPriceForYet to "Qima has no price for %1\$s yet.",
            R.string.widgetIsPer to "%1\$s is %2\$s per %3\$s.",
            R.string.widgetIs to "%1\$s is %2\$s.",
        )
        private val names = mapOf("asset.gold" to "Gold", "asset.bitcoin" to "Bitcoin")

        override fun text(id: Int, vararg args: String): String = String.format(templates.getValue(id), *args)
        override fun name(nameKey: String): String = names[nameKey] ?: nameKey
        override fun karat(karat: Int): String = "${karat}K"
        override fun unitAbbreviation(unit: PriceUnit): String? = when (unit) {
            PriceUnit.TROY_OUNCE -> "oz"
            PriceUnit.GRAM -> "g"
            PriceUnit.KILOGRAM -> "kg"
            PriceUnit.EACH -> null
        }
    }

    private fun snapshot(
        hideBalances: Boolean = false,
        baseCurrency: String = "USD",
        cards: String = "[]",
        portfolio: String = """{"available": false}""",
    ) = Snapshot(
        JSONObject(
            """
            {
              "version": 1,
              "updatedAt": 0,
              "hideBalances": $hideBalances,
              "baseCurrency": "$baseCurrency",
              "currencies": {
                "USD": {"rate": 1, "symbol": "$", "suffix": false},
                "EGP": {"rate": 50, "symbol": "ج.م", "suffix": true}
              },
              "fxHistory": {},
              "cards": $cards,
              "instruments": [
                {
                  "id": "metal.XAU", "symbol": "XAU", "nameKey": "asset.gold", "assetClass": "metal",
                  "units": ["troyOunce", "gram", "kilogram"], "karats": [24, 22, 21, 18],
                  "latest": 3110.34768, "latestAt": 1000.0, "series": {}
                },
                {
                  "id": "crypto.BTC", "symbol": "BTC", "nameKey": "asset.bitcoin", "assetClass": "crypto",
                  "units": ["each"], "karats": [],
                  "latest": 100000.0, "latestAt": 1000.0, "series": {}
                },
                {
                  "id": "stock.GLD", "symbol": "GLD", "nameKey": "Gold ETF", "assetClass": "stock",
                  "units": ["each"], "karats": [],
                  "latest": 290.0, "latestAt": 1000.0, "series": {}
                }
              ],
              "portfolio": $portfolio
            }
            """.trimIndent(),
        ),
    )

    @Test
    fun `without a snapshot both answers ask to open the app`() {
        val answers = AssistantAnswers(null, phrases)
        assertEquals("Open Qima once to load prices.", answers.portfolioValue())
        assertEquals("Open Qima once to load prices.", answers.price("Gold"))
    }

    @Test
    fun `portfolio value is in the base currency with the gain on cost`() {
        val answers = AssistantAnswers(
            snapshot(baseCurrency = "EGP", portfolio = """{"available": true, "valueUSD": 4000.0, "costUSD": 3000.0}"""),
            phrases,
        )
        assertEquals(
            "Your holdings are worth 200,000.00\u00A0ج.م, a gain of 50,000.00\u00A0ج.م on what you paid.",
            answers.portfolioValue(),
        )
    }

    @Test
    fun `a loss is stated as a loss, without a sign`() {
        val answers = AssistantAnswers(
            snapshot(portfolio = """{"available": true, "valueUSD": 2500.0, "costUSD": 3000.0}"""),
            phrases,
        )
        assertEquals("Your holdings are worth $2,500.00, a loss of $500.00 on what you paid.", answers.portfolioValue())
    }

    @Test
    fun `hidden balances are never read out`() {
        val answers = AssistantAnswers(
            snapshot(hideBalances = true, portfolio = """{"available": true, "valueUSD": 4000.0, "costUSD": 3000.0}"""),
            phrases,
        )
        assertEquals("Balances are hidden in Qima.", answers.portfolioValue())
    }

    @Test
    fun `no holdings says so`() {
        assertEquals("There are no holdings in Qima yet.", AssistantAnswers(snapshot(), phrases).portfolioValue())
    }

    @Test
    fun `price uses the first watchlist card's unit, karat and currency`() {
        val cards = """[{"id": "c1", "instrumentID": "metal.XAU", "currency": "EGP", "unit": "gram", "karat": 21}]"""
        val answers = AssistantAnswers(snapshot(cards = cards), phrases)
        // 3110.34768 USD/oz is 100 USD/g; at 21K and 50 EGP/USD, 4,375 EGP/g.
        // A suffix symbol follows a no-break space, as MoneyFormat writes it.
        assertEquals("Gold 21K is 4,375.00\u00A0ج.م per g.", answers.price("gold"))
    }

    @Test
    fun `price without a card uses the default unit in the base currency`() {
        val answers = AssistantAnswers(snapshot(), phrases)
        assertEquals("Gold is $3,110.35 per oz.", answers.price("XAU"))
        assertEquals("Bitcoin is $100,000.00.", answers.price(" btc "))
    }

    @Test
    fun `an exact name wins over a name that only contains it`() {
        val cards = """[{"id": "c1", "instrumentID": "stock.GLD", "currency": "USD", "unit": "each", "karat": null}]"""
        val answers = AssistantAnswers(snapshot(cards = cards), phrases)
        assertEquals("Gold is $3,110.35 per oz.", answers.price("Gold"))
        assertEquals("Gold ETF is $290.00.", answers.price("etf"))
    }

    @Test
    fun `an unknown asset has no price`() {
        val answers = AssistantAnswers(snapshot(), phrases)
        assertEquals("Qima has no price for Dogecoin yet.", answers.price("Dogecoin"))
        assertEquals("Qima has no price for  yet.", answers.price("  "))
    }
}
