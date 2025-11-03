package com.pcremote.pc_remote_controller

object HidKeyCodes {
    // USB HID Keyboard scan codes
    private val KEY_MAP = mapOf(
        "a" to 0x04.toByte(), "b" to 0x05.toByte(), "c" to 0x06.toByte(),
        "d" to 0x07.toByte(), "e" to 0x08.toByte(), "f" to 0x09.toByte(),
        "g" to 0x0A.toByte(), "h" to 0x0B.toByte(), "i" to 0x0C.toByte(),
        "j" to 0x0D.toByte(), "k" to 0x0E.toByte(), "l" to 0x0F.toByte(),
        "m" to 0x10.toByte(), "n" to 0x11.toByte(), "o" to 0x12.toByte(),
        "p" to 0x13.toByte(), "q" to 0x14.toByte(), "r" to 0x15.toByte(),
        "s" to 0x16.toByte(), "t" to 0x17.toByte(), "u" to 0x18.toByte(),
        "v" to 0x19.toByte(), "w" to 0x1A.toByte(), "x" to 0x1B.toByte(),
        "y" to 0x1C.toByte(), "z" to 0x1D.toByte(),
        
        "1" to 0x1E.toByte(), "2" to 0x1F.toByte(), "3" to 0x20.toByte(),
        "4" to 0x21.toByte(), "5" to 0x22.toByte(), "6" to 0x23.toByte(),
        "7" to 0x24.toByte(), "8" to 0x25.toByte(), "9" to 0x26.toByte(),
        "0" to 0x27.toByte(),
        
        "enter" to 0x28.toByte(),
        "escape" to 0x29.toByte(),
        "backspace" to 0x2A.toByte(),
        "tab" to 0x2B.toByte(),
        "space" to 0x2C.toByte(),
        " " to 0x2C.toByte(),
        
        // Printable Special Characters (Base Keys)
        "-" to 0x2D.toByte(), // Maps to - and _ (Shift)
        "=" to 0x2E.toByte(), // Maps to = and + (Shift)
        "[" to 0x2F.toByte(), // Maps to [ and { (Shift)
        "]" to 0x30.toByte(), // Maps to ] and } (Shift)
        "\\" to 0x31.toByte(), // Maps to \ and | (Shift)
        // Key 0x32 (Non-US # and ~ on some keyboards) is often skipped/reserved on US layouts
        ";" to 0x33.toByte(), // Maps to ; and : (Shift)
        "'" to 0x34.toByte(), // Maps to ' and " (Shift)
        "`" to 0x35.toByte(), // Maps to ` and ~ (Shift)
        "," to 0x36.toByte(), // Maps to , and < (Shift)
        "." to 0x37.toByte(), // Maps to . and > (Shift)
        "/" to 0x38.toByte(), // Maps to / and ? (Shift)
        
        "capslock" to 0x39.toByte(),
        
        "f1" to 0x3A.toByte(), "f2" to 0x3B.toByte(), "f3" to 0x3C.toByte(),
        "f4" to 0x3D.toByte(), "f5" to 0x3E.toByte(), "f6" to 0x3F.toByte(),
        "f7" to 0x40.toByte(), "f8" to 0x41.toByte(), "f9" to 0x42.toByte(),
        "f10" to 0x43.toByte(), "f11" to 0x44.toByte(), "f12" to 0x45.toByte(),
        
        "printscreen" to 0x46.toByte(),
        "scrolllock" to 0x47.toByte(),
        "pause" to 0x48.toByte(),
        "insert" to 0x49.toByte(),
        "home" to 0x4A.toByte(),
        "pageup" to 0x4B.toByte(),
        "page_up" to 0x4B.toByte(),
        "delete" to 0x4C.toByte(),
        "end" to 0x4D.toByte(),
        "pagedown" to 0x4E.toByte(),
        "page_down" to 0x4E.toByte(),
        "right" to 0x4F.toByte(),
        "arrow_right" to 0x4F.toByte(),
        "left" to 0x50.toByte(),
        "arrow_left" to 0x50.toByte(),
        "down" to 0x51.toByte(),
        "arrow_down" to 0x51.toByte(),
        "up" to 0x52.toByte(),
        "arrow_up" to 0x52.toByte(),

        // Modifier Keys (these codes are sent in the modifier byte, but included here for completeness)
        "lctrl" to 0xE0.toByte(),
        "lshift" to 0xE1.toByte(),
        "lalt" to 0xE2.toByte(),
        "lgui" to 0xE3.toByte(), // Left Windows/Command key
        "rctrl" to 0xE4.toByte(),
        "rshift" to 0xE5.toByte(),
        "ralt" to 0xE6.toByte(),
        "rgui" to 0xE7.toByte() // Right Windows/Command key
    )
    
