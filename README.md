# BlueMouse - Bluetooth HID Remote Control

A Flutter application for controlling your PC keyboard and mouse remotely via **Bluetooth HID**. Turn your Android phone into a wireless mouse and keyboard! Built with **Clean Architecture** principles and **Provider** for state management.

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

### Core Features
- **Bluetooth HID Protocol** - Direct Bluetooth connection, no server needed
- **Trackpad Control** - Smooth mouse movement with adjustable sensitivity
- **Left & Right Click** - Full mouse button support with drag functionality
- **Scroll Support** - Two-finger vertical scrolling
- **Keyboard Input** - Full keyboard support for typing
- **Media Controls** - Volume up/down, mute, play/pause, next/previous
- **Special Keys** - Enter, backspace, and media keys

### User Experience
- **Screen Always On** - Keeps screen active while app is running
- **Auto-Reconnect** - Automatically reconnects when phone screen unlocks
- **Smart Device List** - Last connected device appears first
- **Visual Indicators** - Highlights previously connected devices
- **Modern UI** - Beautiful dark theme with smooth animations

### Technical
- **Clean Architecture** - Separation of concerns, testable code
- **State Management** - Provider pattern
- **Bluetooth HID** - Standard HID protocol for universal compatibility

## 📋 Prerequisites

- Flutter SDK ^3.5.4
- Android device with Bluetooth (Android 5.0+)
- PC with Bluetooth capability (Windows/Linux/Mac)

## 🛠️ Setup

### 1. Clone and Install Dependencies
```bash
git clone https://github.com/Bozboc/BlueMouse.git
cd BlueMouse
flutter pub get
```

### 2. Build the App
```bash
# For APK (direct install)
flutter build apk --release

# For Play Store (AAB)
flutter build appbundle --release
```

### 3. Pair Your Devices
1. Enable Bluetooth on both PC and phone
2. Pair the devices through Bluetooth settings
3. Launch BlueMouse app
4. Grant Bluetooth permissions
5. Select your PC from the device list
6. Start controlling!

## 📱 How to Use

1. **Launch the App** - Open BlueMouse on your Android device
2. **Grant Permissions** - Allow Bluetooth permissions when prompted
3. **Select Device** - Choose your PC from the paired device list
4. **Start Controlling** - Use the trackpad to move cursor, tap for clicks
5. **Additional Features**:
   - Two-finger scroll for page scrolling
   - Tap keyboard icon to type text
   - Use quick action buttons for media controls
   - Adjust sensitivity in settings

## 🎮 Controls

- **Single Tap** - Left mouse click
- **Two-Finger Tap** - Right mouse click
- **Drag** - Move mouse cursor
- **Two-Finger Scroll** - Vertical scrolling
- **Quick Actions** - Volume, media playback controls
- **Keyboard** - Full keyboard input support

## 📖 Documentation

Additional documentation available in the `docs/` folder:
- Bluetooth HID setup guide
- Troubleshooting guide
- Windows Bluetooth server setup (alternative)
- Integration testing guide

## 🔧 Technical Details

### Bluetooth Protocol
- **Protocol**: Bluetooth HID (Human Interface Device)
- **Min Android Version**: API 21 (Android 5.0 Lollipop)
- **Permissions**: BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_CONNECT, BLUETOOTH_SCAN, LOCATION

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **Clean Architecture**: Maintainable, testable code structure
- **Bluetooth HID**: Standard protocol for keyboard/mouse emulation

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Bluetooth HID specification contributors
- Open source community

---

**Built with ❤️ by BozBoc using Flutter and Clean Architecture**
