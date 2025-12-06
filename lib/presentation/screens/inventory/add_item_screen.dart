import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/presentation/screens/inventory/barcode_scanner_screen.dart';
import 'package:wms_mobile/domain/providers/inventory_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _reorderQtyController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _supplierController = TextEditingController();

  String _selectedCategory = 'Electronics';
  String _selectedUnitOfMeasure = 'PCS';
  bool _isLoading = false;

  final List<String> _categories = [
    'Electronics',
    'Food',
    'Clothing',
    'Tools',
    'Other'
  ];

  final List<String> _unitOfMeasures = ['PCS', 'BOX', 'KG', 'LTR', 'MTR'];

  @override
  void dispose() {
    _skuController.dispose();
    _barcodeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _unitCostController.dispose();
    _sellingPriceController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _reorderPointController.dispose();
    _reorderQtyController.dispose();
    _manufacturerController.dispose();
    _supplierController.dispose();
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
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      print('[ADD_ITEM_SCREEN] Form validation failed');
      return;
    }

    print('\n=== [ADD_ITEM_SCREEN] Form submitted ===');

    setState(() {
      _isLoading = true;
    });

    try {
      final itemData = {
        'sku': _skuController.text,
        'barcode':
            _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        'name': _nameController.text,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        'category': _selectedCategory,
        'unitOfMeasure': _selectedUnitOfMeasure,
        'unitCost': double.parse(_unitCostController.text),
        'sellingPrice': _sellingPriceController.text.isNotEmpty
            ? double.parse(_sellingPriceController.text)
            : null,
        'weight': _weightController.text.isNotEmpty
            ? double.parse(_weightController.text)
            : null,
        'dimensions': _dimensionsController.text.isNotEmpty
            ? _dimensionsController.text
            : null,
        'minStockLevel': _minStockController.text.isNotEmpty
            ? int.parse(_minStockController.text)
            : 0,
        'maxStockLevel': _maxStockController.text.isNotEmpty
            ? int.parse(_maxStockController.text)
            : null,
        'reorderPoint': _reorderPointController.text.isNotEmpty
            ? int.parse(_reorderPointController.text)
            : 0,
        'reorderQty': _reorderQtyController.text.isNotEmpty
            ? int.parse(_reorderQtyController.text)
            : 0,
        'manufacturer': _manufacturerController.text.isNotEmpty
            ? _manufacturerController.text
            : null,
        'supplier': _supplierController.text.isNotEmpty
            ? _supplierController.text
            : null,
      };

      print('[WMS-UI-ADDITEM] ${DateTime.now()} | Item data prepared:');
      print('[WMS-UI-ADDITEM] ${DateTime.now()} |   SKU: ${itemData['sku']}');
      print('[WMS-UI-ADDITEM] ${DateTime.now()} |   Name: ${itemData['name']}');
      print(
          '[WMS-UI-ADDITEM] ${DateTime.now()} |   Category: ${itemData['category']}');
      print(
          '[WMS-UI-ADDITEM] ${DateTime.now()} |   Barcode: ${itemData['barcode']}');
      print(
          '[WMS-UI-ADDITEM] ${DateTime.now()} |   Unit Cost: ${itemData['unitCost']}');
      print(
          '[WMS-UI-ADDITEM] ${DateTime.now()} | Calling inventoryProvider.createItem()...');

      await ref.read(inventoryProvider.notifier).createItem(itemData);

      print(
          '[WMS-UI-ADDITEM] ${DateTime.now()} | SUCCESS - Item created successfully!');
      if (mounted) {
        print('[WMS-UI-ADDITEM] ${DateTime.now()} | Showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        print(
            '[WMS-UI-ADDITEM] ${DateTime.now()} | Navigating back to Dashboard');
        print('================================================\n');
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('[WMS-UI-ADDITEM] ${DateTime.now()} | ERROR: $e');
      print(
          '[WMS-UI-ADDITEM] ${DateTime.now()} | Error type: ${e.runtimeType}');
      print('================================================\n');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create item: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Section
            Text(
              'Basic Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // SKU
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU *',
                hintText: 'e.g., ITEM-001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'SKU is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Barcode',
                hintText: 'Scan or enter barcode',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.barcode_reader),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Item Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'Enter item name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Item name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter item description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Physical Properties Section
            Text(
              'Physical Properties',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Unit of Measure
            DropdownButtonFormField<String>(
              value: _selectedUnitOfMeasure,
              decoration: const InputDecoration(
                labelText: 'Unit of Measure *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.straighten),
              ),
              items: _unitOfMeasures.map((uom) {
                return DropdownMenuItem(
                  value: uom,
                  child: Text(uom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnitOfMeasure = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Weight
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'Enter weight',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Dimensions
            TextFormField(
              controller: _dimensionsController,
              decoration: const InputDecoration(
                labelText: 'Dimensions',
                hintText: 'e.g., 10x20x30 cm',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.square_foot),
              ),
            ),
            const SizedBox(height: 24),

            // Pricing Section
            Text(
              'Pricing',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Unit Cost
            TextFormField(
              controller: _unitCostController,
              decoration: const InputDecoration(
                labelText: 'Unit Cost *',
                hintText: 'Enter cost price',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unit cost is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Selling Price
            TextFormField(
              controller: _sellingPriceController,
              decoration: const InputDecoration(
                labelText: 'Selling Price',
                hintText: 'Enter selling price',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sell),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Stock Control Section
            Text(
              'Stock Control',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Min Stock Level
            TextFormField(
              controller: _minStockController,
              decoration: const InputDecoration(
                labelText: 'Minimum Stock Level',
                hintText: 'Enter minimum stock',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_down),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Max Stock Level
            TextFormField(
              controller: _maxStockController,
              decoration: const InputDecoration(
                labelText: 'Maximum Stock Level',
                hintText: 'Enter maximum stock',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_up),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Reorder Point
            TextFormField(
              controller: _reorderPointController,
              decoration: const InputDecoration(
                labelText: 'Reorder Point',
                hintText: 'Enter reorder point',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notification_important),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Reorder Quantity
            TextFormField(
              controller: _reorderQtyController,
              decoration: const InputDecoration(
                labelText: 'Reorder Quantity',
                hintText: 'Enter reorder quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Supplier Information Section
            Text(
              'Supplier Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Manufacturer
            TextFormField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                labelText: 'Manufacturer',
                hintText: 'Enter manufacturer name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.factory),
              ),
            ),
            const SizedBox(height: 16),

            // Supplier
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier',
                hintText: 'Enter supplier name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_shipping),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Create Item',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
