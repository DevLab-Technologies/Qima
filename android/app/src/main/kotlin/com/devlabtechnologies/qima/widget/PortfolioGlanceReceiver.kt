package com.devlabtechnologies.qima.widget

import android.content.Context
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/**
 * Broadcast receiver driving [PortfolioGlanceWidget]. Registered in
 * `AndroidManifest.xml` pointing at `@xml/portfolio_glance_widget_info`.
 */
class PortfolioGlanceReceiver : HomeWidgetGlanceWidgetReceiver<PortfolioGlanceWidget>() {
    override val glanceAppWidget = PortfolioGlanceWidget()

    /** See [PriceGlanceReceiver.onDeleted]. */
    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        appWidgetIds.forEach { WidgetConfigStore.clear(context, it) }
    }
}
