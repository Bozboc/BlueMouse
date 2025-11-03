import 'package:flutter/services.dart';
import 'package:pc_remote_controller/core/services/models.dart';

/// Service to interact with the native Bluetooth HID implementation
class BluetoothHidService {
  static const MethodChannel _channel = MethodChannel('bluetooth_hid');
  
  // Callback for connection state changes
  Function(String state, String? deviceAddress, String? deviceName)? onConnectionStateChanged;
  Function(bool registered, String? deviceAddress)? onAppStatusChanged;
  Function(String? deviceAddress)? onVirtualCableUnplug;
  
  BluetoothHidService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onConnectionStateChanged':
        final state = call.arguments['state'] as String;
        final deviceAddress = call.arguments['deviceAddress'] as String?;
        final deviceName = call.arguments['deviceName'] as String?;
        onConnectionStateChanged?.call(state, deviceAddress, deviceName);
        break;
      case 'onAppStatusChanged':
        final registered = call.arguments['registered'] as bool;
        final deviceAddress = call.arguments['deviceAddress'] as String?;
        onAppStatusChanged?.call(registered, deviceAddress);
        break;
      case 'onVirtualCableUnplug':
        final deviceAddress = call.arguments['deviceAddress'] as String?;
        onVirtualCableUnplug?.call(deviceAddress);
        break;
    }
  }
  
  /// Initialize the Bluetooth HID service
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }
  
  /// Register the device as a HID device
  Future<bool> registerHidDevice() async {
    try {
      final result = await _channel.invokeMethod('registerHidDevice');
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }
  
  /// Unregister the HID device
  Future<bool> unregisterHidDevice() async {
    try {
      final result = await _channel.invokeMethod('unregisterHidDevice');
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }
  
  /// Connect to a host PC
  Future<bool> connectToHost(String deviceAddress) async {
    try {
      final result = await _channel.invokeMethod('connectToHost', {
        'address': deviceAddress,
      });
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }
  
  /// Disconnect from the host
  Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod('disconnect');
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }
  
  /// Send mouse movement
  Future<bool> sendMove(int dx, int dy) async {
    try {
      final result = await _channel.invokeMethod('sendMove', {
        'dx': dx,
        'dy': dy,
      });
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }

  /// Send mouse scroll
  Future<bool> sendScroll(int dx, int dy) async {
    try {
      final result = await _channel.invokeMethod('sendScroll', {
        'dx': dx,
        'dy': dy,
      });
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }

  /// Send a mouse click
  Future<bool> sendClick(ClickType type) async {
    try {
      final result = await _channel.invokeMethod('sendClick', {
        'type': type.index,
      });
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }

  /// Send mouse button state (down or up)
  Future<bool> sendMouseButtonState(ClickType type, bool isDown) async {
    try {
      final result = await _channel.invokeMethod('sendMouseButtonState', {
        'type': type.index,
        'isDown': isDown,
      });
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }

  /// Send a key press
  Future<bool> sendKeyPress(String key) async {
    try {
      final result = await _channel.invokeMethod('sendKeyPress', {
        'key': key,
      });
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }
  
  /// Send text (types out the text)
  Future<bool> sendText(String text) async {
    try {
      final result = await _channel.invokeMethod('sendText', {
        'text': text,
      });
      return result == true;
    } on PlatformException {
      rethrow;
    }
  }
  
  /// Check if connected
  Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod('isConnected');
      return result == true;
    } on PlatformException {
      return false;
    }
  }
  
  /// Get list of paired devices
  Future<List<Map<String, String>>> getPairedDevices() async {
    try {
      final result = await _channel.invokeMethod('getPairedDevices');
      if (result is List) {
        return result.map((device) {
          return {
            'name': device['name'] as String,
            'address': device['address'] as String,
          };
        }).toList();
      }
      return [];
    } on PlatformException {
      return [];
    }
  }
}
