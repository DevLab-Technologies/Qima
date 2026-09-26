@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.devlabtechnologies.qima.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.lifecycle.lifecycleScope
import com.devlabtechnologies.qima.R
import kotlinx.coroutines.launch

/**
 * Native configuration Activity for the Price widget (spec item 3), Android
 * equivalent of iOS's `PriceWidgetIntent` picker. Launched by the OS when a
 * user places a new instance (`android:configure` in
 * `price_glance_widget_info.xml`) and again from long-press -> Settings on
 * Android 12+ (`widgetFeatures="reconfigurable"`), pre-filled with whatever
 * is already stored for this `appWidgetId`.
 *
 * Placing a widget without ever opening this screen (a launcher can skip
 * `android:configure` on some OEMs) must still produce a working widget, so
 * [PriceGlanceWidget] applies the same "first card / base currency / 1M"
 * defaults as iOS whenever a setting is unconfigured -- see
 * `PriceWidgetConfig.resolve`.
 */
class PriceConfigActivity : ComponentActivity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Cancelled unless Save is tapped, per the App Widget configuration
        // contract: the host only keeps the widget if RESULT_OK comes back.
        setResult(Activity.RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val snapshot = Snapshot.load(this)
        val saved = WidgetConfigStore.loadPriceConfig(this, appWidgetId)

        setContent {
            WidgetConfigTheme {
                Surface {
                    if (snapshot == null) {
                        EmptySnapshotScreen()
                    } else {
                        PriceConfigScreen(
                            context = this,
                            snapshot = snapshot,
                            saved = saved,
                            onSave = { config -> save(config) },
                        )
                    }
                }
            }
        }
    }

    private fun save(config: WidgetConfigStore.PriceConfig) {
        WidgetConfigStore.savePriceConfig(this, appWidgetId, config)

        val result = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(Activity.RESULT_OK, result)

        lifecycleScope.launch {
            try {
                // The host hasn't necessarily bound this appWidgetId to a
                // Glance instance yet at first-placement time (the OS calls
                // this configure Activity before the provider's onUpdate),
                // so a missing GlanceId here is expected, not an error --
                // the placement flow's own update still redraws it.
                val glanceId = GlanceAppWidgetManager(this@PriceConfigActivity).getGlanceIdBy(appWidgetId)
                PriceGlanceWidget().update(this@PriceConfigActivity, glanceId)
            } catch (e: IllegalArgumentException) {
                // No bound GlanceId for this appWidgetId yet -- nothing to redraw.
            } finally {
                finish()
            }
        }
    }
}

@Composable
private fun EmptySnapshotScreen() {
    Scaffold(topBar = { TopAppBar(title = { Text(stringResource(R.string.widgetPrice)) }) }) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            ConfigEmptyState(R.string.widgetOpenQimaToLoadPrices)
        }
    }
}

/** "card:<id>" or "instrument:<id>", the same asset id scheme as iOS's
 * `AssetEntity`. */
private const val CARD_PREFIX = PriceModel.CARD_PREFIX
private const val INSTRUMENT_PREFIX = PriceModel.INSTRUMENT_PREFIX

private data class AssetOption(val id: String, val instrument: Snapshot.InstrumentData, val card: Snapshot.Card?)

