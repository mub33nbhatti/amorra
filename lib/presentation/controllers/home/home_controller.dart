import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/daily_suggestion_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/suggestions_repository.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../base_controller.dart';
import '../auth/auth_controller.dart';

/// Home Controller
/// Handles home screen logic and state
class HomeController extends BaseController {
  final ChatRepository _chatRepository = ChatRepository();
  final SuggestionsRepository _suggestionsRepository = SuggestionsRepository();

  // State
  final RxString userName = ''.obs;
  final RxString greeting = ''.obs;
  final RxBool hasActiveChat = false.obs;
  final Rx<ChatMessageModel?> lastMessage = Rx<ChatMessageModel?>(null);
  final RxList<DailySuggestionModel> dailySuggestions = <DailySuggestionModel>[].obs;

  // Stream subscription for suggestions
  StreamSubscription<List<DailySuggestionModel>>? _suggestionsSubscription;

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
    _setupSuggestionsListener();
    _initializeData();
  }

  @override
  void onClose() {
    // Cancel stream subscription
    _suggestionsSubscription?.cancel();
    super.onClose();
  }

  /// Setup listener for daily suggestions from Firebase
  void _setupSuggestionsListener() {
    try {
      // Cancel existing subscription if any
      _suggestionsSubscription?.cancel();

      // Create new subscription
      _suggestionsSubscription = _suggestionsRepository
          .getActiveSuggestionsStream()
          .listen(
        (suggestions) {
          if (kDebugMode) {
            print('✅ Daily suggestions stream update: ${suggestions.length} items');
          }
          dailySuggestions.value = suggestions;
        },
        onError: (error) {
          if (kDebugMode) {
            print('❌ Error listening to suggestions stream: $error');
          }
          setError('Failed to load suggestions');
          // Set empty list on error
          dailySuggestions.value = [];
        },
        cancelOnError: false, // Keep listening even on error
      );

      if (kDebugMode) {
        print('✅ Suggestions stream listener set up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting up suggestions listener: $e');
      }
      dailySuggestions.value = [];
    }
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

      // Note: Daily suggestions are loaded via stream listener
      // No need to load separately as stream will provide initial data

      // Check active chat and get last message
      if (userId != null) {
        await _checkActiveChat();
        if (hasActiveChat.value) {
          await _getLastMessage();
        }
      }
    } catch (e) {
      setError(e.toString());
      if (kDebugMode) {
        print('❌ Error initializing data: $e');
      }
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

  /// Refresh home screen data
  @override
  Future<void> refresh() async {
    await _initializeData();
  }
}

