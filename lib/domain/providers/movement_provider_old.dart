import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/data/remote/movement_service.dart';
import 'package:wms_mobile/domain/providers/auth_provider.dart';

// Movement State
class MovementState {
  final List<Movement> movements;
  final Movement? selectedMovement;
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
    List<Movement>? movements,
    Movement? selectedMovement,
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
      error: error ?? this.error,
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
        type: type,
        status: status,
      );

      state = state.copyWith(
        movements: movements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get movement by ID
  Future<Movement?> getMovementById(String movementId) async {
    _initializeService();

    try {
      return await _movementService.getMovementById(movementId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Create inbound movement
  Future<bool> createInboundMovement({
    required String itemId,
    required int quantity,
    required String toWarehouseId,
    required String toBinId,
    String? remarks,
  }) async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final movement = await _movementService.createInboundMovement(
        itemId: itemId,
        quantity: quantity,
        toWarehouseId: toWarehouseId,
        toBinId: toBinId,
        remarks: remarks,
      );

      final updatedMovements = [movement, ...state.movements];
      state = state.copyWith(
        movements: updatedMovements,
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

  /// Create outbound movement
  Future<bool> createOutboundMovement({
    required String itemId,
    required int quantity,
    required String fromWarehouseId,
    required String fromBinId,
    String? remarks,
  }) async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final movement = await _movementService.createOutboundMovement(
        itemId: itemId,
        quantity: quantity,
        fromWarehouseId: fromWarehouseId,
        fromBinId: fromBinId,
        remarks: remarks,
      );

      final updatedMovements = [movement, ...state.movements];
      state = state.copyWith(
        movements: updatedMovements,
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

  /// Create transfer movement
  Future<bool> createTransferMovement({
    required String itemId,
    required int quantity,
    required String fromWarehouseId,
    required String fromBinId,
    required String toWarehouseId,
    required String toBinId,
    String? remarks,
  }) async {
    _initializeService();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final movement = await _movementService.createTransferMovement(
        itemId: itemId,
        quantity: quantity,
        fromWarehouseId: fromWarehouseId,
        fromBinId: fromBinId,
        toWarehouseId: toWarehouseId,
        toBinId: toBinId,
        remarks: remarks,
      );

      final updatedMovements = [movement, ...state.movements];
      state = state.copyWith(
        movements: updatedMovements,
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

  /// Approve movement
  Future<bool> approveMovement(String movementId) async {
    _initializeService();

    try {
      final updatedMovement =
          await _movementService.approveMovement(movementId);

      final updatedMovements = state.movements.map((movement) {
        return movement.id == movementId ? updatedMovement : movement;
      }).toList();

      state = state.copyWith(movements: updatedMovements);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reject movement
  Future<bool> rejectMovement(String movementId, String reason) async {
    _initializeService();

    try {
      final updatedMovement = await _movementService.rejectMovement(
        movementId,
        reason,
      );

      final updatedMovements = state.movements.map((movement) {
        return movement.id == movementId ? updatedMovement : movement;
      }).toList();

      state = state.copyWith(movements: updatedMovements);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Filter by type
  Future<void> filterByType(String type) async {
    await fetchMovements(type: type, page: 1);
  }

  /// Filter by status
  Future<void> filterByStatus(String status) async {
    await fetchMovements(status: status, page: 1);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = MovementState();
  }
}

// Movement Provider
final movementProvider =
    StateNotifierProvider<MovementNotifier, MovementState>((ref) {
  return MovementNotifier(ref);
});

// All movements provider
final allMovementsProvider = Provider<List<Movement>>((ref) {
  return ref.watch(movementProvider).movements;
});

// Selected movement provider
final selectedMovementProvider = StateProvider<Movement?>((ref) {
  return null;
});
