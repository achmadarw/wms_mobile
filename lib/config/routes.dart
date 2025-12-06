import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:wms_mobile/presentation/screens/auth/login_screen.dart';
import 'package:wms_mobile/presentation/screens/auth/register_screen.dart';
import 'package:wms_mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:wms_mobile/presentation/screens/inventory/inventory_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String scanBarcode = '/scan-barcode';
  static const String movements = '/movements';
  static const String warehouses = '/warehouses';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      // Auth Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Routes
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: inventory,
        name: 'inventory',
        builder: (context, state) => const InventoryScreen(),
      ),

      // Additional Routes
      GoRoute(
        path: movements,
        name: 'movements',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Movements Screen')),
        ),
      ),
      GoRoute(
        path: warehouses,
        name: 'warehouses',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Warehouses Screen')),
        ),
      ),
    ],

    // Error handler
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
