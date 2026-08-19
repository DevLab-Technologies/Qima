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
import androidx.glance.layout.Column
import androidx.glance.layout.Box
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.devlabtechnologies.qima.MainActivity
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import org.json.JSONObject

/**
 * Home-screen Portfolio widget (Glance port of `PortfolioWidget.swift`,
 * spec §5.2). Every instance currently shows the SAME snapshot — the
 * user's base currency valuation (see `HomeWidgetService._publishPortfolio`)
 * — because there is no Android configuration-activity flow wired up yet
 * for a per-instance currency choice.
 */
class PortfolioGlanceWidget : GlanceAppWidget() {

    override val stateDefinition = HomeWidgetGlanceStateDefinition()
    override val sizeMode = SizeMode.Single

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content(context, currentState()) }
    }

    @Composable
    private fun Content(context: Context, state: HomeWidgetGlanceState) {
        val json = readJson(state.preferences, "portfolio_widget_data")
        val cardBg = Color(0xFF1C1F27)

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(cardBg)
                .padding(14.dp)
                .clickable(onClick = actionStartActivity(Intent(context, MainActivity::class.java)))
        ) {
            if (json == null || !json.optBoolean("available", false)) {
                EmptyState()
            } else {
                PortfolioCard(json)
            }
        }
    }

    @Composable
    private fun EmptyState() {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            verticalAlignment = Alignment.Vertical.CenterVertically,
        ) {
            Text(
                "Portfolio",
                style = TextStyle(fontSize = 13.sp, color = ColorProvider(Color(0xB3FFFFFF))),
            )
            Spacer(modifier = GlanceModifier.height(4.dp))
            Text(
                "Add your first lot",
                style = TextStyle(fontSize = 13.sp, color = ColorProvider(Color(0x99FFFFFF))),
            )
        }
    }

    @Composable
    private fun PortfolioCard(json: JSONObject) {
        val value = json.optString("value", "—")
        val gain = json.optString("gain", "")
        val isUp = json.optBoolean("isUp", true)
        val percent = json.optDouble("percent", 0.0)
        val trendColor = if (isUp) Color(0xFF30D158) else Color(0xFFFF453A)

        Column(modifier = GlanceModifier.fillMaxSize()) {
            Text(
                "Portfolio",
                style = TextStyle(
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = ColorProvider(Color(0xB3FFFFFF)),
                ),
            )
            Spacer(modifier = GlanceModifier.height(6.dp))
            Text(
                value,
                style = TextStyle(
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(Color.White),
                ),
            )
            Spacer(modifier = GlanceModifier.height(6.dp))
            Text(
                "${trendArrow(isUp)} ${formatPercent(percent, isUp)} · $gain",
                style = TextStyle(
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = ColorProvider(trendColor),
                ),
            )
        }
    }
}
