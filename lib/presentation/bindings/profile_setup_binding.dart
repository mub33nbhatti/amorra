import 'package:amorra/presentation/controllers/auth/profile_setup/profile_setup_controller.dart';
import 'package:get/get.dart';

/// Profile Setup Binding
/// Dependency injection for profile setup controller
class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileSetupController());
  }
}

