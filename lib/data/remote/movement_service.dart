import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_mobile/data/local/models/movement_model.dart';

class APIConfig {
  static const String baseURL = 'http://192.168.18.20:3000';
  static const String movementsEndpoint = '/api/inventory/movements';
}

class MovementService {
  final String token;

  MovementService(this.token);

  /// Get movements with optional filters
  Future<List<MovementModel>> getMovements({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? itemId,
    String? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print('[WMS-SERVICE] getMovements called');
    print('[WMS-SERVICE] Endpoint: ${APIConfig.movementsEndpoint}');
    print(
        '[WMS-SERVICE] Params - page: $page, limit: $limit, type: $type, status: $status');

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (itemId != null) 'itemId': itemId,
        if (warehouseId != null) 'warehouseId': warehouseId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final uri =
          Uri.parse('${APIConfig.baseURL}${APIConfig.movementsEndpoint}')
              .replace(queryParameters: queryParams);

      print('[WMS-SERVICE] Full URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[WMS-SERVICE] Response status: ${response.statusCode}');
      print('[WMS-SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Handle different response structures
        List<dynamic> movementsJson;
        if (jsonData is List) {
          movementsJson = jsonData;
        } else if (jsonData['movements'] != null) {
          movementsJson = jsonData['movements'];
        } else if (jsonData['data'] != null) {
          movementsJson = jsonData['data'];
        } else {
          print('[WMS-SERVICE] ERROR - Unexpected response structure');
          return [];
        }

        final movements =
            movementsJson.map((json) => MovementModel.fromJson(json)).toList();

        print('[WMS-SERVICE] SUCCESS - Parsed ${movements.length} movements');
        return movements;
      } else {
        print(
            '[WMS-SERVICE] ERROR - Status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load movements: ${response.statusCode}');
      }
    } catch (e) {
      print('[WMS-SERVICE] ERROR - Exception: $e');
      rethrow;
    }
  }

  /// Get movement by ID
  Future<MovementModel?> getMovementById(String id) async {
    print('[WMS-SERVICE] getMovementById called - ID: $id');
    print('[WMS-SERVICE] Endpoint: ${APIConfig.movementsEndpoint}/$id');

    try {
      final uri =
          Uri.parse('${APIConfig.baseURL}${APIConfig.movementsEndpoint}/$id');
      print('[WMS-SERVICE] Full URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[WMS-SERVICE] Response status: ${response.statusCode}');
      print('[WMS-SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Handle different response structures
        Map<String, dynamic> movementJson;
        if (jsonData is Map) {
          if (jsonData['movement'] != null) {
            movementJson = Map<String, dynamic>.from(jsonData['movement']);
          } else if (jsonData['data'] != null) {
            movementJson = Map<String, dynamic>.from(jsonData['data']);
          } else {
            movementJson = Map<String, dynamic>.from(jsonData);
          }
        } else {
          print('[WMS-SERVICE] ERROR - Unexpected response structure');
          return null;
        }

        final movement = MovementModel.fromJson(movementJson);
        print(
            '[WMS-SERVICE] SUCCESS - Parsed movement: ${movement.referenceNo}');
        return movement;
      } else {
        print(
            '[WMS-SERVICE] ERROR - Status ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[WMS-SERVICE] ERROR - Exception: $e');
      rethrow;
    }
  }

  /// Create movement
  Future<MovementModel> createMovement({
    required String type,
    required int quantity,
    required String itemId,
    String? fromBin,
    String? toBin,
    String? notes,
  }) async {
    print('[WMS-SERVICE] createMovement called');
    print('[WMS-SERVICE] Endpoint: ${APIConfig.movementsEndpoint}');
    print(
        '[WMS-SERVICE] Data - type: $type, itemId: $itemId, quantity: $quantity');

    try {
      final uri =
          Uri.parse('${APIConfig.baseURL}${APIConfig.movementsEndpoint}');
      print('[WMS-SERVICE] Full URL: $uri');

      final requestBody = {
        'type': type,
        'quantity': quantity,
        'itemId': itemId,
        if (fromBin != null) 'fromBin': fromBin,
        if (toBin != null) 'toBin': toBin,
        if (notes != null) 'notes': notes,
      };

      print('[WMS-SERVICE] Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('[WMS-SERVICE] Response status: ${response.statusCode}');
      print('[WMS-SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);

        // Handle different response structures
        Map<String, dynamic> movementJson;
        if (jsonData is Map) {
          if (jsonData['movement'] != null) {
            movementJson = Map<String, dynamic>.from(jsonData['movement']);
          } else if (jsonData['data'] != null) {
            movementJson = Map<String, dynamic>.from(jsonData['data']);
          } else {
            movementJson = Map<String, dynamic>.from(jsonData);
          }
        } else {
          throw Exception('Unexpected response structure');
        }

        final movement = MovementModel.fromJson(movementJson);
        print(
            '[WMS-SERVICE] SUCCESS - Created movement: ${movement.referenceNo}');
        return movement;
      } else {
        print(
            '[WMS-SERVICE] ERROR - Status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to create movement: ${response.statusCode}');
      }
    } catch (e) {
      print('[WMS-SERVICE] ERROR - Exception: $e');
      rethrow;
    }
  }
}
