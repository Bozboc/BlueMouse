import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/remote_control_repository.dart';

class SendHidCommand implements UseCase<void, SendHidCommandParams> {
  final RemoteControlRepository repository;

  SendHidCommand(this.repository);

  @override
  Future<Either<Failure, void>> call(SendHidCommandParams params) async {
    return await repository.sendHidCommand(params.command);
  }
}



class SendHidCommandParams extends Equatable {
  final List<int> command;

  const SendHidCommandParams({required this.command});

  @override
  List<Object> get props => [command];
}
