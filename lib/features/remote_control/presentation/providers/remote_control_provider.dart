import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/services/preferences_service.dart';
import '../../domain/entities/connection_status.dart';
import '../../domain/entities/remote_command.dart';
import '../../domain/repositories/remote_control_repository.dart';
import '../../domain/usecases/connect_to_bluetooth.dart';
import '../../domain/usecases/scan_bluetooth_devices.dart';
import '../../domain/usecases/is_bluetooth_enabled.dart';
import '../../domain/usecases/request_enable_bluetooth.dart';
import '../../domain/usecases/disconnect_from_bluetooth.dart';
import '../../domain/usecases/get_bluetooth_connection_status.dart';
import '../../domain/usecases/send_hid_command.dart';

/// Provider for managing remote control state and operations
class RemoteControlProvider extends ChangeNotifier {
  final ConnectToBluetooth connectToBluetooth;
  final ScanBluetoothDevices scanBluetoothDevices;
  final IsBluetoothEnabled isBluetoothEnabled;
  final RequestEnableBluetooth requestEnableBluetooth;
  final DisconnectFromBluetooth disconnectFromBluetooth;
  final SendHidCommand sendHidCommand;
  final GetBluetoothConnectionStatus getBluetoothConnectionStatus;
  final RemoteControlRepository repository;
  final PreferencesService preferencesService;
  
  RemoteControlProvider({
    required this.connectToBluetooth,
    required this.scanBluetoothDevices,
    required this.isBluetoothEnabled,
    required this.requestEnableBluetooth,
    required this.disconnectFromBluetooth,
    required this.sendHidCommand,
    required this.getBluetoothConnectionStatus,
    required this.repository,
    required this.preferencesService,
  }) {
    _listenToConnectionStatus();
  }
  
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected();
  String _errorMessage = '';
  bool _isConnecting = false;
  bool _isScanning = false;
  String _serverIp = ServerConfig.defaultServerIp;
  int _serverPort = ServerConfig.serverPort;
  List<BluetoothDevice> _availableDevices = [];
  bool _bluetoothEnabled = false;
  
  // Getters
  ConnectionStatus get connectionStatus => _connectionStatus;
  String get errorMessage => _errorMessage;
  bool get isConnecting => _isConnecting;
  bool get isScanning => _isScanning;
  bool get isConnected => _connectionStatus.isConnected;
  String get serverIp => _serverIp;
  int get serverPort => _serverPort;
  List<BluetoothDevice> get availableDevices => _availableDevices;
  bool get bluetoothEnabled => _bluetoothEnabled;
  
  /// Set the server IP address
  void setServerIp(String ip) {
    _serverIp = ip;
    notifyListeners();
  }
  
  /// Set the server port
  void setServerPort(int port) {
    _serverPort = port;
    notifyListeners();
  }
  
  /// Listen to connection status changes from the repository
  void _listenToConnectionStatus() async {
    final statusStreamEither = await getBluetoothConnectionStatus(NoParams());
    statusStreamEither.fold(
      (failure) {
        _errorMessage = failure.message ?? 'Failed to get connection status stream';
        notifyListeners();
      },
      (statusStream) {
        statusStream.listen((status) {
          _connectionStatus = status;
          _isConnecting = false;
          if (!status.isConnected && (status.message?.contains('Error') ?? false)) {
            _errorMessage = status.message ?? 'An unknown error occurred';
          } else {
            _errorMessage = '';
          }
          notifyListeners();
        });
      },
    );
  }
  
  /// Connect to the PC server
  Future<void> connect() async {
    if (_isConnecting) return;
    
    _isConnecting = true;
    _errorMessage = '';
    notifyListeners();
    
    final result = await connectToBluetooth(BluetoothDevice(address: _serverIp));
    
    result.fold(
      (failure) {
        _errorMessage = failure.message ?? '';
        _isConnecting = false;
        notifyListeners();
      },
      (status) {
        _connectionStatus = status;
        _isConnecting = false;
        notifyListeners();
      },
    );
  }
  
  /// Check Bluetooth status
  Future<void> checkBluetoothStatus() async {
    final result = await isBluetoothEnabled(NoParams());
    result.fold(
      (failure) {
        _bluetoothEnabled = false;
        _errorMessage = failure.message ?? '';
        notifyListeners();
      },
      (enabled) {
        _bluetoothEnabled = enabled;
        notifyListeners();
      },
    );
  }
  
