import 'package:equatable/equatable.dart';

class ConnectionStatus extends Equatable {
  final bool isConnected;
  final String? message;
  final String? serverIp;

  const ConnectionStatus({
    required this.isConnected,
    this.message,
    this.serverIp,
  });

  factory ConnectionStatus.connected(String serverIp) {
    return ConnectionStatus(
      isConnected: true,
      message: 'Connected to $serverIp',
      serverIp: serverIp,
    );
  }

  factory ConnectionStatus.disconnected() {
    return const ConnectionStatus(
      isConnected: false,
      message: 'Disconnected',
    );
  }

  factory ConnectionStatus.error(String message) {
    return ConnectionStatus(
      isConnected: false,
      message: 'Error: $message',
    );
  }

  factory ConnectionStatus.connecting(String serverIp) {
    return ConnectionStatus(
      isConnected: false,
      message: 'Connecting to $serverIp...',
      serverIp: serverIp,
    );
  }

  @override
  List<Object?> get props => [isConnected, message, serverIp];
}
