import 'package:get/get.dart';
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';
import 'package:amorra/data/services/chat_service.dart';
import 'package:amorra/data/repositories/chat_repository.dart';

/// Chat Binding
/// Dependency injection for chat-related controllers
class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // Register repositories
    Get.lazyPut(() => ChatRepository());
    
    // Register services
    Get.lazyPut(() => ChatService());
    
    // Register controllers
    Get.lazyPut(() => ChatController());
  }
}

