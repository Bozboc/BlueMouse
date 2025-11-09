# Windows Bluetooth Server Setup Guide

## Problem
Your Android app is trying to connect to your Windows PC via Bluetooth, but the connection fails because Windows doesn't have a Bluetooth server running to accept the connection.

## Solution
You need to create a Bluetooth server on Windows that:
1. Accepts incoming Bluetooth connections from your Android device
2. Receives JSON commands from the app
3. Controls your PC (mouse, keyboard, etc.)

## Quick Setup - Python Bluetooth Server

### Step 1: Install Python Packages
```powershell
pip install pybluez pyautogui
```

**Note**: On Windows, you might need to install additional dependencies:
```powershell
pip install pybluez2
# Or
pip install git+https://github.com/pybluez/pybluez.git#egg=pybluez
```

### Step 2: Create the Server Script

Create a file named `bluetooth_server.py`:

```python
import bluetooth
import json
import pyautogui
import sys

# Bluetooth server socket
server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)

try:
    # Bind to any available port
    server_sock.bind(("", bluetooth.PORT_ANY))
    server_sock.listen(1)
    
    port = server_sock.getsockname()[1]
    
    # Make the PC discoverable
    uuid = "00001101-0000-1000-8000-00805F9B34FB"
    
    bluetooth.advertise_service(
        server_sock,
        "PC Remote Control",
        service_id=uuid,
        service_classes=[uuid, bluetooth.SERIAL_PORT_CLASS],
        profiles=[bluetooth.SERIAL_PORT_PROFILE]
    )
    
    print(f"Waiting for connection on RFCOMM channel {port}")
    print("Make sure your PC Bluetooth is ON and paired with your Android device!")
    
    client_sock, client_info = server_sock.accept()
    print(f"Accepted connection from {client_info}")
    
    try:
        while True:
            data = client_sock.recv(1024)
            if not data:
                break
            
            try:
                # Parse JSON command
                command_str = data.decode('utf-8').strip()
                
                # Handle multiple commands (split by newline)
                for cmd_line in command_str.split('\n'):
                    if not cmd_line:
                        continue
                        
                    command = json.loads(cmd_line)
                    cmd_type = command.get('type')
                    cmd_data = command.get('data', {})
                    
                    print(f"Received command: {cmd_type}")
                    
                    if cmd_type == 'connect':
                        print(f"Device connected: {cmd_data.get('device', 'Unknown')}")
                        
                    elif cmd_type == 'mouse_move':
                        dx = cmd_data.get('dx', 0)
                        dy = cmd_data.get('dy', 0)
                        pyautogui.moveRel(dx, dy)
                        
                    elif cmd_type == 'mouse_click':
                        button = cmd_data.get('button', 'left')
                        pyautogui.click(button=button)
                        
                    elif cmd_type == 'key_press':
                        key = cmd_data.get('key', '')
                        if key:
                            pyautogui.press(key)
                            
                    elif cmd_type == 'text_input':
                        text = cmd_data.get('text', '')
                        if text:
                            pyautogui.write(text)
                    
                    else:
                        print(f"Unknown command type: {cmd_type}")
                        
            except json.JSONDecodeError as e:
                print(f"Failed to parse command: {e}")
            except Exception as e:
                print(f"Error executing command: {e}")
                
    except KeyboardInterrupt:
        print("\nShutting down server...")
    finally:
        client_sock.close()
        
except Exception as e:
    print(f"Server error: {e}")
    print("\nTroubleshooting:")
    print("1. Make sure Bluetooth is enabled on your PC")
    print("2. Pair your PC with your Android device first")
    print("3. Run this script as Administrator")
    print("4. Install PyBluez: pip install pybluez")
finally:
    server_sock.close()
    print("Server closed")
```

### Step 3: Run the Server

1. **Enable Bluetooth** on your Windows PC
2. **Pair your PC with your Android phone** via Windows Settings → Bluetooth
3. **Run the server** (as Administrator recommended):
   ```powershell
   python bluetooth_server.py
   ```

### Step 4: Connect from Android App

1. Open the app on your Android device
2. The Bluetooth device selection screen should appear automatically
3. Select your Windows PC from the list
4. The app will connect to the server

## Alternative: Node.js Bluetooth Server

If Python doesn't work, you can use Node.js:

```bash
npm install bluetooth-serial-port
```

Then create `server.js` - (implementation similar to Python version)

## Troubleshooting

### "Bluetooth not available" on Windows
- Install the PyBluez package properly
- Some Windows versions have limited Bluetooth support
- Try using a USB Bluetooth dongle

### Connection Refused
- Make sure the server is running BEFORE trying to connect from the app
- Check that devices are paired in Windows Settings first
- Run the server as Administrator

### Commands Not Working
- Check the console output on both server and app
- Verify JSON format in the Flutter app matches the server expectations
- Test with simple commands first (like mouse_move)

## Command Format

The app sends commands in this JSON format:
```json
{
  "type": "mouse_move",
  "data": {"dx": 10, "dy": -5}
}
```

Supported command types:
- `connect` - Initial handshake
- `mouse_move` - Move cursor (dx, dy)
- `mouse_click` - Click mouse (left/right/middle)
- `key_press` - Press a key
- `text_input` - Type text

## Next Steps

Once the server is running and connected:
1. Use the mouse pad in the app to control your PC cursor
2. Try the click buttons
3. Use keyboard shortcuts
4. Type text using the input panel

---

**Important**: Keep the Python server running while using the app. The connection will drop if the server stops.
