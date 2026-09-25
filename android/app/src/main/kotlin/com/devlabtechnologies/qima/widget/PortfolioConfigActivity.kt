@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.devlabtechnologies.qima.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
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
 * Native configuration Activity for the Portfolio widget (spec item 3),
 * Android equivalent of iOS's `PortfolioWidgetIntent` picker: currency and
 * chart range. See [PriceConfigActivity] for the shared contract (defaults
 * on skip, reconfigurable via long-press -> Settings, per-`appWidgetId`
 * storage cleaned up in `onDeleted`).
 */
class PortfolioConfigActivity : ComponentActivity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(Activity.RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val snapshot = Snapshot.load(this)
        val saved = WidgetConfigStore.loadPortfolioConfig(this, appWidgetId)

        setContent {
            WidgetConfigTheme {
                Surface {
                    if (snapshot == null) {
                        Scaffold(topBar = { TopAppBar(title = { Text(stringResource(R.string.widgetPortfolio)) }) }) { padding ->
                            Column(modifier = Modifier.padding(padding)) {
                                ConfigEmptyState(R.string.widgetOpenQimaToLoadPrices)
                            }
                        }
                    } else {
                        PortfolioConfigScreen(
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

    private fun save(config: WidgetConfigStore.PortfolioConfig) {
        WidgetConfigStore.savePortfolioConfig(this, appWidgetId, config)

        val result = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(Activity.RESULT_OK, result)

        lifecycleScope.launch {
            try {
                // See PriceConfigActivity.save: the host may not have bound
                // this appWidgetId to a Glance instance yet at
                // first-placement time.
                val glanceId = GlanceAppWidgetManager(this@PortfolioConfigActivity).getGlanceIdBy(appWidgetId)
                PortfolioGlanceWidget().update(this@PortfolioConfigActivity, glanceId)
            } catch (e: IllegalArgumentException) {
                // No bound GlanceId for this appWidgetId yet -- nothing to redraw.
            } finally {
                finish()
            }
        }
    }
}

@Composable
private fun PortfolioConfigScreen(
    context: android.content.Context,
    snapshot: Snapshot,
    saved: WidgetConfigStore.PortfolioConfig,
    onSave: (WidgetConfigStore.PortfolioConfig) -> Unit,
) {
    var selectedCurrency by remember { mutableStateOf(saved.currency) }
    var selectedRange by remember { mutableStateOf(saved.range) }
    val currencies = listOf<String?>(null) + snapshot.currencyCodes

    Scaffold(
        topBar = { TopAppBar(title = { Text(stringResource(R.string.widgetPortfolio)) }) },
        bottomBar = {
            Button(
                onClick = { onSave(WidgetConfigStore.PortfolioConfig(currency = selectedCurrency, range = selectedRange)) },
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
        ) {
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
