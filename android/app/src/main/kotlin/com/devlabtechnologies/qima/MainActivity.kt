package com.devlabtechnologies.qima

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
 */
class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.devlabtechnologies.qima/privacy"

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
    }
}
