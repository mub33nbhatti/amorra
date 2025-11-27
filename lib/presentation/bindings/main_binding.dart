import 'package:get/get.dart';
import '../controllers/main/main_navigation_controller.dart';

/// Main Navigation Binding
/// Dependency injection for main navigation
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavigationController());
  }
}

