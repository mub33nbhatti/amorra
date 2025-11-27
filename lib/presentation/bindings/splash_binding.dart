import 'package:get/get.dart';
import '../controllers/splash/splash_controller.dart';

/// Splash Binding
/// Dependency injection for splash screen
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}

