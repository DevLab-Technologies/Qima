package com.devlabtechnologies.qima

import android.Manifest
import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.security.MessageDigest
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
 * person grants the SMS permission; from then on Qima reads new messages
 * unless they turn it off. Each one is saved with its sender, so Qima can
 * tell which bank (and account) it is from.
 *
 * Messages arrive two ways, and the same message is never kept twice:
 * [BankSmsReceiver] as they come, and [catchUp] each time Qima opens, for
 * any the receiver missed (the app was force-stopped, or the phone's
 * battery saver held the broadcast back).
 */
object BankSms {
    private const val PREFS = "qima_bank_sms"
    private const val ENABLED = "enabled"
    private const val LAST_SEEN = "lastSeen"
    private const val RECENT = "recent"
    private const val WAITING = "waiting"
    private const val TITLE = "notificationTitle"
    private const val BODY = "notificationBody"
    private const val CHANNEL = "bank_messages"
    private const val NOTIFICATION_ID = 4209
    const val OPEN_REVIEW = "com.devlabtechnologies.qima.OPEN_IMPORT_REVIEW"

    /** How long the same text from the same sender counts as the same message. */
    private const val SAME_MESSAGE_MS = 10 * 60 * 1000L

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

    private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /** On unless the person turned it off; it still needs the permission. */
    fun isEnabled(context: Context): Boolean = prefs(context).getBoolean(ENABLED, true)

    fun setEnabled(context: Context, on: Boolean) {
        val edit = prefs(context).edit().putBoolean(ENABLED, on)
        // Turned on: new messages from now; older ones come in through
        // "Bring in the last 60 days".
        if (on && prefs(context).getLong(LAST_SEEN, 0L) == 0L) edit.putLong(LAST_SEEN, System.currentTimeMillis())
        edit.apply()
    }

    private fun markSeen(context: Context, at: Long) {
        val p = prefs(context)
        if (at > p.getLong(LAST_SEEN, 0L)) p.edit().putLong(LAST_SEEN, at).apply()
    }

    /**
     * Whether the same text from the same sender was kept moments ago (the
     * receiver and [catchUp] both saw it); remembers this one if not.
     */
    @Synchronized
    private fun seenRecently(context: Context, sender: String?, body: String, at: Long): Boolean {
        val digest = MessageDigest.getInstance("SHA-256").digest("${sender ?: ""}\n${body.trim()}".toByteArray())
        val key = digest.joinToString("") { "%02x".format(it) }.take(32)
        val p = prefs(context)
        val recent = JSONObject(p.getString(RECENT, "{}") ?: "{}")
        val now = System.currentTimeMillis()
        val keys = recent.keys().asSequence().toList()
        for (k in keys) if (now - recent.optLong(k) > 2 * 24 * 60 * 60 * 1000L) recent.remove(k)
        val before = recent.optLong(key, -1L)
        val seen = before >= 0 && kotlin.math.abs(at - before) < SAME_MESSAGE_MS
        if (!seen) recent.put(key, at)
        p.edit().putString(RECENT, recent.toString()).apply()
        return seen
    }

    fun hasPermission(context: Context, permission: String): Boolean =
        ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED

    /**
     * Writes [body] into the inbox the way the share extension does: under a
     * dotted name, renamed once complete. False when it was kept already.
     */
    fun add(context: Context, body: String, at: Long, sender: String?): Boolean {
        if (seenRecently(context, sender, body, at)) return false
        val inbox = File(context.filesDir, "import_inbox").apply { mkdirs() }
        val id = UUID.randomUUID().toString()
        val staging = File(inbox, ".$id").apply { mkdirs() }
        val name = "Bank message.txt"
        File(staging, name).writeText(body.trim())
        val iso = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply { timeZone = TimeZone.getTimeZone("UTC") }
        val meta = JSONObject().put("name", name).put("receivedAt", iso.format(Date(at))).put("kind", "message")
        if (!sender.isNullOrBlank()) meta.put("sender", sender.trim())
        File(staging, "meta.json").writeText(meta.toString())
        staging.renameTo(File(inbox, id))
        return true
    }

    /** Money messages in the SMS inbox from the last [days] days, oldest first; how many were added. */
    fun importRecent(context: Context, days: Int): Int =
        readSince(context, System.currentTimeMillis() - days * 24L * 60 * 60 * 1000)

    /**
     * Money messages that came since Qima last looked and that the receiver
     * didn't keep; how many were added. Nothing while reading is off.
     */
    fun catchUp(context: Context): Int {
        if (!isEnabled(context)) return 0
        val since = prefs(context).getLong(LAST_SEEN, 0L)
        if (since == 0L) {
            markSeen(context, System.currentTimeMillis())
            return 0
        }
        return readSince(context, since + 1)
    }

