package com.devlabtechnologies.qima

import android.Manifest
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.UUID

/**
 * Bank text messages into Qima's import inbox (`FolderInbox` in Dart, the
 * app's files folder), one inbox item per message marked `kind: message`.
 * Qima reads them like any shared file and the person checks them in
 * review; a message with no transaction in it is dropped there unseen.
 *
 * Only messages that look like money (a figure and a currency or a banking
 * word) are kept, and never one-time codes. Nothing happens until the
 * person turns it on in Qima and grants the SMS permission.
 */
object BankSms {
    private const val PREFS = "qima_bank_sms"
    private const val ENABLED = "enabled"

    private val money = Regex(
        "\\b(SAR|EGP|AED|USD|EUR|GBP|KWD|QAR|BHD|OMR|JOD|SR|LE)\\b|ر\\.?\\s?س|ريال|ج\\.?\\s?م|جنيه|درهم|دينار|" +
            "debit|credit|purchase|withdraw|deposit|transfer|payment|paid|spent|balance|refund|salary|" +
            "خصم|شراء|سحب|إيداع|ايداع|تحويل|حوالة|دفع|سداد|رصيد|راتب|استرداد",
        RegexOption.IGNORE_CASE,
    )
    private val figure = Regex("[0-9٠-٩]")
    private val oneTimeCode = Regex(
        "\\b(OTP|one[- ]time|verification code|passcode|activation code|do not share)\\b|رمز التحقق|كلمة المرور|رمز التفعيل|لا تشارك",
        RegexOption.IGNORE_CASE,
    )

    fun looksLikeMoney(body: String): Boolean =
        figure.containsMatchIn(body) && money.containsMatchIn(body) && !oneTimeCode.containsMatchIn(body)

    fun isEnabled(context: Context): Boolean =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(ENABLED, false)

    fun setEnabled(context: Context, on: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(ENABLED, on).apply()
    }

    fun hasPermission(context: Context, permission: String): Boolean =
        ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED

    /** Writes [body] into the inbox the way the share extension does: under a dotted name, renamed once complete. */
    fun add(context: Context, body: String, at: Long) {
        val inbox = File(context.filesDir, "import_inbox").apply { mkdirs() }
        val id = UUID.randomUUID().toString()
        val staging = File(inbox, ".$id").apply { mkdirs() }
        val name = "Bank message.txt"
        File(staging, name).writeText(body.trim())
        val iso = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply { timeZone = TimeZone.getTimeZone("UTC") }
        val meta = JSONObject().put("name", name).put("receivedAt", iso.format(Date(at))).put("kind", "message")
        File(staging, "meta.json").writeText(meta.toString())
        staging.renameTo(File(inbox, id))
    }

    /** Money messages in the SMS inbox from the last [days] days, oldest first; how many were added. */
    fun importRecent(context: Context, days: Int): Int {
        if (!hasPermission(context, Manifest.permission.READ_SMS)) return 0
        val since = System.currentTimeMillis() - days * 24L * 60 * 60 * 1000
        var added = 0
        context.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(Telephony.Sms.BODY, Telephony.Sms.DATE),
            "${Telephony.Sms.DATE} >= ?",
            arrayOf(since.toString()),
            "${Telephony.Sms.DATE} ASC",
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val body = cursor.getString(0) ?: continue
                if (!looksLikeMoney(body)) continue
                add(context, body, cursor.getLong(1))
                added++
            }
        }
        return added
    }
}

/** New SMS, while the person has bank messages on. */
class BankSmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION || !BankSms.isEnabled(context)) return
        // A long message arrives in parts, all from one sender.
        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        for ((_, pieces) in parts.groupBy { it.originatingAddress }) {
            val body = pieces.joinToString("") { it.messageBody ?: "" }
            if (BankSms.looksLikeMoney(body)) BankSms.add(context, body, pieces.first().timestampMillis)
        }
    }
}

/** The `sms` channel `BankMessages` (Dart) uses to turn it on and off and to bring in recent messages. */
class BankSmsChannel(private val activity: Activity, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    companion object {
        const val PERMISSION_REQUEST = 4208
    }

    private var pending: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, "com.devlabtechnologies.qima/sms").setMethodCallHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> result.success(status())
            "enable" -> {
                if (granted()) {
                    BankSms.setEnabled(activity, true)
                    result.success(status())
                } else if (pending == null) {
                    pending = result
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
                        PERMISSION_REQUEST,
                    )
                } else {
                    result.error("busy", "A permission request is already showing", null)
                }
            }
            "disable" -> {
                BankSms.setEnabled(activity, false)
                result.success(status())
            }
            "importRecent" -> {
                val days = call.argument<Int>("days") ?: 60
                Thread { val n = BankSms.importRecent(activity, days); activity.runOnUiThread { result.success(n) } }.start()
            }
            else -> result.notImplemented()
        }
    }

    fun onPermissionResult() {
        val result = pending ?: return
        pending = null
        if (granted()) BankSms.setEnabled(activity, true)
        result.success(status())
    }

    private fun granted() =
        BankSms.hasPermission(activity, Manifest.permission.RECEIVE_SMS) && BankSms.hasPermission(activity, Manifest.permission.READ_SMS)

    private fun status() = mapOf("granted" to granted(), "enabled" to (granted() && BankSms.isEnabled(activity)))
}
