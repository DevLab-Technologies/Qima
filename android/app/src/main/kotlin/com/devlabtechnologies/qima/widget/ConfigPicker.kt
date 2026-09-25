package com.devlabtechnologies.qima.widget

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp

/**
 * One labelled section of single-choice rows -- the building block for every
 * option group in [PriceConfigActivity] / [PortfolioConfigActivity] (asset,
 * unit, karat, currency, range). Mirrors the iOS App Intent pickers'
 * grouping (`AssetQuery`'s "Your watchlist" / "Other assets" sections) with
 * plain Material list rows since there's no native "widget configuration"
 * picker surface on Android the way WidgetKit provides on iOS. The whole
 * screen is one scrolling Column (see the config Activities), so this stays
 * a plain [Column] rather than its own nested lazy list.
 */
@Composable
fun <T> ConfigSection(
    titleRes: Int,
    options: List<T>,
    selected: T,
    label: @Composable (T) -> String,
    onSelect: (T) -> Unit,
) {
    Text(
        text = stringResource(titleRes),
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.primary,
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
    )
    Column(modifier = Modifier.fillMaxWidth()) {
        options.forEach { option ->
            ListItem(
                headlineContent = { Text(label(option)) },
                trailingContent = {
                    RadioButton(selected = option == selected, onClick = { onSelect(option) })
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onSelect(option) },
            )
        }
    }
    HorizontalDivider()
}

/** A message shown instead of the picker when no snapshot has been
 * published yet (empty state, spec item 5). */
@Composable
fun ConfigEmptyState(messageRes: Int) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text(stringResource(messageRes), style = MaterialTheme.typography.bodyMedium)
    }
}
