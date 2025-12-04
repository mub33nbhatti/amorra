import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../domain/services/chat_service.dart';
import '../base_controller.dart';
import '../../../core/config/app_config.dart';
import '../auth/auth_controller.dart';
import '../../../data/services/chat_api_service.dart';

/// Chat Controller
/// Handles chat interface logic and state
class ChatController extends BaseController {
  final ChatService _chatService = ChatService();
  final ChatApiService _chatApiService = ChatApiService();

  // State
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isTyping = false.obs;
  final RxInt remainingMessages = 10.obs; // Default to 10 for free tier
  final TextEditingController inputController = TextEditingController();

  // Computed
  bool get canSendMessage {
    return remainingMessages.value > 0;
  }

  // User ID (should come from auth)
  String? get userId => Get.find<AuthController>().currentUser.value?.id;

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      loadMessages();
      listenToMessages();
      checkDailyLimit();
    }
    
    // Listen to input changes
    inputController.addListener(() {
      // Update canSendMessage based on input and limit
    });
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
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
  Future<void> sendMessage() async {
    if (userId == null) {
      showError('Sign In Required', subtitle: 'Please sign in to start chatting and send messages.');
      return;
    }

    final message = inputController.text.trim();
    if (message.isEmpty) {
      return;
    }

    // Check daily limit
    if (remainingMessages.value <= 0) {
      showError(
        'Daily Limit Reached',
        subtitle: 'You\'ve reached your daily message limit. Upgrade to Premium for unlimited messages.',
      );
      return;
    }

    try {
      // Clear input
      inputController.clear();

      // Show typing indicator
      isTyping.value = true;

      // TODO: Replace with actual API call
      // This will call ChatApiService.sendMessageToAI() when API is integrated
      await _sendMessageWithAPI(message);

      // Update remaining messages
      remainingMessages.value = (remainingMessages.value - 1).clamp(0, 999);

      // Typing indicator will be handled by stream update or API response
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      setError(e.toString());
      showError('Message Failed', subtitle: 'We couldn\'t send your message. Please check your connection and try again.');
    } finally {
      // Typing indicator will be cleared when AI response arrives
      // For now, clear after a delay (will be replaced with actual API response)
      Future.delayed(const Duration(seconds: 2), () {
        isTyping.value = false;
      });
    }
  }

  /// Send message using API (placeholder)
  /// TODO: Replace with actual API call
  Future<void> _sendMessageWithAPI(String message) async {
    // For now, use existing chat service
    // This will be replaced with ChatApiService.sendMessageToAI() when API is integrated
    await _chatService.sendMessage(
      userId: userId!,
      message: message,
    );
  }

  /// Check daily message limit
  /// TODO: Replace with actual API call
  Future<void> checkDailyLimit() async {
    if (userId == null) return;

    try {
      // TODO: Replace with actual API call
      // This will call ChatApiService.checkDailyLimit() when API is integrated
      // For now, use mock data or existing Firestore data
      final limit = await _chatApiService.checkDailyLimit(userId!);
      remainingMessages.value = limit;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking daily limit: $e');
      }
      // Default to 10 for free tier if check fails
      remainingMessages.value = 10;
    }
  }

  /// Get AI response (placeholder)
  /// TODO: Replace with actual API call
  Future<String> getAIResponse(String messageId) async {
    // TODO: Replace with actual API call
    // This will call ChatApiService.getAIResponse() when API is integrated
    return _chatApiService.getAIResponse(messageId);
  }

  /// Moderate content (placeholder)
  /// TODO: Replace with actual API call
  Future<bool> moderateContent(String content) async {
    // TODO: Replace with actual API call
    // This will call ChatApiService.moderateContent() when API is integrated
    return _chatApiService.moderateContent(content);
  }
}

