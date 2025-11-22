# Release Notes

## v1.0.0 - Initial Release
**Release Date:** 2024-01-01

### Features
- **Bluetooth HID Support**: Transform your Android device into a Bluetooth Mouse and Keyboard.
- **Remote Control**:
    - Trackpad with support for moving, clicking, and scrolling.
    - Full keyboard input support.
    - Media controls (Volume, Play/Pause, Next/Prev).
- **Connection Flow**:
    - Step-by-step instruction menu for initializing, registering, and pairing.
    - Support for standard Bluetooth HID protocol (No server required).
- **Settings**:
    - Adjustable trackpad sensitivity.

---

## v1.1.0 - Connection & UI Improvements
**Release Date:** 2025-11-22

### 🚀 Improvements
- **Streamlined Connection**:
    - Removed the redundant instruction menu.
    - Tapping the Bluetooth icon now directly opens the **Paired Devices** list.
- **Smart Device List**:
    - **Auto-Sort**: The last connected device now always appears at the top of the list for quick access.
    - **Loading Indicator**: Added a spinner to show connection progress.
    - **Integrated Disconnect**: Connected devices are highlighted in green; tapping them allows you to disconnect immediately.
- **Better Feedback**:
    - Added **Red/Green SnackBars** to clearly indicate connection success or failure.
    - **Bluetooth Off Handling**: The app now checks if Bluetooth is disabled and prompts you to turn it on directly from the app.
- **Bug Fixes**:
    - Fixed an issue where the "Connected" green border would persist after disconnecting.
    - Fixed the dialog not closing automatically upon successful connection.