    // Consumer Control codes (for media keys)
    // These are 16-bit values from HID Usage Tables - Consumer Page (0x0C)
    private val CONSUMER_KEYS = mapOf(
        "volume_up" to 0x00E9,
        "volume_down" to 0x00EA,
        "mute" to 0x00E2,
        "media_play_pause" to 0x00CD,
        "media_next" to 0x00B5,
        "media_previous" to 0x00B6,
        "media_stop" to 0x00B7
    )
    
    // Modifier keys (bitmask)
    const val MODIFIER_LEFT_CTRL: Byte = 0x01
    const val MODIFIER_LEFT_SHIFT: Byte = 0x02
    const val MODIFIER_LEFT_ALT: Byte = 0x04
    const val MODIFIER_LEFT_GUI: Byte = 0x08
    const val MODIFIER_RIGHT_CTRL: Byte = 0x10
    const val MODIFIER_RIGHT_SHIFT: Byte = 0x20
    const val MODIFIER_RIGHT_ALT: Byte = 0x40
    const val MODIFIER_RIGHT_GUI: Byte = 0x80.toByte()
    
    fun getKeyCode(key: String): Byte {
        return KEY_MAP[key.lowercase()] ?: 0x00.toByte()
    }
    
    fun isConsumerKey(key: String): Boolean {
        return CONSUMER_KEYS.containsKey(key.lowercase())
    }
    
    fun getConsumerKeyCode(key: String): Int {
        return CONSUMER_KEYS[key.lowercase()] ?: 0
    }
    
    fun getKeyCodeForChar(char: Char): Byte {
        return when (char) {
            in 'a'..'z' -> KEY_MAP[char.toString()]!!
            in 'A'..'Z' -> KEY_MAP[char.lowercaseChar().toString()]!!
            in '0'..'9' -> KEY_MAP[char.toString()]!!
            ' ' -> KEY_MAP[" "]!!
            '.' -> KEY_MAP["."]!!
            ',' -> KEY_MAP[","]!!
            '!' -> KEY_MAP["1"]!! // Shift+1
            '@' -> KEY_MAP["2"]!! // Shift+2
            '#' -> KEY_MAP["3"]!! // Shift+3
            '$' -> KEY_MAP["4"]!! // Shift+4
            '%' -> KEY_MAP["5"]!! // Shift+5
            '^' -> KEY_MAP["6"]!! // Shift+6
            '&' -> KEY_MAP["7"]!! // Shift+7
            '*' -> KEY_MAP["8"]!! // Shift+8
            '(' -> KEY_MAP["9"]!! // Shift+9
            ')' -> KEY_MAP["0"]!! // Shift+0
            '-' -> KEY_MAP["-"]!!
            '_' -> KEY_MAP["-"]!! // Shift+-
            '=' -> KEY_MAP["="]!!
            '+' -> KEY_MAP["="]!! // Shift+=
            '[' -> KEY_MAP["["]!!
            '{' -> KEY_MAP["["]!! // Shift+[
            ']' -> KEY_MAP["]"]!!
            '}' -> KEY_MAP["]"]!! // Shift+]
            '\\' -> KEY_MAP["\\"]!!
            '|' -> KEY_MAP["\\"]!! // Shift+\
            ';' -> KEY_MAP[";"]!!
            ':' -> KEY_MAP[";"]!! // Shift+;
            '\'' -> KEY_MAP["'"]!!
            '"' -> KEY_MAP["'"]!! // Shift+'
            '`' -> KEY_MAP["`"]!!
            '~' -> KEY_MAP["`"]!! // Shift+`
            '/' -> KEY_MAP["/"]!!
            '?' -> KEY_MAP["/"]!! // Shift+/
            '<' -> KEY_MAP[","]!! // Shift+,
            '>' -> KEY_MAP["."]!! // Shift+.
            '\n' -> KEY_MAP["enter"]!!
            '\t' -> KEY_MAP["tab"]!!
            else -> 0x00.toByte()
        }
    }
    
    fun isShiftRequired(char: Char): Boolean {
        return char in 'A'..'Z' || char in "!@#$%^&*()_+{}|:\"<>?~"
    }
}
