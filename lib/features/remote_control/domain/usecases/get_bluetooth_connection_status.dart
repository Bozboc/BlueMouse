import 'package:dartz/dartz.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/connection_status.dart';
import '../repositories/remote_control_repository.dart';

class GetBluetoothConnectionStatus
    implements UseCase<Stream<ConnectionStatus>, NoParams> {
  final RemoteControlRepository repository;

  GetBluetoothConnectionStatus(this.repository);

  @override
  Future<Either<Failure, Stream<ConnectionStatus>>> call(
      NoParams params) async {
    return Right(repository.getBluetoothConnectionStatus());
  }
}
