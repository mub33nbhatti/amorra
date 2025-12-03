import 'package:get/get.dart';
import '../../presentation/controllers/profile/profile_controller.dart';

/// Profile Binding
/// Provides ProfileController dependency injection
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

