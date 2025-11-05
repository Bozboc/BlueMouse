package com.bozboc.bluemouse

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the Bluetooth HID plugin
        flutterEngine.plugins.add(BluetoothHidPlugin())
    }
}

