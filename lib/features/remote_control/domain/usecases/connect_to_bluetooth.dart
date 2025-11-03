import 'package:dartz/dartz.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/connection_status.dart';
import '../repositories/remote_control_repository.dart';

/// Use case for connecting to a Bluetooth device
class ConnectToBluetooth implements UseCase<ConnectionStatus, BluetoothDevice> {
  final RemoteControlRepository repository;
  
  ConnectToBluetooth(this.repository);
  
  @override
  Future<Either<Failure, ConnectionStatus>> call(BluetoothDevice device) {
    return repository.connectBluetooth(device);
  }
}
