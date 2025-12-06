import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/data/remote/movement_service.dart';
import 'package:wms_mobile/data/local/models/movement_model.dart';
import 'package:wms_mobile/domain/providers/auth_provider.dart';

// Movement State
class MovementState {
  final List<MovementModel> movements;
  final MovementModel? selectedMovement;
  final bool isLoading;
  final String? error;
  final int page;
  final int limit;
  final String? filterType;
  final String? filterStatus;

  MovementState({
    this.movements = const [],
    this.selectedMovement,
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.limit = 20,
    this.filterType,
    this.filterStatus,
  });

  MovementState copyWith({
    List<MovementModel>? movements,
    MovementModel? selectedMovement,
    bool? isLoading,
    String? error,
    int? page,
    int? limit,
    String? filterType,
    String? filterStatus,
  }) {
    return MovementState(
      movements: movements ?? this.movements,
      selectedMovement: selectedMovement ?? this.selectedMovement,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      filterType: filterType ?? this.filterType,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

// Movement Notifier
class MovementNotifier extends StateNotifier<MovementState> {
  late MovementService _movementService;
  final Ref ref;

  MovementNotifier(this.ref) : super(MovementState());

  /// Initialize service with token
  void _initializeService() {
    final token = ref.read(tokenProvider);
    if (token != null) {
      _movementService = MovementService(token);
    }
  }

  /// Fetch movements
  Future<void> fetchMovements({
    int? page,
    String? type,
    String? status,
  }) async {
    print(
        '[WMS-PROVIDER] fetchMovements called - page: $page, type: $type, status: $status');
    _initializeService();

    state = state.copyWith(
      isLoading: true,
      error: null,
      page: page ?? state.page,
      filterType: type,
      filterStatus: status,
    );

    try {
      final movements = await _movementService.getMovements(
        page: page ?? state.page,
        limit: state.limit,
        type: type ?? state.filterType,
        status: status ?? state.filterStatus,
      );

      print('[WMS-PROVIDER] SUCCESS - Fetched ${movements.length} movements');

      state = state.copyWith(
        movements: movements,
        isLoading: false,
      );
    } catch (e) {
      print('[WMS-PROVIDER] ERROR - Failed to fetch movements: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get movement by ID
  Future<MovementModel?> getMovementById(String movementId) async {
    print('[WMS-PROVIDER] getMovementById called - ID: $movementId');
    _initializeService();

    try {
      final movement = await _movementService.getMovementById(movementId);
      print(
          '[WMS-PROVIDER] SUCCESS - Fetched movement: ${movement?.referenceNo}');
      return movement;
    } catch (e) {
      print('[WMS-PROVIDER] ERROR - Failed to get movement: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Create movement
  Future<bool> createMovement({
    required String type,
    required int quantity,
    required String itemId,
    String? fromBin,
    String? toBin,
    String? notes,
  }) async {
    print(
        '[WMS-PROVIDER] createMovement called - type: $type, itemId: $itemId, quantity: $quantity');
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final movement = await _movementService.createMovement(
        type: type,
        quantity: quantity,
        itemId: itemId,
        fromBin: fromBin,
        toBin: toBin,
        notes: notes,
      );

      print(
          '[WMS-PROVIDER] SUCCESS - Movement created: ${movement.referenceNo}');

      final updatedMovements = [movement, ...state.movements];
      state = state.copyWith(
        movements: updatedMovements,
        isLoading: false,
      );

      return true;
    } catch (e) {
      print('[WMS-PROVIDER] ERROR - Failed to create movement: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Filter by type
  void filterByType(String? type) {
    print('[WMS-PROVIDER] filterByType called - type: $type');
    fetchMovements(type: type, status: state.filterStatus);
  }

  /// Filter by status
  void filterByStatus(String? status) {
    print('[WMS-PROVIDER] filterByStatus called - status: $status');
    fetchMovements(type: state.filterType, status: status);
  }

  /// Clear filters
  void clearFilters() {
    print('[WMS-PROVIDER] clearFilters called');
    state = state.copyWith(
      filterType: null,
      filterStatus: null,
    );
    fetchMovements();
  }

  /// Load more movements (pagination)
  Future<void> loadMore() async {
    print('[WMS-PROVIDER] loadMore called - current page: ${state.page}');
    if (!state.isLoading) {
      fetchMovements(
        page: state.page + 1,
        type: state.filterType,
        status: state.filterStatus,
      );
    }
  }
}

// Provider
final movementProvider =
    StateNotifierProvider<MovementNotifier, MovementState>((ref) {
  return MovementNotifier(ref);
});
