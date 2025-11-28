import 'package:get/get.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../domain/services/chat_service.dart';
import '../base_controller.dart';
import '../../../core/config/app_config.dart';
import '../auth/auth_controller.dart';

/// Chat Controller
/// Handles chat interface logic and state
class ChatController extends BaseController {
  final ChatService _chatService = ChatService();

  // State
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isTyping = false.obs;
  final RxString inputMessage = ''.obs;

  // User ID (should come from auth)
  String? get userId => Get.find<AuthController>().currentUser.value?.id;

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      loadMessages();
      listenToMessages();
    }
  }

  /// Load messages stream
  void listenToMessages() {
    if (userId == null) return;

    _chatService.getMessagesStream(userId!).listen((newMessages) {
      messages.value = newMessages;
    }, onError: (error) {
      setError('Failed to load messages: ${error.toString()}');
    });
  }

  /// Load initial messages
  Future<void> loadMessages() async {
    if (userId == null) return;

    try {
      setLoading(true);
      final recentMessages = await _chatService.getRecentMessages(
        userId!,
        AppConfig.maxContextMessages * 2,
      );
      messages.value = recentMessages;
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Send message
  Future<void> sendMessage(String message) async {
    if (userId == null) {
      showError('Sign In Required', subtitle: 'Please sign in to start chatting and send messages.');
      return;
    }

    if (message.trim().isEmpty) {
      return;
    }

    try {
      // Clear input
      inputMessage.value = '';

      // Show typing indicator
      isTyping.value = true;

      // Send message and get AI response
      await _chatService.sendMessage(
        userId: userId!,
        message: message,
      );

      // Typing indicator will be handled by stream update
    } catch (e) {
      setError(e.toString());
      showError('Message Failed', subtitle: 'We couldn\'t send your message. Please check your connection and try again.');
    } finally {
      isTyping.value = false;
    }
  }

  /// Update input message
  void updateInputMessage(String value) {
    inputMessage.value = value;
  }
}

