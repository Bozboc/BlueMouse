# Project Brief

## BlueMouse - Bluetooth HID Remote Control

### Purpose
Create a universal Android app that turns any smartphone into a wireless mouse and keyboard for PCs using standard Bluetooth HID protocol. The app eliminates the need for server installation, drivers, or network configuration - it works out-of-the-box with any Bluetooth-enabled PC.

### Problem Statement
Users often need to control their PC from a distance but don't have immediate access to a physical mouse or keyboard. Existing solutions either:
- Require installing server software on the PC
- Need both devices on the same WiFi network
- Have complex setup processes
- Lack reliability and disconnect frequently

### Solution
BlueMouse uses the standard Bluetooth HID protocol, making the phone appear as a regular Bluetooth mouse and keyboard to the PC. This provides:
- **Zero installation** on PC (uses built-in Bluetooth HID support)
- **Universal compatibility** (Windows, macOS, Linux)
- **Reliable connection** through Bluetooth pairing
- **Simple setup** (pair once, connect automatically)
- **Smart features** (auto-reconnect, screen wake lock)

### Target Users

**Primary:**
- **Remote workers** controlling presentation PCs or meeting room systems
- **Home theater enthusiasts** with media center PCs (HTPCs)
- **Developers** needing to control remote test machines
- **Casual users** wanting quick PC control without getting up

**Secondary:**
- Smart home users with PC-connected systems
- IT professionals managing multiple computers
- Students presenting from their laptops in classrooms
- Gamers wanting simple media controls during gaming

### Key Success Metrics
- ✅ Connection reliability > 95%
- ✅ Reconnection time < 3 seconds
- ✅ Input latency < 100ms
- ✅ Battery consumption < 5%/hour
- ✅ User rating > 4.0 stars
- ✅ Setup time < 2 minutes for new users

### Project Goals
1. **Reliability:** Stable Bluetooth connection with auto-reconnect
2. **Simplicity:** Minimal setup, intuitive interface
3. **Performance:** Low latency, smooth cursor movement
4. **Compatibility:** Works with all major operating systems
5. **User Experience:** Modern UI, smart features, helpful feedback

### Constraints
- Must use standard Bluetooth HID protocol (no proprietary solutions)
- Android only (iOS has Bluetooth HID restrictions)
- Minimum Android 5.0 (API 21) for Bluetooth LE support
- Must handle Bluetooth permissions properly (Android 12+)
- Battery-efficient (can't drain phone during extended use)

### Timeline
- ✅ Phase 1: Core Bluetooth HID implementation (Completed)
- ✅ Phase 2: UI/UX improvements (Completed)
- ✅ Phase 3: Smart features (wake lock, auto-reconnect) (Completed)
- ✅ Phase 4: Testing and optimization (Completed)
- 🎯 Phase 5: Play Store release (Current)
- 📋 Phase 6: User feedback and iterations (Planned)
