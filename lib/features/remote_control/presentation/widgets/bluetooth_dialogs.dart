import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../providers/bluetooth_hid_provider.dart';

void showBluetoothDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1e293b),
      title: const Row(
        children: [
          Icon(Icons.bluetooth, color: Color(0xFF60a5fa)),
          SizedBox(width: 12),
          Text(
            'Bluetooth Setup',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Consumer<BluetoothHidProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: provider.isConnected 
                              ? const Color(0xFF22c55e)
                              : const Color(0xFF94a3b8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.isConnected 
                              ? 'Connected to ${provider.connectedDeviceName ?? "PC"}'
                              : 'Not Connected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Setup Steps
                if (!provider.isInitialized || !provider.isRegistered || !provider.isConnected) ...[
                  const Text(
                    'Setup Steps:',
                    style: TextStyle(
                      color: Color(0xFF60a5fa),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Step 1: Initialize
                  _buildSetupStep(
                    context: context,
                    number: '1',
                    title: 'Initialize Bluetooth',
                    description: 'Initialize the HID service',
                    isComplete: provider.isInitialized,
                    onTap: () async {
                      await provider.initialize();
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Step 2: Register
                  _buildSetupStep(
                    context: context,
                    number: '2',
                    title: 'Register HID Device',
                    description: 'Register as keyboard/mouse',
                    isComplete: provider.isRegistered,
                    enabled: provider.isInitialized,
                    onTap: () async {
                      await provider.registerHidDevice();
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Step 3: Pair
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: provider.isRegistered
                            ? const Color(0xFF60a5fa)
                            : const Color(0xFF475569),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pair on Windows',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Settings → Bluetooth → Add device',
                          style: TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Step 4: Connect
                  _buildSetupStep(
                    context: context,
                    number: '4',
                    title: 'Connect to PC',
                    description: 'Select your PC from paired devices',
                    isComplete: provider.isConnected,
                    enabled: provider.isRegistered,
                    onTap: () async {
                      final devices = await provider.getPairedDevices();
                      if (context.mounted && devices.isNotEmpty) {
                        _showDeviceList(context, devices);
                      }
                    },
                  ),
                ],
                
                // Connected Actions
                if (provider.isConnected) ...[
                  const Text(
                    'Actions:',
                    style: TextStyle(
                      color: Color(0xFF60a5fa),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await provider.disconnect();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFef4444), // red
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Disconnect'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: Color(0xFF60a5fa)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSetupStep({
  required BuildContext context,
  required String number,
  required String title,
  required String description,
  required bool isComplete,
  bool enabled = true,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isComplete 
                ? const Color(0xFF22c55e)
                : enabled 
                    ? const Color(0xFF60a5fa)
                    : const Color(0xFF475569),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isComplete 
                    ? const Color(0xFF22c55e)
                    : enabled 
                        ? const Color(0xFF60a5fa)
                        : const Color(0xFF475569),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isComplete
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled ? Colors.white : const Color(0xFF94a3b8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (enabled && !isComplete)
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF60a5fa),
                size: 16,
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showDeviceSelectionDialog(BuildContext context) async {
  // Check Bluetooth state first
  final bluetoothState = await FlutterBluetoothSerial.instance.state;
  
  if (bluetoothState == BluetoothState.STATE_OFF) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: const Text(
            'Bluetooth is Off',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please turn on Bluetooth to connect to your PC.',
            style: TextStyle(color: Color(0xFFcbd5e1)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FlutterBluetoothSerial.instance.openSettings();
              },
              child: const Text(
                'Settings',
                style: TextStyle(color: Color(0xFF94a3b8)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FlutterBluetoothSerial.instance.requestEnable();
                // Wait a bit for it to turn on, then try showing list again
                // In a real app we might want to listen to state changes
                if (context.mounted) {
                   // Optional: could retry automatically or just let user tap again
                }
              },
              child: const Text(
                'Turn On',
                style: TextStyle(color: Color(0xFF60a5fa)),
              ),
            ),
          ],
        ),
      );
    }
    return;
  }

  final provider = Provider.of<BluetoothHidProvider>(context, listen: false);
  
  // Show loading if needed, or just get devices
  // For now, let's just get the devices directly
  final devices = await provider.getPairedDevices();
  
  if (context.mounted) {
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No paired devices found. Please pair in Android Settings.'),
          backgroundColor: Color(0xFFef4444),
        ),
      );
      return;
    }
    _showDeviceList(context, devices);
  }
}

void _showDeviceList(BuildContext context, List<Map<String, String>> devices) {
  showDialog(
    context: context,
    builder: (context) {
      String? connectingAddress;
      
      return StatefulBuilder(
        builder: (context, setState) {
          return Consumer<BluetoothHidProvider>(
            builder: (context, provider, _) {
              // Sort devices: Last connected first, then alphabetical
              final sortedDevices = List<Map<String, String>>.from(devices);
              final lastAddress = provider.lastConnectedDeviceAddress;
              
              sortedDevices.sort((a, b) {
                if (lastAddress != null) {
                  if (a['address'] == lastAddress) return -1;
                  if (b['address'] == lastAddress) return 1;
                }
                return (a['name'] ?? '').compareTo(b['name'] ?? '');
              });

              return AlertDialog(
                backgroundColor: const Color(0xFF1e293b),
                title: const Text(
                  'Select PC',
                  style: TextStyle(color: Colors.white),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sortedDevices.length,
                    itemBuilder: (context, index) {
                      final device = sortedDevices[index];
                      final isConnecting = device['address'] == connectingAddress;
                      final isAnyConnecting = connectingAddress != null;
                      final isCurrentDevice = device['address'] == provider.connectedDeviceAddress;
                      final isConnected = provider.isConnected && isCurrentDevice;
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isAnyConnecting ? null : () async {
                            // If connected to this device, disconnect
                            if (isConnected) {
                              await provider.disconnect();
                              return;
                            }
                            
                            // If connected to another device, don't allow connecting (optional, but safer)
                            if (provider.isConnected && !isCurrentDevice) {
                              return; 
                            }

                            setState(() {
                              connectingAddress = device['address'];
                            });
                            
                            try {
                              await provider.connectToHost(device['address']!);
                              
                              // Poll for connection success
                              for (int i = 0; i < 10; i++) {
                                if (!context.mounted) break;
                                await Future.delayed(const Duration(milliseconds: 500));
                                if (provider.isConnected) {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                  return;
                                }
                                if (provider.errorMessage.isNotEmpty) break;
                              }
                              
                              if (context.mounted) {
                                setState(() {
                                  connectingAddress = null;
                                });
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() {
                                  connectingAddress = null;
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isConnected 
                                  ? const Color(0xFF22c55e).withOpacity(0.1)
                                  : const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(8),
                              border: isConnected 
                                  ? Border.all(color: const Color(0xFF22c55e))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.computer,
                                  color: isConnected ? const Color(0xFF22c55e) : const Color(0xFF60a5fa),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        device['address'] ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFF94a3b8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isConnecting)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF60a5fa),
                                    ),
                                  )
                                else if (isConnected)
                                  const Icon(
                                    Icons.power_settings_new,
                                    color: Color(0xFFef4444),
                                    size: 20,
                                  )
                                else
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFF60a5fa),
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  if (connectingAddress == null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Color(0xFF94a3b8)),
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
