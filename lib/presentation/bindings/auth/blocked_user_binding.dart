import 'package:get/get.dart';
import 'package:amorra/presentation/controllers/auth/blocked/blocked_user_controller.dart';
import 'package:amorra/data/repositories/auth_repository.dart';

/// Blocked User Binding
/// Dependency injection for blocked user controller
class BlockedUserBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthRepository is registered
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(AuthRepository(), permanent: true);
    }

    // Register blocked user controller
    Get.lazyPut(() => BlockedUserController());
  }
}

