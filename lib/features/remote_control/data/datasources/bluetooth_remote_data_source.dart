import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/connection_status_model.dart';
import '../models/remote_command_model.dart';

/// Abstract interface for Bluetooth remote data source
abstract class BluetoothRemoteDataSource {
  /// Scan for available Bluetooth devices
  Future<List<BluetoothDevice>> scanDevices();
  
  /// Connect to a Bluetooth device
  Future<ConnectionStatusModel> connect(BluetoothDevice device);
  
  /// Disconnect from the Bluetooth device
  Future<void> disconnect();
  
  /// Send a command to the device
  Future<void> sendCommand(RemoteCommandModel command);
  
  /// Get the current connection status
  ConnectionStatusModel getConnectionStatus();
  
  /// Listen to connection status changes
  Stream<ConnectionStatusModel> watchConnectionStatus();
  
  /// Listen to messages from the device
  Stream<String> watchDeviceMessages();
  
  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled();
  
  /// Request to enable Bluetooth
  Future<bool> requestEnableBluetooth();

  /// Send a HID command to the device
  Future<void> sendHidCommand(List<int> report);
}

/// Implementation of Bluetooth data source
class BluetoothRemoteDataSourceImpl implements BluetoothRemoteDataSource {
  BluetoothConnection? _connection;
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  
  final StreamController<ConnectionStatusModel> _statusController = 
      StreamController<ConnectionStatusModel>.broadcast();
  final StreamController<String> _messageController = 
      StreamController<String>.broadcast();
  
  ConnectionStatusModel _currentStatus = ConnectionStatusModel.disconnected();
  
  @override
  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      // Check if Bluetooth is enabled
      final isEnabled = await isBluetoothEnabled();
      if (!isEnabled) {
        throw Exception('Bluetooth is not enabled');
      }
      
      // Get bonded (paired) devices
      final bondedDevices = await _bluetooth.getBondedDevices();
      return bondedDevices;
    } catch (e) {
      throw Exception('Failed to scan devices: $e');
    }
  }
  
  @override
  Future<ConnectionStatusModel> connect(BluetoothDevice device) async {
    try {
      // Update status to connecting
      _currentStatus = ConnectionStatusModel.connecting(device.address);
      _statusController.add(_currentStatus);
      
      // Disconnect if already connected
      if (_connection != null && _connection!.isConnected) {
        await disconnect();
      }
      

      
      // Connect to the device with timeout
      try {
        _connection = await BluetoothConnection.toAddress(device.address)
            .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Connection timeout - Device is not responding. Make sure the Bluetooth server is running on the target device.');
          },
        );
      } catch (e) {
        if (e.toString().contains('read failed')) {
          throw Exception('Connection failed: Device not accepting connections. Please ensure:\n1. The Windows Bluetooth server is running\n2. Devices are properly paired\n3. No firewall is blocking the connection');
        } else if (e.toString().contains('timeout')) {
          throw Exception(e.toString());
        } else {
          throw Exception('Connection error: $e');
        }
      }
      
      // Check if connection was successful
      if (_connection == null || !_connection!.isConnected) {
        throw Exception('Failed to establish Bluetooth connection - Connection object is null or not connected');
      }
      

      
      // Listen to incoming data
      _connection!.input!.listen(
        (Uint8List data) {
          // Convert bytes to string
          final message = String.fromCharCodes(data);
          _messageController.add(message);
        },
        onDone: () {
          _currentStatus = ConnectionStatusModel.disconnected();
          _statusController.add(_currentStatus);
          _connection = null;
        },
        onError: (error) {
          _currentStatus = ConnectionStatusModel.error(error.toString());
          _statusController.add(_currentStatus);
          _connection = null;
        },
      );
      
      // Update status to connected first
      _currentStatus = ConnectionStatusModel.connected(device.name ?? 'Unknown Device');
      _statusController.add(_currentStatus);
      
      // Send initial handshake after connection is established
      try {
        const connectCommand = RemoteCommandModel(
          type: 'connect',
          data: {'device': 'android_hmi'},
        );
        await sendCommand(connectCommand);
      } catch (e) {
        // Handshake failed but connection is established
      }
      
      return _currentStatus;
    } catch (e) {
      _currentStatus = ConnectionStatusModel.error('Failed to connect: $e');
      _statusController.add(_currentStatus);
      _connection = null;
      throw Exception('Failed to connect: $e');
    }
  }
  
  @override
  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _connection!.close();
        _connection = null;
      }
      _currentStatus = ConnectionStatusModel.disconnected();
      _statusController.add(_currentStatus);
    } catch (e) {
      throw Exception('Failed to disconnect: $e');
    }
  }
  
  @override
  Future<void> sendCommand(RemoteCommandModel command) async {
    if (_connection == null || !(_connection?.isConnected ?? false)) {
      throw Exception('Not connected to device');
    }
    
    try {
      // Convert command to JSON string and then to bytes
      final jsonCommand = jsonEncode(command.toJson());
      final bytes = utf8.encode('$jsonCommand\n'); // Add newline delimiter
      
      _connection!.output.add(Uint8List.fromList(bytes));
      await _connection!.output.allSent;
    } catch (e) {
      throw Exception('Failed to send command: $e');
    }
  }

  @override
  Future<void> sendHidCommand(List<int> report) async {
    if (_connection == null || !(_connection?.isConnected ?? false)) {
      throw Exception('Not connected to device');
    }

    try {
      _connection!.output.add(Uint8List.fromList(report));
      await _connection!.output.allSent;
    } catch (e) {
      throw Exception('Failed to send HID report: $e');
    }
  }

  @override
  ConnectionStatusModel getConnectionStatus() {
    return _currentStatus;
  }
  
  @override
  Stream<ConnectionStatusModel> watchConnectionStatus() {
    return _statusController.stream;
  }
  
  @override
  Stream<String> watchDeviceMessages() {
    return _messageController.stream;
  }
  
  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      final isEnabled = await _bluetooth.isEnabled;
      return isEnabled ?? false;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> requestEnableBluetooth() async {
    try {
      final result = await _bluetooth.requestEnable();
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose the data source and close streams
  void dispose() {
    _statusController.close();
    _messageController.close();
    _connection?.close();
  }
}
