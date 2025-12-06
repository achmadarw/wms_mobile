# Flutter WMS Mobile App - Developer Checklist

## Pre-Launch Checklist

### Environment Setup

-   [ ] Flutter 3.13.0+ installed (`flutter --version`)
-   [ ] Dart 3.0.0+ available (`dart --version`)
-   [ ] Android SDK installed (for emulator)
-   [ ] Git installed (for version control)

### Project Preparation

-   [ ] Navigate to project: `cd D:\WORKSPACE\PROJECT\wms_mobile`
-   [ ] Backend WMS server running: `http://localhost:3000`
-   [ ] Internet connection available
-   [ ] Sufficient disk space (2+ GB)

### Dependency Installation

-   [ ] Run `flutter pub get`
    -   Expected: "Running "flutter pub get" in wms_mobile..."
    -   Expected: "Got dependencies" message
-   [ ] Verify pubspec.lock created
    -   Expected: File exists in project root

### Code Generation

-   [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
    -   Expected: Multiple .g.dart files generated
    -   Expected: "build/generated_plugins.dart" created
    -   Files to check:
        -   [ ] `lib/data/local/models/user_model.g.dart`
        -   [ ] `lib/data/local/models/item_model.g.dart`

### Android Emulator Setup

-   [ ] Start Android emulator

    -   Command: `flutter emulators --launch <emulator_id>`
    -   Or use Android Studio to launch
    -   Expected: Emulator boots and shows home screen

-   [ ] Verify emulator connectivity
    -   Command: `adb devices`
    -   Expected: Emulator listed as "device"

### Backend Verification

-   [ ] Backend server running
    -   Expected: `http://localhost:3000` responsive
-   [ ] Check database populated
    -   Expected: SQLite database has schema and tables
-   [ ] API health check
    -   Manual: Visit `http://localhost:3000/api/health` (if implemented)
    -   Or test with Postman/Insomnia

### First Run

-   [ ] Run app: `flutter run`
    -   Expected: App launches on emulator
    -   Expected: No compilation errors
    -   Expected: No runtime crashes
-   [ ] Check login screen
    -   Expected: Login form displayed
    -   Expected: Email/password fields visible
    -   Expected: Register link clickable

### Testing Basic Flow

-   [ ] **Login Flow**
    -   [ ] Enter test credentials
    -   [ ] Press Login button
    -   [ ] Expected: Navigate to dashboard
    -   [ ] Expected: User name displayed
-   [ ] **Dashboard Screen**
    -   [ ] Verify welcome message
    -   [ ] Check stats cards load
    -   [ ] Verify quick actions visible
    -   [ ] Check recent items list
-   [ ] **Inventory Screen**
    -   [ ] Navigate from dashboard
    -   [ ] Expected: Item list loads
    -   [ ] Try search functionality
    -   [ ] Test category filter
-   [ ] **Register Flow**
    -   [ ] Return to login
    -   [ ] Click register link
    -   [ ] Expected: Register form displayed
    -   [ ] Fill in form and submit
    -   [ ] Expected: New account created and logged in

### Error Handling

-   [ ] **Network Error**
    -   [ ] Stop backend server
    -   [ ] Try to login
    -   [ ] Expected: Error message displayed
    -   [ ] Expected: App doesn't crash
-   [ ] **Invalid Credentials**

    -   [ ] Try wrong password
    -   [ ] Expected: Error message shown
    -   [ ] Expected: Stay on login screen

-   [ ] **Offline Mode**
    -   [ ] Disable network
    -   [ ] Expected: Use cached data (if logged in previously)

### Performance Testing

-   [ ] **App Startup**
    -   [ ] Time app from launch to dashboard
    -   [ ] Expected: < 3 seconds
-   [ ] **Data Loading**
    -   [ ] Navigate to inventory
    -   [ ] Check loading spinner
    -   [ ] Expected: Items load within 2 seconds
-   [ ] **Hot Reload**
    -   [ ] Make a code change
    -   [ ] Press 'r' in terminal
    -   [ ] Expected: App reloads instantly

### Code Quality

-   [ ] **Analyze Code**
    -   [ ] Run: `flutter analyze`
    -   [ ] Expected: No errors or warnings
-   [ ] **Format Code**
    -   [ ] Run: `flutter format lib/`
    -   [ ] Expected: All files formatted correctly

### API Integration

-   [ ] **Login Endpoint**
    -   [ ] Test with correct credentials
    -   [ ] Expected: Valid JWT token received
    -   [ ] Expected: User object in response
-   [ ] **Inventory Endpoint**
    -   [ ] Test GET /api/inventory/items
    -   [ ] Expected: JSON list received
    -   [ ] Expected: Items displayed in app
-   [ ] **Warehouse Endpoint**
    -   [ ] Test GET /api/warehouses
    -   [ ] Expected: Warehouse list loaded

### Local Storage (Hive)

-   [ ] **Token Persistence**
    -   [ ] Login successfully
    -   [ ] Kill app completely
    -   [ ] Restart app
    -   [ ] Expected: Remain logged in
-   [ ] **Cache Clearing**
    -   [ ] Logout
    -   [ ] Expected: Hive boxes cleared
    -   [ ] Expected: Redirect to login

### UI/UX Testing

-   [ ] **Responsive Design**
    -   [ ] Test on different emulator sizes
    -   [ ] Expected: Layout adapts properly
-   [ ] **Theme System**
    -   [ ] Check light theme applies
    -   [ ] Toggle dark mode (if implemented)
    -   [ ] Expected: Colors update correctly
-   [ ] **Navigation**
    -   [ ] Test all route transitions
    -   [ ] Press back button
    -   [ ] Expected: Navigation history preserved

### Documentation Verification

-   [ ] [ ] QUICKSTART.md is accurate
-   [ ] [ ] IMPLEMENTATION_PROGRESS.md is updated
-   [ ] [ ] FLUTTER_APP_SUMMARY.md reflects current state
-   [ ] [ ] Code comments are clear and complete
-   [ ] [ ] README files accessible

### Debugging Tools

-   [ ] **Flutter DevTools**
    -   [ ] Run: `flutter pub global activate devtools`
    -   [ ] Run app with: `flutter run`
    -   [ ] Open browser to DevTools URL
    -   [ ] Expected: Can inspect widget tree
-   [ ] **Android Logcat**
    -   [ ] View logs: `adb logcat`
    -   [ ] Expected: App logs visible
-   [ ] **IDE Debugging**
    -   [ ] Set breakpoint in code
    -   [ ] Run with debugger
    -   [ ] Expected: Can step through code

### Known Issues & Workarounds

| Issue                  | Solution                                 | Status  |
| ---------------------- | ---------------------------------------- | ------- |
| JSON generation fails  | Run `flutter clean` then `pub get` again | ✓ Known |
| Emulator won't connect | Try `adb reconnect`                      | ✓ Known |
| API timeout            | Check backend is running                 | ✓ Known |
| App freezes on login   | Check network connectivity               | ✓ Known |

### Next Steps After Verification

1. **If All Tests Pass:**

    - [ ] Commit code to git
    - [ ] Create release branch
    - [ ] Proceed with additional screens

2. **If Issues Found:**
    - [ ] Document in ISSUES.md
    - [ ] Check logs for errors
    - [ ] Review TROUBLESHOOTING section in QUICKSTART.md

### Build & Deployment (Future)

#### Android

-   [ ] Configure signing key
-   [ ] Update app version in pubspec.yaml
-   [ ] Run: `flutter build apk --release`
-   [ ] Test APK on physical device
-   [ ] Upload to PlayStore

#### iOS

-   [ ] Update app version
-   [ ] Configure bundle identifier
-   [ ] Run: `flutter build ios --release`
-   [ ] Archive in Xcode
-   [ ] Upload to TestFlight

### Post-Launch Checklist

-   [ ] User feedback documented
-   [ ] Crash logs reviewed
-   [ ] Performance metrics analyzed
-   [ ] Security audit completed
-   [ ] Release notes prepared
-   [ ] PlayStore listing created
-   [ ] Marketing materials prepared

---

## Quick Commands Reference

```bash
# Project Setup
cd D:\WORKSPACE\PROJECT\wms_mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Running
flutter run                    # Run on default device
flutter run -d emulator-5554   # Run on specific device
flutter run -v                 # Run with verbose logging
flutter run --profile          # Run in profile mode
flutter run --release          # Run in release mode

# Development
flutter hot reload             # Press 'r' in terminal
flutter hot restart            # Press 'R' in terminal
flutter analyze               # Check code
flutter format lib/           # Format code
flutter doctor                # Check Flutter setup

# Debugging
flutter run --debug           # Run with debugger
flutter attach                # Attach to running app
adb logcat                     # View device logs
adb devices                    # List connected devices

# Building
flutter build apk --release   # Build Android APK
flutter build ios --release   # Build iOS app
flutter clean                 # Clean all build files

# Testing
flutter test                  # Run tests
flutter test --coverage       # Run with coverage
```

---

## Troubleshooting Quick Guide

### App Won't Launch

1. Check emulator is running: `flutter devices`
2. Verify backend: `http://localhost:3000`
3. Clean build: `flutter clean && flutter pub get`
4. Restart emulator

### JSON Generation Failed

1. Delete `pubspec.lock`
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`

### API Connection Failed

1. Verify backend URL in `lib/config/api_config.dart`
2. Restart backend server
3. Check firewall settings
4. Verify emulator network settings

### Hot Reload Not Working

1. Hot reload requires code changes only
2. Changes to pubspec.yaml require hot restart
3. Some changes require full rebuild

### Emulator Performance Slow

1. Increase allocated RAM
2. Use release mode for testing
3. Restart emulator

---

## Success Indicators

✅ When you see these, you're good to go:

1. **Login Screen** - Displays without errors
2. **Login Works** - Can authenticate with test credentials
3. **Dashboard Loads** - Shows statistics and user info
4. **Inventory Shows** - Item list populates from backend
5. **No Crashes** - App runs for 5+ minutes without issues
6. **Navigation Works** - Can switch between screens
7. **Data Persists** - After logout and login, data remains
8. **Search Works** - Can search inventory items
9. **No Console Errors** - Logcat shows no exceptions
10. **Performance OK** - Screens load in < 2 seconds

---

**Checklist Version:** 1.0  
**Last Updated:** December 1, 2025  
**Status:** 🟢 Ready for Use
