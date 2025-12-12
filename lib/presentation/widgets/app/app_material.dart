import 'package:amorra/presentation/screens/main/not_found/not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/core/config/routes.dart';
import 'package:amorra/core/theme/app_theme.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';

/// App Material Widget
/// Wraps the GetMaterialApp with all configurations
class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        // Dark icons for white background
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
