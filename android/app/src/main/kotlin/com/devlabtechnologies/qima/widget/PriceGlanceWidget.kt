package com.devlabtechnologies.qima.widget

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.devlabtechnologies.qima.MainActivity
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import org.json.JSONObject

/**
 * Home-screen Price widget (Glance port of `PriceWidget.swift`, spec §5.1).
 *
 * This pass does not have an Android "Configuration Activity" wired up yet,
 * so every placed instance shows the SAME instrument: whichever watchlist
 * card is first (see `HomeWidgetService._priceSnapshot`). A future pass can
 * add per-instance configuration by giving this class a real config
 * activity and keying the read below by `GlanceId`/`appWidgetId` instead of
 * always reading the single shared `price_widget_data` key.
 */
class PriceGlanceWidget : GlanceAppWidget() {

    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    // Glance recomposes per declared size bucket; a price card only needs a
    // "compact vs roomy" distinction so `Single` (fixed layout, we branch on
    // LocalSize ourselves) keeps this simple.
    override val sizeMode = SizeMode.Single

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content(context, currentState()) }
    }

    @Composable
    private fun Content(context: Context, state: HomeWidgetGlanceState) {
        val json = readJson(state.preferences, "price_widget_data")
        val cardBg = Color(0xFF1C1F27)

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(cardBg)
                .padding(14.dp)
                .clickable(onClick = actionStartActivity(Intent(context, MainActivity::class.java)))
        ) {
            if (json == null || !json.optBoolean("available", false)) {
                NoData(json)
            } else {
                PriceCard(json)
            }
        }
    }

    @Composable
    private fun NoData(json: JSONObject?) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            verticalAlignment = Alignment.Vertical.CenterVertically,
        ) {
            Text(
                json?.optString("symbol").takeUnless { it.isNullOrBlank() } ?: "—",
                style = TextStyle(
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(Color.White),
                ),
            )
            Spacer(modifier = GlanceModifier.height(4.dp))
            Text(
                "No data yet",
                style = TextStyle(fontSize = 12.sp, color = ColorProvider(Color(0xB3FFFFFF))),
            )
        }
    }

    @Composable
    private fun PriceCard(json: JSONObject) {
        val symbol = json.optString("symbol", "")
        val karatLabel = json.optString("karatLabel", "")
        val unitSuffix = json.optString("unitSuffix", "")
        val price = json.optString("price", "—")
        val hasChange = json.optBoolean("hasChange", false)
        val isUp = json.optBoolean("isUp", true)
        val changePercent = json.optDouble("changePercent", 0.0)
        val accent = argbColor(json.optInt("accentColor", 0xFFE6BA4D.toInt()))
        val trendColor = if (isUp) Color(0xFF30D158) else Color(0xFFFF453A)
        val sparkline = json.optJSONArray("sparkline")

        Column(modifier = GlanceModifier.fillMaxSize()) {
            Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                Box(
                    modifier = GlanceModifier
                        .width(8.dp)
                        .height(8.dp)
                        .background(accent)
                ) {}
                Spacer(modifier = GlanceModifier.width(6.dp))
                Text(
                    if (karatLabel.isNotBlank()) "$symbol · $karatLabel" else symbol,
                    style = TextStyle(
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = ColorProvider(Color(0xB3FFFFFF)),
                    ),
                )
            }
            Spacer(modifier = GlanceModifier.height(8.dp))
            Text(
                price,
                style = TextStyle(
                    fontSize = 26.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(Color.White),
                ),
            )
            if (unitSuffix.isNotBlank()) {
                Text(
                    "per $unitSuffix",
                    style = TextStyle(fontSize = 11.sp, color = ColorProvider(Color(0x99FFFFFF))),
                )
            }
            Spacer(modifier = GlanceModifier.height(6.dp))
            if (hasChange) {
                Text(
                    "${trendArrow(isUp)} ${formatPercent(changePercent, isUp)}",
                    style = TextStyle(
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = ColorProvider(trendColor),
                    ),
                )
            } else {
                Text("—", style = TextStyle(fontSize = 13.sp, color = ColorProvider(Color(0x66FFFFFF))))
            }
            Spacer(modifier = GlanceModifier.height(8.dp))
            Sparkline(sparkline, accent)
        }
    }

    /**
     * Bar-chart approximation of the sparkline curve: Glance widgets render
     * to RemoteViews, which has no arbitrary path/canvas drawing API, so a
     * true bezier sparkline (as in the SwiftUI original) isn't reproducible
     * here. A row of height-scaled bars reads the same trend shape at a
     * glance, which is the actual goal of the sparkline in this widget.
     */
    @Composable
    private fun Sparkline(points: org.json.JSONArray?, accent: Color) {
        if (points == null || points.length() < 2) {
            Spacer(modifier = GlanceModifier.height(22.dp))
            return
        }
        val maxBars = 16
        val step = maxOf(1, points.length() / maxBars)
        val sampled = mutableListOf<Double>()
        var i = 0
        while (i < points.length()) {
            sampled.add(points.optDouble(i, 0.0))
            i += step
        }
        val min = sampled.min()
        val max = sampled.max()
        val range = (max - min).let { if (it == 0.0) 1.0 else it }

        Row(
            modifier = GlanceModifier.fillMaxWidth().height(22.dp),
            verticalAlignment = Alignment.Vertical.Bottom,
        ) {
            sampled.forEachIndexed { index, value ->
                val fraction = ((value - min) / range).coerceIn(0.05, 1.0)
                val barHeight = (4 + fraction * 18).dp
                Box(modifier = GlanceModifier.width(3.dp).height(barHeight).background(accent)) {}
                if (index != sampled.lastIndex) Spacer(modifier = GlanceModifier.width(2.dp))
            }
        }
    }
}
