import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_hid_provider.dart';

class RemoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isKeyboardVisible;
  final VoidCallback onToggleKeyboard;
  final VoidCallback onShowBluetoothDialog;
  final VoidCallback onShowSensitivityDialog;

  const RemoteAppBar({
    super.key,
    required this.isKeyboardVisible,
    required this.onToggleKeyboard,
    required this.onShowBluetoothDialog,
    required this.onShowSensitivityDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF020617), // slate-950
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Consumer<BluetoothHidProvider>(
        builder: (context, provider, _) {
          return Row(
            children: [
              // Monitor Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.monitor,
                  color: Color(0xFF60a5fa), // blue-400
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Title and Connection Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BlueMouse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: provider.isConnected 
                                ? const Color(0xFF22c55e) // green-500
                                : const Color(0xFF94a3b8), // slate-400
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isConnected 
                              ? 'Connected • ${provider.connectedDeviceName ?? "PC"}'
                              : 'Not Connected',
                          style: const TextStyle(
                            color: Color(0xFF94a3b8), // slate-400
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bluetooth Button
              Material(
                color: provider.isConnected 
                    ? const Color(0xFF22c55e) // green-500
                    : const Color(0xFF6b7280), // gray-500
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onShowBluetoothDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.bluetooth,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Settings Button
              Material(
                color: const Color(0xFF334155), // slate-700
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onShowSensitivityDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Keyboard Button
              Material(
                color: isKeyboardVisible
                    ? const Color(0xFF2563eb) // blue-600
                    : const Color(0xFF334155), // slate-700
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onToggleKeyboard,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.keyboard,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 32);
}
