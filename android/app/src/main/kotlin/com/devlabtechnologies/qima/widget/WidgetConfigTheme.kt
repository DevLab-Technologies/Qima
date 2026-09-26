package com.devlabtechnologies.qima.widget

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/**
 * Material 3 theme for the widgets' configuration Activities, using the same
 * brand/trend tokens as the Glance widgets themselves ([QimaWidgetColors])
 * so the picker doesn't look like a different app. Compose resolves
 * light/dark on its own (`isSystemInDarkTheme`), same as the Glance
 * `ColorProvider` pairs -- there's no in-app Appearance override to read
 * here either, for the same reason noted on [QimaWidgetColors].
 */
@Composable
fun WidgetConfigTheme(content: @Composable () -> Unit) {
    val brand = Color(0xFFE6BA4D)
    val colorScheme = if (isSystemInDarkTheme()) {
        darkColorScheme(primary = brand, secondary = brand)
    } else {
        lightColorScheme(primary = Color(0xFFA87B14), secondary = Color(0xFFA87B14))
    }
    MaterialTheme(colorScheme = colorScheme, content = content)
}
