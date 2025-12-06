import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/data/remote/inventory_service.dart';
import 'package:wms_mobile/data/local/models/item_model.dart';
import 'package:wms_mobile/domain/providers/auth_provider.dart';

// Inventory State
class InventoryState {
  final List<ItemModel> items;
  final bool isLoading;
  final String? error;
  final int page;
  final int limit;
  final String? searchQuery;

  InventoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
  });

  InventoryState copyWith({
    List<ItemModel>? items,
    bool? isLoading,
    String? error,
    int? page,
    int? limit,
    String? searchQuery,
  }) {
    return InventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Inventory Notifier
class InventoryNotifier extends StateNotifier<InventoryState> {
  late InventoryService _inventoryService;
  final Ref ref;

  InventoryNotifier(this.ref) : super(InventoryState());

  /// Initialize service with token
  void _initializeService() {
    final token = ref.read(tokenProvider);
    if (token != null) {
      _inventoryService = InventoryService(token);
    }
  }

  /// Fetch items
  Future<void> fetchItems({
    int? page,
    String? search,
    String? category,
  }) async {
    print('\n================================================');
    print('[WMS-PROVIDER] ${DateTime.now()} | fetchItems called');
    print('[WMS-PROVIDER] ${DateTime.now()} | Page: ${page ?? state.page}');
    print('[WMS-PROVIDER] ${DateTime.now()} | Search: ${search ?? "none"}');
    print('[WMS-PROVIDER] ${DateTime.now()} | Category: ${category ?? "none"}');

    _initializeService();
    print('[WMS-PROVIDER] ${DateTime.now()} | Service initialized');

    state = state.copyWith(
      isLoading: true,
      error: null,
      page: page ?? state.page,
      searchQuery: search,
    );
    print('[WMS-PROVIDER] ${DateTime.now()} | State set to loading');

    try {
      print(
          '[WMS-PROVIDER] ${DateTime.now()} | Calling inventoryService.getItems()...');
      final items = await _inventoryService.getItems(
        page: page ?? state.page,
        limit: state.limit,
        search: search,
        category: category,
      );

      print(
          '[WMS-PROVIDER] ${DateTime.now()} | Items received: ${items.length}');
      if (items.isNotEmpty) {
        print(
            '[WMS-PROVIDER] ${DateTime.now()} | First item: ${items[0].sku} - ${items[0].name}');
      }

      state = state.copyWith(
        items: items,
        isLoading: false,
      );

      print(
          '[WMS-PROVIDER] ${DateTime.now()} | SUCCESS - Fetch successful! Total items: ${items.length}');
      print('================================================\n');
    } catch (e) {
      print('[WMS-PROVIDER] ${DateTime.now()} | ERROR - Fetch failed: $e');
      print('[WMS-PROVIDER] ${DateTime.now()} | Error type: ${e.runtimeType}');
      print('================================================\n');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search items
  Future<void> searchItems(String query) async {
    await fetchItems(search: query, page: 1);
  }

  /// Get item by ID
  Future<ItemWithStock?> getItemById(String itemId) async {
    _initializeService();

    try {
      return await _inventoryService.getItemById(itemId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Create item
  Future<bool> createItem(Map<String, dynamic> itemData) async {
    print('\n================================================');
    print('[WMS-PROVIDER] ${DateTime.now()} | createItem called');
    print(
        '[WMS-PROVIDER] ${DateTime.now()} | Data: SKU=${itemData['sku']}, Name=${itemData['name']}');

    _initializeService();
    print('[WMS-PROVIDER] ${DateTime.now()} | Service initialized');

    state = state.copyWith(isLoading: true);
    print('[WMS-PROVIDER] ${DateTime.now()} | State set to loading');

    try {
      print(
          '[WMS-PROVIDER] ${DateTime.now()} | Calling inventoryService.createItem()...');
      final newItem = await _inventoryService.createItem(
        sku: itemData['sku'] as String,
        name: itemData['name'] as String,
        category: itemData['category'] as String,
        barcode: itemData['barcode'] as String?,
        description: itemData['description'] as String?,
        unitOfMeasure: itemData['unitOfMeasure'] as String?,
        weight: itemData['weight'] as double?,
        dimensions: itemData['dimensions'] as String?,
        unitCost: itemData['unitCost'] as double?,
        sellingPrice: itemData['sellingPrice'] as double?,
        minStockLevel: itemData['minStockLevel'] as int?,
        maxStockLevel: itemData['maxStockLevel'] as int?,
        reorderPoint: itemData['reorderPoint'] as int?,
        reorderQty: itemData['reorderQty'] as int?,
        manufacturer: itemData['manufacturer'] as String?,
        supplier: itemData['supplier'] as String?,
      );

      print(
          '[WMS-PROVIDER] ${DateTime.now()} | SUCCESS - Item created successfully!');
      print('[WMS-PROVIDER] ${DateTime.now()} | New item ID: ${newItem.id}');
      print('[WMS-PROVIDER] ${DateTime.now()} | New item SKU: ${newItem.sku}');

      // Add to list
      final updatedItems = [newItem, ...state.items];
      state = state.copyWith(
        items: updatedItems,
        isLoading: false,
      );

      print('[WMS-PROVIDER] ${DateTime.now()} | State updated with new item');
      print(
          '[WMS-PROVIDER] ${DateTime.now()} | Total items in state: ${updatedItems.length}');
      print('================================================\n');

      return true;
    } catch (e) {
      print('[WMS-PROVIDER] ${DateTime.now()} | ERROR: $e');
      print('[WMS-PROVIDER] ${DateTime.now()} | Error type: ${e.runtimeType}');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      print('[WMS-PROVIDER] ${DateTime.now()} | State updated with error');
      print('================================================\n');
      rethrow;
    }
  }

  /// Update item
  Future<bool> updateItem(
    String itemId, {
    String? name,
    String? description,
    String? category,
    double? unitCost,
    double? sellingPrice,
    bool? active,
  }) async {
    _initializeService();

    try {
      final updatedItem = await _inventoryService.updateItem(
        itemId,
        name: name,
        description: description,
        category: category,
        unitCost: unitCost,
        sellingPrice: sellingPrice,
        active: active,
      );

      // Update in list
      final updatedItems = state.items.map((item) {
        return item.id == itemId ? updatedItem : item;
      }).toList();

      state = state.copyWith(items: updatedItems);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Get items by category
  Future<void> getItemsByCategory(String category) async {
    await fetchItems(category: category, page: 1);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = InventoryState();
  }
}

// Inventory Provider
final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier(ref);
});

// Selected item provider
final selectedItemProvider = StateProvider<ItemModel?>((ref) {
  return null;
});

// Stock levels provider
final stockLevelsProvider =
    FutureProvider.family<List<StockData>, String>((ref, itemId) async {
  final token = ref.watch(tokenProvider);
  if (token == null) return [];

  final service = InventoryService(token);
  return service.getStockLevels(itemId: itemId);
});
