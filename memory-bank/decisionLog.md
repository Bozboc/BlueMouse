# Decision Log

## Architectural Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-11 | Use Bluetooth HID instead of WiFi/WebSocket | Eliminates need for server installation, works universally with all PCs, more reliable connection, simpler setup |
| 2025-11 | Implement Clean Architecture | Better separation of concerns, easier testing, more maintainable code, clear dependency flow |
| 2025-11 | Use Provider for state management | Simpler than BLoC for this use case, good integration with Flutter, adequate for app complexity |
| 2025-11 | Native Kotlin for Bluetooth HID | Android Bluetooth HID APIs only available in native code, better performance, more control |
| 2025-11 | Target Android only (not iOS) | iOS restricts Bluetooth HID access, Android has full API support, larger addressable market |
| 2025-11 | Min SDK 21 (Android 5.0) | Balances feature support with device coverage, required for Bluetooth LE, covers 99%+ devices |
| 2025-11 | Store last connected device | Enables smart sorting and auto-reconnect, better UX for repeat usage |
| 2025-11 | Use GetIt for dependency injection | Lightweight, simple service locator pattern, works well with Provider |

## Feature Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-11 | Implement screen wake lock | Bluetooth disconnects when screen locks, users need continuous control, prevents accidental disconnects |
| 2025-11 | Auto-reconnect on screen unlock | Improves UX after manual lock, reduces friction, maintains session continuity |
| 2025-11 | Sort devices by last connected | Faster access to frequently used device, reduces taps, better UX for repeat users |
| 2025-11 | Two-finger scroll instead of scroll bar | More natural gesture, consistent with smartphone UX, less screen real estate |
| 2025-11 | Adjustable trackpad sensitivity | Different users/PCs need different settings, accommodates various screen sizes |
| 2025-11 | Dark theme only (initially) | Battery savings on OLED screens, modern aesthetic, less eye strain during use |
| 2025-11 | No onboarding tutorial | Direct access to functionality, users familiar with Bluetooth pairing, simpler first experience |
| 2025-11 | Show devices directly (no wizard) | Reduces setup friction, users know their device names, faster connection |

## Technical Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-11 | HID descriptor: Mouse + Keyboard combo | Single device profile, simpler pairing, full functionality, standard approach |
| 2025-11 | Use flutter_bluetooth_serial package | Mature package, good Android support, active maintenance, sufficient for our needs |
| 2025-11 | Accumulate fractional movements | Prevents jerky cursor, smooth movement, better precision, handles different sensitivities |
| 2025-11 | Request all permissions upfront | Simpler UX, avoid permission dialogs during use, clear expectations |
| 2025-11 | SharedPreferences for settings | Simple key-value storage, sufficient for current needs, fast access, no database overhead |
| 2025-11 | Pin package_info_plus to v8.x | v9.0 has Gradle incompatibility, v8.x stable and working, avoids build failures |

## UI/UX Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-11 | Single-screen main interface | Quick access to all functions, no navigation needed, optimized for one-handed use |
| 2025-11 | Visual indicator for last connected device | Helps user identify correct device quickly, reduces connection errors |
| 2025-11 | Connection status in app bar | Always visible, no hunting for status, clear feedback |
| 2025-11 | Quick action buttons grid | Fast access to common functions, reduces need for typing, better than menu |
| 2025-11 | Large trackpad area | Primary function needs maximum space, comfortable gesture area, reduces misclicks |
| 2025-11 | Haptic feedback on buttons | Confirms actions, better tactile experience, accessibility |

## Security & Privacy Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-11 | No data collection/analytics (initially) | Privacy-first approach, faster approval, build trust, simpler compliance |
| 2025-11 | No internet permission | App works offline, privacy benefit, security benefit, simpler permissions |
| 2025-11 | Store only device address locally | Minimal data storage, no personal info, respects privacy |
| 2025-11 | Use Bluetooth pairing security | Standard OS-level security, no custom crypto needed, trusted by users |