@Composable
private fun PriceConfigScreen(
    context: android.content.Context,
    snapshot: Snapshot,
    saved: WidgetConfigStore.PriceConfig,
    onSave: (WidgetConfigStore.PriceConfig) -> Unit,
) {
    val cardOptions = snapshot.cards.mapNotNull { card ->
        snapshot.instrument(card.instrumentID)?.let { AssetOption(CARD_PREFIX + card.id, it, card) }
    }
    val cardedInstrumentIDs = snapshot.cards.map { it.instrumentID }.toSet()
    val otherOptions = snapshot.instruments
        .filter { it.id !in cardedInstrumentIDs }
        .map { AssetOption(INSTRUMENT_PREFIX + it.id, it, null) }
    val allOptions = cardOptions + otherOptions

    if (allOptions.isEmpty()) {
        EmptySnapshotScreen()
        return
    }

    var selectedAsset by remember { mutableStateOf(allOptions.firstOrNull { it.id == saved.assetID } ?: allOptions.first()) }
    var selectedUnit by remember { mutableStateOf(saved.unit) }
    var karatIsAutomatic by remember { mutableStateOf(saved.karatIsAutomatic) }
    var selectedKarat by remember { mutableStateOf(saved.karat) }
    var selectedCurrency by remember { mutableStateOf(saved.currency) }
    var selectedRange by remember { mutableStateOf(saved.range) }

    val units = selectedAsset.instrument.units.mapNotNull(PriceUnit::fromRawValue)
    val karats = selectedAsset.instrument.karats
    val currencies = listOf<String?>(null) + snapshot.currencyCodes

    Scaffold(
        topBar = { TopAppBar(title = { Text(stringResource(R.string.widgetPrice)) }) },
        bottomBar = {
            Button(
                onClick = {
                    onSave(
                        WidgetConfigStore.PriceConfig(
                            assetID = selectedAsset.id,
                            unit = selectedUnit,
                            karat = selectedKarat,
                            karatIsAutomatic = karatIsAutomatic,
                            currency = selectedCurrency,
                            range = selectedRange,
                        ),
                    )
                },
                modifier = Modifier.fillMaxWidth().padding(16.dp),
            ) {
                Text(stringResource(R.string.widgetSave))
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.Top,
        ) {
            ConfigSection(
                titleRes = R.string.widgetAsset,
                options = allOptions,
                selected = selectedAsset,
                label = { assetLabel(context, it) },
                onSelect = { option ->
                    selectedAsset = option
                    // Switching asset drops choices the new one doesn't
                    // support, same as the app's own card editor.
                    if (selectedUnit != null && option.instrument.units.none { it == selectedUnit?.rawValue }) {
                        selectedUnit = null
                    }
                    if (option.instrument.karats.isEmpty()) {
                        karatIsAutomatic = true
                        selectedKarat = null
                    } else if (selectedKarat != null && selectedKarat !in option.instrument.karats) {
                        selectedKarat = null
                        karatIsAutomatic = true
                    }
                },
            )
            if (units.size > 1) {
                ConfigSection(
                    titleRes = R.string.widgetUnit,
                    options = listOf<PriceUnit?>(null) + units,
                    selected = selectedUnit,
                    label = { unit -> unit?.let { WidgetStrings.unitLabel(context, it) } ?: WidgetStrings.widgetOnly(context, "widgetAutomatic") },
                    onSelect = { selectedUnit = it },
                )
            }
            if (karats.isNotEmpty()) {
                ConfigSection(
                    titleRes = R.string.widgetKarat,
                    options = listOf<Int?>(null) + karats,
                    selected = if (karatIsAutomatic) null else selectedKarat,
                    label = { karat -> karat?.let { WidgetStrings.karat(context, it) } ?: WidgetStrings.widgetOnly(context, "widgetAutomatic") },
                    onSelect = { karat ->
                        karatIsAutomatic = karat == null
                        selectedKarat = karat
                    },
                )
            }
            ConfigSection(
                titleRes = R.string.widgetCurrency,
                options = currencies,
                selected = selectedCurrency,
                label = { code -> code ?: WidgetStrings.widgetOnly(context, "widgetAutomatic") },
                onSelect = { selectedCurrency = it },
            )
            ConfigSection(
                titleRes = R.string.widgetChartRange,
                options = ChartWindow.values().toList(),
                selected = selectedRange,
                label = { WidgetStrings.rangeShortLabel(context, it) },
                onSelect = { selectedRange = it },
            )
        }
    }
}

private fun assetLabel(context: android.content.Context, option: AssetOption): String {
    val name = WidgetStrings.key(context, option.instrument.nameKey)
    return option.card?.karat?.let { "$name ${WidgetStrings.karat(context, it)}" } ?: name
}
