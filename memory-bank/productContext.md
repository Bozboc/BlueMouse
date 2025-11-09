# Product Context

## BlueMouse - Bluetooth HID Remote Control

### Overview
BlueMouse is an Android application that transforms your smartphone into a wireless mouse and keyboard for your PC using the standard Bluetooth HID (Human Interface Device) protocol. No server installation required - it works directly through Bluetooth pairing, compatible with Windows, macOS, and Linux.

### Core Features

**Input Controls:**
- Trackpad with smooth cursor movement
- Adjustable sensitivity settings
- Left and right mouse clicks
- Click and drag functionality
- Two-finger vertical scrolling
- Full keyboard input support

**Smart Features:**
- Screen wake lock (keeps phone screen on during use)
- Auto-reconnect when screen unlocks after manual lock
- Smart device list (last connected device appears first)
- Visual indicators for previously connected devices
- Direct device selection (no setup wizards)

**Media Controls:**
- Volume up/down
- Mute/unmute
- Play/pause
- Next/previous track

**User Experience:**
- Modern dark theme UI
- Smooth animations and transitions
- Haptic feedback on interactions
- Real-time connection status
- Connection strength indicator

### Technical Stack

**Frontend:**
- Flutter 3.5.4 (Dart)
- Material Design 3
- Provider (state management)
- Clean Architecture pattern

**Bluetooth:**
- Bluetooth HID protocol
- flutter_bluetooth_serial package
- Native Android Bluetooth APIs
- HID descriptor for mouse + keyboard combo

**Android:**
- Min SDK: 21 (Android 5.0 Lollipop)
- Target SDK: 34 (Android 14)
- Permissions: Bluetooth, Location, Wake Lock
- Native Kotlin integration for HID

**Dependencies:**
- provider: ^6.1.2 (state management)
- flutter_bluetooth_serial: ^0.4.0 (Bluetooth)
- permission_handler: ^11.3.1 (permissions)
- shared_preferences: ^2.3.3 (settings storage)
- wakelock_plus: ^1.2.8 (screen management)
- dartz: ^0.10.1 (functional programming)
- get_it: ^8.0.2 (dependency injection)
- equatable: ^2.0.7 (value equality)

### Architecture
- **Presentation Layer:** Widgets, Providers, Screens
- **Domain Layer:** Entities, Use Cases, Repository Interfaces
- **Data Layer:** Data Sources, Models, Repository Implementations
- **Core:** Services, Constants, Utilities

### Target Audience
- Remote workers controlling presentation PCs
- Users with HTPCs (Home Theater PCs)
- Anyone needing quick PC control without a physical mouse/keyboard
- Developers testing on remote machines
- Smart home enthusiasts