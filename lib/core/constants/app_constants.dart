/// Server configuration constants
class ServerConfig {
  /// Default PC server IP (must be replaced with actual IP)
  static const String defaultServerIp = '192.168.1.XX';
  
  /// Server port
  static const int serverPort = 8080;
  
  /// Connection timeout in seconds
  static const int connectionTimeout = 5;
  
  /// Reconnection delay in seconds
  static const int reconnectionDelay = 3;
}

/// Command types for remote control
class CommandTypes {
  static const String connect = 'connect';
  static const String mouseMove = 'mouse_move';
  static const String mouseClick = 'mouse_click';
  static const String keyPress = 'key_press';
  static const String textInput = 'text_input';
  static const String volumeUp = 'volume_up';
  static const String volumeDown = 'volume_down';
  static const String volumeMute = 'volume_mute';
}

/// Mouse button types
class MouseButtons {
  static const String left = 'left';
  static const String right = 'right';
  static const String double = 'double';
}

/// Keyboard key names
class KeyboardKeys {
  static const String space = 'space';
  static const String enter = 'enter';
  static const String esc = 'esc';
  static const String winL = 'win+l';
  static const String ctrlC = 'ctrl+c';
  static const String altF4 = 'alt+f4';
}
