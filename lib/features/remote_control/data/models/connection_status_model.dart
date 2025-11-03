import '../../domain/entities/connection_status.dart';

/// Data model for ConnectionStatus
/// Extends the domain entity
class ConnectionStatusModel extends ConnectionStatus {
  const ConnectionStatusModel({
    required super.isConnected,
    required super.message,
    super.serverIp,
  });
  
  /// Factory for disconnected state
  factory ConnectionStatusModel.disconnected() {
    return const ConnectionStatusModel(
      isConnected: false,
      message: 'Disconnected',
    );
  }
  
  /// Factory for connecting state
  factory ConnectionStatusModel.connecting(String serverIp) {
    return ConnectionStatusModel(
      isConnected: false,
      message: 'Connecting to $serverIp...',
      serverIp: serverIp,
    );
  }
  
  /// Factory for connected state
  factory ConnectionStatusModel.connected(String serverIp) {
    return ConnectionStatusModel(
      isConnected: true,
      message: 'Connected to $serverIp',
      serverIp: serverIp,
    );
  }
  
  /// Factory for error state
  factory ConnectionStatusModel.error(String errorMessage) {
    return ConnectionStatusModel(
      isConnected: false,
      message: 'Error: $errorMessage',
    );
  }
  
  /// Create a model from a domain entity
  factory ConnectionStatusModel.fromEntity(ConnectionStatus status) {
    return ConnectionStatusModel(
      isConnected: status.isConnected,
      message: status.message,
      serverIp: status.serverIp,
    );
  }
}
