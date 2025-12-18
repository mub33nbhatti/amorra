import 'package:amorra/presentation/screens/main/not_found/not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/core/config/routes.dart';
import 'package:amorra/core/theme/app_theme.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';

/// Admin App Material Widget
/// Wraps the GetMaterialApp with admin-only configurations
/// Used for separate admin dashboard deployment
class AppMaterialAdmin extends StatelessWidget {
  const AppMaterialAdmin({super.key});

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
        title: '${AppConfig.appName} Admin',
        debugShowCheckedModeBanner: false,

        // Theme Configuration (Light Theme Only)
        theme: AppTheme.lightTheme,

        // Routing Configuration - Admin routes only
        initialRoute: AppRoutes.adminLogin,
        getPages: AppRoutes.getAdminRoutes(),
        unknownRoute: GetPage(
          name: '/notfound',
          page: () => const NotFoundScreen(),
        ),
      ),
    );
  }
}

