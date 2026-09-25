package com.devlabtechnologies.qima.widget

/**
 * The portfolio in one currency over one range, resolved from the
 * [Snapshot] the way the app's portfolio hero computes it. Kotlin port of
 * `PortfolioModel` / `PortfolioModel.resolve` in `PortfolioWidget.swift`.
 */
data class PortfolioModel(
    val currency: String,
    val range: ChartWindow,
    val value: Double,
    val points: List<ChartPoint>,
    /** Change in gain (value minus cost) over the range, so money added
     * mid-range never shows as profit. */
    val gainDelta: Double?,
    val gainFraction: Double?,
) {
    val isUp: Boolean get() = (gainDelta ?: 0.0) >= 0.0

    companion object {
        fun resolve(snapshot: Snapshot, currencyOption: String?, range: ChartWindow): PortfolioModel? {
            val portfolio = snapshot.portfolio
            if (!portfolio.available || portfolio.valueUSD == null) return null

            var currency = snapshot.baseCurrency
            if (currencyOption != null && snapshot.currency(currencyOption) != null) {
                currency = currencyOption
            }
            val liveRate = snapshot.liveRate(currency) ?: return null

            // Value follows historical FX like the app's chart; cost is
            // always at today's rate, as on the Holdings screen.
            val samples = portfolio.series?.get(range.id) ?: emptyList()
            val points = mutableListOf<ChartPoint>()
            val gains = mutableListOf<Pair<Double, Double>>()
            for (sample in samples) {
                val time = sample[0]
                val rate = snapshot.rate(currency, time) ?: continue
                val value = sample[1] * rate
                points.add(ChartPoint(time, value))
                gains.add(value to sample[2] * liveRate)
            }

            // Same rule as the app's PortfolioRangeChange.from: gain change
            // over the money at work (start value plus what was invested
            // during the range); "All" starts from before the first purchase.
            var gainDelta: Double? = null
            var gainFraction: Double? = null
            val first = gains.firstOrNull()
            val last = gains.lastOrNull()
            if (first != null && last != null) {
                val start = if (range == ChartWindow.ALL) 0.0 to 0.0 else first
                val delta = (last.first - last.second) - (start.first - start.second)
                val invested = start.first + (last.second - start.second)
                gainDelta = delta
                gainFraction = if (invested > 0) delta / invested else 0.0
            }

            return PortfolioModel(
                currency = currency,
                range = range,
                value = portfolio.valueUSD * liveRate,
                points = points,
                gainDelta = gainDelta,
                gainFraction = gainFraction,
            )
        }
    }
}
