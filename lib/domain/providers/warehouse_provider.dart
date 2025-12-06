import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/data/remote/warehouse_service.dart';
import 'package:wms_mobile/domain/providers/auth_provider.dart';

// Warehouse State
class WarehouseState {
  final List<Warehouse> warehouses;
  final Warehouse? selectedWarehouse;
  final List<BinLocation> bins;
  final bool isLoading;
  final String? error;

  WarehouseState({
    this.warehouses = const [],
    this.selectedWarehouse,
    this.bins = const [],
    this.isLoading = false,
    this.error,
  });

  WarehouseState copyWith({
    List<Warehouse>? warehouses,
    Warehouse? selectedWarehouse,
    List<BinLocation>? bins,
    bool? isLoading,
    String? error,
  }) {
    return WarehouseState(
      warehouses: warehouses ?? this.warehouses,
      selectedWarehouse: selectedWarehouse ?? this.selectedWarehouse,
      bins: bins ?? this.bins,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Warehouse Notifier
class WarehouseNotifier extends StateNotifier<WarehouseState> {
  late WarehouseService _warehouseService;
  final Ref ref;

  WarehouseNotifier(this.ref) : super(WarehouseState());

  /// Initialize service with token
  void _initializeService() {
    final token = ref.read(tokenProvider);
    if (token != null) {
      _warehouseService = WarehouseService(token);
    }
  }

  /// Fetch all warehouses
  Future<void> fetchWarehouses() async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final warehouses = await _warehouseService.getWarehouses();
      state = state.copyWith(
        warehouses: warehouses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select warehouse and fetch its bins
  Future<void> selectWarehouse(String warehouseId) async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final warehouse = await _warehouseService.getWarehouseById(warehouseId);
      final bins = await _warehouseService.getWarehousingBins(warehouseId);

      state = state.copyWith(
        selectedWarehouse: warehouse,
        bins: bins,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get warehouse by ID
  Future<Warehouse?> getWarehouse(String warehouseId) async {
    _initializeService();

    try {
      return await _warehouseService.getWarehouseById(warehouseId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get bins for warehouse
  Future<void> fetchBins(String warehouseId) async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final bins = await _warehouseService.getWarehousingBins(warehouseId);
      state = state.copyWith(
        bins: bins,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create warehouse
  Future<bool> createWarehouse({
    required String name,
    required String location,
    required String managerId,
  }) async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newWarehouse = await _warehouseService.createWarehouse(
        name: name,
        location: location,
        managerId: managerId,
      );

      final updatedWarehouses = [newWarehouse, ...state.warehouses];
      state = state.copyWith(
        warehouses: updatedWarehouses,
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

  /// Create bin
  Future<bool> createBin(
    String warehouseId, {
    required String binCode,
    required String level,
    required String row,
    required String column,
    required int capacity,
    List<String>? allowedCategories,
  }) async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newBin = await _warehouseService.createBin(
        warehouseId,
        binCode: binCode,
        level: level,
        row: row,
        column: column,
        capacity: capacity,
        allowedCategories: allowedCategories,
      );

      final updatedBins = [newBin, ...state.bins];
      state = state.copyWith(
        bins: updatedBins,
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

  /// Update warehouse
  Future<bool> updateWarehouse(
    String warehouseId, {
    String? name,
    String? location,
    String? managerId,
    bool? active,
  }) async {
    _initializeService();

    try {
      final updatedWarehouse = await _warehouseService.updateWarehouse(
        warehouseId,
        name: name,
        location: location,
        managerId: managerId,
        active: active,
      );

      final updatedWarehouses = state.warehouses.map((wh) {
        return wh.id == warehouseId ? updatedWarehouse : wh;
      }).toList();

      state = state.copyWith(warehouses: updatedWarehouses);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete bin
  Future<bool> deleteBin(String warehouseId, String binId) async {
    _initializeService();

    try {
      final success = await _warehouseService.deleteBin(warehouseId, binId);

      if (success) {
        final updatedBins = state.bins.where((bin) => bin.id != binId).toList();
        state = state.copyWith(bins: updatedBins);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = WarehouseState();
  }
}

// Warehouse Provider
final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, WarehouseState>((ref) {
  return WarehouseNotifier(ref);
});

// All warehouses provider
final allWarehousesProvider = Provider<List<Warehouse>>((ref) {
  return ref.watch(warehouseProvider).warehouses;
});

// Selected warehouse provider
final selectedWarehouseProvider = Provider<Warehouse?>((ref) {
  return ref.watch(warehouseProvider).selectedWarehouse;
});

// Bins for selected warehouse provider
final selectedWarehouseBinsProvider = Provider<List<BinLocation>>((ref) {
  return ref.watch(warehouseProvider).bins;
});
