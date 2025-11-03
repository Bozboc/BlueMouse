import 'package:dartz/dartz.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../../../core/failure/failure.dart';
import '../entities/connection_status.dart';

/// Repository interface for remote control operations.
/// Following the Dependency Inversion Principle, this interface is in the domain layer.
abstract class RemoteControlRepository {
  // --- Legacy Server Methods ---

  /// Connect to the PC server via WiFi.
  Future<Either<Failure, ConnectionStatus>> connect(String serverIp, int port);

  /// Disconnect from the PC server.
  Future<Either<Failure, void>> disconnect();

  /// Send a command to the PC server.
  Future<Either<Failure, void>> sendCommand(List<int> command);

  /// Get the current connection status for the server.
  Either<Failure, ConnectionStatus> getConnectionStatus();

  /// Listen to server connection status changes.
  Stream<ConnectionStatus> watchConnectionStatus();

  /// Listen to messages from the server.
  Stream<String> watchServerMessages();

  // --- Bluetooth HID Methods ---

  /// Connect to a Bluetooth device.
  Future<Either<Failure, ConnectionStatus>> connectBluetooth(
      BluetoothDevice device);

  /// Disconnect from the currently connected Bluetooth device.
  Future<Either<Failure, void>> disconnectFromBluetooth();

  /// Get the Bluetooth connection status as a stream.
  Stream<ConnectionStatus> getBluetoothConnectionStatus();

  /// Scan for available Bluetooth devices.
  Future<Either<Failure, List<BluetoothDevice>>> scanBluetoothDevices();

  /// Send a HID report to the connected device.
  Future<Either<Failure, void>> sendHidCommand(List<int> report);

  /// Check if Bluetooth is enabled on the device.
  Future<Either<Failure, bool>> isBluetoothEnabled();

  /// Request the user to enable Bluetooth.
  Future<Either<Failure, bool>> requestEnableBluetooth();
}

