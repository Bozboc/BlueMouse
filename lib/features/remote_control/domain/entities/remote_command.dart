import 'package:equatable/equatable.dart';

class RemoteCommand extends Equatable {
  final String type;
  final Map<String, dynamic> data;

  const RemoteCommand({
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ...data,
    };
  }

  @override
  List<Object?> get props => [type, data];
}
