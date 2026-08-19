package com.devlabtechnologies.qima.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/**
 * Broadcast receiver driving [PortfolioGlanceWidget]. Registered in
 * `AndroidManifest.xml` pointing at `@xml/portfolio_glance_widget_info`.
 */
class PortfolioGlanceReceiver : HomeWidgetGlanceWidgetReceiver<PortfolioGlanceWidget>() {
    override val glanceAppWidget = PortfolioGlanceWidget()
}
