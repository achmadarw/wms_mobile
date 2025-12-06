import 'package:wms_mobile/data/local/models/item_model.dart';
import 'package:wms_mobile/data/remote/api_client.dart';
import 'package:wms_mobile/config/api_config.dart';

class StockData {
  final String warehouseId;
  final String binId;
  final int quantity;
  final DateTime lastUpdated;

  StockData({
    required this.warehouseId,
    required this.binId,
    required this.quantity,
    required this.lastUpdated,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      warehouseId: json['warehouseId'] as String,
      binId: json['binId'] as String,
      quantity: json['quantity'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class ItemWithStock {
  final ItemModel item;
  final List<StockData> stocks;
  final int totalQuantity;

  ItemWithStock({
    required this.item,
    required this.stocks,
    required this.totalQuantity,
  });

  factory ItemWithStock.fromJson(Map<String, dynamic> json) {
    final stocksData = (json['stocks'] as List?)
            ?.map((e) => StockData.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ItemWithStock(
      item: ItemModel.fromJson(json['item'] as Map<String, dynamic>),
      stocks: stocksData,
      totalQuantity: json['totalQuantity'] as int? ?? 0,
    );
  }
}

class InventoryService {
  late final ApiClient _apiClient;

  InventoryService(String token) {
    _apiClient = ApiClient(token: token);
  }

  /// Get all items
  Future<List<ItemModel>> getItems({
    int? page,
    int? limit,
    String? search,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.inventoryItemsEndpoint,
      queryParameters: queryParams,
    );

    final items = (response['data'] as List?)
            ?.map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return items;
  }

  /// Get item by ID
  Future<ItemWithStock> getItemById(String itemId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.inventoryItemsEndpoint}/$itemId',
    );

    return ItemWithStock.fromJson(response);
  }

  /// Create new item
  Future<ItemModel> createItem({
    required String sku,
    required String name,
    required String category,
    String? description,
    String? unitOfMeasure,
    double? weight,
    String? dimensions,
    double? unitCost,
    double? sellingPrice,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.inventoryItemsEndpoint,
      data: {
        'sku': sku,
        'name': name,
        'category': category,
        'description': description,
        'unitOfMeasure': unitOfMeasure,
        'weight': weight,
        'dimensions': dimensions,
        'unitCost': unitCost,
        'sellingPrice': sellingPrice,
      },
    );

    return ItemModel.fromJson(response);
  }

  /// Update item
  Future<ItemModel> updateItem(
    String itemId, {
    String? name,
    String? description,
    String? category,
    double? unitCost,
    double? sellingPrice,
    bool? active,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (category != null) data['category'] = category;
    if (unitCost != null) data['unitCost'] = unitCost;
    if (sellingPrice != null) data['sellingPrice'] = sellingPrice;
    if (active != null) data['active'] = active;

    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.inventoryItemsEndpoint}/$itemId',
      data: data,
    );

    return ItemModel.fromJson(response);
  }

  /// Get stock levels
  Future<List<StockData>> getStockLevels({
    String? warehouseId,
    String? itemId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (warehouseId != null) queryParams['warehouseId'] = warehouseId;
    if (itemId != null) queryParams['itemId'] = itemId;

    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.inventoryStockEndpoint,
      queryParameters: queryParams,
    );

    return response
        .map((e) => StockData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Search items by name or SKU
  Future<List<ItemModel>> searchItems(String query) async {
    return getItems(search: query);
  }

  /// Get items by category
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    return getItems(category: category);
  }

  /// Update token (for session management)
  void updateToken(String token) {
    _apiClient.updateToken(token);
  }
}
