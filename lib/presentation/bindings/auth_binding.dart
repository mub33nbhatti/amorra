import 'package:get/get.dart';
import '../controllers/auth/auth_controller.dart';
import '../controllers/auth/signin_controller.dart';
import '../controllers/auth/signup_controller.dart';
import '../../domain/services/chat_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/chat_repository.dart';

/// Auth Binding
/// Dependency injection for auth-related controllers
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthRepository as singleton with fenix
    // This ensures the same instance is reused across signin/signup
    // and the pending Google credential persists
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(AuthRepository(), permanent: true);
    }

    // Register other repositories/services
    Get.lazyPut(() => ChatRepository(), fenix: true);
    Get.lazyPut(() => ChatService(), fenix: true);

    // Register controllers - NO fenix for controllers
    // This allows proper disposal and cleanup
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => SigninController());
    Get.lazyPut(() => SignupController());
  }
}