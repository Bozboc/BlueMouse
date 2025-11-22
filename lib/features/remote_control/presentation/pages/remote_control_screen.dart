import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:blue_mouse/core/services/models.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/bluetooth_hid_provider.dart';
import '../widgets/remote_app_bar.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/trackpad_section.dart';
import '../widgets/bluetooth_dialogs.dart';
import '../widgets/sensitivity_dialog.dart';

class RemoteControlScreen extends StatefulWidget {
  const RemoteControlScreen({super.key});

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> with WidgetsBindingObserver {
  // State for UI elements
  bool _isKeyboardVisible = false;
  final FocusNode _focusNode = FocusNode();
  bool _isDragging = false;
  double _accumulatedDx = 0.0; // Accumulate fractional x movement
  double _accumulatedDy = 0.0; // Accumulate fractional y movement

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Enable wake lock to keep screen on
    _enableWakeLock();
    
    // Request focus when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        // Add listener for provider changes
        context.read<BluetoothHidProvider>().addListener(_onProviderStateChanged);
      }
    });
  }

  void _onProviderStateChanged() {
    if (!mounted) return;
    final provider = context.read<BluetoothHidProvider>();
    
    // Show error message if any
    if (provider.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: const Color(0xFFef4444),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      provider.clearError();
    }
    
    // Show connection success
    if (provider.isConnected && !_wasConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${provider.connectedDeviceName ?? "Device"}'),
          backgroundColor: const Color(0xFF22c55e),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
    _wasConnected = provider.isConnected;
  }
  
  bool _wasConnected = false;

  @override
  void dispose() {
    // Disable wake lock when leaving the screen
    _disableWakeLock();
    _disableWakeLock();
    WidgetsBinding.instance.removeObserver(this);
    // Remove listener
    if (mounted) {
      try {
        context.read<BluetoothHidProvider>().removeListener(_onProviderStateChanged);
      } catch (_) {}
    }
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _enableWakeLock() async {
    try {
      await WakelockPlus.enable();
      debugPrint('🔒 Wake lock enabled - screen will stay on');
    } catch (e) {
      debugPrint('❌ Failed to enable wake lock: $e');
    }
  }

  Future<void> _disableWakeLock() async {
    try {
      await WakelockPlus.disable();
      debugPrint('🔓 Wake lock disabled');
    } catch (e) {
      debugPrint('❌ Failed to disable wake lock: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle screen on/off for reconnection
    if (state == AppLifecycleState.resumed) {
      // Screen turned back on or app resumed
      debugPrint('📱 App resumed - checking Bluetooth connection');
      _reconnectIfNeeded();
    } else if (state == AppLifecycleState.paused) {
      // App paused (screen locked manually)
      debugPrint('📱 App paused - screen locked');
    }
  }

  Future<void> _reconnectIfNeeded() async {
    final provider = context.read<BluetoothHidProvider>();
    
    // If not connected, try to reconnect to last device
    if (!provider.isConnected && !provider.isConnecting) {
      debugPrint('🔄 Attempting to reconnect...');
      
      // Reinitialize and reconnect
      try {
        await provider.initialize();
      } catch (e) {
        debugPrint('❌ Reconnection failed: $e');
      }
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final keyboardVisible = View.of(context).viewInsets.bottom > 0;
    if (keyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = keyboardVisible;
      });
    }
  }

  // --- Keyboard Control ---

  void _toggleKeyboard() {
    if (!mounted) return;
    
    if (_isKeyboardVisible) {
      _hideKeyboard();
    } else {
      _showKeyboard();
    }
  }

  void _showKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
    if (mounted) {
      setState(() {
        _isKeyboardVisible = true;
      });
    }
  }

  void _hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (mounted) {
      setState(() {
        _isKeyboardVisible = false;
      });
    }
  }
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final provider = context.read<BluetoothHidProvider>();
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        provider.sendKeyPress('backspace');
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        provider.sendKeyPress('enter');
        return KeyEventResult.handled;
      } else if (event.character != null && event.character!.isNotEmpty) {
        provider.sendKeyPress(event.character!);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      // Accumulate fractional movement
      _accumulatedDx += details.delta.dx;
      _accumulatedDy += details.delta.dy;
      
      // Only send movement when accumulated values reach at least 1 pixel
      final int dx = _accumulatedDx.truncate();
      final int dy = _accumulatedDy.truncate();
      
      if (dx != 0 || dy != 0) {
        context.read<BluetoothHidProvider>().sendMove(dx, dy);
        // Subtract the sent amount, keeping the fractional remainder
        _accumulatedDx -= dx;
        _accumulatedDy -= dy;
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _accumulatedDx = 0.0; // Reset accumulator
      _accumulatedDy = 0.0; // Reset accumulator
    });
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a), // slate-900
      body: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: SafeArea(
          child: Column(
            children: [
              RemoteAppBar(
                isKeyboardVisible: _isKeyboardVisible,
                onToggleKeyboard: _toggleKeyboard,
                onShowBluetoothDialog: () => showDeviceSelectionDialog(context),
                onShowSensitivityDialog: () => showSensitivityDialog(context),
              ),
              QuickActionsGrid(
                onVolumeUp: _volumeUp,
                onVolumeDown: _volumeDown,
                onMute: _mute,
                onPrevious: _previous,
                onPlayPause: _playPause,
                onNext: _next,
              ),
              Expanded(
                child: TrackpadSection(
                  trackpadActive: _isDragging,
                  onPanStart: _handlePanStart,
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  onScroll: (dx, dy) {
                    context.read<BluetoothHidProvider>().sendScroll(
                          dx.round(),
                          dy.round(),
                        );
                  },
                  onLeftClick: () => context.read<BluetoothHidProvider>().sendClick(ClickType.left),
                  onRightClick: () => context.read<BluetoothHidProvider>().sendClick(ClickType.right),
                  onLeftMouseDown: () => _mouseButtonDown(ClickType.left),
                  onLeftMouseUp: () => _mouseButtonUp(ClickType.left),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HID Actions ---
  void _mouseButtonDown(ClickType type) {
    context.read<BluetoothHidProvider>().sendMouseButtonState(type, true);
  }

  void _mouseButtonUp(ClickType type) {
    context.read<BluetoothHidProvider>().sendMouseButtonState(type, false);
  }

  void _volumeUp() {
    context.read<BluetoothHidProvider>().sendKeyPress('volume_up');
  }

  void _volumeDown() {
    context.read<BluetoothHidProvider>().sendKeyPress('volume_down');
  }

  void _mute() {
    context.read<BluetoothHidProvider>().sendKeyPress('mute');
  }

  void _previous() {
    context.read<BluetoothHidProvider>().sendKeyPress('media_previous');
  }

  void _playPause() {
    context.read<BluetoothHidProvider>().sendKeyPress('media_play_pause');
  }

  void _next() {
    context.read<BluetoothHidProvider>().sendKeyPress('media_next');
  }
}
