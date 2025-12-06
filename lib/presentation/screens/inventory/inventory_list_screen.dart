import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/presentation/screens/inventory/barcode_scanner_screen.dart';
import 'package:wms_mobile/presentation/screens/inventory/stock_adjust_screen.dart';
import 'package:wms_mobile/presentation/screens/inventory/add_item_screen.dart';
import 'package:wms_mobile/domain/providers/inventory_provider.dart';

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  final _searchController = TextEditingController();
  bool _showLowStockOnly = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load inventory after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryProvider.notifier).fetchItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _searchController.text = result;
      });
      // Trigger search
      _performSearch(result);
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      ref
          .read(inventoryProvider.notifier)
          .fetchItems(category: _selectedCategory);
    } else {
      ref.read(inventoryProvider.notifier).searchItems(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Inventory'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by SKU, name, or barcode',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _performSearch,
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Low Stock'),
                    selected: _showLowStockOnly,
                    onSelected: (selected) {
                      setState(() {
                        _showLowStockOnly = selected;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = null;
                      });
                      ref.read(inventoryProvider.notifier).fetchItems();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Electronics'),
                    selected: _selectedCategory == 'Electronics',
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = 'Electronics';
                      });
                      ref
                          .read(inventoryProvider.notifier)
                          .fetchItems(category: 'Electronics');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Food'),
                    selected: _selectedCategory == 'Food',
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = 'Food';
                      });
                      ref
                          .read(inventoryProvider.notifier)
                          .fetchItems(category: 'Food');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Clothing'),
                    selected: _selectedCategory == 'Clothing',
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = 'Clothing';
                      });
                      ref
                          .read(inventoryProvider.notifier)
                          .fetchItems(category: 'Clothing');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Tools'),
                    selected: _selectedCategory == 'Tools',
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = 'Tools';
                      });
                      ref
                          .read(inventoryProvider.notifier)
                          .fetchItems(category: 'Tools');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Item List
            Expanded(
              child: _buildItemList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddItemScreen(),
              ),
            );
            if (result == true && mounted) {
              // Refresh inventory list after adding new item
              ref.read(inventoryProvider.notifier).fetchItems();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ),
    );
  }

  Widget _buildItemList() {
    final inventoryState = ref.watch(inventoryProvider);

    if (inventoryState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (inventoryState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: ${inventoryState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(inventoryProvider.notifier).fetchItems(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final items = inventoryState.items;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(inventoryProvider.notifier)
            .fetchItems(category: _selectedCategory);
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final stock = item.totalStock ?? 0;
          final reorderPoint = item.reorderPoint ?? 20;
          final isLowStock = stock <= reorderPoint;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isLowStock ? Colors.red : Colors.green,
                child: Text(
                  stock.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SKU: ${item.sku}'),
                  if (item.barcode != null) Text('Barcode: ${item.barcode}'),
                  Text(
                    'Category: ${item.category}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.unitCost.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (isLowStock)
                    const Text(
                      'Low Stock',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
              onTap: () async {
                // Navigate to stock adjust screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockAdjustScreen(
                      itemId: item.id,
                      barcode: item.barcode,
                    ),
                  ),
                );
                if (result == true && mounted) {
                  // Refresh list after adjustment
                  ref.read(inventoryProvider.notifier).fetchItems();
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Low Stock Only'),
              value: _showLowStockOnly,
              onChanged: (value) {
                setState(() {
                  _showLowStockOnly = value ?? false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
