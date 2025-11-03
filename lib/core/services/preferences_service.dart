import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app preferences
class PreferencesService {
  static const String _lastDeviceAddressKey = 'last_device_address';
  static const String _lastDeviceNameKey = 'last_device_name';
  static const String _trackpadSensitivityKey = 'trackpad_sensitivity';
  
  // Default sensitivity multiplier - 0.5 (will be multiplied by 3 = 1.5x)
  // Range: 0.5x to 2.0x (multiplied by 3 internally = 1.5x to 6.0x actual speed)
  static const double _defaultSensitivity = 0.5;
  
  final SharedPreferences _prefs;
  
  PreferencesService(this._prefs);
  
  /// Save the last connected device
  Future<void> saveLastConnectedDevice(String address, String name) async {
    await _prefs.setString(_lastDeviceAddressKey, address);
    await _prefs.setString(_lastDeviceNameKey, name);
  }
  
  /// Get the last connected device address
  String? getLastDeviceAddress() {
    return _prefs.getString(_lastDeviceAddressKey);
  }
  
  /// Get the last connected device name
  String? getLastDeviceName() {
    return _prefs.getString(_lastDeviceNameKey);
  }
  
  /// Clear the last connected device
  Future<void> clearLastConnectedDevice() async {
    await _prefs.remove(_lastDeviceAddressKey);
    await _prefs.remove(_lastDeviceNameKey);
  }
  
  /// Save trackpad sensitivity (1.0 = normal, higher = more sensitive)
  Future<void> saveTrackpadSensitivity(double sensitivity) async {
    await _prefs.setDouble(_trackpadSensitivityKey, sensitivity);
  }
  
  /// Get trackpad sensitivity
  double getTrackpadSensitivity() {
    return _prefs.getDouble(_trackpadSensitivityKey) ?? _defaultSensitivity;
  }
  
  /// Factory method to create an instance
  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }
}
