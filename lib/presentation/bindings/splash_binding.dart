import 'package:get/get.dart';
import '../controllers/splash/splash_controller.dart';
import '../../data/repositories/auth_repository.dart';

/// Splash Binding
/// Dependency injection for splash screen
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthRepository is available
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(AuthRepository(), permanent: true);
    }
    
    Get.lazyPut(() => SplashController());
  }
}

