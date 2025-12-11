import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:amorra/data/models/chat_message_model.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/domain/services/chat_service.dart';
import 'package:amorra/presentation/controllers/base_controller.dart';
import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/core/utils/free_trial_utils.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';
import 'package:amorra/data/services/chat_api_service.dart';
import 'package:amorra/presentation/controllers/auth/profile_setup/profile_setup_controller.dart';
import 'package:amorra/presentation/widgets/auth/profile_setup/profile_setup_bottom_sheet.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';

/// Chat Controller
/// Handles chat interface logic and state
class ChatController extends BaseController {
  final ChatService _chatService = ChatService();
  final ChatApiService _chatApiService = ChatApiService();

  // State
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isTyping = false.obs;
  final RxInt remainingMessages = 999.obs; // Default to unlimited (will be updated based on trial/subscription)
  final RxBool isWithinFreeTrial = false.obs;
  final TextEditingController inputController = TextEditingController();

  // Computed
  bool get canSendMessage {
    // If within free trial or subscribed, always allow
    if (isWithinFreeTrial.value) return true;
    return remainingMessages.value > 0;
  }

  // Get current user
  UserModel? get currentUser {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().currentUser.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // User ID (should come from auth)
  String? get userId {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().currentUser.value?.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // User Age (should come from auth)
  int? get userAge {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().currentUser.value?.age;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      loadMessages();
      listenToMessages();
      _checkFreeTrialStatus();
      checkDailyLimit();
    }

    // Listen to user changes to update free trial status
    _setupUserListener();

    // Listen to input changes
    inputController.addListener(() {
      // Update canSendMessage based on input and limit
    });
  }

  /// Setup listener for user changes to update free trial status
  void _setupUserListener() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        ever(authController.currentUser, (UserModel? user) {
          _checkFreeTrialStatus();
          if (userId != null) {
            checkDailyLimit();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up user listener: $e');
      }
    }
  }

  /// Check if user is within free trial period
  void _checkFreeTrialStatus() {
    final user = currentUser;
    if (user != null) {
      isWithinFreeTrial.value = FreeTrialUtils.isWithinFreeTrial(user);
      // If within free trial, set unlimited messages
      if (isWithinFreeTrial.value) {
        remainingMessages.value = 999; // Unlimited indicator
      }
    }
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

    // Check if user can send message
    final user = currentUser;
    final hasUnlimited = user != null && FreeTrialUtils.hasUnlimitedMessages(user);
    
    if (!hasUnlimited && remainingMessages.value <= 0) {
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

      // Update remaining messages (only if not in free trial and not subscribed)
      final user = currentUser;
      final hasUnlimited = user != null && FreeTrialUtils.hasUnlimitedMessages(user);
      if (!hasUnlimited) {
        remainingMessages.value = (remainingMessages.value - 1).clamp(0, 999);
      }

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

    final user = currentUser;
    final hasUnlimited = user != null && FreeTrialUtils.hasUnlimitedMessages(user);
    
    // If user has unlimited (trial or subscribed), don't check limit
    if (hasUnlimited) {
      remainingMessages.value = 999; // Unlimited indicator
      return;
    }

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
      // Default to free tier limit if check fails
      remainingMessages.value = AppConfig.freeMessageLimit;
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

  /// Show profile setup bottom sheet
  void showProfileSetupBottomSheet() {
    // Get or create ProfileSetupController
    ProfileSetupController profileSetupController;
    try {
      profileSetupController = Get.find<ProfileSetupController>();
      // Reload existing preferences
      profileSetupController.loadExistingPreferences();
    } catch (e) {
      // Controller not found, create it
      profileSetupController = Get.put(ProfileSetupController());
    }

    final context = Get.context;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppResponsive.radius(context, factor: 2)),
        ),
      ),
      builder: (context) => const ProfileSetupBottomSheet(),
    );
  }
}

