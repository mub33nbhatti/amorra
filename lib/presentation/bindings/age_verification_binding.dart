import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../controllers/auth/age_verification/age_verification_controller.dart';

/// Age Verification Binding
/// Provides dependencies for Age Verification screen
class AgeVerificationBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthRepository is available
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    }

    // Register AgeVerificationController
    Get.lazyPut<AgeVerificationController>(
      () => AgeVerificationController(),
      fenix: true,
    );
  }
}

