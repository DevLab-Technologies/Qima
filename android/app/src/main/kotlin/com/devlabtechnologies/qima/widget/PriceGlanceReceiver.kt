package com.devlabtechnologies.qima.widget

import android.content.Context
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/**
 * Broadcast receiver the OS uses to drive [PriceGlanceWidget] (update
 * ticks, resize, pin/remove). Registered in `AndroidManifest.xml` pointing
 * at `@xml/price_glance_widget_info`. `home_widget`'s
 * `HomeWidget.updateWidget(androidName: ...)` call from Dart targets this
 * class by its fully-qualified name.
 */
class PriceGlanceReceiver : HomeWidgetGlanceWidgetReceiver<PriceGlanceWidget>() {
    override val glanceAppWidget = PriceGlanceWidget()

    /** A removed instance's per-`appWidgetId` settings (asset, unit, karat,
     * currency, range) are cleared so a future widget id never inherits a
     * stranger's config. */
    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        appWidgetIds.forEach { WidgetConfigStore.clear(context, it) }
    }
}
