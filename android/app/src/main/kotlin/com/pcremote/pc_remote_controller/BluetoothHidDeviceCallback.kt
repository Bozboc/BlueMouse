package com.pcremote.pc_remote_controller

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothHidDevice
import android.os.Handler
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class BluetoothHidDeviceCallback(
    private val channel: MethodChannel,
    private val mainHandler: Handler
) : BluetoothHidDevice.Callback() {
    
    companion object {
        private const val TAG = "HidDeviceCallback"
    }
    
    override fun onAppStatusChanged(pluggedDevice: BluetoothDevice?, registered: Boolean) {
        super.onAppStatusChanged(pluggedDevice, registered)
        Log.d(TAG, "App status changed: registered=$registered, device=${pluggedDevice?.address}")
        
        mainHandler.post {
            channel.invokeMethod("onAppStatusChanged", mapOf(
                "registered" to registered,
                "deviceAddress" to pluggedDevice?.address
            ))
        }
    }
    
    override fun onConnectionStateChanged(device: BluetoothDevice?, state: Int) {
        super.onConnectionStateChanged(device, state)
        
        val stateString = when (state) {
            BluetoothHidDevice.STATE_DISCONNECTED -> "disconnected"
            BluetoothHidDevice.STATE_CONNECTING -> "connecting"
            BluetoothHidDevice.STATE_CONNECTED -> "connected"
            BluetoothHidDevice.STATE_DISCONNECTING -> "disconnecting"
            else -> "unknown"
        }
        
        Log.d(TAG, "Connection state changed: $stateString, device=${device?.address}")
        
        mainHandler.post {
            channel.invokeMethod("onConnectionStateChanged", mapOf(
                "state" to stateString,
                "deviceAddress" to device?.address,
                "deviceName" to device?.name
            ))
        }
    }
    
    override fun onGetReport(
        device: BluetoothDevice?,
        type: Byte,
        id: Byte,
        bufferSize: Int
    ) {
        super.onGetReport(device, type, id, bufferSize)
        Log.d(TAG, "Get report request: type=$type, id=$id, size=$bufferSize")
    }
    
    override fun onSetReport(device: BluetoothDevice?, type: Byte, id: Byte, data: ByteArray?) {
        super.onSetReport(device, type, id, data)
        Log.d(TAG, "Set report: type=$type, id=$id")
    }
    
    override fun onSetProtocol(device: BluetoothDevice?, protocol: Byte) {
        super.onSetProtocol(device, protocol)
        Log.d(TAG, "Set protocol: $protocol")
    }
    
    override fun onInterruptData(device: BluetoothDevice?, reportId: Byte, data: ByteArray?) {
        super.onInterruptData(device, reportId, data)
        Log.d(TAG, "Interrupt data: reportId=$reportId")
    }
    
    override fun onVirtualCableUnplug(device: BluetoothDevice?) {
        super.onVirtualCableUnplug(device)
        Log.d(TAG, "Virtual cable unplugged: device=${device?.address}")
        
        mainHandler.post {
            channel.invokeMethod("onVirtualCableUnplug", mapOf(
                "deviceAddress" to device?.address
            ))
        }
    }
}
