import '../../domain/entities/remote_command.dart';

/// Data model for RemoteCommand
/// Extends the domain entity and adds JSON serialization
class RemoteCommandModel extends RemoteCommand {
  const RemoteCommandModel({
    required super.type,
    required super.data,
  });
  
  /// Create a RemoteCommandModel from JSON
  factory RemoteCommandModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final data = Map<String, dynamic>.from(json)..remove('type');
    
    return RemoteCommandModel(
      type: type,
      data: data,
    );
  }
  
  /// Convert the model to JSON
  @override
  @override
  @override
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ...data,
    };
  }
  
  /// Create a RemoteCommandModel from a domain entity
  factory RemoteCommandModel.fromEntity(RemoteCommand command) {
    return RemoteCommandModel(
      type: command.type,
      data: command.data,
    );
  }
}
