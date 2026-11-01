package com.devlabtechnologies.qima

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * On-device speech to text for `PlatformDictation` (Dart). Only the
 * on-device recognizer (Android 12+) is used, so audio never goes to a
 * server; a phone or language without one reports "unsupported" and the
 * mic stays off.
 */
class DictationChannel(private val activity: Activity, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val PERMISSION_REQUEST = 4207
    }

    private var recognizer: SpeechRecognizer? = null
    private var sink: EventChannel.EventSink? = null
    private var pendingLocale: String? = null
    private var lastText = ""

    init {
        MethodChannel(messenger, "com.devlabtechnologies.qima/dictation").setMethodCallHandler(this)
        EventChannel(messenger, "com.devlabtechnologies.qima/dictation/events").setStreamHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "availability" -> availability(call.argument<String>("locale") ?: "") { result.success(it) }
            "stop" -> {
                recognizer?.stopListening()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun hasPermission() =
        ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED

    private fun availability(tag: String, done: (String) -> Unit) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || !SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)) {
            return done("unsupported")
        }
        // Asked once and refused for good: the system won't prompt again.
        if (!hasPermission() && wasPermanentlyDenied()) return done("denied")
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return done("available")
        checkLanguage(tag, done)
    }

    private fun wasPermanentlyDenied(): Boolean {
        val prefs = activity.getSharedPreferences("dictation", Activity.MODE_PRIVATE)
        return prefs.getBoolean("asked", false) &&
            !ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.RECORD_AUDIO)
    }

    /** Whether the on-device recognizer has [tag]'s language installed. */
    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun checkLanguage(tag: String, done: (String) -> Unit) {
        val probe = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
        probe.checkRecognitionSupport(
            intentFor(tag),
            ContextCompat.getMainExecutor(activity),
            object : RecognitionSupportCallback {
                override fun onSupportResult(support: RecognitionSupport) {
                    val language = tag.substringBefore('-')
                    val installed = support.installedOnDeviceLanguages.any { it.substringBefore('-') == language }
                    probe.destroy()
                    done(if (installed) "available" else "unsupported")
                }

                override fun onError(error: Int) {
                    probe.destroy()
                    done("unsupported")
                }
            },
        )
    }

    private fun intentFor(tag: String) = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        putExtra(RecognizerIntent.EXTRA_LANGUAGE, tag)
        putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        val tag = (arguments as? Map<*, *>)?.get("locale") as? String ?: ""
        if (hasPermission()) return start(tag)
        pendingLocale = tag
        activity.getSharedPreferences("dictation", Activity.MODE_PRIVATE).edit().putBoolean("asked", true).apply()
        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.RECORD_AUDIO), PERMISSION_REQUEST)
    }

    override fun onCancel(arguments: Any?) {
        teardown()
        sink = null
    }

    /** Forwarded from `MainActivity.onRequestPermissionsResult`. */
    fun onPermissionResult(granted: Boolean) {
        val tag = pendingLocale ?: return
        pendingLocale = null
        if (granted) start(tag) else fail("denied")
    }

    private fun start(tag: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || !SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)) {
            return fail("unsupported")
        }
        lastText = ""
        val recognizer = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
        this.recognizer = recognizer
        recognizer.setRecognitionListener(object : RecognitionListener {
            override fun onPartialResults(partialResults: Bundle) {
                val text = partialResults.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull() ?: return
                lastText = text
                sink?.success(mapOf("type" to "partial", "text" to text))
            }

            override fun onResults(results: Bundle) {
                val text = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull() ?: lastText
                end(mapOf("type" to "final", "text" to text))
            }

            override fun onError(error: Int) {
                when (error) {
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> fail("denied")
                    SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED,
                    SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE -> fail("unsupported")
                    // Silence or no match: whatever was heard still counts.
                    else -> end(mapOf("type" to "final", "text" to lastText))
                }
            }

            override fun onReadyForSpeech(params: Bundle?) {}
            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {}
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
        recognizer.startListening(intentFor(tag))
    }

    private fun end(event: Map<String, String>) {
        val sink = sink ?: return
        teardown()
        sink.success(event)
        sink.endOfStream()
        this.sink = null
    }

    private fun fail(code: String) = end(mapOf("type" to "error", "code" to code))

    private fun teardown() {
        recognizer?.destroy()
        recognizer = null
    }
}
