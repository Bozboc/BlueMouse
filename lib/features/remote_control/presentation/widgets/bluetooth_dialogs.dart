import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

void _showDeviceList(BuildContext context, List<Map<String, String>> devices) {
  final navigator = Navigator.of(context);
  navigator.pop(); // Close bluetooth dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1e293b),
      title: const Text(
        'Select PC',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final dialogNavigator = Navigator.of(context);
                  await Provider.of<BluetoothHidProvider>(context, listen: false)
                      .connectToHost(device['address']!);
                  dialogNavigator.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.computer,
                        color: Color(0xFF60a5fa),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF94a3b8)),
          ),
        ),
      ],
    ),
  );
}
