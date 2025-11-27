import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../screens/core/not_found_screen.dart';

/// App Material Widget
/// Wraps the GetMaterialApp with all configurations
class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // Theme Configuration (Light Theme Only)
      theme: AppTheme.lightTheme,

      // Routing Configuration
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.getRoutes(),
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const NotFoundScreen(),
      ),
    );
  }
}

