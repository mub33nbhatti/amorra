import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/daily_suggestion_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../../core/config/app_config.dart';
import '../base_controller.dart';
import '../auth/auth_controller.dart';
import '../subscription/subscription_controller.dart';

/// Home Controller
/// Handles home screen logic and state
class HomeController extends BaseController {
  final ChatRepository _chatRepository = ChatRepository();

  // State
  final RxString userName = ''.obs;
  final RxString greeting = ''.obs;
  final RxBool hasActiveChat = false.obs;
  final Rx<ChatMessageModel?> lastMessage = Rx<ChatMessageModel?>(null);

  // Hardcoded daily suggestions
  List<DailySuggestionModel> get dailySuggestions => [
    DailySuggestionModel(
      id: '1',
      title: AppTexts.suggestion1Title,
      description: AppTexts.suggestion1Description,
      starterMessage: AppTexts.suggestion1StarterMessage,
    ),
    DailySuggestionModel(
      id: '2',
      title: AppTexts.suggestion2Title,
      description: AppTexts.suggestion2Description,
      starterMessage: AppTexts.suggestion2StarterMessage,
    ),
    DailySuggestionModel(
      id: '3',
      title: AppTexts.suggestion3Title,
      description: AppTexts.suggestion3Description,
      starterMessage: AppTexts.suggestion3StarterMessage,
    ),
    DailySuggestionModel(
      id: '4',
      title: AppTexts.suggestion4Title,
      description: AppTexts.suggestion4Description,
      starterMessage: AppTexts.suggestion4StarterMessage,
    ),
    DailySuggestionModel(
      id: '5',
      title: AppTexts.suggestion5Title,
      description: AppTexts.suggestion5Description,
      starterMessage: AppTexts.suggestion5StarterMessage,
    ),
  ];

  // User ID getter
  String? get userId {
    try {
      return Get.find<AuthController>().currentUser.value?.id;
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _setupUserListener();
    _initializeData();
  }

  /// Setup listener for user changes
  void _setupUserListener() {
    try {
      final authController = Get.find<AuthController>();
      
      // Listen to currentUser changes reactively
      ever(authController.currentUser, (UserModel? user) {
        if (user != null) {
          userName.value = user.name;
          // Refresh chat data when user is available
          if (userId != null) {
            _checkActiveChat();
          }
        } else {
          userName.value = 'there';
        }
      });
      
      // Set initial user if available
      if (authController.currentUser.value != null) {
        userName.value = authController.currentUser.value!.name;
      } else {
        userName.value = 'there';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up user listener: $e');
      }
      userName.value = 'there';
    }
  }

  /// Initialize all data
  Future<void> _initializeData() async {
    try {
      setLoading(true);

      // Set time-based greeting
      greeting.value = _getTimeBasedGreeting();

      // Check active chat and get last message
      if (userId != null) {
        await _checkActiveChat();
        if (hasActiveChat.value) {
          await _getLastMessage();
        }
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Get time-based greeting
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return AppTexts.homeGreetingMorning;
    } else if (hour >= 12 && hour < 17) {
      return AppTexts.homeGreetingAfternoon;
    } else {
      return AppTexts.homeGreetingEvening;
    }
  }

  /// Check if user has active chat
  Future<void> _checkActiveChat() async {
    if (userId == null) return;

    try {
      hasActiveChat.value = await _chatRepository.hasActiveChat(userId!);
    } catch (e) {
      hasActiveChat.value = false;
      if (kDebugMode) {
        print('Error checking active chat: $e');
      }
    }
  }

  /// Get last message
  Future<void> _getLastMessage() async {
    if (userId == null) return;

    try {
      lastMessage.value = await _chatRepository.getLastMessage(userId!);
    } catch (e) {
      lastMessage.value = null;
      if (kDebugMode) {
        print('Error getting last message: $e');
      }
    }
  }

  /// Get message snippet (truncated)
  String getMessageSnippet(String message) {
    if (message.length <= 50) return message;
    return '${message.substring(0, 50)}...';
  }

  /// Navigate to chat screen
  void navigateToChat({String? starterMessage}) {
    if (starterMessage != null) {
      showInfo(
        'Navigating to Chat',
        subtitle: starterMessage.length > 30 
            ? 'Starting conversation: ${starterMessage.substring(0, 30)}...'
            : 'Starting conversation: $starterMessage',
      );
    } else {
      showInfo(
        'Navigating to Chat',
        subtitle: hasActiveChat.value
            ? 'Opening your conversation...'
            : 'Starting your first conversation...',
      );
    }
    // TODO: Implement actual navigation later
    // Get.toNamed(AppRoutes.chat, arguments: {'starterMessage': starterMessage});
  }

  /// Navigate to subscription screen
  void navigateToSubscription() {
    showInfo(
      'Navigating to Subscription',
      subtitle: 'Opening subscription plans...',
    );
    // TODO: Implement actual navigation later
    // Get.toNamed(AppRoutes.subscription);
  }

  /// Get subscription controller
  SubscriptionController? get _subscriptionController {
    try {
      return Get.find<SubscriptionController>();
    } catch (e) {
      return null;
    }
  }

  /// Check if user is subscribed
  bool get isSubscribed {
    return _subscriptionController?.isSubscribed.value ?? false;
  }

  /// Get remaining free messages
  int get remainingFreeMessages {
    return _subscriptionController?.remainingFreeMessages.value ?? AppConfig.freeMessageLimit;
  }

  /// Get used messages (for progress indicator)
  int get usedMessages {
    return AppConfig.freeDailyLimit - remainingFreeMessages;
  }

  /// Get daily limit
  int get dailyLimit => AppConfig.freeDailyLimit;

  /// Get next billing date (if subscribed)
  DateTime? get nextBillingDate {
    final subscription = _subscriptionController?.subscription.value;
    return subscription?.endDate;
  }

  /// Refresh home screen data
  @override
  Future<void> refresh() async {
    await _initializeData();
  }
}

