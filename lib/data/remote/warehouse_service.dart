import 'package:wms_mobile/data/remote/api_client.dart';
import 'package:wms_mobile/config/api_config.dart';

class BinLocation {
  final String id;
  final String warehouseId;
  final String binCode;
  final String level;
  final String row;
  final String column;
  final int capacity;
  final int currentQuantity;
  final List<String> allowedCategories;
  final bool active;

  BinLocation({
    required this.id,
    required this.warehouseId,
    required this.binCode,
    required this.level,
    required this.row,
    required this.column,
    required this.capacity,
    required this.currentQuantity,
    required this.allowedCategories,
    required this.active,
  });

  factory BinLocation.fromJson(Map<String, dynamic> json) {
    return BinLocation(
      id: json['id'] as String,
      warehouseId: json['warehouseId'] as String,
      binCode: json['binCode'] as String,
      level: json['level'] as String,
      row: json['row'] as String,
      column: json['column'] as String,
      capacity: json['capacity'] as int,
      currentQuantity: json['currentQuantity'] as int? ?? 0,
      allowedCategories:
          List<String>.from(json['allowedCategories'] as List? ?? []),
      active: json['active'] as bool? ?? true,
    );
  }
}

class Warehouse {
  final String id;
  final String name;
  final String location;
  final String managerId;
  final int totalBins;
  final double totalCapacity;
  final double usedCapacity;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    required this.managerId,
    required this.totalBins,
    required this.totalCapacity,
    required this.usedCapacity,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      managerId: json['managerId'] as String,
      totalBins: json['totalBins'] as int? ?? 0,
      totalCapacity: (json['totalCapacity'] as num?)?.toDouble() ?? 0.0,
      usedCapacity: (json['usedCapacity'] as num?)?.toDouble() ?? 0.0,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  double get capacityPercentage =>
      totalCapacity > 0 ? (usedCapacity / totalCapacity * 100) : 0;
}

class WarehouseService {
  late final ApiClient _apiClient;

  WarehouseService(String token) {
    _apiClient = ApiClient(token: token);
  }

  /// Get all warehouses
  Future<List<Warehouse>> getWarehouses() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.warehousesEndpoint,
    );

    final warehouses = (response['data'] as List?)
            ?.map((e) => Warehouse.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return warehouses;
  }

  /// Get warehouse by ID
  Future<Warehouse> getWarehouseById(String warehouseId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.warehousesEndpoint}/$warehouseId',
    );

    return Warehouse.fromJson(response);
  }

  /// Get warehouse bins
  Future<List<BinLocation>> getWarehousingBins(String warehouseId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConfig.warehousesEndpoint}/$warehouseId/bins',
    );

    return response
        .map((e) => BinLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get bin location by ID
  Future<BinLocation> getBinById(String warehouseId, String binId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.warehousesEndpoint}/$warehouseId/bins/$binId',
    );

    return BinLocation.fromJson(response);
  }

  /// Create warehouse
  Future<Warehouse> createWarehouse({
    required String name,
    required String location,
    required String managerId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.warehousesEndpoint,
      data: {
        'name': name,
        'location': location,
        'managerId': managerId,
      },
    );

    return Warehouse.fromJson(response);
  }

  /// Create bin location
  Future<BinLocation> createBin(
    String warehouseId, {
    required String binCode,
    required String level,
    required String row,
    required String column,
    required int capacity,
    List<String>? allowedCategories,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.warehousesEndpoint}/$warehouseId/bins',
      data: {
        'binCode': binCode,
        'level': level,
        'row': row,
        'column': column,
        'capacity': capacity,
        'allowedCategories': allowedCategories ?? [],
      },
    );

    return BinLocation.fromJson(response);
  }

  /// Update warehouse
  Future<Warehouse> updateWarehouse(
    String warehouseId, {
    String? name,
    String? location,
    String? managerId,
    bool? active,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (location != null) data['location'] = location;
    if (managerId != null) data['managerId'] = managerId;
    if (active != null) data['active'] = active;

    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.warehousesEndpoint}/$warehouseId',
      data: data,
    );

    return Warehouse.fromJson(response);
  }

  /// Update bin location
  Future<BinLocation> updateBin(
    String warehouseId,
    String binId, {
    int? capacity,
    List<String>? allowedCategories,
    bool? active,
  }) async {
    final data = <String, dynamic>{};
    if (capacity != null) data['capacity'] = capacity;
    if (allowedCategories != null)
      data['allowedCategories'] = allowedCategories;
    if (active != null) data['active'] = active;

    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.warehousesEndpoint}/$warehouseId/bins/$binId',
      data: data,
    );

    return BinLocation.fromJson(response);
  }

  /// Delete bin
  Future<bool> deleteBin(String warehouseId, String binId) async {
    return _apiClient.delete(
      '${ApiConfig.warehousesEndpoint}/$warehouseId/bins/$binId',
    );
  }

  /// Update token
  void updateToken(String token) {
    _apiClient.updateToken(token);
  }
}
