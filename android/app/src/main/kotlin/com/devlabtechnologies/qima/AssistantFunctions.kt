package com.devlabtechnologies.qima

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.appfunctions.AppFunctionDeclaration
import androidx.appfunctions.AppFunctionService
import androidx.appfunctions.AppFunctionServiceEntryPoint
import com.devlabtechnologies.qima.widget.ChartWindow
import com.devlabtechnologies.qima.widget.MoneyFormat
import com.devlabtechnologies.qima.widget.PriceModel
import com.devlabtechnologies.qima.widget.PriceUnit
import com.devlabtechnologies.qima.widget.Snapshot
import com.devlabtechnologies.qima.widget.WidgetStrings
import kotlin.math.abs
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Read-only answers for the system assistant on Android 16 and later (v4
 * phase 5), the counterpart of `AssistantIntents.swift`. Both read the
 * snapshot the app publishes for its widgets and price with the widgets'
 * rules, so an answer matches what the widget and the app show. Nothing
 * here writes or reaches the network: an assistant can't show Qima's
 * check-before-saving step, so recording stays in the app.
 *
 * The compiler generates `QimaAssistantService` from this class and
 * `assets/qima_assistant.xml` from the KDoc below; both are declared in
 * `AndroidManifest.xml`.
 */
@RequiresApi(Build.VERSION_CODES.BAKLAVA)
@AppFunctionServiceEntryPoint(serviceName = "QimaAssistantService", appFunctionXmlFileName = "qima_assistant")
abstract class AssistantFunctions : AppFunctionService() {
    /**
     * What the user's holdings tracked in Qima are worth now, in their base
     * currency, with the gain or loss on what they paid. Returns a sentence
     * to show or read out, or says that balances are hidden when the user
     * hides them in Qima.
     */
    @AppFunctionDeclaration(isDescribedByKDoc = true)
    suspend fun getPortfolioValue(): String =
        withContext(Dispatchers.IO) { answers().portfolioValue() }

    /**
     * Today's price of an asset tracked in Qima, in the unit, karat and
     * currency the app shows it in. Returns a sentence to show or read out.
     *
     * @param asset The asset's name or symbol, such as "Gold", "XAU" or "Bitcoin".
     */
    @AppFunctionDeclaration(isDescribedByKDoc = true)
    suspend fun getPrice(asset: String): String =
        withContext(Dispatchers.IO) { answers().price(asset) }

    /** Read on each call, so an answer reflects the latest snapshot. */
    private fun answers() = AssistantAnswers(Snapshot.load(this), AssistantAnswers.Phrases.of(this))
}

/**
 * The answers, apart from the service so they can be checked on the JVM
 * with a hand-built [Snapshot]. A null [snapshot] means the app hasn't
 * published one yet.
 */
class AssistantAnswers(private val snapshot: Snapshot?, private val phrases: Phrases) {
    /** Where the answers' words come from: the app's string resources. */
    interface Phrases {
        fun text(id: Int, vararg args: String): String
        fun name(nameKey: String): String
        fun karat(karat: Int): String
        fun unitAbbreviation(unit: PriceUnit): String?

        companion object {
            fun of(context: Context) = object : Phrases {
                override fun text(id: Int, vararg args: String): String = context.getString(id, *args)
                override fun name(nameKey: String): String = WidgetStrings.key(context, nameKey)
                override fun karat(karat: Int): String = WidgetStrings.karat(context, karat)
                override fun unitAbbreviation(unit: PriceUnit): String? = WidgetStrings.unitAbbreviation(context, unit)
            }
        }
    }

    fun portfolioValue(): String {
        val snapshot = snapshot ?: return phrases.text(R.string.widgetOpenQimaOnceToLoadPrices)
        // Hiding balances in the app hides them from the assistant too.
        if (snapshot.hideBalances) return phrases.text(R.string.widgetBalancesAreHiddenInQima)
        val portfolio = snapshot.portfolio
        val valueUSD = portfolio.valueUSD
        val rate = snapshot.liveRate(snapshot.baseCurrency)
        if (!portfolio.available || valueUSD == null || rate == null) {
            return phrases.text(R.string.widgetThereAreNoHoldingsInQimaYet)
        }
        val gain = (valueUSD - (portfolio.costUSD ?: valueUSD)) * rate
        val value = MoneyFormat.format(valueUSD * rate, snapshot.baseCurrency, snapshot)
        val gainText = MoneyFormat.format(abs(gain), snapshot.baseCurrency, snapshot)
        val template = if (gain >= 0) {
            R.string.widgetYourHoldingsAreWorthAGainOfOnWhatYouPaid
        } else {
            R.string.widgetYourHoldingsAreWorthALossOfOnWhatYouPaid
        }
        return phrases.text(template, value, gainText)
    }

    fun price(query: String): String {
        val snapshot = snapshot ?: return phrases.text(R.string.widgetOpenQimaOnceToLoadPrices)
        val wanted = query.trim()
        val instrument = match(snapshot, wanted)
            ?: return phrases.text(R.string.widgetQimaHasNoPriceForYet, wanted)

        // As the app shows it: its first watchlist card's unit, karat and
        // currency, else its default unit in the base currency.
        val card = snapshot.cards.firstOrNull { it.instrumentID == instrument.id }
        val assetID = card?.let { PriceModel.CARD_PREFIX + it.id } ?: (PriceModel.INSTRUMENT_PREFIX + instrument.id)
        var name = phrases.name(instrument.nameKey)
        val model = PriceModel.resolve(snapshot, assetID, null, null, true, null, ChartWindow.DAY)
            ?: return phrases.text(R.string.widgetQimaHasNoPriceForYet, name)
        model.karat?.let { name += " " + phrases.karat(it) }
        val amount = MoneyFormat.format(model.price, model.currency, snapshot)
        val unit = phrases.unitAbbreviation(model.unit)
        return if (unit != null) {
            phrases.text(R.string.widgetIsPer, name, amount, unit)
        } else {
            phrases.text(R.string.widgetIs, name, amount)
        }
    }

    /**
     * The instrument [wanted] names: an exact symbol or name first, then a
     * name or symbol containing it, watchlist cards' assets before the rest
     * as in `AssistantAssetQuery`.
     */
    private fun match(snapshot: Snapshot, wanted: String): Snapshot.InstrumentData? {
        if (wanted.isEmpty()) return null
        val carded = snapshot.cards.map { it.instrumentID }
        val ordered = snapshot.instruments.sortedBy { carded.indexOf(it.id).let { i -> if (i < 0) Int.MAX_VALUE else i } }
        val named = ordered.map { it to phrases.name(it.nameKey) }
        return named.firstOrNull { (instrument, name) ->
            instrument.symbol.equals(wanted, ignoreCase = true) || name.equals(wanted, ignoreCase = true)
        }?.first ?: named.firstOrNull { (instrument, name) ->
            name.contains(wanted, ignoreCase = true) || instrument.symbol.contains(wanted, ignoreCase = true)
        }?.first
    }
}
