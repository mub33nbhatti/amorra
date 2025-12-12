import 'dart:async';
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
  final Rx<DateTime> visibleDate = DateTime.now().obs; // Date of message currently visible at top

  // Stream subscription for messages
  StreamSubscription<List<ChatMessageModel>>? _messagesSubscription;
  
  // Pending starter message to send when chat screen becomes active
  String? _pendingStarterMessage;

  // Scroll controller for messages list (managed by controller for better control)
  final ScrollController scrollController = ScrollController();

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
    
    // Initialize scroll controller listener
    _setupScrollController();
    
    // Initialize if user is already available
    if (userId != null) {
      _initializeChat();
    }

    // Listen to user changes to update free trial status and load messages
    _setupUserListener();

    // Listen to input changes
    inputController.addListener(() {
      // Update canSendMessage based on input and limit
    });
  }

  /// Setup scroll controller listener for visible date updates
  void _setupScrollController() {
    scrollController.addListener(() {
      // Update visible date when scrolling
      // Note: We use the basic update since we don't have context here
      // The context-aware update will be called from the widget when needed
      _updateVisibleDate();
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Check if there's a pending starter message to send
    if (_pendingStarterMessage != null && _pendingStarterMessage!.isNotEmpty) {
      final message = _pendingStarterMessage!;
      _pendingStarterMessage = null; // Clear it first to prevent duplicate sends
      
      // Send the starter message after a short delay to ensure screen is ready
      Future.delayed(const Duration(milliseconds: 300), () {
        if (userId != null && message.isNotEmpty) {
          sendStarterMessage(message);
        }
      });
    }
  }

  /// Initialize chat when user is available
  void _initializeChat() {
    if (userId != null) {
      loadMessages();
      listenToMessages();
      _checkFreeTrialStatus();
      checkDailyLimit();
    }
  }

  /// Setup listener for user changes to update free trial status and load messages
  void _setupUserListener() {
    try {
      if (!Get.isRegistered<AuthController>()) {
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
    }
  }

  /// Handle user change (called by listener and manually)
  /// Made public so MainNavigationController can call it
  void handleUserChange(UserModel? user) {
    if (kDebugMode) {
      print('👤 User changed in ChatController: ${user?.name ?? 'null'} (ID: ${user?.id ?? 'null'})');
    }
    
    _checkFreeTrialStatus();
    if (userId != null && user != null) {
      // New user logged in - re-initialize everything
      if (kDebugMode) {
        print('🔄 Re-initializing chat for new user: ${user.name}');
      }
      // Cancel existing stream first
      _cancelMessagesStream();
      // Clear old messages
      messages.clear();
      // Initialize chat for the new user
      _initializeChat();
      checkDailyLimit();
    } else {
      // Clear messages and cancel stream if user logs out
      if (kDebugMode) {
        print('🛑 User logged out, clearing chat data');
      }
      _cancelMessagesStream();
      messages.clear();
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
    _cancelMessagesStream();
    scrollController.dispose();
    inputController.dispose();
    super.onClose();
  }

  /// Cancel messages stream subscription
  void _cancelMessagesStream() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    if (kDebugMode) {
      print('🛑 Cancelled messages stream subscription');
    }
  }

  /// Load messages stream
  /// Note: This listens to Firestore for real-time updates
  /// Since we're using API that saves to Firestore, this will sync messages
  void listenToMessages() {
    if (userId == null) {
      if (kDebugMode) {
        print('⚠️ Cannot listen to messages: userId is null');
      }
      return;
    }

    // Cancel existing subscription if any
    _cancelMessagesStream();

    if (kDebugMode) {
      print('👂 Starting Firestore stream listener for userId: $userId');
    }

    _messagesSubscription = _chatService.getMessagesStream(userId!).listen((newMessages) {
      // Merge Firestore messages with local temp messages
      // Replace local temp messages with Firestore versions to prevent duplicates
      if (kDebugMode) {
        print('📡 Firestore stream update: ${newMessages.length} messages');
      }
      
      // Get Firestore message IDs
      final firestoreIds = newMessages.map((m) => m.id).toSet();
      
      // Find local temp messages (messages not in Firestore yet)
      // Temp messages are recent (within last 10 seconds) and not in Firestore
      final now = DateTime.now();
      final localTempMessages = messages.where((localMsg) {
        final isRecent = now.difference(localMsg.timestamp).inSeconds < 10;
        final notInFirestore = !firestoreIds.contains(localMsg.id);
        return isRecent && notInFirestore;
      }).toList();
      
      // Start with Firestore messages (source of truth)
      final mergedMessages = List<ChatMessageModel>.from(newMessages);
      
      // Add local temp messages that aren't in Firestore yet
      // These will be replaced when Firestore updates
      for (var tempMsg in localTempMessages) {
        // Check if Firestore has a message with same content (might have different ID)
        final hasMatchingContent = newMessages.any((fsMsg) => 
          fsMsg.message == tempMsg.message && 
          fsMsg.type == tempMsg.type &&
          (fsMsg.timestamp.difference(tempMsg.timestamp).inSeconds.abs() < 5)
        );
        
        if (!hasMatchingContent) {
          // No matching content in Firestore yet, keep temp message
          mergedMessages.add(tempMsg);
        }
      }
      
      // Sort by timestamp
      mergedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      if (kDebugMode) {
        print('  - Merged: ${mergedMessages.length} messages (${newMessages.length} from Firestore, ${localTempMessages.length} temp)');
      }
      
      // Update messages list
      messages.value = mergedMessages;
      
      // Update visible date if we have messages
      if (mergedMessages.isNotEmpty) {
        final lastMessage = mergedMessages.last;
        visibleDate.value = DateTime(
          lastMessage.timestamp.year,
          lastMessage.timestamp.month,
          lastMessage.timestamp.day,
        );
      }
    }, onError: (error) {
      // Only log error if user is still authenticated
      // Permission errors are expected when user logs out
      if (userId != null) {
        if (kDebugMode) {
          print('❌ Firestore stream error: $error');
          print('Stack trace: ${StackTrace.current}');
        }
        setError('Failed to load messages: ${error.toString()}');
      } else {
        // User logged out, silently ignore permission errors
        if (kDebugMode) {
          print('ℹ️ Stream error after logout (expected): $error');
        }
      }
    }, cancelOnError: false);
  }

  /// Load initial messages
  Future<void> loadMessages() async {
    if (userId == null) {
      if (kDebugMode) {
        print('⚠️ Cannot load messages: userId is null');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('📥 Loading messages for userId: $userId');
      }
      setLoading(true);
      final recentMessages = await _chatService.getRecentMessages(
        userId!,
        AppConfig.maxContextMessages * 2,
      );
      
      if (kDebugMode) {
        print('✅ Loaded ${recentMessages.length} messages from Firestore');
      }
      
      messages.value = recentMessages;
      
      // Initialize visible date with the most recent message or current date
      if (recentMessages.isNotEmpty) {
        final lastMessage = recentMessages.last;
        visibleDate.value = DateTime(
          lastMessage.timestamp.year,
          lastMessage.timestamp.month,
          lastMessage.timestamp.day,
        );
        
        if (kDebugMode) {
          print('✅ Loaded ${recentMessages.length} messages. Last message: ${lastMessage.type}');
        }
      } else {
        visibleDate.value = DateTime.now();
        if (kDebugMode) {
          print('ℹ️ No messages found for userId: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading messages: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Send a starter message (called from HomeController when navigating from suggestions)
  /// This method sets the message in input field and sends it automatically
  Future<void> sendStarterMessage(String message) async {
    if (kDebugMode) {
      print('📝 Sending starter message: $message');
    }
    
    // Set the message in the input field
    inputController.text = message;
    
    // Send the message
    await sendMessage();
  }

  /// Set pending starter message (called when navigating to chat)
  /// The message will be sent when chat screen becomes ready
  void setPendingStarterMessage(String? message) {
    if (message == null || message.isEmpty) {
      _pendingStarterMessage = null;
      return;
    }
    
    _pendingStarterMessage = message;
    if (kDebugMode) {
      print('📝 Pending starter message set: $message');
    }
    
    // If user is available and controller is ready, send immediately
    // Otherwise, onReady will handle it
    if (userId != null) {
      // Wait a bit for navigation to complete, then send
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_pendingStarterMessage == message && userId != null) {
          final messageToSend = _pendingStarterMessage!;
          _pendingStarterMessage = null; // Clear it first
          sendStarterMessage(messageToSend);
        }
      });
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

    // Store message text before clearing input
    final messageText = message;

    try {
      // Clear input immediately for better UX
      inputController.clear();

      // Add user message to UI immediately for instant feedback
      final userMessageTimestamp = DateTime.now();
      final tempUserMessageId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final userMessage = ChatMessageModel(
        id: tempUserMessageId,
        userId: userId!,
        message: messageText,
        type: 'user', // Use string directly instead of AppConstants
        timestamp: userMessageTimestamp,
      );
      
      // Add user message to the list immediately
      final updatedMessages = List<ChatMessageModel>.from(messages);
      updatedMessages.add(userMessage);
      messages.value = updatedMessages;

      // Show typing indicator
      isTyping.value = true;

      // Send message via API and get AI response
      await _sendMessageWithAPI(messageText);

      // Update remaining messages (only if not in free trial and not subscribed)
      final user = currentUser;
      final hasUnlimited = user != null && FreeTrialUtils.hasUnlimitedMessages(user);
      if (!hasUnlimited) {
        remainingMessages.value = (remainingMessages.value - 1).clamp(0, 999);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      setError(e.toString());
      
      // Restore message in input field on error
      inputController.text = messageText;
      
      // Show user-friendly error message
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      showError(
        'Message Failed', 
        subtitle: errorMessage.isNotEmpty 
            ? errorMessage 
            : 'We couldn\'t send your message. Please check your connection and try again.',
      );
    } finally {
      // Hide typing indicator
        isTyping.value = false;
    }
  }

  /// Send message using API and update UI directly from response
  Future<void> _sendMessageWithAPI(String message) async {
    if (userId == null) return;

    // Call backend API
    final response = await _chatApiService.sendMessageToAI(
      userId: userId!,
      message: message,
      chatSessionId: 'session_001', // Hardcoded for testing
    );

    // Check if API call was successful
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to get response from server');
    }

    // Extract response data
    // The API returns data in multiple possible formats:
    // 1. Direct message field: {success: true, message: "...", ...}
    // 2. Data message field: {success: true, data: {message: "...", ...}}
    // 3. History array: {success: true, data: {history: [{content: "...", role: "assistant"}, ...]}}
    String aiResponseText = '';
    
    if (kDebugMode) {
      print('🔍 Parsing API response...');
      print('  - response[\'data\']: ${response['data']}');
      print('  - response[\'data\'][\'message\']: ${response['data']?['message']}');
      print('  - response[\'message\']: ${response['message']}');
    }
    
    // Try data.message field first (most common for first message)
    if (response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null && data['message'] != null) {
        aiResponseText = data['message'].toString();
        if (kDebugMode) {
          print('✅ Found message in response[\'data\'][\'message\']: ${aiResponseText.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length)}...');
        }
      }
    }
    
    // If still empty, try direct message field
    if (aiResponseText.isEmpty && response['message'] != null) {
      aiResponseText = response['message'].toString();
      if (kDebugMode) {
        print('✅ Found message in response[\'message\']: ${aiResponseText.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length)}...');
      }
    }
    
    // If still empty, try extracting from history array
    if (aiResponseText.isEmpty && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null && data['history'] != null) {
        final history = data['history'] as List<dynamic>?;
        if (history != null && history.isNotEmpty) {
          // Find the last assistant message in the history
          for (int i = history.length - 1; i >= 0; i--) {
            final msg = history[i] as Map<String, dynamic>?;
            if (msg != null && msg['role'] == 'assistant' && msg['content'] != null) {
              aiResponseText = msg['content'].toString();
              if (kDebugMode) {
                print('✅ Found message in history: ${aiResponseText.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length)}...');
              }
              break;
            }
          }
        }
      }
    }
    
    if (kDebugMode) {
      print('✅ API Response received:');
      print('  - Success: ${response['success']}');
      print('  - AI Message: ${aiResponseText.isNotEmpty ? aiResponseText.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length) : "EMPTY"}...');
      print('  - User Message ID: ${response['user_message_id']}');
      print('  - AI Message ID: ${response['ai_message_id']}');
    }
    
    if (aiResponseText.isEmpty) {
      if (kDebugMode) {
        print('⚠️ Warning: AI response text is empty!');
        print('Full response: $response');
      }
      throw Exception('AI response is empty');
    }
    
    // Don't add messages locally - Firestore stream will handle all updates
    // The API saves both user and AI messages to Firestore, so the stream will update
    // This prevents duplicates since we use Firestore as the single source of truth
    if (kDebugMode) {
      print('✅ API response received. Firestore stream will update with user and AI messages...');
    }
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

  /// Scroll to bottom of messages list
  void scrollToBottom() {
    if (messages.isEmpty || !scrollController.hasClients) {
      return;
    }

    // Try multiple times to ensure we scroll to the actual bottom
    // ListView needs time to measure all content
    void attemptScroll(int attempt) {
      if (!scrollController.hasClients || messages.isEmpty) {
        return;
      }

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;
      
      if (maxScroll > 0 && (maxScroll - currentScroll).abs() > 10) {
        // Not at bottom yet, scroll there
        scrollController.jumpTo(maxScroll);
        _updateVisibleDate();
        
        // Try again after a delay if we're still not at bottom (content might still be measuring)
        if (attempt < 3) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (scrollController.hasClients) {
              attemptScroll(attempt + 1);
            }
          });
        }
      }
    }

    // Start scrolling after ListView is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        attemptScroll(0);
      });
    });
  }

  /// Scroll up when keyboard opens to keep last message visible
  void scrollUpForKeyboard(BuildContext context) {
    if (messages.isEmpty || !scrollController.hasClients) {
      return;
    }

    // Wait for keyboard to fully appear and ListView to measure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!scrollController.hasClients) {
          return;
        }

        // Get keyboard height from MediaQuery
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        
        if (keyboardHeight > 0) {
          final maxScroll = scrollController.position.maxScrollExtent;
          final currentScroll = scrollController.offset;
          
          // If we're at or near the bottom, scroll up to show last message above keyboard
          final isNearBottom = (maxScroll - currentScroll) < 150;
          
          if (isNearBottom && maxScroll > 0) {
            // Calculate scroll amount: keyboard height + input field height + padding
            // This ensures the last message is clearly visible above the keyboard
            final scrollUpAmount = keyboardHeight + 120; // Extra padding for visibility
            final targetScroll = (currentScroll + scrollUpAmount).clamp(0.0, maxScroll);
            
            if (targetScroll > currentScroll) {
              scrollController.animateTo(
                targetScroll,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
              
              // Update visible date after scroll
              Future.delayed(const Duration(milliseconds: 350), () {
                _updateVisibleDate();
              });
            }
          }
        }
      });
    });
  }

  /// Update visible date based on scroll position
  void _updateVisibleDate() {
    if (!scrollController.hasClients || messages.isEmpty) {
      return;
    }

    // Get the scroll position
    final scrollOffset = scrollController.offset;
    
    // Estimate which message is at the top of the viewport
    // This is approximate - we calculate based on average message height
    // Note: We need context for screen height, so we'll use a default estimate
    // In a real implementation, you might want to track actual message heights
    final averageMessageHeight = 100.0; // Approximate height
    final estimatedIndex = (scrollOffset / averageMessageHeight).floor();
    
    // Clamp to valid range
    final validIndex = estimatedIndex.clamp(0, messages.length - 1);
    
    if (validIndex >= 0 && validIndex < messages.length) {
      final visibleMessage = messages[validIndex];
      final visibleDate = DateTime(
        visibleMessage.timestamp.year,
        visibleMessage.timestamp.month,
        visibleMessage.timestamp.day,
      );
      
      // Only update if different to avoid unnecessary rebuilds
      final currentDate = DateTime(
        this.visibleDate.value.year,
        this.visibleDate.value.month,
        this.visibleDate.value.day,
      );
      
      if (!_isSameDay(currentDate, visibleDate)) {
        this.visibleDate.value = visibleDate;
      }
    }
  }

  /// Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Update visible date with context (for more accurate calculation)
  void updateVisibleDateWithContext(BuildContext context) {
    if (!scrollController.hasClients || messages.isEmpty) {
      return;
    }

    final scrollOffset = scrollController.offset;
    final averageMessageHeight = AppResponsive.screenHeight(context) * 0.1; // Approximate
    final estimatedIndex = (scrollOffset / averageMessageHeight).floor();
    final validIndex = estimatedIndex.clamp(0, messages.length - 1);
    
    if (validIndex >= 0 && validIndex < messages.length) {
      final visibleMessage = messages[validIndex];
      final visibleDate = DateTime(
        visibleMessage.timestamp.year,
        visibleMessage.timestamp.month,
        visibleMessage.timestamp.day,
      );
      
      final currentDate = DateTime(
        this.visibleDate.value.year,
        this.visibleDate.value.month,
        this.visibleDate.value.day,
      );
      
      if (!_isSameDay(currentDate, visibleDate)) {
        this.visibleDate.value = visibleDate;
      }
    }
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

