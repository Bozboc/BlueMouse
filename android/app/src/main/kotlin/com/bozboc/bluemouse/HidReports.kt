package com.bozboc.bluemouse

object HidReports {
    const val MOUSE_REPORT_ID: Int = 1
    const val KEYBOARD_REPORT_ID: Int = 2
    const val CONSUMER_REPORT_ID: Int = 3
    
    /**
     * Create a mouse movement report
     * Format: [buttons(1 byte), x(1 byte), y(1 byte), wheel(1 byte), pan(1 byte)]
     */
    fun createMouseMoveReport(buttons: Byte, dx: Byte, dy: Byte): ByteArray {
        return byteArrayOf(buttons, dx, dy, 0, 0)
    }

    /**
     * Create a mouse button report
     * Format: [buttons(1 byte), x(1 byte), y(1 byte), wheel(1 byte), pan(1 byte)]
     */
    fun createMouseButtonReport(buttons: Byte): ByteArray {
        return byteArrayOf(buttons, 0, 0, 0, 0)
    }
    
    /**
     * Create a keyboard report
     * Format: [modifier(1 byte), reserved(1 byte), key1-6(6 bytes)]
     */
    fun createKeyboardReport(keyCode: Byte, pressed: Boolean): ByteArray {
        return if (pressed) {
            byteArrayOf(
                0x00.toByte(),      // No modifiers
                0x00.toByte(),      // Reserved
                keyCode,            // Key 1
                0x00.toByte(),      // Key 2
                0x00.toByte(),      // Key 3
                0x00.toByte(),      // Key 4
                0x00.toByte(),      // Key 5
                0x00.toByte()       // Key 6
            )
        } else {
            byteArrayOf(
                0x00.toByte(),      // No modifiers
                0x00.toByte(),      // Reserved
                0x00.toByte(),      // No keys
                0x00.toByte(),
                0x00.toByte(),
                0x00.toByte(),
                0x00.toByte(),
                0x00.toByte()
            )
        }
    }
    
    /**
     * Create a keyboard report with modifier keys
     */
    fun createKeyboardReportWithModifier(
        keyCode: Byte,
        modifier: Byte,
        pressed: Boolean
    ): ByteArray {
        val key = if (pressed) keyCode else 0x00.toByte()
        val mod = if (pressed) modifier else 0x00.toByte()
        return byteArrayOf(
            mod,                // Modifier keys
            0x00.toByte(),      // Reserved
            key,                // Key 1
            0x00.toByte(),      // Key 2
            0x00.toByte(),      // Key 3
            0x00.toByte(),      // Key 4
            0x00.toByte(),      // Key 5
            0x00.toByte()       // Key 6
        )
    }
    
    /**
     * Create a consumer control report for media keys
     * Format: [usage_code_low(1 byte), usage_code_high(1 byte)]
     */
    fun createConsumerReport(usageCode: Int): ByteArray {
        return byteArrayOf(
            (usageCode and 0xFF).toByte(),        // Low byte
            ((usageCode shr 8) and 0xFF).toByte() // High byte
        )
    }

    /**
     * Create a consumer control report for releasing media keys
     */
    fun createConsumerReleaseReport(): ByteArray {
        return byteArrayOf(0x00, 0x00)
    }

    /**
     * Create a mouse scroll report
     * Format: [buttons(1 byte), x(1 byte), y(1 byte), wheel(1 byte), pan(1 byte)]
     */
    fun createScrollReport(h: Byte, v: Byte): ByteArray {
        return byteArrayOf(0, 0, 0, v, h)
    }
}
