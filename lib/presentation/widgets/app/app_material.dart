import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../screens/core/not_found_screen.dart';

/// App Material Widget
/// Wraps the GetMaterialApp with all configurations
class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark, // Dark icons for white background
        statusBarBrightness: Brightness.light, // For iOS
      ),
      child: GetMaterialApp(
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
      ),
    );
  }
}

