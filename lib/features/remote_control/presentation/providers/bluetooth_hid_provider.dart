import 'package:flutter/material.dart';
import 'package:blue_mouse/core/services/models.dart';
import '../../../../core/services/bluetooth_hid_service.dart';
import '../../../../core/services/preferences_service.dart';

/// Provider for Bluetooth HID connection and control
class BluetoothHidProvider extends ChangeNotifier {
  final BluetoothHidService _hidService;
  final PreferencesService _prefsService;
  
  bool _isInitialized = false;
  bool _isRegistered = false;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _manualDisconnect = false; // Track if disconnect was manual
  String _errorMessage = '';
  String? _connectedDeviceAddress;
  String? _connectedDeviceName;
  List<Map<String, String>> _pairedDevices = [];
  double _trackpadSensitivity = 1.0;
  
  BluetoothHidProvider(this._hidService, this._prefsService) {
    _setupCallbacks();
    _trackpadSensitivity = _prefsService.getTrackpadSensitivity();
  }
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRegistered => _isRegistered;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String get errorMessage => _errorMessage;
  String? get connectedDeviceAddress => _connectedDeviceAddress;
  String? get connectedDeviceName => _connectedDeviceName;
  List<Map<String, String>> get pairedDevices => _pairedDevices;
  double get trackpadSensitivity => _trackpadSensitivity;
  
  void _setupCallbacks() {
    _hidService.onConnectionStateChanged = (state, deviceAddress, deviceName) {
      _connectedDeviceAddress = deviceAddress;
      _connectedDeviceName = deviceName;
      
      switch (state) {
        case 'connected':
          _isConnected = true;
          _isConnecting = false;
          _errorMessage = '';
          _manualDisconnect = false;
          // Save the connected device for auto-reconnect
          if (deviceAddress != null && deviceName != null) {
            debugPrint('💾 Saving connected device: $deviceName ($deviceAddress)');
            _prefsService.saveLastConnectedDevice(deviceAddress, deviceName);
          }
          break;
        case 'disconnected':
          _isConnected = false;
          _isConnecting = false;
          // Auto-reconnect if not manually disconnected
          if (!_manualDisconnect && deviceAddress != null) {
            _attemptReconnect(deviceAddress);
          }
          break;
        case 'connecting':
          _isConnecting = true;
          break;
        case 'disconnecting':
          _isConnecting = false;
          break;
      }
      notifyListeners();
    };
    
    _hidService.onAppStatusChanged = (registered, deviceAddress) {
      _isRegistered = registered;
      notifyListeners();
    };
    
    _hidService.onVirtualCableUnplug = (deviceAddress) {
      _isConnected = false;
      _connectedDeviceAddress = null;
      _connectedDeviceName = null;
      _errorMessage = 'Virtual cable unplugged';
      notifyListeners();
    };
  }
  
