# PC Remote Controller - Flutter HID App

A Flutter application for controlling your Windows PC keyboard and mouse remotely using WebSocket communication. Built with **Clean Architecture** principles and **Provider** for state management.

## 🏗️ Architecture

This project follows **Clean Architecture** with three main layers:

### 📁 Project Structure

```
lib/
├── core/
│   ├── constants/         # App-wide constants
│   ├── error/            # Error handling and failures
│   └── usecases/         # Base use case interface
├── features/
│   └── remote_control/
│       ├── data/
│       │   ├── datasources/    # WebSocket data source
│       │   ├── models/         # Data models
│       │   └── repositories/   # Repository implementation
│       ├── domain/
│       │   ├── entities/       # Business entities
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business logic
│       └── presentation/
│           ├── providers/      # State management (Provider)
│           ├── screens/        # UI screens
│           └── widgets/        # Reusable widgets
└── injection_container.dart   # Dependency injection
```

## 🚀 Features

- **WebSocket Communication** - Real-time connection to PC server
- **Mouse Control** - Drag to move cursor, tap for clicks
- **Keyboard Shortcuts** - Quick access to common keys
- **Text Input** - Send text directly to PC
- **Media Controls** - Volume up/down, mute
- **Clean Architecture** - Separation of concerns, testable code
- **State Management** - Provider pattern
- **Comprehensive Testing** - Unit, Widget, and Integration tests

## 📋 Prerequisites

- Flutter SDK 3.24.5 (managed via FVM)
- FVM (Flutter Version Management)
- A Windows PC running the WebSocket server
- Android device/emulator or iOS device/simulator

## 🛠️ Setup

```bash
cd d:\Projects\bluetooth_app
fvm use 3.24.5
fvm flutter pub get
```

## 🧪 Testing

### Run All Tests
```bash
fvm flutter test
```

### Run Integration Tests (REAL-TIME on Device/Emulator)

**Step 1: Start a device or emulator**
```bash
# Check available devices
fvm flutter devices
```

**Step 2: Run the integration test with driver**
```bash
fvm flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart
```

**Or specify a device:**
```powershell
fvm flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d <device-id>
```

**What you'll see:**
- ✅ App launches on your device/emulator
- ✅ Tests interact with the UI in real-time
- ✅ You can watch the app navigate, tap buttons, enter text
- ✅ Console shows detailed progress with emojis
- ✅ Complete user flow demonstration

The integration test performs:
1. Launch app and verify UI
2. Enter server IP
3. Tap Connect button
4. Test mouse pad gestures
5. Tap quick control buttons
6. Enter text input
7. Navigate to settings and back
8. Complete end-to-end user flow

## 🏃 Running the App

```bash
fvm flutter run
```

## 📱 Using the App

1. **Configure Server IP** - Tap settings, enter PC IP
2. **Connect** - Tap Connect button
3. **Control PC** - Use mouse pad, shortcuts, and text input

## 🔧 Server Setup (Python Example)

```python
import asyncio
import websockets
import json
import pyautogui

async def handle_client(websocket, path):
    async for message in websocket:
        data = json.loads(message)
        command_type = data['type']
        
        if command_type == 'mouse_move':
            pyautogui.move(data['dx'], data['dy'])
        elif command_type == 'mouse_click':
            pyautogui.click(button=data['button'])
        elif command_type == 'key_press':
            pyautogui.press(data['key'])
        elif command_type == 'text_input':
            pyautogui.write(data['text'])

async def main():
    async with websockets.serve(handle_client, "0.0.0.0", 8080):
        print("Server started on port 8080")
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
```

Install: `pip install websockets pyautogui`
Run: `python server.py`

## 📊 Test Coverage

- **25+ Unit Tests** - Domain layer, use cases, repositories
- **10+ Widget Tests** - UI components, provider
- **10+ Integration Tests** - End-to-end flows

---

**Built with ❤️ using Flutter and Clean Architecture**
