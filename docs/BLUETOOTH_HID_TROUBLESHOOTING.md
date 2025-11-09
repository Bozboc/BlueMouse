# Bluetooth HID Troubleshooting Guide

## Issue: Windows Not Recognizing Phone as HID Device

### Current Status
- ✅ Android app successfully registers as HID device
- ✅ Connection is established to PC
- ❌ Windows does not enumerate HID profile
- ❌ No HID device appears in Device Manager
- ❌ Mouse/Keyboard actions not working

### Root Cause
Windows has paired with your Vivo phone and discovered these profiles:
- Hands-Free (Audio)
- A2DP (Audio)
- AVRCP (Media Control)

But **HID profile is NOT discovered**. Windows needs to re-enumerate the device services.

## Solution Steps

### Option 1: Force Windows to Re-Discover Services

1. **Remove the device completely from Windows:**
   ```powershell
   # Open Settings > Bluetooth & devices > Devices
   # Click on "vivo X200 FE" and click "Remove device"
   ```

2. **In your Android app:**
   - Tap "Initialize"
   - Tap "Register HID Device"
   - Wait for "HID Device registered successfully" message

3. **Re-pair from Windows:**
   - Open Settings > Bluetooth & devices > Add device
   - Select your phone "vivo X200 FE"
   - Complete pairing
   - Windows should now discover the HID service

4. **In your Android app:**
   - Tap "Connect to Host"
   - Try the test buttons

### Option 2: Check if HID Service is Advertising

Run this command to check Android logs while connecting:

```powershell
adb -s 192.168.29.65:39833 logcat | Select-String -Pattern "BluetoothHid|SDP|UUID"
```

Look for:
- "HID Device registered successfully"
- UUID: `00001124-0000-1000-8000-00805f9b34fb` (HID Service Class)
- SDP record creation

### Option 3: Verify HID Reports

After successful connection, check if reports are being sent:

```powershell
adb -s 192.168.29.65:39833 logcat BluetoothHidPlugin:D *:S
```

Then press test buttons in the app. You should see:
```
Sending mouse move report: dx=10, dy=10, report=[0, 10, 10, 0]
Mouse move report sent: true
```

If `sent: false`, the HID connection is not established.

### Option 4: Windows Device Manager Check

1. Open Device Manager (devmgmt.msc)
2. View > Show hidden devices
3. Look for "Bluetooth" section
4. Check if "vivo X200 FE" has an HID entry
5. If there's a yellow warning icon, update the driver

### Option 5: Alternative - Use USB Debugging Mode

Some Android devices work better with USB tethering for HID:

1. Connect phone via USB cable
2. Enable USB debugging
3. Modify the app to use USB HID instead of Bluetooth HID
   - This requires using USB Accessory API instead

## Known Limitations

### Windows Security
- Windows 10/11 may block unknown HID devices for security
- Some versions require devices to be signed with Microsoft certificates
- Enterprise/Corporate PCs may have group policies blocking BT HID

### Android Limitations  
- BluetoothHidDevice API requires Android 9+ (API 28+)
- Some manufacturers restrict HID device mode
- Vivo/OPPO devices may have additional restrictions in their ROM

### Bluetooth Spec Issues
- Classic Bluetooth HID requires proper SDP record advertisement
- Windows expects specific HID device attributes
- Timing issues can cause connection drops

## Debugging Checklist

- [ ] Phone is Android 9+ (API 28+)
- [ ] Bluetooth permissions granted in app
- [ ] HID device registered successfully (check logs)
- [ ] Windows has Bluetooth enabled
- [ ] Device removed and re-paired after HID registration
- [ ] No other Bluetooth HID devices causing conflicts
- [ ] Windows HID service is running: `Get-Service -Name hidserv`
- [ ] Check logs show `sent: true` for HID reports

## Next Steps if Still Not Working

1. **Try on different Windows PC** - to rule out PC-specific issues
2. **Try different Android phone** - some manufacturers restrict HID mode
3. **Use alternative approach:**
   - WiFi-based solution with server software on PC
   - USB cable connection with ADB forwarding
   - Third-party apps like "Unified Remote" or "KDE Connect"

## Technical Details

### HID Service UUID
```
Service Class: 00001124-0000-1000-8000-00805f9b34fb
```

### Expected Windows Device IDs
When working correctly, you should see:
```
BTHENUM\{00001124-0000-1000-8000-00805f9b34fb}_VID&...
```

Currently, Windows only shows:
- `{0000111F-...}` - Hands-Free
- `{0000110A-...}` - A2DP  
- `{0000110C-...}` - AVRCP
- `{0000110E-...}` - AVRCP

**Missing: `{00001124-...}` - HID**

### Report Format Being Sent

**Mouse Report (Report ID 1):**
```
[buttons, dx, dy, wheel]
[0x00, 0x0A, 0x0A, 0x00]  // Move right+down 10 pixels
```

**Keyboard Report (Report ID 2):**
```
[modifiers, reserved, key1, key2, key3, key4, key5, key6]
[0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00]  // Press 'a' key
```

## References

- [Android BluetoothHidDevice API](https://developer.android.com/reference/android/bluetooth/BluetoothHidDevice)
- [USB HID Usage Tables](https://www.usb.org/sites/default/files/documents/hut1_12v2.pdf)
- [Bluetooth HID Profile Spec](https://www.bluetooth.com/specifications/specs/human-interface-device-profile-1-1-1/)