  Future<void> initialize() async {
    try {
      _errorMessage = '';
      final result = await _hidService.initialize();
      _isInitialized = result;
      
      if (_isInitialized) {
        // Auto-register HID device
        await registerHidDevice();
        
        // Try to auto-connect to last device
        await _autoConnectToLastDevice();
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = false;
      notifyListeners();
    }
  }
  
  Future<void> _autoConnectToLastDevice() async {
    final lastAddress = _prefsService.getLastDeviceAddress();
    final lastName = _prefsService.getLastDeviceName();
    
    debugPrint('🔄 Auto-connect: Checking last device...');
    debugPrint('   Address: $lastAddress');
    debugPrint('   Name: $lastName');
    
    if (lastAddress != null && lastAddress.isNotEmpty) {
      try {
        debugPrint('🔄 Auto-connect: Attempting to connect to $lastName ($lastAddress)');
        await connectToHost(lastAddress);
      } catch (e) {
        // Silently fail auto-connect, user can manually connect
        debugPrint('❌ Auto-connect failed: $e');
      }
    } else {
      debugPrint('ℹ️ Auto-connect: No previous device found');
    }
  }
  
  Future<void> _attemptReconnect(String deviceAddress) async {
    // Wait a bit before attempting reconnect
    await Future.delayed(const Duration(seconds: 2));
    if (!_isConnected && !_manualDisconnect) {
      try {
        await connectToHost(deviceAddress);
      } catch (e) {
        debugPrint('Reconnect failed: $e');
      }
    }
  }
  
  Future<void> registerHidDevice() async {
    try {
      _errorMessage = '';
      final result = await _hidService.registerHidDevice();
      _isRegistered = result;
      
      if (_isRegistered) {
        // Load paired devices
        await loadPairedDevices();
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to register HID device: ${e.toString()}';
      _isRegistered = false;
      notifyListeners();
    }
  }
  
  Future<void> loadPairedDevices() async {
    try {
      _pairedDevices = await _hidService.getPairedDevices();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load paired devices: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<void> connectToDevice(String deviceAddress) async {
    try {
      _errorMessage = '';
      _isConnecting = true;
      notifyListeners();
      
      final result = await _hidService.connectToHost(deviceAddress);
      
      if (!result) {
        _errorMessage = 'Failed to connect to device';
        _isConnecting = false;
        notifyListeners();
      }
      // Connection state will be updated via callback
    } catch (e) {
      _errorMessage = 'Connection error: ${e.toString()}';
      _isConnecting = false;
      notifyListeners();
    }
  }
  
  // Alias for connectToDevice
  Future<void> connectToHost(String deviceAddress) async {
    return connectToDevice(deviceAddress);
  }
  
  // Get paired devices
  Future<List<Map<String, String>>> getPairedDevices() async {
    await loadPairedDevices();
    return _pairedDevices;
  }
  
  Future<void> disconnect() async {
    try {
      _manualDisconnect = true; // Mark as manual disconnect to prevent auto-reconnect
      await _hidService.disconnect();
      _isConnected = false;
      _connectedDeviceAddress = null;
      _connectedDeviceName = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Disconnect error: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> sendMove(int dx, int dy) async {
    if (!_isConnected) return;
    try {
      // Apply sensitivity multiplier (multiplied by 3 to make 0.5x = current 1.5x speed)
      // Range: 0.5x (1.5x current) to 2.0x (6x current speed)
      final adjustedDx = (dx * _trackpadSensitivity * 3).round();
      final adjustedDy = (dy * _trackpadSensitivity * 3).round();
      await _hidService.sendMove(adjustedDx, adjustedDy);
    } catch (e) {
      _errorMessage = 'Failed to send move: $e';
      notifyListeners();
    }
  }
  
  Future<void> setTrackpadSensitivity(double sensitivity) async {
    _trackpadSensitivity = sensitivity.clamp(0.5, 2.0); // Limit range 0.5x to 2.0x
    await _prefsService.saveTrackpadSensitivity(_trackpadSensitivity);
    notifyListeners();
  }

  Future<void> sendScroll(int dx, int dy) async {
    if (!_isConnected) return;
    try {
      await _hidService.sendScroll(dx, dy);
    } catch (e) {
      _errorMessage = 'Failed to send scroll: $e';
      notifyListeners();
    }
  }
  
  Future<void> sendClick(ClickType type) async {
    if (!_isConnected) return;
    try {
      await _hidService.sendClick(type);
    } catch (e) {
      _errorMessage = 'Failed to send click: $e';
      notifyListeners();
    }
  }

  Future<void> sendMouseButtonState(ClickType type, bool isDown) async {
    if (!_isConnected) return;
    try {
      await _hidService.sendMouseButtonState(type, isDown);
    } catch (e) {
      _errorMessage = 'Failed to send mouse button state: $e';
      notifyListeners();
    }
  }

  Future<void> sendKeyPress(String key) async {
    if (!_isConnected) return;
    try {
      await _hidService.sendKeyPress(key);
    } catch (e) {
      _errorMessage = 'Failed to send key press: $e';
      notifyListeners();
    }
  }
  
  Future<void> sendText(String text) async {
    if (!_isConnected) {
      _errorMessage = 'Not connected to device';
      notifyListeners();
      return;
    }
    
    try {
      await _hidService.sendText(text);
    } catch (e) {
      _errorMessage = 'Failed to send text: ${e.toString()}';
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
