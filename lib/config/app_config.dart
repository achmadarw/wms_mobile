import 'package:hive_flutter/hive_flutter.dart';

class AppConfig {
  static const String appName = 'WMS Mobile';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String authBoxName = 'auth_box';
  static const String inventoryBoxName = 'inventory_box';
  static const String warehouseBoxName = 'warehouse_box';
  static const String movementBoxName = 'movement_box';

  // Shared preferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String lastSyncKey = 'last_sync';

  /// Initialize Hive for local storage
  static Future<void> initializeHive() async {
    await Hive.initFlutter();

    // Create and open boxes
    await Hive.openBox(authBoxName);
    await Hive.openBox(inventoryBoxName);
    await Hive.openBox(warehouseBoxName);
    await Hive.openBox(movementBoxName);
  }

  /// Get Hive box
  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  /// Clear all Hive boxes (for logout)
  static Future<void> clearAllBoxes() async {
    await Hive.box(authBoxName).clear();
    await Hive.box(inventoryBoxName).clear();
    await Hive.box(warehouseBoxName).clear();
    await Hive.box(movementBoxName).clear();
  }
}
