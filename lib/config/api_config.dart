import 'package:dio/dio.dart';

class ApiConfig {
  // API Base URL
  // For Android Emulator: 10.0.2.2 (special alias for host machine)
  // For Physical Device: Your machine IP (e.g., 192.168.x.x)
  static const String baseUrl = 'http://192.168.18.20:3000';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';

  static const String inventoryItemsEndpoint = '/api/inventory/items';
  static const String inventoryStockEndpoint = '/api/inventory/stock';

  static const String warehousesEndpoint = '/api/warehouses';
  static const String binsEndpoint = '/api/warehouses/bins';

  static const String movementsEndpoint = '/api/movements';
  static const String reportsEndpoint = '/api/reports';

  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get inventoryItemsUrl => '$baseUrl$inventoryItemsEndpoint';
  static String get inventoryStockUrl => '$baseUrl$inventoryStockEndpoint';
  static String get warehousesUrl => '$baseUrl$warehousesEndpoint';
  static String get binsUrl => '$baseUrl$binsEndpoint';
  static String get movementsUrl => '$baseUrl$movementsEndpoint';
  static String get reportsUrl => '$baseUrl$reportsEndpoint';

  // Create Dio instance with base config
  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // Create Dio instance with auth token
  static Dio createAuthDio(String token) {
    final dio = createDio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    return dio;
  }
}
