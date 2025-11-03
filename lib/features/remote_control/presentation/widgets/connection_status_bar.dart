import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/remote_control_provider.dart';
import '../screens/bluetooth_device_selection_screen.dart';

/// Widget for displaying and controlling connection status
class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RemoteControlProvider>(
      builder: (context, provider, child) {
        final isConnected = provider.isConnected;
        final status = provider.connectionStatus;
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: isConnected ? Colors.green.shade600 : Colors.red.shade600,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  status.message ?? 'Unknown Status',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!provider.isConnecting) ...[
                IconButton(
                  icon: const Icon(Icons.bluetooth, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BluetoothDeviceSelectionScreen(),
                      ),
                    );
                  },
                  tooltip: 'Select Bluetooth Device',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    if (isConnected) {
                      provider.disconnect();
                    } else {
                      provider.scanForDevices();
                    }
                  },
                  tooltip: isConnected ? 'Disconnect' : 'Scan Devices',
                ),
              ]
              else
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
