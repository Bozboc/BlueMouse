import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_hid_provider.dart';

void showSensitivityDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return _SensitivityDialog();
    },
  );
}

class _SensitivityDialog extends StatefulWidget {
  @override
  State<_SensitivityDialog> createState() => _SensitivityDialogState();
}

class _SensitivityDialogState extends State<_SensitivityDialog> {
  late double _sensitivity;
  
  @override
  void initState() {
    super.initState();
    _sensitivity = context.read<BluetoothHidProvider>().trackpadSensitivity;
  }
  
  String _getSensitivityLabel(double value) {
    if (value < 0.6) return 'Normal';
    if (value < 0.9) return 'Faster';
    if (value < 1.3) return 'Fast';
    if (value < 1.7) return 'Very Fast';
    return 'Ultra Fast';
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFF334155),
          width: 2,
        ),
      ),
      title: const Row(
        children: [
          Icon(Icons.tune, color: Color(0xFF60a5fa)),
          SizedBox(width: 12),
          Text(
            'Trackpad Sensitivity',
            style: TextStyle(
              color: Color(0xFFf1f5f9),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getSensitivityLabel(_sensitivity),
            style: const TextStyle(
              color: Color(0xFF60a5fa),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_sensitivity * 100).round()}%',
            style: const TextStyle(
              color: Color(0xFF94a3b8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF60a5fa),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFF60a5fa),
              overlayColor: const Color(0xFF60a5fa).withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _sensitivity,
              min: 0.5,
              max: 2.0,
              divisions: 30,
              onChanged: (value) {
                setState(() {
                  _sensitivity = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.5x',
                style: TextStyle(color: Color(0xFF64748b), fontSize: 12),
              ),
              Text(
                '2.0x',
                style: TextStyle(color: Color(0xFF64748b), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF94a3b8)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<BluetoothHidProvider>().setTrackpadSensitivity(_sensitivity);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF60a5fa),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
