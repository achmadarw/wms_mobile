import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_mobile/config/app_config.dart';
import 'package:wms_mobile/config/routes.dart';
import 'package:wms_mobile/config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await AppConfig.initializeHive();

  runApp(
    const ProviderScope(
      child: WMSMobileApp(),
    ),
  );
}

class WMSMobileApp extends ConsumerWidget {
  const WMSMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'WMS Mobile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
