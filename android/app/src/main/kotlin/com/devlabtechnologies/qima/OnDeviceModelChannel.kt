package com.devlabtechnologies.qima

import android.os.Build
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel
import com.google.mlkit.genai.prompt.TextPart
import com.google.mlkit.genai.prompt.generateContentRequest
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull
import org.json.JSONObject

/**
 * The on-device model on Android: Gemini Nano through ML Kit's Prompt API,
 * on phones whose AICore has it. The `ai` channel's Android side, as
 * `OnDeviceModelPlugin.swift` is on Apple's.
 *
 * Only `availability` and `readMessage` are answered; the rest are left to
 * the rules (Dart treats not implemented as "the model said nothing"). The
 * model only copies a message's words: Dart checks each one against the
 * message and takes every figure from the message itself.
 *
 * Messages never leave the phone. ML Kit does send Google usage figures
 * about the API (not the text), which the Play Data safety form declares.
 */
class OnDeviceModelChannel(messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "com.devlabtechnologies.qima/ai")
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    /** ML Kit's GenAI needs Android 8; older phones never load it. */
    private val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
    private var client: GenerativeModel? = null
    private var download: Job? = null

    init {
        channel.setMethodCallHandler(this)
    }

    private fun model(): GenerativeModel = client ?: Generation.getClient().also { client = it }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "availability" -> {
                if (!supported) return result.success("unsupported")
                scope.launch { result.success(status()) }
            }
            "readMessage" -> {
                val text = call.argument<String>("text").orEmpty()
                if (!supported || text.isBlank()) return result.success(null)
                scope.launch { result.success(readMessage(text)) }
            }
            else -> result.notImplemented()
        }
    }

    /** ready, notReady while Gemini Nano downloads (started here), or unsupported. */
    private suspend fun status(): String = try {
        when (model().checkStatus()) {
            FeatureStatus.AVAILABLE -> "ready"
            FeatureStatus.DOWNLOADING -> "notReady"
            FeatureStatus.DOWNLOADABLE -> {
                if (download?.isActive != true) {
                    download = scope.launch {
                        try {
                            model().download().collect {}
                        } catch (_: Exception) {
                            // Tried again on the next check.
                        }
                    }
                }
                "notReady"
            }
            else -> "unsupported"
        }
    } catch (_: Exception) {
        "unsupported"
    }

    /** What one bank message is about, with the exact words of its figures, or null. */
    private suspend fun readMessage(text: String): Map<String, String>? = try {
        val request = generateContentRequest(TextPart(prompt(text.take(1200)))) {
            temperature = 0f
            topK = 1
            maxOutputTokens = 160
        }
        val answer = withTimeoutOrNull(20_000) { model().generateContent(request) }
        answer?.candidates?.firstOrNull()?.text?.let(::labels)
    } catch (_: Exception) {
        null
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        scope.cancel()
        client?.close()
        client = null
    }

    companion object {
        private val INTENTS = listOf(
            "purchase", "refund", "withdrawal", "transferOut", "transferIn", "deposit",
            "fee", "debit", "unknown", "notice", "code", "declined",
        )

        /** The same question the Apple model is asked, with the answer as JSON. */
        fun prompt(message: String): String = """
            You read one text message from a bank, in any language. Say what happened: a purchase, a refund, cash taken out (withdrawal), a transfer sent (transferOut) or received (transferIn), a deposit or salary, a bank fee, another debit, money that moved in an unclear direction (unknown), or nothing moved: a statement or due-date notice, a one-time code, or a declined payment.
            Copy the words of the amount, the balance left and the other side exactly as written. Never change, convert, compute or invent a number.
            Answer with one JSON object and nothing else:
            {"intent": one of ${INTENTS.joinToString(", ")}, "amount": the exact words of the amount that moved with its currency if written, or "", "balance": the exact words of the balance or limit left after it, or "", "name": the exact words naming the merchant or person on the other side, never the person's own card or account, or ""}

            Message:
            $message
        """.trimIndent()

        /** The model's JSON as the channel's map; null when it isn't JSON. */
        fun labels(answer: String): Map<String, String>? {
            val start = answer.indexOf('{')
            val end = answer.lastIndexOf('}')
            if (start < 0 || end <= start) return null
            return try {
                val json = JSONObject(answer.substring(start, end + 1))
                listOf("intent", "amount", "balance", "name").associateWith { json.optString(it, "").trim() }
            } catch (_: Exception) {
                null
            }
        }
    }
}
