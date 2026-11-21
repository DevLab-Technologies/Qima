package com.devlabtechnologies.qima

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The parts of [OnDeviceModelChannel] that don't need Gemini Nano: the
 * question asked and how the answer is read. Dart checks every word the
 * model copies against the message, so here only the shape matters.
 */
class OnDeviceModelChannelTest {

    @Test
    fun `the answer is read from the JSON, whatever the model wraps it in`() {
        val answer = "Here you go:\n```json\n{\"intent\": \"purchase\", \"amount\": \" USD 18.50 \", \"balance\": \"USD 981.50\", \"name\": \"CORNER CAFE\"}\n```"
        assertEquals(
            mapOf("intent" to "purchase", "amount" to "USD 18.50", "balance" to "USD 981.50", "name" to "CORNER CAFE"),
            OnDeviceModelChannel.labels(answer),
        )
    }

    @Test
    fun `missing fields come back empty, and no JSON gives nothing`() {
        assertEquals(
            mapOf("intent" to "code", "amount" to "", "balance" to "", "name" to ""),
            OnDeviceModelChannel.labels("{\"intent\": \"code\"}"),
        )
        assertNull(OnDeviceModelChannel.labels("I can't help with that."))
        assertNull(OnDeviceModelChannel.labels("{not json}"))
    }

    @Test
    fun `the question names every intent Dart knows and carries the message`() {
        val prompt = OnDeviceModelChannel.prompt("Purchase of USD 7.00 at SUN BAKERY")
        for (intent in listOf("purchase", "refund", "withdrawal", "transferOut", "transferIn", "deposit", "fee", "debit", "unknown", "notice", "code", "declined")) {
            assertTrue(intent, prompt.contains(intent))
        }
        assertTrue(prompt.endsWith("Purchase of USD 7.00 at SUN BAKERY"))
        assertTrue(prompt.contains("Never change, convert, compute or invent a number"))
    }
}
