import 'package:get/get.dart';
import 'package:amorra/presentation/controllers/base_controller.dart';
import 'package:amorra/core/config/routes.dart';
import 'package:amorra/data/repositories/auth_repository.dart';

/// Blocked User Controller
/// Handles blocked user screen logic
class BlockedUserController extends BaseController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final RxBool isSigningOut = false.obs;

  /// Sign out the blocked user
  Future<void> signOut() async {
    try {
      isSigningOut.value = true;
      await _authRepository.signOut();
      // Navigate to sign in screen
      Get.offAllNamed(AppRoutes.signin);
    } catch (e) {
      showError(
        'Sign Out Failed',
        subtitle: 'Unable to sign out. Please try again.',
      );
    } finally {
      isSigningOut.value = false;
    }
  }
}

