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
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
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
import com.devlabtechnologies.qima.MainActivity
import com.devlabtechnologies.qima.R
import kotlin.math.max
import kotlin.math.min

/**
 * Home-screen Price widget (Glance port of `PriceWidget.swift`, spec §5.1).
 *
 * Every placed instance is configured on its own via [PriceConfigActivity]
 * (asset, unit, karat, currency, chart range), the same settings iOS's
 * `PriceWidgetIntent` offers. This widget never reads the config store
 * directly, though -- [PriceModel.resolve] (Kotlin port of
 * `PriceModel.resolve` in `PriceWidget.swift`) applies it on top of the
 * shared [Snapshot] so the two platforms price a configuration identically.
 * An instance placed without ever visiting the configuration screen (some
 * launchers skip `android:configure`) falls back to the same defaults as
 * iOS: the first watchlist card, its own currency/unit/karat, 1 month.
 */
class PriceGlanceWidget : GlanceAppWidget() {

    // Glance recomposes per declared size bucket; a price card only needs a
    // "compact vs roomy" distinction so `Single` (fixed layout, we branch on
    // LocalSize ourselves) keeps this simple.
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
                Message(textRes = R.string.widgetOpenQimaToLoadPrices)
                return@Box
            }
            val config = WidgetConfigStore.loadPriceConfig(context, appWidgetId)
            val assetID = config.assetID ?: snapshot.cards.firstOrNull()?.let { PriceModel.CARD_PREFIX + it.id }
            if (assetID == null) {
                Message(textRes = R.string.widgetAddAssetsInQimaToSeeThemHere)
                return@Box
            }
            val model = PriceModel.resolve(
                snapshot = snapshot,
                assetID = assetID,
                unitOption = config.unit,
                karatOption = config.karat,
                karatIsAutomatic = config.karatIsAutomatic,
                currencyOption = config.currency,
                range = config.range,
            )
            if (model == null) {
                Message(textRes = R.string.widgetEditTheWidgetToPickAnAsset)
            } else {
                PriceCard(context, snapshot, model)
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
                style = TextStyle(
                    fontSize = 12.sp,
                    color = QimaWidgetColors.textSecondary,
                    textAlign = androidx.glance.text.TextAlign.Center,
                ),
            )
        }
    }

    @Composable
    private fun PriceCard(context: Context, snapshot: Snapshot, model: PriceModel) {
        val karatLabel = model.karat?.let { WidgetStrings.karat(context, it) } ?: ""
        val unitSuffix = WidgetStrings.unitAbbreviation(context, model.unit) ?: ""
        val name = WidgetStrings.key(context, model.instrument.nameKey)
        val price = MoneyFormat.format(model.price, model.currency, snapshot)
        val change = model.change
        val isUp = change?.isUp ?: true
        val accent = InstrumentPalette.accent(model.instrument)
        val trendColor = if (isUp) QimaWidgetColors.up else QimaWidgetColors.down

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
                    if (karatLabel.isNotBlank()) "$name · $karatLabel" else name,
                    style = TextStyle(
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = QimaWidgetColors.textSecondary,
                    ),
                    maxLines = 1,
                )
            }
            Spacer(modifier = GlanceModifier.height(8.dp))
            Text(
                price,
                style = TextStyle(
                    fontSize = 26.sp,
                    fontWeight = FontWeight.Bold,
                    color = QimaWidgetColors.textPrimary,
                ),
                maxLines = 1,
            )
            if (unitSuffix.isNotBlank()) {
                Text(
                    "per $unitSuffix",
                    style = TextStyle(fontSize = 11.sp, color = QimaWidgetColors.textTertiary),
                )
            }
            Spacer(modifier = GlanceModifier.height(6.dp))
            if (change != null) {
                Text(
                    "${trendArrow(isUp)} ${formatPercent(change.fraction * 100, isUp)} ${WidgetStrings.rangeShortLabel(context, model.range)}",
                    style = TextStyle(
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = trendColor,
                    ),
                    maxLines = 1,
                )
            } else {
                Text("—", style = TextStyle(fontSize = 13.sp, color = QimaWidgetColors.textTertiary))
            }
            Spacer(modifier = GlanceModifier.height(8.dp))
            Sparkline(model.points, accent)
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
    private fun Sparkline(points: List<ChartPoint>, accent: Color) {
        if (points.size < 2) {
            Spacer(modifier = GlanceModifier.height(22.dp))
            return
        }
        val maxBars = 16
        val step = max(1, points.size / maxBars)
        val sampled = points.filterIndexed { index, _ -> index % step == 0 }.map { it.value }
        val minValue = sampled.min()
        val maxValue = sampled.max()
        val range = (maxValue - minValue).let { if (it == 0.0) 1.0 else it }

        Row(
            modifier = GlanceModifier.fillMaxWidth().height(22.dp),
            verticalAlignment = Alignment.Vertical.Bottom,
        ) {
            sampled.forEachIndexed { index, value ->
                val fraction = min(1.0, max(0.05, (value - minValue) / range))
                val barHeight = (4 + fraction * 18).dp
                Box(modifier = GlanceModifier.width(3.dp).height(barHeight).background(accent)) {}
                if (index != sampled.lastIndex) Spacer(modifier = GlanceModifier.width(2.dp))
            }
        }
    }
}