    private fun readSince(context: Context, since: Long): Int {
        if (!hasPermission(context, Manifest.permission.READ_SMS)) return 0
        var added = 0
        var newest = 0L
        context.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(Telephony.Sms.BODY, Telephony.Sms.DATE, Telephony.Sms.ADDRESS),
            "${Telephony.Sms.DATE} >= ?",
            arrayOf(since.toString()),
            "${Telephony.Sms.DATE} ASC",
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val at = cursor.getLong(1)
                newest = maxOf(newest, at)
                val body = cursor.getString(0) ?: continue
                if (!looksLikeMoney(body)) continue
                if (add(context, body, at, cursor.getString(2))) added++
            }
        }
        if (newest > 0) markSeen(context, newest)
        return added
    }

    /** A new message from the receiver: kept, then counted on the notification. */
    fun received(context: Context, body: String, at: Long, sender: String?) {
        // The SMS store dates a message when it lands; so does this.
        markSeen(context, System.currentTimeMillis())
        if (!add(context, body, at, sender)) return
        val p = prefs(context)
        p.edit().putInt(WAITING, p.getInt(WAITING, 0) + 1).apply()
        notifyWaiting(context)
    }

    /** The notification's words in the app's language, given by Qima (Dart). */
    fun setNotificationText(context: Context, title: String, body: String) {
        prefs(context).edit().putString(TITLE, title).putString(BODY, body).apply()
    }

    /**
     * "Bank messages to check": no amounts or names, as on the lock screen
     * anyone can read it. One notification, however many wait.
     */
    private fun notifyWaiting(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            !hasPermission(context, Manifest.permission.POST_NOTIFICATIONS)
        ) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && manager.getNotificationChannel(CHANNEL) == null) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL, prefs(context).getString(TITLE, null) ?: "Bank messages", NotificationManager.IMPORTANCE_DEFAULT),
            )
        }
        val open = Intent(context, MainActivity::class.java)
            .setAction(OPEN_REVIEW)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val tap = PendingIntent.getActivity(context, NOTIFICATION_ID, open, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val p = prefs(context)
        val notification = NotificationCompat.Builder(context, CHANNEL)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(p.getString(TITLE, null) ?: "Bank messages to check")
            .setContentText(p.getString(BODY, null) ?: "Open Qima to check them before they're added.")
            .setNumber(p.getInt(WAITING, 1))
            .setContentIntent(tap)
            .setAutoCancel(true)
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
            .build()
        try {
            NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
        } catch (_: SecurityException) {
            // Notifications were turned off in between.
        }
    }

    fun clearNotification(context: Context) {
        prefs(context).edit().putInt(WAITING, 0).apply()
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
    }
}

/** New SMS, while the person has bank messages on. */
class BankSmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION || !BankSms.isEnabled(context)) return
        // A long message arrives in parts, all from one sender.
        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        for ((sender, pieces) in parts.groupBy { it.originatingAddress }) {
            val body = pieces.joinToString("") { it.messageBody ?: "" }
            if (BankSms.looksLikeMoney(body)) BankSms.received(context, body, pieces.first().timestampMillis, sender)
        }
    }
}

/** The `sms` channel `BankMessages` (Dart) uses to turn it on and off and to bring in recent messages. */
class BankSmsChannel(private val activity: Activity, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    companion object {
        const val PERMISSION_REQUEST = 4208
    }

    private var pending: MethodChannel.Result? = null
    private val channel = MethodChannel(messenger, "com.devlabtechnologies.qima/sms")

    /** Qima was opened from the notification before Dart was listening. */
    private var openWaiting = false

    init {
        channel.setMethodCallHandler(this)
    }

    /** The notification was tapped: Qima opens the review. */
    fun openReview() {
        openWaiting = true
        // Dart answers true once it opened the review; until then (a cold
        // start) it asks with takeOpenReview.
        channel.invokeMethod("openReview", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result == true) openWaiting = false
            }

            override fun error(code: String, message: String?, details: Any?) {}

            override fun notImplemented() {}
        })
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
            "catchUp" -> Thread { val n = BankSms.catchUp(activity); activity.runOnUiThread { result.success(n) } }.start()
            "clearNotification" -> {
                BankSms.clearNotification(activity)
                result.success(null)
            }
            "setNotificationText" -> {
                BankSms.setNotificationText(activity, call.argument<String>("title") ?: "", call.argument<String>("body") ?: "")
                result.success(null)
            }
            "takeOpenReview" -> {
                result.success(openWaiting)
                openWaiting = false
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
