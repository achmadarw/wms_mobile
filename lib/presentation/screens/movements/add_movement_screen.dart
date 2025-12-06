import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_mobile/domain/providers/movement_provider.dart';
import 'package:wms_mobile/domain/providers/inventory_provider.dart';
import 'package:wms_mobile/data/local/models/item_model.dart';

class AddMovementScreen extends ConsumerStatefulWidget {
  const AddMovementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddMovementScreen> createState() => _AddMovementScreenState();
}

class _AddMovementScreenState extends ConsumerState<AddMovementScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'INBOUND';
  String? _selectedItemId;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _fromBinController = TextEditingController();
  final TextEditingController _toBinController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isSubmitting = false;

  final List<Map<String, String>> _movementTypes = [
    {'value': 'INBOUND', 'label': 'Stock In', 'icon': 'arrow_downward'},
    {'value': 'OUTBOUND', 'label': 'Stock Out', 'icon': 'arrow_upward'},
    {'value': 'TRANSFER', 'label': 'Transfer', 'icon': 'swap_horiz'},
    {'value': 'ADJUSTMENT', 'label': 'Adjustment', 'icon': 'tune'},
    {'value': 'RETURN', 'label': 'Return', 'icon': 'keyboard_return'},
    {'value': 'DAMAGE', 'label': 'Damage', 'icon': 'broken_image'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryProvider.notifier).fetchItems();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _fromBinController.dispose();
    _toBinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await ref.read(movementProvider.notifier).createMovement(
            type: _selectedType,
            quantity: int.parse(_quantityController.text),
            itemId: _selectedItemId!,
            fromBin: _fromBinController.text.isEmpty
                ? null
                : _fromBinController.text,
            toBin: _toBinController.text.isEmpty ? null : _toBinController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movement created successfully')),
        );
        context.go('/movements');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create movement')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inventoryState = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/movements'),
        ),
        title: const Text('New Movement'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Movement Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movement Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _movementTypes.map((type) {
                          final isSelected = _selectedType == type['value'];
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getIconData(type['icon']!),
                                  size: 16,
                                  color: isSelected ? Colors.white : null,
                                ),
                                const SizedBox(width: 4),
                                Text(type['label']!),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = type['value']!;
                              });
                            },
                            selectedColor: _getTypeColor(type['value']!),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Item Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Item',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      inventoryState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Item',
                                hintText: 'Select an item',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedItemId,
                              items: inventoryState.items.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item.id,
                                  child: Text('${item.name} (${item.sku})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedItemId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select an item';
                                }
                                return null;
                              },
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quantity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bins (only for TRANSFER)
              if (_selectedType == 'TRANSFER') ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bin Locations',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _fromBinController,
                          decoration: const InputDecoration(
                            labelText: 'From Bin',
                            hintText: 'e.g., A1-01',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (_selectedType == 'TRANSFER' &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter source bin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _toBinController,
                          decoration: const InputDecoration(
                            labelText: 'To Bin',
                            hintText: 'e.g., B2-03',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (_selectedType == 'TRANSFER' &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter destination bin';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Single bin for other types
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _toBinController,
                      decoration: const InputDecoration(
                        labelText: 'Bin Location (Optional)',
                        hintText: 'e.g., A1-01',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any notes here',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: _getTypeColor(_selectedType),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Movement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'arrow_downward':
        return Icons.arrow_downward;
      case 'arrow_upward':
        return Icons.arrow_upward;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'tune':
        return Icons.tune;
      case 'keyboard_return':
        return Icons.keyboard_return;
      case 'broken_image':
        return Icons.broken_image;
      default:
        return Icons.swap_horiz;
    }
  }
}
