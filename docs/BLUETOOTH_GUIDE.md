# Bluetooth HID Connection Guide

## Overview
This Flutter app has been updated to connect to your Windows PC via Bluetooth instead of WiFi. The app acts as a Bluetooth HID (Human Interface Device) to remotely control your Windows PC.

## Changes Made

### 1. **Dependencies Added**
- `flutter_bluetooth_serial`: For Bluetooth Classic communication
- `permission_handler`: To handle Android Bluetooth permissions

### 2. **Android Configuration**
- **Permissions**: Added Bluetooth permissions in `AndroidManifest.xml`
  - BLUETOOTH
  - BLUETOOTH_ADMIN
  - BLUETOOTH_CONNECT
  - BLUETOOTH_SCAN
  - BLUETOOTH_ADVERTISE (Android 12+)
  - ACCESS_FINE_LOCATION
  - ACCESS_COARSE_LOCATION

- **Minimum SDK**: Updated to API 21 (Android 5.0) for Bluetooth LE support

### 3. **New Features**
- **Bluetooth Device Scanner**: Scan for paired Bluetooth devices
- **Device Selection Screen**: Choose which Bluetooth device to connect to
- **Automatic Bluetooth Check**: App checks if Bluetooth is enabled on launch
- **Permission Handling**: Automatic request for required permissions

### 4. **Architecture Changes**
- Created `BluetoothRemoteDataSource` to replace WiFi WebSocket connection
- Updated repository to support both WiFi and Bluetooth
- Added new use cases:
  - `ScanBluetoothDevices`
  - `ConnectToBluetooth`
  - `IsBluetoothEnabled`
  - `RequestEnableBluetooth`

## How to Use

### Step 1: Pair Your Devices
1. On your Windows PC:
   - Open **Settings** → **Devices** → **Bluetooth & other devices**
   - Turn on Bluetooth
   - Make your PC discoverable

2. On your Android phone:
   - Go to **Settings** → **Bluetooth**
   - Search for your PC
   - Pair with your PC

### Step 2: Run the App
1. Launch the app on your Android device
2. Grant Bluetooth and Location permissions when prompted
3. Tap the **Bluetooth icon** in the app bar
4. Select your PC from the list of paired devices
5. Wait for connection to establish

### Step 3: Control Your PC
Once connected, you can:
- Use the touchpad to move the mouse cursor
- Tap to click (left/right/middle click)
- Use quick controls for keyboard shortcuts
- Type text using the text input panel

## Windows Server Requirements

Your Windows PC needs to have a Bluetooth server application running that can:
1. Accept incoming Bluetooth connections
2. Receive JSON commands in this format:
```json
{
  "type": "mouse_move",
  "data": {"dx": 10, "dy": -5}
}
```

3. Execute the corresponding actions (mouse movement, clicks, keyboard input)

### Command Types
- `connect`: Initial handshake
- `mouse_move`: Move cursor by delta x/y
- `mouse_click`: Click with button (left/right/middle)
- `key_press`: Press keyboard key
- `text_input`: Type text

## Troubleshooting

### Connection Issues
- **Can't find device**: Ensure devices are paired in system settings first
- **Connection fails**: Check if Windows Bluetooth server is running
- **Permission denied**: Go to app settings and grant all Bluetooth permissions

### Bluetooth Not Enabled
- The app will prompt you to enable Bluetooth
- If prompt doesn't work, enable manually in Android settings

### No Devices Found
- Make sure your PC and phone are already paired
- The app only shows **bonded/paired** devices
- Re-scan by tapping the refresh button

## Development Notes

### File Structure
```
lib/
  features/
    remote_control/
      data/
        datasources/
          bluetooth_remote_data_source.dart  (NEW)
          remote_control_remote_data_source.dart  (Legacy WiFi)
        repositories/
          remote_control_repository_impl.dart  (Updated)
      domain/
        usecases/
          connect_to_bluetooth.dart  (NEW)
          scan_bluetooth_devices.dart  (NEW)
          is_bluetooth_enabled.dart  (NEW)
          request_enable_bluetooth.dart  (NEW)
      presentation/
        screens/
          bluetooth_device_selection_screen.dart  (NEW)
        providers/
          remote_control_provider.dart  (Updated)
```

### Testing
All tests have been updated to include the new Bluetooth functionality. Run tests with:
```bash
flutter test
```

### Building
To build the APK:
```bash
flutter build apk --release
```

## Future Enhancements
- Auto-reconnect to last connected device
- Support for Bluetooth Low Energy (BLE)
- Custom device name filtering
- Connection status notifications
- Bluetooth signal strength indicator

## Windows Server Implementation

You'll need to create a Bluetooth server on Windows. Here's a basic example using Python with PyBluez:

```python
import bluetooth
import json
import pyautogui

server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
server_sock.bind(("", bluetooth.PORT_ANY))
server_sock.listen(1)

port = server_sock.getsockname()[1]
print(f"Listening on port {port}")

client_sock, client_info = server_sock.accept()
print(f"Accepted connection from {client_info}")

while True:
    data = client_sock.recv(1024)
    if not data:
        break
    
    command = json.loads(data.decode('utf-8'))
    
    if command['type'] == 'mouse_move':
        dx = command['data']['dx']
        dy = command['data']['dy']
        pyautogui.moveRel(dx, dy)
    
    elif command['type'] == 'mouse_click':
        button = command['data']['button']
        pyautogui.click(button=button)
    
    # Add more command handlers...

client_sock.close()
server_sock.close()
```

---

**Note**: This implementation uses Bluetooth Classic (RFCOMM). For better range and lower latency, consider implementing Bluetooth Low Energy (BLE) in future versions.
