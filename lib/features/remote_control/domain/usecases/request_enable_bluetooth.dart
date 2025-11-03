import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/remote_control_repository.dart';

/// Use case for requesting to enable Bluetooth
class RequestEnableBluetooth implements UseCase<bool, NoParams> {
  final RemoteControlRepository repository;
  
  RequestEnableBluetooth(this.repository);
  
  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.requestEnableBluetooth();
  }
}
