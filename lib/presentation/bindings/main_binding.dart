import 'package:get/get.dart';
import '../controllers/main/main_navigation_controller.dart';
import '../controllers/home/home_controller.dart';
import '../controllers/auth/auth_controller.dart';
import '../controllers/subscription/subscription_controller.dart';

/// Main Navigation Binding
/// Dependency injection for main navigation
class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthController is available (might already exist from AuthBinding)
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut(() => AuthController());
    }
    // Ensure SubscriptionController is available
    if (!Get.isRegistered<SubscriptionController>()) {
      Get.lazyPut(() => SubscriptionController());
    }
    Get.lazyPut(() => MainNavigationController());
    Get.lazyPut(() => HomeController());
  }
}

