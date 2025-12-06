# Flutter Mobile App - Quick Start Guide

## Current Status

✅ Infrastructure complete - 19 core files created
🟡 UI screens created (4/8) - Ready for testing
⏳ Build and deployment pending

## Project Structure

```
D:\WORKSPACE\PROJECT\wms_mobile\
├── lib/
│   ├── config/            ✅ (4 files)
│   ├── data/
│   │   ├── local/models/  ✅ (2 files)
│   │   └── remote/        ✅ (5 files)
│   ├── domain/providers/  ✅ (4 files)
│   ├── presentation/
│   │   ├── screens/       ✅ (4 files)
│   │   └── widgets/       ⏳ (TBD)
│   └── main.dart          ✅
├── pubspec.yaml           ✅
└── [Flutter boilerplate]
```

## Prerequisites

1. **Flutter Installation** (version 3.13.0+)

    ```bash
    flutter --version
    ```

2. **Backend Running** (WMS Next.js server)
    ```bash
    # From D:\WORKSPACE\PROJECT\wms directory
    npm run dev
    # Should be running on http://localhost:3000
    ```

## Setup Instructions

### 1. Install Dependencies

```bash
cd D:\WORKSPACE\PROJECT\wms_mobile
flutter pub get
```

### 2. Generate JSON Serialization Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Verify Android Emulator (for testing)

```bash
# Start emulator
flutter emulators --launch <emulator_id>

# Or list available emulators
flutter emulators
```

### 4. Run the App

```bash
# On Android emulator
flutter run

# Or specify device
flutter run -d emulator-5554

# On physical device (if connected)
flutter run -d <device_id>
```

## Available Screens

### ✅ Authentication

-   **Login Screen** (`/login`)

    -   Email/password input
    -   Remember me checkbox
    -   Forgot password link
    -   Register redirect

-   **Register Screen** (`/register`)
    -   Email, username, full name, phone
    -   Password confirmation
    -   Terms and conditions acceptance
    -   Login redirect

### ✅ Main App

-   **Dashboard Screen** (`/dashboard`)

    -   Welcome greeting with user info
    -   Quick stats (Items, Warehouses, Bins, Stock Value)
    -   Quick action buttons
    -   Recent items list
    -   Refresh capability

-   **Inventory Screen** (`/inventory`)
    -   Search functionality
    -   Category filter chips
    -   Item list with SKU and status
    -   Expandable item details
    -   Add new item button
    -   Filter options

### 🟡 Placeholder Screens (Need Implementation)

-   **Movements Screen** (`/movements`) - WIP
-   **Warehouses Screen** (`/warehouses`) - WIP

## API Configuration

-   **Base URL**: `http://10.0.2.2:3000` (Android emulator)
-   **API Endpoints Configured**:
    -   `/api/auth/login` - User login
    -   `/api/auth/register` - User registration
    -   `/api/inventory/items` - Inventory CRUD
    -   `/api/inventory/stock` - Stock levels
    -   `/api/warehouses` - Warehouse management
    -   `/api/warehouses/:id/bins` - Bin locations
    -   `/api/movements` - Stock movements

## Features Implemented

### Authentication ✅

-   JWT token-based login/registration
-   Local token storage with Hive
-   Auto-logout on invalid token
-   Password encryption support

### Inventory Management ✅

-   View all items with pagination
-   Search items by name/SKU
-   Filter by category
-   Display stock levels
-   Item details view

### State Management ✅

-   Riverpod providers for auth, inventory, warehouse, movements
-   Automatic state refresh
-   Error handling with user messages
-   Loading states

### Offline Support ✅

-   Hive local storage for caching
-   Auto-sync when online
-   Local authentication token storage

### UI/UX ✅

-   Material 3 design system
-   Light and dark themes
-   Responsive layout
-   Loading indicators
-   Error messages
-   Empty states

## Test Credentials

Use these for testing:

**Admin User:**

-   Email: `admin@wms.local`
-   Password: `admin123`

**Operator User:**

-   Email: `operator@wms.local`
-   Password: `operator123`

## Troubleshooting

### Issue: "Connection refused" when trying to login

**Solution**: Make sure the backend WMS server is running on `http://localhost:3000`

```bash
# In a separate terminal
cd D:\WORKSPACE\PROJECT\wms
npm run dev
```

### Issue: "Failed to load assets" or "Asset not found"

**Solution**: Verify pubspec.yaml assets configuration and run:

```bash
flutter pub get
flutter clean
flutter run
```

### Issue: JSON serialization files not generated (\*.g.dart)

**Solution**: Run build_runner:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Emulator timeout

**Solution**:

```bash
# Kill all Dart processes
Get-Process dart -ErrorAction SilentlyContinue | Stop-Process -Force

# Restart emulator
flutter clean
flutter run
```

## Next Development Steps

1. **Complete Remaining Screens**

    - Implement Movements Screen (create/view/approve movements)
    - Implement Warehouses Screen (bin locations, capacity management)

2. **Add Barcode Scanning**

    - Integrate mobile_scanner package
    - Create barcode scan screen
    - Link to movement creation

3. **Enhance UI Components**

    - Create reusable widgets
    - Add more detailed animations
    - Improve loading states

4. **Testing**

    - Unit tests for providers
    - Widget tests for screens
    - Integration tests with backend

5. **Deployment**
    - Android APK build
    - iOS IPA build
    - PlayStore / TestFlight submission

## Development Tips

### Hot Reload

During development, use hot reload to see changes instantly:

```
Press 'r' in terminal to hot reload
Press 'R' to hot restart
```

### Debugging

Enable debug logging:

```bash
flutter run -v  # Verbose mode
```

### Performance Testing

```bash
flutter run --profile   # Profile mode for performance testing
flutter run --release   # Release mode
```

## File Modifications Reference

### To Update API Configuration

File: `lib/config/api_config.dart`

-   Change `baseUrl` for different backend
-   Modify endpoints as needed
-   Adjust timeout values

### To Update Theme

File: `lib/config/theme.dart`

-   Modify color scheme
-   Update text styles
-   Adjust component themes

### To Add New Routes

File: `lib/config/routes.dart`

-   Add new GoRoute with path and builder
-   Import new screen widget
-   Add to router.routes array

## Resources

-   [Flutter Documentation](https://flutter.dev/docs)
-   [Riverpod Documentation](https://riverpod.dev/)
-   [Go Router Documentation](https://pub.dev/packages/go_router)
-   [Material 3 Design](https://m3.material.io/)

## Support & Issues

For backend API issues, check:

-   Backend status: `http://localhost:3000/api/health` (if implemented)
-   Backend logs for error messages
-   Network connectivity on emulator

For app issues:

-   Check Flutter version compatibility
-   Review build_runner output
-   Check Logcat for runtime errors
