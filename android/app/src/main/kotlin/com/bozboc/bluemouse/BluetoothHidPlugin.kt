package com.bozboc.bluemouse

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothHidDevice
import android.bluetooth.BluetoothHidDeviceAppSdpSettings
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors

class BluetoothHidPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var hidDevice: BluetoothHidDevice? = null
    private var hidDeviceCallback: BluetoothHidDeviceCallback? = null
    private var connectedHost: BluetoothDevice? = null
    private var currentMouseButtons: Byte = 0 // Track current button state
    
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    
    companion object {
        private const val TAG = "BluetoothHidPlugin"
        private const val CHANNEL_NAME = "bluetooth_hid"
    }
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        cleanup()
    }
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
    
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    
    override fun onDetachedFromActivity() {
        activity = null
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "registerHidDevice" -> registerHidDevice(result)
            "unregisterHidDevice" -> unregisterHidDevice(result)
            "connectToHost" -> {
                val address = call.argument<String>("address")
                if (address != null) {
                    connectToHost(address, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Device address is required", null)
                }
            }
            "disconnect" -> disconnect(result)
            "sendMove" -> {
                val dx = call.argument<Int>("dx") ?: 0
                val dy = call.argument<Int>("dy") ?: 0
                sendMove(dx, dy, result)
            }
            "sendScroll" -> {
                val dx = call.argument<Int>("dx") ?: 0
                val dy = call.argument<Int>("dy") ?: 0
                sendScroll(dx, dy, result)
            }
            "sendClick" -> {
                val type = call.argument<Int>("type") ?: 0
                sendClick(type, result)
            }
            "sendMouseButtonState" -> {
                val type = call.argument<Int>("type") ?: 0
                val isDown = call.argument<Boolean>("isDown") ?: false
                sendMouseButtonState(type, isDown, result)
            }
            "sendKeyPress" -> {
                val key = call.argument<String>("key")
                if (key != null) {
                    sendKeyPress(key, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Key is required", null)
                }
            }
            "sendText" -> {
                val text = call.argument<String>("text")
                if (text != null) {
                    sendText(text, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Text is required", null)
                }
            }
            "isConnected" -> result.success(connectedHost != null)
            "getPairedDevices" -> getPairedDevices(result)
            else -> result.notImplemented()
        }
    }
    
    private fun initialize(result: Result) {
        try {
            if (bluetoothAdapter == null) {
                result.error("NO_BLUETOOTH", "Bluetooth adapter not available", null)
                return
            }
            
            if (!bluetoothAdapter!!.isEnabled) {
                result.error("BLUETOOTH_DISABLED", "Bluetooth is disabled", null)
                return
            }
            
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Initialize error", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }
    
    private fun registerHidDevice(result: Result) {
        try {
            if (bluetoothAdapter == null) {
                result.error("NO_BLUETOOTH", "Bluetooth adapter not available", null)
                return
            }
            
            hidDeviceCallback = BluetoothHidDeviceCallback(channel, mainHandler)
            
            bluetoothAdapter!!.getProfileProxy(
                context,
                object : BluetoothProfile.ServiceListener {
                    override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
                        if (profile == BluetoothProfile.HID_DEVICE) {
                            hidDevice = proxy as BluetoothHidDevice
                            
                            // Unregister any existing app first
                            try {
                                // Check permission before calling Bluetooth API
                                val ctx = context ?: run {
                                    result.error("NO_CONTEXT", "Context not available", null)
                                    return
                                }
                                
                                if (ActivityCompat.checkSelfPermission(
                                        ctx,
                                        Manifest.permission.BLUETOOTH_CONNECT
                                    ) != PackageManager.PERMISSION_GRANTED
                                ) {
                                    Log.e(TAG, "Missing BLUETOOTH_CONNECT permission")
                                    result.error("PERMISSION_DENIED", "BLUETOOTH_CONNECT permission required. Please restart the app and grant all Bluetooth permissions.", null)
                                    return
                                }
                                
                                hidDevice!!.unregisterApp()
                                Log.d(TAG, "Unregistered any existing HID app")
                            } catch (e: SecurityException) {
                                Log.e(TAG, "SecurityException during unregister", e)
                                result.error("PERMISSION_ERROR", "Bluetooth permission error: ${e.message}", null)
                                return
                            } catch (e: Exception) {
                                Log.d(TAG, "No previous HID app to unregister: ${e.message}")
                            }
                            
                            val sdpSettings = BluetoothHidDeviceAppSdpSettings(
                                "PC Remote Controller",
                                "Remote control for PC",
                                "YourCompany",
                                BluetoothHidDevice.SUBCLASS1_COMBO,
                                HidDescriptors.MOUSE_KEYBOARD_COMBO_DESCRIPTOR
                            )
                            
                            val registered = hidDevice!!.registerApp(
                                sdpSettings,
                                null,  // inQos
                                null,  // outQos
                                executor,
                                hidDeviceCallback
                            )
                            
                            if (registered) {
                                Log.d(TAG, "HID Device registered successfully")
                                result.success(true)
                            } else {
                                Log.e(TAG, "Failed to register HID Device")
                                result.error("REGISTER_FAILED", "Failed to register HID device", null)
                            }
                        }
                    }
                    
                    override fun onServiceDisconnected(profile: Int) {
                        if (profile == BluetoothProfile.HID_DEVICE) {
                            hidDevice = null
                            Log.d(TAG, "HID Device service disconnected")
                        }
                    }
                },
                BluetoothProfile.HID_DEVICE
            )
        } catch (e: Exception) {
            Log.e(TAG, "Register HID device error", e)
            result.error("REGISTER_ERROR", e.message, null)
        }
    }
    
    private fun unregisterHidDevice(result: Result) {
        try {
            hidDevice?.unregisterApp()
            hidDevice = null
            hidDeviceCallback = null
            connectedHost = null
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Unregister error", e)
            result.error("UNREGISTER_ERROR", e.message, null)
        }
    }
    
    private fun connectToHost(address: String, result: Result) {
        try {
            if (hidDevice == null) {
                result.error("NOT_REGISTERED", "HID device not registered", null)
                return
            }
            
            val device = bluetoothAdapter?.getRemoteDevice(address)
            if (device == null) {
                result.error("INVALID_DEVICE", "Invalid device address", null)
                return
            }
            
            val connected = hidDevice!!.connect(device)
            if (connected) {
                connectedHost = device
                Log.d(TAG, "Connection initiated to $address")
                result.success(true)
            } else {
                result.error("CONNECT_FAILED", "Failed to initiate connection", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Connect error", e)
            result.error("CONNECT_ERROR", e.message, null)
        }
    }
    
    private fun disconnect(result: Result) {
        try {
            connectedHost?.let { device ->
                hidDevice?.disconnect(device)
                connectedHost = null
            }
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Disconnect error", e)
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }
    
    private fun sendMove(dx: Int, dy: Int, result: Result) {
        if (connectedHost == null) {
            result.error("NOT_CONNECTED", "No device connected", null)
            return
        }
        
        // Include current button state in the movement report
        val report = HidReports.createMouseMoveReport(currentMouseButtons, dx.toByte(), dy.toByte())
        
        if (ActivityCompat.checkSelfPermission(context!!, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "BLUETOOTH_CONNECT permission not granted", null)
            return
        }
        
        val success = hidDevice?.sendReport(connectedHost, HidReports.MOUSE_REPORT_ID, report) ?: false
        result.success(success)
    }

    private fun sendScroll(dx: Int, dy: Int, result: Result) {
        if (connectedHost == null) {
            result.error("NOT_CONNECTED", "No device connected", null)
            return
        }
        
        val report = HidReports.createScrollReport(dx.toByte(), dy.toByte())
        
        if (ActivityCompat.checkSelfPermission(context!!, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "BLUETOOTH_CONNECT permission not granted", null)
            return
        }
        
        val success = hidDevice?.sendReport(connectedHost, HidReports.MOUSE_REPORT_ID, report) ?: false
        result.success(success)
    }

    private fun sendClick(type: Int, result: Result) {
        if (connectedHost == null) {
            result.error("NOT_CONNECTED", "No device connected", null)
            return
        }
        
        val button = if (type == 0) 1.toByte() else 2.toByte()
        val report = HidReports.createMouseButtonReport(button)
        val releaseReport = HidReports.createMouseButtonReport(0)
        
        if (ActivityCompat.checkSelfPermission(context!!, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "BLUETOOTH_CONNECT permission not granted", null)
            return
        }
        
        hidDevice?.sendReport(connectedHost, HidReports.MOUSE_REPORT_ID, report)
        Thread.sleep(30)
        val success = hidDevice?.sendReport(connectedHost, HidReports.MOUSE_REPORT_ID, releaseReport) ?: false
        result.success(success)
    }

    private fun sendMouseButtonState(type: Int, isDown: Boolean, result: Result) {
        if (connectedHost == null) {
            result.error("NOT_CONNECTED", "No device connected", null)
            return
        }
        
        val buttonMask = if (type == 0) 1.toByte() else 2.toByte()
        
        // Update the current button state
        currentMouseButtons = if (isDown) {
            (currentMouseButtons.toInt() or buttonMask.toInt()).toByte()  // Set the bit
        } else {
            (currentMouseButtons.toInt() and buttonMask.toInt().inv()).toByte()  // Clear the bit
        }
        
        val report = HidReports.createMouseButtonReport(currentMouseButtons)
        
        if (ActivityCompat.checkSelfPermission(context!!, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "BLUETOOTH_CONNECT permission not granted", null)
            return
        }
        
        val success = hidDevice?.sendReport(connectedHost, HidReports.MOUSE_REPORT_ID, report) ?: false
        result.success(success)
    }

    private fun sendKeyPress(key: String, result: Result) {
        val host = connectedHost
        try {
            if (hidDevice == null || host == null) {
                result.error("NOT_CONNECTED", "Not connected to host", null)
                return
            }
            
            // Check if it's a consumer/media key
            if (HidKeyCodes.isConsumerKey(key)) {
                sendConsumerKey(key, result)
                return
            }
            
            val keyCode = HidKeyCodes.getKeyCode(key)
            if (keyCode == 0.toByte()) {
                result.error("INVALID_KEY", "Invalid key: $key", null)
                return
            }
            
            Log.d(TAG, "Sending key press: key=$key, keyCode=$keyCode")
            
            // Key press
            var report = HidReports.createKeyboardReport(keyCode, true)
            val pressResult = hidDevice!!.sendReport(connectedHost, HidReports.KEYBOARD_REPORT_ID, report)
            Log.d(TAG, "Key press sent: $pressResult, report=${report.contentToString()}")
            
            Thread.sleep(50)
            
            // Key release
            report = HidReports.createKeyboardReport(keyCode, false)
            val releaseResult = hidDevice!!.sendReport(connectedHost, HidReports.KEYBOARD_REPORT_ID, report)
            Log.d(TAG, "Key release sent: $releaseResult")
            
            if (pressResult && releaseResult) {
                result.success(true)
            } else {
                result.error("SEND_FAILED", "Failed to send key press report", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Send key press error", e)
            result.error("SEND_ERROR", e.message, null)
        }
    }
    
    private fun sendConsumerKey(key: String, result: Result) {
        try {
            if (hidDevice == null || connectedHost == null) {
                result.error("NOT_CONNECTED", "Not connected to host", null)
                return
            }
            
            val usageCode = HidKeyCodes.getConsumerKeyCode(key)
            if (usageCode == 0) {
                result.error("INVALID_KEY", "Invalid consumer key: $key", null)
                return
            }
            
            Log.d(TAG, "Sending consumer key: $key, usageCode=$usageCode")
            
            // Press - send the consumer usage code
            var report = HidReports.createConsumerReport(usageCode)
            val pressResult = hidDevice!!.sendReport(connectedHost, HidReports.CONSUMER_REPORT_ID, report)
            Log.d(TAG, "Consumer key press sent: $pressResult, report=${report.contentToString()}")
            
            Thread.sleep(50)
            
            // Release - send empty report
            report = HidReports.createConsumerReleaseReport()
            val releaseResult = hidDevice!!.sendReport(connectedHost, HidReports.CONSUMER_REPORT_ID, report)
            Log.d(TAG, "Consumer key release sent: $releaseResult")
            
            if (pressResult && releaseResult) {
                result.success(true)
            } else {
                result.error("SEND_FAILED", "Failed to send consumer key", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Send consumer key error", e)
            result.error("SEND_ERROR", e.message, null)
        }
    }
    
    private fun sendText(text: String, result: Result) {
        try {
            if (hidDevice == null || connectedHost == null) {
                result.error("NOT_CONNECTED", "Not connected to host", null)
                return
            }
            
            executor.execute {
                try {
                    for (char in text) {
                        val keyCode = HidKeyCodes.getKeyCodeForChar(char)
                        val modifier = if (HidKeyCodes.isShiftRequired(char)) {
                            HidKeyCodes.MODIFIER_LEFT_SHIFT
                        } else {
                            0.toByte()
                        }

                        if (keyCode != 0.toByte()) {
                            // Press
                            var report = HidReports.createKeyboardReportWithModifier(keyCode, modifier, true)
                            hidDevice!!.sendReport(connectedHost, HidReports.KEYBOARD_REPORT_ID, report)
                            
                            Thread.sleep(30)
                            
                            // Release
                            report = HidReports.createKeyboardReportWithModifier(0.toByte(), 0.toByte(), false)
                            hidDevice!!.sendReport(connectedHost, HidReports.KEYBOARD_REPORT_ID, report)
                            
                            Thread.sleep(30)
                        }
                    }
                    
                    mainHandler.post {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Send text error", e)
                    mainHandler.post {
                        result.error("SEND_ERROR", e.message, null)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Send text error", e)
            result.error("SEND_ERROR", e.message, null)
        }
    }
    
    private fun getPairedDevices(result: Result) {
        try {
            if (bluetoothAdapter == null) {
                result.error("NO_BLUETOOTH", "Bluetooth adapter not available", null)
                return
            }
            
            val pairedDevices = bluetoothAdapter!!.bondedDevices
            val devicesList = pairedDevices.map { device ->
                mapOf(
                    "name" to (device.name ?: "Unknown"),
                    "address" to device.address
                )
            }
            
            result.success(devicesList)
        } catch (e: Exception) {
            Log.e(TAG, "Get paired devices error", e)
            result.error("GET_DEVICES_ERROR", e.message, null)
        }
    }
    
    private fun cleanup() {
        try {
            hidDevice?.unregisterApp()
            hidDevice = null
            hidDeviceCallback = null
            connectedHost = null
            bluetoothAdapter?.closeProfileProxy(BluetoothProfile.HID_DEVICE, hidDevice)
        } catch (e: Exception) {
            Log.e(TAG, "Cleanup error", e)
        }
    }
}
