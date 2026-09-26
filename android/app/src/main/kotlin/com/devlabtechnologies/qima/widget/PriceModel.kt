package com.devlabtechnologies.qima.widget

/**
 * One configured price widget, resolved against the latest [Snapshot].
 * Kotlin port of `PriceModel` / `PriceModel.resolve` in `PriceWidget.swift`.
 */
data class PriceModel(
    val instrument: Snapshot.InstrumentData,
    val currency: String,
    val unit: PriceUnit,
    val karat: Int?,
    val range: ChartWindow,
    val price: Double,
    val points: List<ChartPoint>,
    val change: Change?,
    val updatedAtMillis: Double?,
) {
    companion object {
        const val CARD_PREFIX = "card:"
        const val INSTRUMENT_PREFIX = "instrument:"

        /**
         * One asset ("card:<id>" or "instrument:<id>") priced with the given
         * overrides; a null unit/karat/currency option keeps the card's own
         * settings ("Automatic").
         */
        fun resolve(
            snapshot: Snapshot,
            assetID: String,
            unitOption: PriceUnit?,
            karatOption: Int?,
            karatIsAutomatic: Boolean,
            currencyOption: String?,
            range: ChartWindow,
        ): PriceModel? {
            val card: Snapshot.Card?
            val instrumentID: String
            if (assetID.startsWith(CARD_PREFIX)) {
                card = snapshot.card(assetID.removePrefix(CARD_PREFIX)) ?: return null
                instrumentID = card.instrumentID
            } else {
                card = null
                instrumentID = assetID.removePrefix(INSTRUMENT_PREFIX)
            }
            val instrument = snapshot.instrument(instrumentID) ?: return null

            var unit = card?.let { PriceUnit.fromRawValue(it.unit) }
                ?: instrument.units.firstOrNull()?.let(PriceUnit::fromRawValue)
                ?: PriceUnit.EACH
            if (unitOption != null && instrument.units.contains(unitOption.rawValue)) {
                unit = unitOption
            }

            val karat = if (instrument.karats.isEmpty()) {
                null
            } else if (!karatIsAutomatic) {
                karatOption
            } else {
                card?.karat
            }
            val purity = (karat ?: 24).toDouble() / 24.0

            var currency = card?.currency ?: snapshot.baseCurrency
            if (currencyOption != null && snapshot.currency(currencyOption) != null) {
                currency = currencyOption
            }

            val latest = instrument.latest ?: return null
            val liveRate = snapshot.liveRate(currency) ?: return null
            val factor = unit.multiplier * purity
            val samples = instrument.series[range.id] ?: emptyList()
            val points = samples.mapNotNull { sample ->
                val time = sample[0]
                val value = sample[1]
                val rate = snapshot.rate(currency, time) ?: return@mapNotNull null
                ChartPoint(time, value * rate * factor)
            }

            return PriceModel(
                instrument = instrument,
                currency = currency,
                unit = unit,
                karat = karat,
                range = range,
                price = latest * liveRate * factor,
                points = points,
                change = Change.from(points),
                updatedAtMillis = instrument.latestAt,
            )
        }
    }
}
