import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/remote_control_provider.dart';

/// Screen for selecting and connecting to a Bluetooth device
class BluetoothDeviceSelectionScreen extends StatefulWidget {
  const BluetoothDeviceSelectionScreen({super.key});

  @override
  State<BluetoothDeviceSelectionScreen> createState() => _BluetoothDeviceSelectionScreenState();
}

class _BluetoothDeviceSelectionScreenState extends State<BluetoothDeviceSelectionScreen> {
  String _lastError = '';
  
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request Bluetooth and Location permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    // Automatically scan for devices after permissions
    if (mounted) {
      final provider = Provider.of<RemoteControlProvider>(context, listen: false);
      await provider.checkBluetoothStatus();
      if (provider.bluetoothEnabled) {
        provider.scanForDevices();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bluetooth Device'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RemoteControlProvider>(
        builder: (context, provider, child) {
          // Show error as SnackBar when it changes
          if (provider.errorMessage.isNotEmpty && provider.errorMessage != _lastError) {
            _lastError = provider.errorMessage;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 8),
                  action: SnackBarAction(
                    label: 'DISMISS',
                    textColor: Colors.white,
                    onPressed: () {
                      provider.clearError();
                    },
                  ),
                ),
              );
            });
          }
          
          if (!provider.bluetoothEnabled) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bluetooth_disabled,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bluetooth is not enabled',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final enabled = await provider.enableBluetooth();
                      if (enabled && mounted) {
                        provider.scanForDevices();
                      }
                    },
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Enable Bluetooth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.isScanning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Scanning for devices...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      provider.errorMessage,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.clearError();
                        provider.scanForDevices();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.availableDevices.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bluetooth_searching,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Bluetooth devices found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Make sure your PC Bluetooth is on and paired',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.scanForDevices(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Available Devices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => provider.scanForDevices(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = provider.availableDevices[index];
                    final isLastConnected = device.address == provider.getLastConnectedDeviceAddress();
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isLastConnected ? Colors.blue.shade50 : null,
                      elevation: isLastConnected ? 4 : 1,
                      child: ListTile(
                        leading: Stack(
                          children: [
                            Icon(
                              Icons.devices,
                              size: 40,
                              color: isLastConnected ? Colors.blue.shade700 : Colors.blue,
                            ),
                            if (isLastConnected)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                device.name ?? 'Unknown Device',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isLastConnected ? FontWeight.w700 : FontWeight.w600,
                                  color: isLastConnected ? Colors.blue.shade900 : null,
                                ),
                              ),
                            ),
                            if (isLastConnected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Last Used',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          device.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: isLastConnected ? Colors.blue.shade700 : Colors.grey.shade600,
                          ),
                        ),
                        trailing: provider.isConnecting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: isLastConnected ? Colors.blue.shade700 : null,
                              ),
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await provider.connectToDevice(device);
                          if (provider.isConnected) {
                            navigator.pop();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
