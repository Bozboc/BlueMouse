import 'package:dartz/dartz.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/remote_control_repository.dart';

/// Use case for scanning Bluetooth devices
class ScanBluetoothDevices implements UseCase<List<BluetoothDevice>, NoParams> {
  final RemoteControlRepository repository;
  
  ScanBluetoothDevices(this.repository);
  
  @override
  Future<Either<Failure, List<BluetoothDevice>>> call(NoParams params) {
    return repository.scanBluetoothDevices();
  }
}
