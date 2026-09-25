package com.devlabtechnologies.qima

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * `local_auth`'s Android implementation requires a `FragmentActivity` host
 * (it shows the biometric prompt via `androidx.biometric`), so `MainActivity`
 * is a [FlutterFragmentActivity] rather than the default `FlutterActivity`
 * (spec Phase 4 "App lock").
 *
 * Also hosts a small platform channel that toggles `FLAG_SECURE` — set
 * whenever app lock or hide-balances is on, so the OS recents thumbnail and
 * screenshots never capture a portfolio amount. Dart calls this from
 * `LockGate` whenever either setting (or the locked/hidden state) changes.
 *
 * And the `system_settings` channel `SystemSettings` (Dart) uses to open
 * Qima's notification settings from the "Notifications are off" banner.
 */
class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.devlabtechnologies.qima/privacy"
    private val systemSettingsChannelName = "com.devlabtechnologies.qima/system_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecure" -> {
                    val secure = call.argument<Boolean>("secure") ?: false
                    if (secure) {
                        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, systemSettingsChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    startActivity(notificationSettingsIntent())
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Qima's notification settings (Android 8+), else its app info page. */
    private fun notificationSettingsIntent(): Intent =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null))
        }
}
