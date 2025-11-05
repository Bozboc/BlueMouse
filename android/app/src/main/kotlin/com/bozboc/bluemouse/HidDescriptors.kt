package com.bozboc.bluemouse

object HidDescriptors {
    /**
     * HID descriptor for a combo mouse + keyboard device
     * This descriptor defines the device as both a mouse and keyboard
     */
    val MOUSE_KEYBOARD_COMBO_DESCRIPTOR = byteArrayOf(
        // Mouse descriptor
        0x05.toByte(), 0x01.toByte(),        // Usage Page (Generic Desktop)
        0x09.toByte(), 0x02.toByte(),        // Usage (Mouse)
        0xA1.toByte(), 0x01.toByte(),        // Collection (Application)
        0x85.toByte(), 0x01.toByte(),        //   Report ID (1) - Mouse
        0x09.toByte(), 0x01.toByte(),        //   Usage (Pointer)
        0xA1.toByte(), 0x00.toByte(),        //   Collection (Physical)
        0x05.toByte(), 0x09.toByte(),        //     Usage Page (Buttons)
        0x19.toByte(), 0x01.toByte(),        //     Usage Minimum (1)
        0x29.toByte(), 0x05.toByte(),        //     Usage Maximum (5)
        0x15.toByte(), 0x00.toByte(),        //     Logical Minimum (0)
        0x25.toByte(), 0x01.toByte(),        //     Logical Maximum (1)
        0x95.toByte(), 0x05.toByte(),        //     Report Count (5)
        0x75.toByte(), 0x01.toByte(),        //     Report Size (1)
        0x81.toByte(), 0x02.toByte(),        //     Input (Data, Variable, Absolute)
        0x95.toByte(), 0x01.toByte(),        //     Report Count (1)
        0x75.toByte(), 0x03.toByte(),        //     Report Size (3)
        0x81.toByte(), 0x01.toByte(),        //     Input (Constant) for padding
        0x05.toByte(), 0x01.toByte(),        //     Usage Page (Generic Desktop)
        0x09.toByte(), 0x30.toByte(),        //     Usage (X)
        0x09.toByte(), 0x31.toByte(),        //     Usage (Y)
        0x09.toByte(), 0x38.toByte(),        //     Usage (Wheel)
        0x15.toByte(), 0x81.toByte(),        //     Logical Minimum (-127)
        0x25.toByte(), 0x7F.toByte(),        //     Logical Maximum (127)
        0x75.toByte(), 0x08.toByte(),        //     Report Size (8)
        0x95.toByte(), 0x03.toByte(),        //     Report Count (3)
        0x81.toByte(), 0x06.toByte(),        //     Input (Data, Variable, Relative)
        0xC0.toByte(),                       //   End Collection
        0xC0.toByte(),                       // End Collection
        
        // Keyboard descriptor
        0x05.toByte(), 0x01.toByte(),        // Usage Page (Generic Desktop)
        0x09.toByte(), 0x06.toByte(),        // Usage (Keyboard)
        0xA1.toByte(), 0x01.toByte(),        // Collection (Application)
        0x85.toByte(), 0x02.toByte(),        //   Report ID (2) - Keyboard
        0x05.toByte(), 0x07.toByte(),        //   Usage Page (Key Codes)
        0x19.toByte(), 0xE0.toByte(),        //   Usage Minimum (224)
        0x29.toByte(), 0xE7.toByte(),        //   Usage Maximum (231)
        0x15.toByte(), 0x00.toByte(),        //   Logical Minimum (0)
        0x25.toByte(), 0x01.toByte(),        //   Logical Maximum (1)
        0x75.toByte(), 0x01.toByte(),        //   Report Size (1)
        0x95.toByte(), 0x08.toByte(),        //   Report Count (8)
        0x81.toByte(), 0x02.toByte(),        //   Input (Data, Variable, Absolute)
        0x95.toByte(), 0x01.toByte(),        //   Report Count (1)
        0x75.toByte(), 0x08.toByte(),        //   Report Size (8)
        0x81.toByte(), 0x01.toByte(),        //   Input (Constant) reserved byte
        0x95.toByte(), 0x05.toByte(),        //   Report Count (5)
        0x75.toByte(), 0x01.toByte(),        //   Report Size (1)
        0x05.toByte(), 0x08.toByte(),        //   Usage Page (LEDs)
        0x19.toByte(), 0x01.toByte(),        //   Usage Minimum (1)
        0x29.toByte(), 0x05.toByte(),        //   Usage Maximum (5)
        0x91.toByte(), 0x02.toByte(),        //   Output (Data, Variable, Absolute)
        0x95.toByte(), 0x01.toByte(),        //   Report Count (1)
        0x75.toByte(), 0x03.toByte(),        //   Report Size (3)
        0x91.toByte(), 0x01.toByte(),        //   Output (Constant)
        0x95.toByte(), 0x06.toByte(),        //   Report Count (6)
        0x75.toByte(), 0x08.toByte(),        //   Report Size (8)
        0x15.toByte(), 0x00.toByte(),        //   Logical Minimum (0)
        0x25.toByte(), 0x65.toByte(),        //   Logical Maximum (101)
        0x05.toByte(), 0x07.toByte(),        //   Usage Page (Key Codes)
        0x19.toByte(), 0x00.toByte(),        //   Usage Minimum (0)
        0x29.toByte(), 0x65.toByte(),        //   Usage Maximum (101)
        0x81.toByte(), 0x00.toByte(),        //   Input (Data, Array)
        0xC0.toByte(),                       // End Collection
        
        // Consumer Control descriptor (for media keys)
        0x05.toByte(), 0x0C.toByte(),        // Usage Page (Consumer)
        0x09.toByte(), 0x01.toByte(),        // Usage (Consumer Control)
        0xA1.toByte(), 0x01.toByte(),        // Collection (Application)
        0x85.toByte(), 0x03.toByte(),        //   Report ID (3) - Consumer
        0x19.toByte(), 0x00.toByte(),        //   Usage Minimum (0)
        0x2A.toByte(), 0x3C.toByte(), 0x02.toByte(), // Usage Maximum (572)
        0x15.toByte(), 0x00.toByte(),        //   Logical Minimum (0)
        0x26.toByte(), 0x3C.toByte(), 0x02.toByte(), // Logical Maximum (572)
        0x95.toByte(), 0x01.toByte(),        //   Report Count (1)
        0x75.toByte(), 0x10.toByte(),        //   Report Size (16)
        0x81.toByte(), 0x00.toByte(),        //   Input (Data, Array)
        0xC0.toByte()                        // End Collection
    )
}
