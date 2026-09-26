package com.devlabtechnologies.qima.widget

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import com.devlabtechnologies.qima.MainActivity
import com.devlabtechnologies.qima.R

/**
 * Home-screen Portfolio widget (Glance port of `PortfolioWidget.swift`,
 * spec §5.2). Every placed instance is configured on its own via
 * [PortfolioConfigActivity] (currency, chart range), applied on top of the
 * shared [Snapshot] by [PortfolioModel.resolve] the same way iOS's
 * `PortfolioWidgetIntent` does. Unconfigured falls back to the base
 * currency over all time, matching iOS's defaults.
 */
class PortfolioGlanceWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Single

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        provideContent { Content(context, appWidgetId) }
    }

    @Composable
    private fun Content(context: Context, appWidgetId: Int) {
        val snapshot = Snapshot.load(context)

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(QimaWidgetColors.surfaceTop)
                .padding(14.dp)
                .clickable(onClick = actionStartActivity(Intent(context, MainActivity::class.java)))
        ) {
            if (snapshot == null) {
                Message(R.string.widgetOpenQimaToLoadPrices)
                return@Box
            }
            val config = WidgetConfigStore.loadPortfolioConfig(context, appWidgetId)
            val model = PortfolioModel.resolve(snapshot, config.currency, config.range)
            if (model == null) {
                Message(R.string.widgetAddHoldingsInQimaToSeeYourPortfolio)
            } else {
                PortfolioCard(context, snapshot, model)
            }
        }
    }

    @Composable
    private fun Message(textRes: Int) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            verticalAlignment = Alignment.Vertical.CenterVertically,
        ) {
            Text(
                androidx.glance.LocalContext.current.getString(textRes),
                style = TextStyle(fontSize = 12.sp, color = QimaWidgetColors.textSecondary, textAlign = TextAlign.Center),
            )
        }
    }

    @Composable
    private fun PortfolioCard(context: Context, snapshot: Snapshot, model: PortfolioModel) {
        val hidden = snapshot.hideBalances
        val value = if (hidden) MASK else MoneyFormat.format(model.value, model.currency, snapshot)
        val isUp = model.isUp
        val trendColor = if (isUp) QimaWidgetColors.up else QimaWidgetColors.down
        val gainDelta = model.gainDelta
        val gainFraction = model.gainFraction

        Column(modifier = GlanceModifier.fillMaxSize()) {
            Text(
                androidx.glance.LocalContext.current.getString(R.string.portfolioTitle),
                style = TextStyle(
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = QimaWidgetColors.textSecondary,
                ),
            )
            Spacer(modifier = GlanceModifier.height(6.dp))
            Text(
                value,
                style = TextStyle(
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = QimaWidgetColors.textPrimary,
                ),
                maxLines = 1,
            )
            Spacer(modifier = GlanceModifier.height(6.dp))
            if (gainDelta != null && gainFraction != null) {
                val changeText = if (hidden) {
                    formatPercent(gainFraction * 100, isUp)
                } else {
                    "${MoneyFormat.format(gainDelta, model.currency, snapshot, signed = true)} · ${formatPercent(gainFraction * 100, isUp)}"
                }
                Text(
                    "${trendArrow(isUp)} $changeText",
                    style = TextStyle(
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = trendColor,
                    ),
                    maxLines = 1,
                )
            }
        }
    }

    private companion object {
        const val MASK = "••••••"
    }
}