  /// Request to enable Bluetooth
  Future<bool> enableBluetooth() async {
    final result = await requestEnableBluetooth(NoParams());
    return result.fold(
      (failure) {
        _errorMessage = failure.message ?? '';
        notifyListeners();
        return false;
      },
      (enabled) {
        _bluetoothEnabled = enabled;
        notifyListeners();
        return enabled;
      },
    );
  }
  
  /// Scan for Bluetooth devices
  Future<void> scanForDevices() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _errorMessage = '';
    notifyListeners();
    
    // Check if Bluetooth is enabled first
    await checkBluetoothStatus();
    
    if (!_bluetoothEnabled) {
      final enabled = await enableBluetooth();
      if (!enabled) {
        _isScanning = false;
        _errorMessage = 'Bluetooth is not enabled';
        notifyListeners();
        return;
      }
    }
    
    final result = await scanBluetoothDevices(NoParams());
    
    result.fold(
      (failure) {
        _errorMessage = failure.message ?? '';
        _isScanning = false;
        notifyListeners();
      },
      (devices) {
        _availableDevices = _sortDevicesByLastConnected(devices);
        _isScanning = false;
        notifyListeners();
      },
    );
  }

  /// Sort devices so last connected device appears first
  List<BluetoothDevice> _sortDevicesByLastConnected(List<BluetoothDevice> devices) {
    final lastConnectedAddress = preferencesService.getLastDeviceAddress();
    
    if (lastConnectedAddress == null || lastConnectedAddress.isEmpty) {
      return devices;
    }
    
    // Sort devices: last connected first, then rest
    final sortedDevices = List<BluetoothDevice>.from(devices);
    sortedDevices.sort((a, b) {
      if (a.address == lastConnectedAddress) return -1;
      if (b.address == lastConnectedAddress) return 1;
      return 0;
    });
    
    return sortedDevices;
  }

  /// Get the last connected device address for UI highlighting
  String? getLastConnectedDeviceAddress() {
    return preferencesService.getLastDeviceAddress();
  }
  
  /// Connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;
    
    _isConnecting = true;
    _errorMessage = '';
    notifyListeners();
    
    final result = await connectToBluetooth(device);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message ?? '';
        _isConnecting = false;
        notifyListeners();
      },
      (status) {
        _connectionStatus = status;
        _isConnecting = false;
        notifyListeners();
      },
    );
  }
  
  /// Disconnect from the PC server
  Future<void> disconnect() async {
    final result = await disconnectFromBluetooth(NoParams());
    
    result.fold(
      (failure) {
        _errorMessage = failure.message ?? 'Unknown error';
        notifyListeners();
      },
      (_) {
        _connectionStatus = ConnectionStatus.disconnected();
        _errorMessage = '';
        notifyListeners();
      },
    );
  }
  
  /// Send a mouse move command
  Future<void> sendMouseMove(int dx, int dy) async {
    final command = RemoteCommand(
      type: CommandTypes.mouseMove,
      data: {'dx': dx, 'dy': dy},
    );
    
    await _sendCommand(command);
  }
  
  /// Send a mouse click command
  Future<void> sendMouseClick(String button) async {
    final command = RemoteCommand(
      type: CommandTypes.mouseClick,
      data: {'button': button},
    );
    
    await _sendCommand(command);
  }
  
  /// Send a key press command
  Future<void> sendKeyPress(String key) async {
    final command = RemoteCommand(
      type: CommandTypes.keyPress,
      data: {'key': key},
    );
    
    await _sendCommand(command);
  }
  
  /// Send a text input command
  Future<void> sendTextInput(String text) async {
    final command = RemoteCommand(
      type: CommandTypes.textInput,
      data: {'text': text},
    );
    
    await _sendCommand(command);
  }
  
  /// Generic method to send any command
  Future<void> _sendCommand(RemoteCommand command) async {
    if (!_connectionStatus.isConnected) {
      _errorMessage = 'Not connected to PC server!';
      notifyListeners();
      return;
    }

    final jsonCommand = jsonEncode(command.toJson());
    final bytes = utf8.encode(jsonCommand);

    final params = SendHidCommandParams(command: bytes);
    final result = await sendHidCommand(params);

    result.fold(
      (failure) {
        _errorMessage = failure.message ?? 'Unknown error';
        notifyListeners();
      },
      (_) {
        // Command sent successfully
        _errorMessage = '';
      },
    );
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
