import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/remote_control_repository.dart';

/// Use case for checking if Bluetooth is enabled
class IsBluetoothEnabled implements UseCase<bool, NoParams> {
  final RemoteControlRepository repository;
  
  IsBluetoothEnabled(this.repository);
  
  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.isBluetoothEnabled();
  }
}
