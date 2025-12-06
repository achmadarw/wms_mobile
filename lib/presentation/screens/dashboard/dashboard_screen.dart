import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_mobile/domain/providers/auth_provider.dart';
import 'package:wms_mobile/domain/providers/inventory_provider.dart';
import 'package:wms_mobile/domain/providers/warehouse_provider.dart';
import 'package:wms_mobile/data/local/models/user_model.dart';
import 'package:wms_mobile/presentation/screens/inventory/add_item_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    // Load initial data
    ref.read(inventoryProvider.notifier).fetchItems();
    ref.read(warehouseProvider.notifier).fetchWarehouses();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final inventoryState = ref.watch(inventoryProvider);
    final warehouseState = ref.watch(warehouseProvider);
    final theme = Theme.of(context);

    return BackButtonListener(
      onBackButtonPressed: () async {
        print('[WMS-UI-DASHBOARD] ${DateTime.now()} | Back button pressed');
        // Dashboard adalah halaman utama, konfirmasi untuk keluar aplikasi
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
          return true;
        }
        return true; // Return true to prevent default behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                _showProfileMenu(context);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.read(inventoryProvider.notifier).fetchItems(),
                ref.read(warehouseProvider.notifier).fetchWarehouses(),
              ]);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting Card
                  _buildGreetingCard(user, theme),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(inventoryState, warehouseState, theme),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context, theme),
                  const SizedBox(height: 24),

                  // Recent Items
                  _buildRecentItems(inventoryState, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(UserModel? user, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.fullName ?? 'User',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user?.role ?? 'User',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    InventoryState inventoryState,
    WarehouseState warehouseState,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard(
              icon: Icons.inventory_2,
              title: 'Total Items',
              value: '${inventoryState.items.length}',
              color: Colors.blue,
              theme: theme,
            ),
            _buildStatCard(
              icon: Icons.warehouse,
              title: 'Warehouses',
              value: '${warehouseState.warehouses.length}',
              color: Colors.green,
              theme: theme,
            ),
            _buildStatCard(
              icon: Icons.layers,
              title: 'Total Bins',
              value: '${warehouseState.bins.length}',
              color: Colors.orange,
              theme: theme,
            ),
            _buildStatCard(
              icon: Icons.trending_up,
              title: 'Stock Value',
              value: '\$0.00',
              color: Colors.purple,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildActionButton(
              icon: Icons.add_circle_outline,
              title: 'New Item',
              color: Colors.blue,
              onTap: () async {
                print('\n================================================');
                print(
                    '[WMS-UI-DASHBOARD] ${DateTime.now()} | New Item button tapped');
                print(
                    '[WMS-UI-DASHBOARD] ${DateTime.now()} | Navigating to AddItemScreen');

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddItemScreen()),
                );

                print(
                    '[WMS-UI-DASHBOARD] ${DateTime.now()} | Returned with result: $result');

                if (result == true && mounted) {
                  print(
                      '[WMS-UI-DASHBOARD] ${DateTime.now()} | Refreshing inventory list');
                  ref.read(inventoryProvider.notifier).fetchItems();
                  print(
                      '[WMS-UI-DASHBOARD] ${DateTime.now()} | SUCCESS - Inventory list refreshed');
                }
                print('================================================\n');
              },
            ),
            _buildActionButton(
              icon: Icons.exit_to_app,
              title: 'Outbound',
              color: Colors.green,
              onTap: () => context.go('/movements'),
            ),
            _buildActionButton(
              icon: Icons.input,
              title: 'Inbound',
              color: Colors.orange,
              onTap: () => context.go('/movements'),
            ),
            _buildActionButton(
              icon: Icons.qr_code_2,
              title: 'Scan Item',
              color: Colors.purple,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItems(InventoryState inventoryState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Items',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/inventory'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (inventoryState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (inventoryState.items.isEmpty)
          Center(
            child: Text(
              'No items found',
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inventoryState.items.length > 3
                ? 3
                : inventoryState.items.length,
            itemBuilder: (context, index) {
              final item = inventoryState.items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'SKU: ${item.sku}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.active ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: item.active ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
