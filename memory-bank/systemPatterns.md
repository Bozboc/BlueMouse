# System Patterns

## Architectural Patterns

### Clean Architecture (3-Layer)
**Structure:**
```
lib/
├── presentation/    # UI, Widgets, Providers
├── domain/         # Entities, Use Cases, Repository Interfaces  
├── data/           # Data Sources, Models, Repository Implementations
└── core/           # Shared utilities, services
```

**Rules:**
- Dependencies flow inward (presentation → domain ← data)
- Domain layer has no external dependencies
- Use cases encapsulate business logic
- Repositories abstract data sources

**Example:**
```dart
// Domain Use Case
class ConnectToBluetooth implements UseCase<ConnectionStatus, BluetoothDevice> {
  final RemoteControlRepository repository;
  
  @override
  Future<Either<Failure, ConnectionStatus>> call(BluetoothDevice device) {
    return repository.connectBluetooth(device);
  }
}
```

### Repository Pattern
**Purpose:** Abstract data sources behind interfaces

**Implementation:**
```dart
// Domain - Interface
abstract class RemoteControlRepository {
  Future<Either<Failure, ConnectionStatus>> connectBluetooth(BluetoothDevice device);
}

// Data - Implementation  
class RemoteControlRepositoryImpl implements RemoteControlRepository {
  final BluetoothRemoteDataSource dataSource;
  
  @override
  Future<Either<Failure, ConnectionStatus>> connectBluetooth(BluetoothDevice device) {
    try {
      final status = await dataSource.connect(device);
      return Right(status);
    } catch (e) {
      return Left(ConnectionFailure(message: e.toString()));
    }
  }
}
```

### Provider Pattern (State Management)
**Purpose:** Reactive state updates across widget tree

**Implementation:**
```dart
class BluetoothHidProvider extends ChangeNotifier {
  bool _isConnected = false;
  
  bool get isConnected => _isConnected;
  
  Future<void> connect(String address) async {
    // ... connection logic
    _isConnected = true;
    notifyListeners(); // Updates all listening widgets
  }
}

// In UI
Consumer<BluetoothHidProvider>(
  builder: (context, provider, _) {
    return Text(provider.isConnected ? 'Connected' : 'Disconnected');
  },
)
```

## Design Patterns

### Service Locator (Dependency Injection)
**Tool:** GetIt package

**Pattern:**
```dart
// Registration
final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => BluetoothHidService());
  final prefs = await PreferencesService.create();
  sl.registerSingleton<PreferencesService>(prefs);
}

// Usage
class BluetoothHidProvider {
  final BluetoothHidService service = sl<BluetoothHidService>();
}
```

### Either Pattern (Error Handling)
**Tool:** Dartz package

**Pattern:**
```dart
// Success or Failure
Future<Either<Failure, Data>> fetchData() async {
  try {
    final data = await source.getData();
    return Right(data); // Success
  } catch (e) {
    return Left(ServerFailure(message: e.toString())); // Failure
  }
}

// Usage
final result = await fetchData();
result.fold(
  (failure) => showError(failure.message),
  (data) => displayData(data),
);
```

### Observer Pattern (Callbacks)
**Purpose:** Notify about state changes

**Pattern:**
```dart
class BluetoothHidService {
  Function(String state, String? address, String? name)? onConnectionStateChanged;
  Function(bool registered)? onAppStatusChanged;
  
  void _notifyConnectionChanged(String state) {
    onConnectionStateChanged?.call(state, deviceAddress, deviceName);
  }
}

// Provider listens
_hidService.onConnectionStateChanged = (state, address, name) {
  if (state == 'connected') {
    _isConnected = true;
    notifyListeners();
  }
};
```

### Factory Pattern (Model Creation)
**Purpose:** Create models with different states

**Pattern:**
```dart
class ConnectionStatusModel {
  factory ConnectionStatusModel.disconnected() {
    return ConnectionStatusModel(isConnected: false, message: 'Disconnected');
  }
  
  factory ConnectionStatusModel.connected(String deviceName) {
    return ConnectionStatusModel(isConnected: true, message: 'Connected to $deviceName');
  }
  
  factory ConnectionStatusModel.error(String error) {
    return ConnectionStatusModel(isConnected: false, message: 'Error: $error');
  }
}
```

### Strategy Pattern (Platform-Specific Implementation)
**Purpose:** Different implementations for different platforms

**Pattern:**
```dart
abstract class BluetoothService {
  Future<void> connect();
}

class AndroidBluetoothService implements BluetoothService {
  @override
  Future<void> connect() {
    // Android-specific HID implementation
  }
}

class IOSBluetoothService implements BluetoothService {
  @override
  Future<void> connect() {
    // iOS-specific implementation (limited)
  }
}
```

## Common Idioms

### Gesture Accumulation
**Problem:** Precise cursor movement with fractional deltas

**Solution:**
```dart
double _accumulatedDx = 0.0;
double _accumulatedDy = 0.0;

void _handlePanUpdate(DragUpdateDetails details) {
  _accumulatedDx += details.delta.dx;
  _accumulatedDy += details.delta.dy;
  
  final int dx = _accumulatedDx.truncate();
  final int dy = _accumulatedDy.truncate();
  
  if (dx != 0 || dy != 0) {
    sendMove(dx, dy);
    _accumulatedDx -= dx;
    _accumulatedDy -= dy;
  }
}
```

### Safe Navigation After Async
**Problem:** Widget disposed during async operation

**Solution:**
```dart
Future<void> connect() async {
  await performAsyncOperation();
  
  if (mounted) { // Check if widget still exists
    setState(() {
      // Safe to update state
    });
  }
}
```

### Stream Subscription Lifecycle
**Problem:** Memory leaks from active streams

**Solution:**
```dart
final StreamController<Status> _controller = StreamController.broadcast();

@override
void dispose() {
  _controller.close(); // Always close streams
  _connection?.close();
  super.dispose();
}
```

### Permission Request Chain
**Problem:** Multiple permissions needed

**Solution:**
```dart
Future<void> requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();
}
```

### Last Connected Device Sorting
**Problem:** Find preferred device quickly

**Solution:**
```dart
List<BluetoothDevice> _sortDevices(List<BluetoothDevice> devices) {
  final lastAddress = prefs.getLastDeviceAddress();
  return List.from(devices)..sort((a, b) {
    if (a.address == lastAddress) return -1;
    if (b.address == lastAddress) return 1;
    return 0;
  });
}
```

### Auto-Reconnect on Resume
**Problem:** Connection lost when screen locks

**Solution:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    if (!provider.isConnected) {
      provider.initialize(); // Triggers auto-reconnect
    }
  }
}
```

### Wake Lock Management
**Problem:** Screen timeout disconnects Bluetooth

**Solution:**
```dart
@override
void initState() {
  super.initState();
  WakelockPlus.enable(); // Keep screen on
}

@override
void dispose() {
  WakelockPlus.disable(); // Release when done
  super.dispose();
}
```