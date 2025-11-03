import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/remote_control_repository.dart';

class DisconnectFromBluetooth implements UseCase<void, NoParams> {
  final RemoteControlRepository repository;

  DisconnectFromBluetooth(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.disconnectFromBluetooth();
  }
}
