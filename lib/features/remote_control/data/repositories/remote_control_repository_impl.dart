import 'package:dartz/dartz.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../../../core/failure/failure.dart';
import '../../domain/entities/connection_status.dart';

import '../../domain/repositories/remote_control_repository.dart';
import '../datasources/bluetooth_remote_data_source.dart';

/// Implementation of the RemoteControlRepository
/// Handles error conversion and delegates to the data source
class RemoteControlRepositoryImpl implements RemoteControlRepository {
  final BluetoothRemoteDataSource bluetoothDataSource;

  RemoteControlRepositoryImpl({
    required this.bluetoothDataSource,
  });

  @override
  Future<Either<Failure, ConnectionStatus>> connect(
      String serverIp, int port) async {
    // WiFi connection disabled - use Bluetooth instead
    return const Left(ConnectionFailure(
        message: 'WiFi connection not supported. Please use Bluetooth.'));
  }

  @override
  Future<Either<Failure, ConnectionStatus>> connectBluetooth(
      BluetoothDevice device) async {
    try {
      final status = await bluetoothDataSource.connect(device);
      return Right(status);
    } catch (e) {
      return Left(ConnectionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BluetoothDevice>>> scanBluetoothDevices() async {
    try {
      final devices = await bluetoothDataSource.scanDevices();
      return Right(devices);
    } catch (e) {
      return Left(ConnectionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBluetoothEnabled() async {
    try {
      final isEnabled = await bluetoothDataSource.isBluetoothEnabled();
      return Right(isEnabled);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestEnableBluetooth() async {
    try {
      final result = await bluetoothDataSource.requestEnableBluetooth();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    try {
      await bluetoothDataSource.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(ConnectionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendCommand(List<int> command) async {
    // This is for the legacy server, but we can route it to HID for now
    return sendHidCommand(command);
  }

  @override
  Either<Failure, ConnectionStatus> getConnectionStatus() {
    try {
      final status = bluetoothDataSource.getConnectionStatus();
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<ConnectionStatus> watchConnectionStatus() {
    return bluetoothDataSource.watchConnectionStatus();
  }

  @override
  Stream<String> watchServerMessages() {
    // Return an empty stream as this is a legacy server feature
    return Stream.value('');
  }

  @override
  Future<Either<Failure, void>> disconnectFromBluetooth() async {
    try {
      await bluetoothDataSource.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(ConnectionFailure(message: e.toString()));
    }
  }

  @override
  Stream<ConnectionStatus> getBluetoothConnectionStatus() {
    return bluetoothDataSource.watchConnectionStatus();
  }

  @override
  Future<Either<Failure, void>> sendHidCommand(List<int> report) async {
    try {
      await bluetoothDataSource.sendHidCommand(report);
      return const Right(null);
    } catch (e) {
      return Left(CommandFailure(message: e.toString()));
    }
  }
}
