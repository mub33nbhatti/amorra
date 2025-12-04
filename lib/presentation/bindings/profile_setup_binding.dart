import 'package:get/get.dart';
import '../controllers/profile_setup/profile_setup_controller.dart';

/// Profile Setup Binding
/// Dependency injection for profile setup controller
class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileSetupController());
  }
}

