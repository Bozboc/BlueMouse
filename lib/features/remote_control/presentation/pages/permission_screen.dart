import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_hid_provider.dart';
import 'remote_control_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isChecking = true;
  bool _hasPermissions = false;
  String _statusMessage = 'Checking permissions...';

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Checking permissions...';
    });

    // Check if all required permissions are granted
    final bluetoothConnect = await Permission.bluetoothConnect.status;
    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetooth = await Permission.bluetooth.status;
    final location = await Permission.location.status;

    if (bluetoothConnect.isGranted &&
        bluetoothScan.isGranted &&
        bluetooth.isGranted &&
        location.isGranted) {
      setState(() {
        _hasPermissions = true;
        _statusMessage = 'All permissions granted!';
      });
      _initializeAndNavigate();
      return;
    }

    // Request permissions
    setState(() {
      _statusMessage = 'Requesting Bluetooth permissions...';
    });

    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    setState(() {
      _hasPermissions = allGranted;
      _isChecking = false;
      if (allGranted) {
        _statusMessage = 'All permissions granted!';
      } else {
        _statusMessage = 'Some permissions were denied. Please grant all permissions to use this app.';
      }
    });

    if (allGranted) {
      _initializeAndNavigate();
    }
  }

  Future<void> _initializeAndNavigate() async {
    // Give a moment for the permissions to settle
    await Future.delayed(const Duration(milliseconds: 500));

    // Initialize Bluetooth HID
    if (mounted) {
      final provider = context.read<BluetoothHidProvider>();
      await provider.initialize();

      // Navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RemoteControlScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.bluetooth,
                    size: 80,
                    color: Color(0xFF60a5fa),
                  ),
                ),
                const SizedBox(height: 32),

                // App Title
                const Text(
                  'BlueMouse',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),

                // Status Indicator
                if (_isChecking)
                  const CircularProgressIndicator(
                    color: Color(0xFF60a5fa),
                  )
                else if (_hasPermissions)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF22c55e),
                    size: 64,
                  )
                else
                  const Icon(
                    Icons.error,
                    color: Color(0xFFef4444),
                    size: 64,
                  ),

                const SizedBox(height: 24),

                // Status Message
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF94a3b8),
                  ),
                ),

                const SizedBox(height: 48),

                // Retry Button (if permissions denied)
                if (!_isChecking && !_hasPermissions)
                  ElevatedButton(
                    onPressed: _checkAndRequestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563eb),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Grant Permissions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Info Text
                const Text(
                  'This app needs Bluetooth permissions to\ncontrol your PC remotely',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
