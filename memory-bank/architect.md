# BlueMouse: System Architecture

## Overview
This document outlines the architectural design, component structure, and technical decisions for the BlueMouse Bluetooth HID remote control application.

## System Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Widgets    │  │  Providers   │  │   Screens    │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼──────────────────┼──────────────────┼─────────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────┐
│                    Domain Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Entities   │  │  Use Cases   │  │ Repositories │ │
│  │              │  │              │  │ (Interfaces) │ │
│  └──────────────┘  └──────┬───────┘  └──────────────┘ │
└────────────────────────────┼─────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────┐
│                     Data Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │    Models    │  │ Data Sources │  │ Repositories │ │
│  │              │  │              │  │    (Impl)    │ │
│  └──────────────┘  └──────┬───────┘  └──────────────┘ │
└────────────────────────────┼─────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────┐
│                  Platform Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Flutter    │  │Native Kotlin │  │  Bluetooth   │ │
│  │  Bluetooth   │  │  HID Plugin  │  │  HID Stack   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Presentation Layer

#### BluetoothHidProvider
- **Responsibility:** Manage Bluetooth HID connection state
- **Key Methods:**
  - `initialize()` - Initialize Bluetooth HID service
  - `connectToHost()` - Connect to PC
  - `disconnect()` - Disconnect from PC
  - `sendMove()` - Send mouse movement
  - `sendClick()` - Send mouse click
  - `sendKeyPress()` - Send keyboard input
- **State:** Connection status, paired devices, error messages

#### RemoteControlProvider
- **Responsibility:** Manage UI state and Bluetooth scanning
- **Key Methods:**
  - `scanForDevices()` - Scan for paired devices
  - `connectToDevice()` - Connect to selected device
  - `getLastConnectedDeviceAddress()` - Get last connected device
- **State:** Available devices, scanning status, connection status

#### RemoteControlScreen
- **Responsibility:** Main control interface
- **Features:**
  - Trackpad for mouse movement
  - Left/right click buttons
  - Scroll gesture recognition
  - Keyboard input toggle
  - Media control buttons
  - Wake lock management
  - Auto-reconnect on resume

### 2. Domain Layer

#### Entities
- `ConnectionStatus` - Connection state information
- `RemoteCommand` - Command data structure

#### Use Cases
- `ConnectToBluetooth` - Handle Bluetooth connection
- `DisconnectFromBluetooth` - Handle disconnection
- `ScanBluetoothDevices` - Scan for available devices
- `IsBluetoothEnabled` - Check Bluetooth status
- `RequestEnableBluetooth` - Request Bluetooth activation
- `SendHidCommand` - Send HID commands to PC

#### Repository Interfaces
- `RemoteControlRepository` - Define data operations

### 3. Data Layer

#### Data Sources
- `BluetoothRemoteDataSource` - Bluetooth communication
- Native methods through method channels

#### Models
- `ConnectionStatusModel` - Data model for connection state
- `RemoteCommandModel` - Data model for commands

#### Repository Implementation
- `RemoteControlRepositoryImpl` - Implement repository interface

### 4. Core Services

#### BluetoothHidService
- **Native Integration:** Kotlin plugin for Android Bluetooth HID
- **HID Descriptor:** Mouse + Keyboard combo device
- **Report Format:**
  - Mouse: [buttons, dx, dy, scroll]
  - Keyboard: [modifiers, reserved, key codes...]
- **Callbacks:** Connection state, app status, errors

#### PreferencesService
- **Storage:** SharedPreferences for persistent data
- **Data Stored:**
  - Last connected device address
  - Last connected device name
  - Trackpad sensitivity setting
- **Methods:** Save, retrieve, clear preferences

## Data Flow

### Connection Flow
```
User Taps Device
      ↓
RemoteControlScreen
      ↓
BluetoothHidProvider.connectToHost()
      ↓
BluetoothHidService (Native)
      ↓
Android Bluetooth HID API
      ↓
PC Bluetooth Stack
      ↓
Connection Established
      ↓
Callback to Provider
      ↓
UI Updates
```

### Input Flow
```
User Gesture (e.g., Drag)
      ↓
RemoteControlScreen._handlePanUpdate()
      ↓
Accumulate fractional movements
      ↓
BluetoothHidProvider.sendMove(dx, dy)
      ↓
BluetoothHidService.sendMove()
      ↓
Native HID Report Generation
      ↓
Bluetooth Transmission
      ↓
PC Cursor Movement
```

### Reconnection Flow
```
Screen Unlocked
      ↓
didChangeAppLifecycleState(resumed)
      ↓
Check if connected
      ↓
If disconnected → initialize()
      ↓
Auto-connect to last device
      ↓
Connection restored
```

## Key Design Decisions

### 1. Clean Architecture
**Rationale:** Separation of concerns, testability, maintainability
**Benefits:**
- Easy to test each layer independently
- Business logic isolated from UI and frameworks
- Can swap data sources without affecting domain
- Clear dependency rules

### 2. Native Bluetooth HID
**Rationale:** Android Bluetooth HID APIs only available natively
**Benefits:**
- Full control over HID protocol
- Better performance than pure Dart
- Access to all Android Bluetooth APIs
- Can handle complex HID descriptors

### 3. Provider State Management
**Rationale:** Simpler than BLoC, sufficient for app complexity
**Benefits:**
- Less boilerplate than BLoC
- Good Flutter integration
- Easy to understand and maintain
- Reactive UI updates

### 4. Service Locator (GetIt)
**Rationale:** Simple dependency injection without complex DI frameworks
**Benefits:**
- Lightweight solution
- Easy to set up
- Works well with Provider
- No code generation needed

### 5. Either Pattern (Dartz)
**Rationale:** Functional error handling without exceptions
**Benefits:**
- Explicit error handling
- Forces handling of failure cases
- Type-safe error propagation
- Better than try-catch for domain logic

## Security Considerations

### Bluetooth Security
- Uses standard Bluetooth pairing security
- OS-level encryption for HID communication
- No custom authentication needed
- Relies on trusted pairing process

### Data Privacy
- No data collection or analytics
- No internet permission
- Only stores device address locally
- No personal information transmitted

### Permissions
- Request permissions upfront
- Clear permission rationale
- Handle denied permissions gracefully
- Minimum required permissions only

## Performance Considerations

### Input Latency
- Fractional movement accumulation
- Batch small movements
- Direct native calls (no middleware)
- Target: < 100ms end-to-end latency

### Battery Optimization
- Wake lock only when app active
- Disable wake lock on dispose
- Efficient Bluetooth connection management
- Minimal background processing

### Memory Management
- Close streams on dispose
- Clean up Bluetooth connections
- Unregister callbacks
- Proper provider disposal

## Scalability

### Future Enhancements
- Modular architecture allows easy additions
- New HID reports can be added to descriptor
- Additional screens/features fit into existing structure
- Can add more providers without affecting existing ones

### Platform Expansion
- Architecture supports iOS (if Apple allows HID)
- Can add tablet-specific layouts
- Desktop app possible with similar architecture
- Web version theoretically possible

