import 'package:wms_mobile/data/remote/api_client.dart';
import 'package:wms_mobile/config/api_config.dart';

enum MovementType {
  inbound,
  outbound,
  transfer,
  adjustment,
  returns,
}

class Movement {
  final String id;
  final String movementNumber;
  final MovementType type;
  final String itemId;
  final String itemName;
  final String itemSku;
  final int quantity;
  final String fromBinId;
  final String fromBinCode;
  final String toBinId;
  final String toBinCode;
  final String fromWarehouseId;
  final String toWarehouseId;
  final String createdBy;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Movement({
    required this.id,
    required this.movementNumber,
    required this.type,
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    required this.quantity,
    required this.fromBinId,
    required this.fromBinCode,
    required this.toBinId,
    required this.toBinCode,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.createdBy,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      id: json['id'] as String,
      movementNumber: json['movementNumber'] as String,
      type: MovementType.values.byName(json['type'] as String),
      itemId: json['itemId'] as String,
      itemName: json['itemName'] as String,
      itemSku: json['itemSku'] as String,
      quantity: json['quantity'] as int,
      fromBinId: json['fromBinId'] as String,
      fromBinCode: json['fromBinCode'] as String,
      toBinId: json['toBinId'] as String,
      toBinCode: json['toBinCode'] as String,
      fromWarehouseId: json['fromWarehouseId'] as String,
      toWarehouseId: json['toWarehouseId'] as String,
      createdBy: json['createdBy'] as String,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'movementNumber': movementNumber,
        'type': type.name,
        'itemId': itemId,
        'itemName': itemName,
        'itemSku': itemSku,
        'quantity': quantity,
        'fromBinId': fromBinId,
        'fromBinCode': fromBinCode,
        'toBinId': toBinId,
        'toBinCode': toBinCode,
        'fromWarehouseId': fromWarehouseId,
        'toWarehouseId': toWarehouseId,
        'createdBy': createdBy,
        'status': status,
        'remarks': remarks,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class MovementService {
  late final ApiClient _apiClient;

  MovementService(String token) {
    _apiClient = ApiClient(token: token);
  }

  /// Get all movements
  Future<List<Movement>> getMovements({
    int? page,
    int? limit,
    String? type,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.movementsEndpoint,
      queryParameters: queryParams,
    );

    final movements = (response['data'] as List?)
            ?.map((e) => Movement.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return movements;
  }

  /// Get movement by ID
  Future<Movement> getMovementById(String movementId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.movementsEndpoint}/$movementId',
    );

    return Movement.fromJson(response);
  }

  /// Create inbound movement
  Future<Movement> createInboundMovement({
    required String itemId,
    required int quantity,
    required String toWarehouseId,
    required String toBinId,
    String? remarks,
  }) async {
    return _createMovement(
      type: 'inbound',
      itemId: itemId,
      quantity: quantity,
      toWarehouseId: toWarehouseId,
      toBinId: toBinId,
      remarks: remarks,
    );
  }

  /// Create outbound movement
  Future<Movement> createOutboundMovement({
    required String itemId,
    required int quantity,
    required String fromWarehouseId,
    required String fromBinId,
    String? remarks,
  }) async {
    return _createMovement(
      type: 'outbound',
      itemId: itemId,
      quantity: quantity,
      fromWarehouseId: fromWarehouseId,
      fromBinId: fromBinId,
      remarks: remarks,
    );
  }

  /// Create transfer movement
  Future<Movement> createTransferMovement({
    required String itemId,
    required int quantity,
    required String fromWarehouseId,
    required String fromBinId,
    required String toWarehouseId,
    required String toBinId,
    String? remarks,
  }) async {
    return _createMovement(
      type: 'transfer',
      itemId: itemId,
      quantity: quantity,
      fromWarehouseId: fromWarehouseId,
      fromBinId: fromBinId,
      toWarehouseId: toWarehouseId,
      toBinId: toBinId,
      remarks: remarks,
    );
  }

  /// Create adjustment movement
  Future<Movement> createAdjustmentMovement({
    required String itemId,
    required int quantity,
    required String warehouseId,
    required String binId,
    String? remarks,
  }) async {
    return _createMovement(
      type: 'adjustment',
      itemId: itemId,
      quantity: quantity,
      fromWarehouseId: warehouseId,
      fromBinId: binId,
      toWarehouseId: warehouseId,
      toBinId: binId,
      remarks: remarks,
    );
  }

  /// Create return movement
  Future<Movement> createReturnMovement({
    required String itemId,
    required int quantity,
    required String fromWarehouseId,
    required String fromBinId,
    required String toWarehouseId,
    required String toBinId,
    String? remarks,
  }) async {
    return _createMovement(
      type: 'returns',
      itemId: itemId,
      quantity: quantity,
      fromWarehouseId: fromWarehouseId,
      fromBinId: fromBinId,
      toWarehouseId: toWarehouseId,
      toBinId: toBinId,
      remarks: remarks,
    );
  }

  /// Internal method to create movement
  Future<Movement> _createMovement({
    required String type,
    required String itemId,
    required int quantity,
    String? fromWarehouseId,
    String? fromBinId,
    String? toWarehouseId,
    String? toBinId,
    String? remarks,
  }) async {
    final data = <String, dynamic>{
      'type': type,
      'itemId': itemId,
      'quantity': quantity,
    };

    if (fromWarehouseId != null) data['fromWarehouseId'] = fromWarehouseId;
    if (fromBinId != null) data['fromBinId'] = fromBinId;
    if (toWarehouseId != null) data['toWarehouseId'] = toWarehouseId;
    if (toBinId != null) data['toBinId'] = toBinId;
    if (remarks != null) data['remarks'] = remarks;

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.movementsEndpoint,
      data: data,
    );

    return Movement.fromJson(response);
  }

  /// Approve movement
  Future<Movement> approveMovement(String movementId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.movementsEndpoint}/$movementId/approve',
    );

    return Movement.fromJson(response);
  }

  /// Reject movement
  Future<Movement> rejectMovement(String movementId, String reason) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.movementsEndpoint}/$movementId/reject',
      data: {'reason': reason},
    );

    return Movement.fromJson(response);
  }

  /// Update token
  void updateToken(String token) {
    _apiClient.updateToken(token);
  }
}
