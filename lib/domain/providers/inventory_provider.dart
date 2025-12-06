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
    _initializeService();

    state = state.copyWith(
      isLoading: true,
      error: null,
      page: page ?? state.page,
      searchQuery: search,
    );

    try {
      final items = await _inventoryService.getItems(
        page: page ?? state.page,
        limit: state.limit,
        search: search,
        category: category,
      );

      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (e) {
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
  Future<bool> createItem({
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
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newItem = await _inventoryService.createItem(
        sku: sku,
        name: name,
        category: category,
        description: description,
        unitOfMeasure: unitOfMeasure,
        weight: weight,
        dimensions: dimensions,
        unitCost: unitCost,
        sellingPrice: sellingPrice,
      );

      // Add to list
      final updatedItems = [newItem, ...state.items];
      state = state.copyWith(
        items: updatedItems,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
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
