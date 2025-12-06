import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_mobile/domain/providers/movement_provider.dart';
import 'package:wms_mobile/data/local/models/movement_model.dart';
import 'package:intl/intl.dart';

class MovementsScreen extends ConsumerStatefulWidget {
  const MovementsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends ConsumerState<MovementsScreen> {
  String? _selectedType;
  String? _selectedStatus;

  final List<String> _types = [
    'All',
    'INBOUND',
    'OUTBOUND',
    'TRANSFER',
    'ADJUSTMENT',
    'RETURN',
    'DAMAGE',
  ];

  final List<String> _statuses = [
    'All',
    'PENDING',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovements();
    });
  }

  void _loadMovements() {
    ref.read(movementProvider.notifier).fetchMovements();
  }

  void _filterByType(String type) {
    setState(() {
      _selectedType = type == 'All' ? null : type;
    });
    ref.read(movementProvider.notifier).filterByType(_selectedType);
  }

  void _filterByStatus(String status) {
    setState(() {
      _selectedStatus = status == 'All' ? null : status;
    });
    ref.read(movementProvider.notifier).filterByStatus(_selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    final movementState = ref.watch(movementProvider);
    final theme = Theme.of(context);

    return BackButtonListener(
      onBackButtonPressed: () async {
        context.go('/dashboard');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          title: const Text('Stock Movements'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterBottomSheet(context, theme);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Type Filter Chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _types.length,
                  itemBuilder: (context, index) {
                    final type = _types[index];
                    final isSelected =
                        (type == 'All' && _selectedType == null) ||
                            type == _selectedType;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          _filterByType(type);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Movements List
              Expanded(
                child: movementState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : movementState.movements.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No movements found',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(movementProvider.notifier)
                                  .fetchMovements();
                            },
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: movementState.movements.length,
                              itemBuilder: (context, index) {
                                final movement = movementState.movements[index];
                                return _buildMovementCard(movement, theme);
                              },
                            ),
                          ),
              ),

              // Error Message
              if (movementState.error != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    movementState.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/movements/add');
          },
          child: const Icon(Icons.add),
          tooltip: 'Add Movement',
        ),
      ),
    );
  }

  Widget _buildMovementCard(MovementModel movement, ThemeData theme) {
    final typeColor = _getTypeColor(movement.type);
    final statusColor = _getStatusColor(movement.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getTypeIcon(movement.type),
                  color: typeColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movement.typeLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        movement.referenceNo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    movement.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Info
                if (movement.item != null) ...[
                  Row(
                    children: [
                      Icon(Icons.inventory_2,
                          size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movement.item!.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'SKU: ${movement.item!.sku}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Quantity
                Row(
                  children: [
                    Icon(Icons.numbers, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Quantity: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${movement.quantity} ${movement.item?.unitOfMeasure ?? "units"}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Warehouse
                if (movement.warehouse != null) ...[
                  Row(
                    children: [
                      Icon(Icons.warehouse, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        movement.warehouse!.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Bins
                if (movement.fromBin != null || movement.toBin != null) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      if (movement.fromBin != null)
                        Text(
                          'From: ${movement.fromBin}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (movement.fromBin != null && movement.toBin != null)
                        const Text(' → '),
                      if (movement.toBin != null)
                        Text(
                          'To: ${movement.toBin}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Date
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm')
                          .format(movement.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Notes
                if (movement.notes != null && movement.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          movement.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Created By
                if (movement.createdBy != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        movement.createdBy!.fullName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'INBOUND':
        return Colors.green;
      case 'OUTBOUND':
        return Colors.red;
      case 'TRANSFER':
        return Colors.blue;
      case 'ADJUSTMENT':
        return Colors.orange;
      case 'RETURN':
        return Colors.purple;
      case 'DAMAGE':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'INBOUND':
        return Icons.arrow_downward;
      case 'OUTBOUND':
        return Icons.arrow_upward;
      case 'TRANSFER':
        return Icons.swap_horiz;
      case 'ADJUSTMENT':
        return Icons.tune;
      case 'RETURN':
        return Icons.keyboard_return;
      case 'DAMAGE':
        return Icons.broken_image;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'All':
        return 'All';
      case 'INBOUND':
        return 'Stock In';
      case 'OUTBOUND':
        return 'Stock Out';
      case 'TRANSFER':
        return 'Transfer';
      case 'ADJUSTMENT':
        return 'Adjust';
      case 'RETURN':
        return 'Return';
      case 'DAMAGE':
        return 'Damage';
      default:
        return type;
    }
  }

  void _showFilterBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter by Status',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._statuses.map((status) => ListTile(
                  leading: Icon(
                    status == _selectedStatus ||
                            (status == 'All' && _selectedStatus == null)
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(status == 'All' ? 'All Status' : status),
                  onTap: () {
                    _filterByStatus(status);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedStatus = null;
                });
                ref.read(movementProvider.notifier).clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
