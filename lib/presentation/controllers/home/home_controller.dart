import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';

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
    // Set up user listener immediately (synchronously) to catch all changes
    _setupUserListener();
    
    // Set up listener for chat messages to update last message in real-time
    _setupChatMessagesListener();
    
    // Delay other setup slightly to ensure AuthController is fully initialized
    Future.microtask(() {
      try {
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
  void onReady() {
    super.onReady();
    // Refresh all data when controller becomes ready
    // This handles the case where a new user logs in after the controller is initialized
    Future.microtask(() {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        handleUserChange(authController.currentUser.value);
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
          // Only log error if user is still authenticated
          // Permission errors are expected when user logs out
          if (userId != null) {
            if (kDebugMode) {
              print('❌ Error listening to suggestions stream: $error');
            }
            setError('Failed to load suggestions');
            // Set empty list on error
            dailySuggestions.value = [];
            isSuggestionsLoading.value = false;
          } else {
            // User logged out, silently ignore permission errors
            if (kDebugMode) {
              print('ℹ️ Suggestions stream error after logout (expected): $error');
            }
          }
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
    try {
      // Check if AuthController is registered before accessing it
      if (!Get.isRegistered<AuthController>()) {
        if (kDebugMode) {
          print('⚠️ AuthController not registered, setting default userName');
        }
        userName.value = 'there';
        isUserNameLoading.value = false;
        // Try again after a delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isRegistered<AuthController>()) {
            _setupUserListener();
          }
        });
        return;
      }

      final authController = Get.find<AuthController>();
      
        // Listen to currentUser changes reactively
        // This will fire whenever currentUser.value changes
        ever(authController.currentUser, (UserModel? user) {
          handleUserChange(user);
        });
      
      // Immediately check and handle the current user value
      // This ensures we catch the user if they're already logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleUserChange(authController.currentUser.value);
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting up user listener: $e');
      }
      userName.value = 'there';
      isUserNameLoading.value = false;
    }
  }

  /// Handle user change (called by listener and manually)
  /// Made public so MainNavigationController can call it
  void handleUserChange(UserModel? user) {
    try {
      if (user != null && user.name.isNotEmpty) {
        if (kDebugMode) {
          print('👤 User changed in HomeController: ${user.name} (ID: ${user.id})');
        }
        // Set user name IMMEDIATELY (synchronously) - don't wait for async operations
        userName.value = user.name;
        isUserNameLoading.value = false;
        
        // Cancel old suggestions stream first
        _suggestionsSubscription?.cancel();
        _suggestionsSubscription = null;
        dailySuggestions.clear();
        isSuggestionsLoading.value = true; // Show loading while fetching
        
        // Re-setup suggestions stream for the new user FIRST (this is critical)
        _setupSuggestionsListener();
        
        // Then re-initialize all other data (async, but doesn't block UI)
        _initializeData();
      } else {
        // User logged out or name is empty - cancel stream and reset state
        if (kDebugMode) {
          print('👤 User logged out or name empty, resetting HomeController');
        }
        _suggestionsSubscription?.cancel();
        _suggestionsSubscription = null;
        dailySuggestions.clear();
        hasActiveChat.value = false;
        lastMessage.value = null;
        userName.value = 'there';
        isUserNameLoading.value = false;
        isSuggestionsLoading.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling user change: $e');
      }
      userName.value = 'there';
      isUserNameLoading.value = false;
      isSuggestionsLoading.value = false;
    }
  }

  /// Initialize all data
  Future<void> _initializeData() async {
    try {
      // Don't set loading=true here as it blocks the UI
      // Only set loading for specific operations that need it
      
      // Set time-based greeting (synchronous)
      greeting.value = _getTimeBasedGreeting();

      // Note: Daily suggestions are loaded via stream listener
      // No need to load separately as stream will provide initial data

      // Check active chat and get last message (async, but doesn't block)
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
      if (kDebugMode) {
        print('❌ Error initializing data: $e');
      }
      // Don't set error here as it might show error messages unnecessarily
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

  /// Setup listener for chat messages to update last message in real-time
  void _setupChatMessagesListener() {
    try {
      // Wait for ChatController to be registered
      Future.delayed(const Duration(milliseconds: 200), () {
        if (Get.isRegistered<ChatController>()) {
          final chatController = Get.find<ChatController>();
          
          // Listen to messages changes and update last message and active chat status
          ever(chatController.messages, (List<ChatMessageModel> messages) {
            _updateLastMessageFromChat(messages);
          });
          
          // Immediately update with current messages
          if (chatController.messages.isNotEmpty) {
            _updateLastMessageFromChat(chatController.messages);
          }
        } else {
          // Retry if ChatController not ready yet
          Future.delayed(const Duration(milliseconds: 300), () {
            if (Get.isRegistered<ChatController>()) {
              _setupChatMessagesListener();
            }
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting up chat messages listener: $e');
      }
    }
  }

  /// Update last message from ChatController's messages list
  void _updateLastMessageFromChat(List<ChatMessageModel> messages) {
    try {
      if (messages.isNotEmpty) {
        // Get the last message (messages are sorted by timestamp)
        final latestMessage = messages.last;
        lastMessage.value = latestMessage;
        hasActiveChat.value = true;
        
        if (kDebugMode) {
          print('📝 Updated last message in HomeController: ${latestMessage.message.substring(0, latestMessage.message.length > 30 ? 30 : latestMessage.message.length)}...');
        }
      } else {
        lastMessage.value = null;
        hasActiveChat.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating last message from chat: $e');
      }
    }
  }

  /// Get last message (fallback method - called during initialization)
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
      // If there's a starter message, set it in ChatController first
      if (starterMessage != null && starterMessage.isNotEmpty) {
        if (Get.isRegistered<ChatController>()) {
          final chatController = Get.find<ChatController>();
          chatController.setPendingStarterMessage(starterMessage);
        }
      }
      
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
}

