import 'package:amorra/presentation/controllers/auth/auth_main/signup_controller.dart';
import 'package:get/get.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';
import 'package:amorra/presentation/controllers/auth/auth_main/signin_controller.dart';
import 'package:amorra/data/services/chat_service.dart';
import 'package:amorra/data/repositories/auth_repository.dart';
import 'package:amorra/data/repositories/chat_repository.dart';

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