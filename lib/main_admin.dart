import 'package:flutter/material.dart';
import 'core/config/app_initializer.dart';
import 'presentation/widgets/app/app_material_admin.dart';

/// Admin Dashboard Entry Point
/// Separate entry point for admin dashboard web app deployment
/// 
/// Usage:
/// - For web: flutter run -d chrome --target=lib/main_admin.dart
/// - For build: flutter build web --target=lib/main_admin.dart
void main() async {
  await AppInitializer.initialize();

  runApp(const AmorraAdminApp());
}

class AmorraAdminApp extends StatelessWidget {
  const AmorraAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppMaterialAdmin();
  }
}

