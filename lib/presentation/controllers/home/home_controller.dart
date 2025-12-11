import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:amorra/data/models/chat_message_model.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/data/models/daily_suggestion_model.dart';
import 'package:amorra/data/repositories/chat_repository.dart';
import 'package:amorra/data/repositories/suggestions_repository.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/core/config/routes.dart';
import 'package:amorra/presentation/controllers/base_controller.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';
import 'package:amorra/presentation/controllers/main/main_navigation_controller.dart';

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
  
  // Loading states for individual sections
  final RxBool isUserNameLoading = true.obs;
  final RxBool isSuggestionsLoading = true.obs;

  // Stream subscription for suggestions
  StreamSubscription<List<DailySuggestionModel>>? _suggestionsSubscription;

  // User ID getter
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

  @override
  void onInit() {
    super.onInit();
    // Delay setup slightly to ensure AuthController is fully initialized
    // This prevents race conditions when navigating after logout/login
    Future.microtask(() {
      try {
        _setupUserListener();
        _setupSuggestionsListener();
        _initializeData();
      } catch (e) {
        if (kDebugMode) {
          print('Error in HomeController delayed init: $e');
        }
      }
    });
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
          isSuggestionsLoading.value = false;
        },
        onError: (error) {
          if (kDebugMode) {
            print('❌ Error listening to suggestions stream: $error');
          }
          setError('Failed to load suggestions');
          // Set empty list on error
          dailySuggestions.value = [];
          isSuggestionsLoading.value = false;
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
      isSuggestionsLoading.value = false;
    }
  }

  /// Setup listener for user changes
  void _setupUserListener() {
    // Use a delayed approach to ensure AuthController is ready
    Future.microtask(() {
      try {
        // Check if AuthController is registered before accessing it
        if (!Get.isRegistered<AuthController>()) {
          if (kDebugMode) {
            print('⚠️ AuthController not registered, setting default userName');
          }
          userName.value = 'there';
          isUserNameLoading.value = false;
          return;
        }

        final authController = Get.find<AuthController>();
        
        // Listen to currentUser changes reactively
        ever(authController.currentUser, (UserModel? user) {
          // Check if controller still exists before accessing
          if (!Get.isRegistered<AuthController>()) {
            return;
          }
          
          try {
            if (user != null) {
              userName.value = user.name;
              isUserNameLoading.value = false;
              // Refresh chat data when user is available
              if (userId != null) {
                _checkActiveChat();
              }
            } else {
              userName.value = 'there';
              isUserNameLoading.value = false;
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error in user listener callback: $e');
            }
            userName.value = 'there';
            isUserNameLoading.value = false;
          }
        });
        
        // Set initial user if available
        try {
          if (authController.currentUser.value != null) {
            userName.value = authController.currentUser.value!.name;
            isUserNameLoading.value = false;
          } else {
            userName.value = 'there';
            isUserNameLoading.value = false;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting initial user: $e');
          }
          userName.value = 'there';
          isUserNameLoading.value = false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error setting up user listener: $e');
        }
        userName.value = 'there';
        isUserNameLoading.value = false;
      }
    });
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
      if (Get.isRegistered<AuthController>()) {
        final currentUserId = userId;
        if (currentUserId != null) {
          await _checkActiveChat();
          if (hasActiveChat.value) {
            await _getLastMessage();
          }
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
    try {
      if (!Get.isRegistered<AuthController>()) {
        return;
      }
      
      final currentUserId = userId;
      if (currentUserId == null) return;

      hasActiveChat.value = await _chatRepository.hasActiveChat(currentUserId);
    } catch (e) {
      hasActiveChat.value = false;
      if (kDebugMode) {
        print('Error checking active chat: $e');
      }
    }
  }

  /// Get last message
  Future<void> _getLastMessage() async {
    try {
      if (!Get.isRegistered<AuthController>()) {
        return;
      }
      
      final currentUserId = userId;
      if (currentUserId == null) return;

      lastMessage.value = await _chatRepository.getLastMessage(currentUserId);
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
    try {
      // Get MainNavigationController and change to chat tab (index 1)
      final mainNavController = Get.find<MainNavigationController>();
      mainNavController.changeTab(1); // Chat tab index
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to chat: $e');
      }
      // Fallback: try to navigate using route
      Get.toNamed(AppRoutes.chat, arguments: {'starterMessage': starterMessage});
    }
  }

  /// Refresh home screen data
  @override
  Future<void> refresh() async {
    await _initializeData();
  }
}

