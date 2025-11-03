# 🧪 Integration Test Guide

## Running Integration Tests in Real-Time

### Quick Start

```powershell
# Make sure an emulator is running or device is connected
fvm flutter devices

# Run the integration test with driver (you'll see it on your device!)
fvm flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d emulator-5554
```

### What You'll See

The integration test will automatically:

1. **Launch the App** 📱
   - App opens on your emulator/device
   
2. **Test UI Elements** ✅
   - Verifies all buttons, text fields, and widgets are present
   
3. **Enter Server IP** 🌐
   - Automatically types `192.168.1.100` in the IP field
   
4. **Tap Connect Button** 🔌
   - Simulates user tapping the Connect button
   - Shows connecting state
   
5. **Test Mouse Pad** 🖱️
   - Simulates tap gestures on the mouse pad
   - Tests drag functionality
   
6. **Test Quick Controls** ⌨️
   - Taps Space, Enter, Volume buttons
   - Verifies all 9 quick control buttons
   
7. **Test Text Input** 📝
   - Types "Integration test message"
   - Verifies send icon appears
   
8. **Test Navigation** 🧭
   - Opens settings screen
   - Navigates back to main screen
   
9. **Complete User Flow** 🎯
   - Runs through entire app workflow
   - Shows success messages in console

### Console Output

You'll see progress indicators like:

```
✓ App launched successfully with all UI elements
✓ Server IP field works correctly
✓ Connection attempt triggered successfully
✓ All 9 quick control buttons displayed
✓ Mouse pad responds to tap
✓ Text input field works correctly
✓ Quick control buttons are tappable (3 buttons tested)
✓ Refresh button works correctly

🚀 Starting Full User Flow Integration Test...

1️⃣ App launched
2️⃣ Server IP entered: 192.168.1.50
3️⃣ Connect button tapped
4️⃣ Connection attempt completed
5️⃣ Mouse pad tap simulated
6️⃣ Space button tapped
7️⃣ Text input entered
8️⃣ Settings screen opened
9️⃣ Returned to main screen

✅ Full user flow completed successfully!
```

### Alternative Methods

**Option 1: Simple Test (No visual)**
```powershell
fvm flutter test integration_test/app_test.dart
```

**Option 2: Specific Device**
```powershell
# Windows
fvm flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d windows

# Chrome
fvm flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d chrome
```

### Troubleshooting

**Problem: "No devices found"**
```powershell
# Start an emulator
fvm flutter emulators
fvm flutter emulators --launch <emulator-id>
```

**Problem: "Build failed"**
```powershell
# Clean and rebuild
fvm flutter clean
fvm flutter pub get
fvm flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart
```

**Problem: "Tests timeout"**
```powershell
# Increase timeout
fvm flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart --timeout=120s
```

### Test Coverage

The integration test covers:

- ✅ App launch and initialization
- ✅ All UI component rendering
- ✅ User input handling
- ✅ State management (Provider)
- ✅ Navigation between screens
- ✅ Connection flow
- ✅ Command sending (with mock server response)
- ✅ Error handling
- ✅ Complete user journey

### Duration

- **First run**: ~3-5 minutes (includes build time)
- **Subsequent runs**: ~1-2 minutes
- **Test execution**: ~30-60 seconds

### Tips

1. **Watch the emulator** - You'll see the app interact in real-time!
2. **Check console** - Progress messages show what's being tested
3. **Don't interact** - Let the test run automatically
4. **Use a real device** - Even better visual experience

---

**Enjoy watching your Flutter app test itself! 🎉**
