# Bluetooth Connection Troubleshooting Guide

## Common Connection Errors and Solutions

### Error: "Connection timeout - Device is not responding"

**Cause:** The Windows PC is not running a Bluetooth server to accept connections.

**Solution:**
1. Make sure you've set up the Windows Bluetooth server (see `WINDOWS_BLUETOOTH_SERVER.md`)
2. Run the Python server script as Administrator:
   ```bash
   python bluetooth_server.py
   ```
3. Ensure the server shows "Waiting for connections on port 1..."

---

### Error: "Connection failed: Device not accepting connections"

**Cause:** Either the Bluetooth server is not running, devices aren't properly paired, or a firewall is blocking the connection.

**Solutions:**

1. **Check if server is running:**
   - Open Command Prompt or PowerShell on Windows
   - Run the bluetooth_server.py script
   - You should see: "Bluetooth Server Started. Waiting for connections..."

2. **Verify device pairing:**
   - On Windows: Settings → Bluetooth & devices
   - Ensure your Android phone is in the "Paired devices" list
   - If not paired, click "Add device" and pair your phone
   - On Android, you should also see the Windows PC in Bluetooth settings

3. **Check Windows Firewall:**
   - Windows Security → Firewall & network protection
   - Click "Allow an app through firewall"
   - Make sure Python is allowed for both Private and Public networks
   - Or temporarily disable firewall to test

4. **Restart Bluetooth services:**
   - On Windows: Settings → Bluetooth & devices → Turn Bluetooth OFF then ON
   - On Android: Settings → Connections → Bluetooth → Turn OFF then ON
   - Re-pair the devices if necessary

---

### Error: "Bluetooth is not enabled"

**Cause:** Bluetooth is turned off on the Android device.

**Solution:**
1. On Android: Settings → Connections → Bluetooth
2. Turn on Bluetooth
3. Or tap "Enable Bluetooth" button in the app

---

### Error: "No Bluetooth devices found"

**Cause:** No paired Bluetooth devices available.

**Solution:**
1. Pair your Windows PC with your Android phone first:
   - On Windows: Settings → Bluetooth & devices → Add device
   - On Android: Settings → Connections → Bluetooth → Pair new device
   - Select your PC from the list
   - Confirm the pairing code on both devices

2. After pairing, tap the "Refresh" button in the app

---

### Error: "Failed to scan devices"

**Cause:** Missing Bluetooth or location permissions.

**Solution:**
1. On Android: Settings → Apps → PC Remote Controller → Permissions
2. Ensure the following permissions are granted:
   - Nearby devices (Bluetooth)
   - Location (required for Bluetooth scanning on Android)
3. Restart the app after granting permissions

---

## Connection Process Overview

For a successful Bluetooth connection, follow these steps in order:

### Step 1: Pair Devices (One-time setup)
1. On Windows PC:
   - Settings → Bluetooth & devices → Add device
   - Select "Bluetooth"
   
2. On Android Phone:
   - Settings → Connections → Bluetooth
   - Turn on Bluetooth
   - Under "Available devices", find your Windows PC
   - Tap to pair
   
3. Confirm the same pairing code appears on both devices
4. Accept the pairing on both devices

### Step 2: Start Windows Bluetooth Server
1. Open Command Prompt or PowerShell **as Administrator**
2. Navigate to the server script location
3. Run: `python bluetooth_server.py`
4. Wait for message: "Bluetooth Server Started. Waiting for connections on port 1"

### Step 3: Connect from Android App
1. Open the PC Remote Controller app
2. Tap "Connect via Bluetooth" (or the Bluetooth icon)
3. Select your Windows PC from the list
4. Wait for connection confirmation
5. If connection fails, check the error message for specific details

---

## Debugging Tips

### Enable Verbose Logging

If you're still having issues, check the Flutter console output:

1. Connect your phone via USB or WiFi ADB
2. Run: `flutter run -d "YOUR_DEVICE_NAME"`
3. Look for log messages starting with:
   - `D/FlutterBluePlugin` - Bluetooth plugin messages
   - `I/BluetoothSocket` - Socket connection attempts
   - `I/BluetoothAdapter` - Bluetooth adapter state

### Common Log Messages

- `connect() for device XXX called` - Connection attempt started
- `close() this: android.bluetooth.BluetoothSocket` - Connection closed
- `onBluetoothStateChange: up=false` - Bluetooth turned off
- `onBluetoothStateChange: up=true` - Bluetooth turned on

### Test Bluetooth Connection Manually

You can test if Bluetooth pairing works by sending a file:

1. On Android, go to a file manager
2. Select any file → Share → Bluetooth
3. Select your Windows PC
4. If the file transfer works, Bluetooth communication is functional
5. The issue is likely with the server not running or firewall blocking

---

## Technical Details

### Bluetooth Protocol Used
- **Type:** Bluetooth Classic (not BLE)
- **Profile:** RFCOMM (Serial Port Profile)
- **UUID:** Standard SPP UUID `00001101-0000-1000-8000-00805F9B34FB`
- **Port:** 1 (default RFCOMM channel)

### Data Format
- Commands are sent as JSON strings
- Each command ends with a newline character (`\n`)
- Example: `{"type":"mouse_move","data":{"dx":10,"dy":5}}\n`

### Connection Timeout
- Default timeout: 15 seconds
- If connection takes longer, it will fail with a timeout error
- Ensure the Windows server is running and ready before connecting

---

## Still Having Issues?

If you've tried all the solutions above and still can't connect:

1. **Check Android version compatibility:**
   - Minimum supported: Android 5.0 (Lollipop, API 21)
   - Bluetooth permissions work differently on Android 12+

2. **Check Windows Bluetooth hardware:**
   - Ensure your PC has a Bluetooth adapter
   - Check Device Manager → Bluetooth for any errors
   - Update Bluetooth drivers if needed

3. **Try a different Bluetooth device:**
   - Test with another Android device
   - Test with another Windows PC
   - This helps isolate hardware issues

4. **Check Python dependencies:**
   - Make sure PyBluez is properly installed
   - On Windows, PyBluez requires Microsoft Visual C++ 14.0+
   - Install from: https://visualstudio.microsoft.com/visual-cpp-build-tools/

5. **Review the logs:**
   - Check the Flutter console for detailed error messages
   - Check the Python server console for connection attempts
   - Look for specific error codes or exceptions
