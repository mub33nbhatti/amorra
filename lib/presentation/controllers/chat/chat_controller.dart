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
  
  // Track pending messages to prevent duplicates
  // Key: message content + type + timestamp (rounded to seconds)
  // Value: temp message ID
  final Map<String, String> _pendingMessages = {};

  // Computed
  bool get canSendMessage {
    // Check subscription status first
    final user = currentUser;
    if (user != null && user.isSubscribed) {
      return true; // Subscribed users have unlimited messages
    }
    
    // If within free trial, always allow
    if (isWithinFreeTrial.value) return true;
    
    // After trial, check remaining messages
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
      print('  - isSubscribed: ${user?.isSubscribed ?? false}');
    }
    
    _checkFreeTrialStatus();
    _updateMessageLimitBasedOnSubscription(user);
    
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

  /// Update message limit based on subscription status
  void _updateMessageLimitBasedOnSubscription(UserModel? user) {
    if (user == null) {
      remainingMessages.value = AppConfig.freeMessageLimit;
      return;
    }

    // Check subscription status first
    if (user.isSubscribed) {
      remainingMessages.value = 999; // Unlimited for subscribed users
      if (kDebugMode) {
        print('✅ User is subscribed - setting unlimited messages');
      }
      return;
    }

    // Check free trial status
    if (FreeTrialUtils.isWithinFreeTrial(user)) {
      remainingMessages.value = 999; // Unlimited for free trial
      if (kDebugMode) {
        print('✅ User is in free trial - setting unlimited messages');
      }
      return;
    }

    // Free tier - keep current limit or set default
    if (remainingMessages.value >= 999) {
      remainingMessages.value = AppConfig.freeMessageLimit;
    }
  }

  /// Check if user is within free trial period
  void _checkFreeTrialStatus() {
    final user = currentUser;
    if (user != null) {
      isWithinFreeTrial.value = FreeTrialUtils.isWithinFreeTrial(user);
      // Update message limit based on subscription and trial status
      _updateMessageLimitBasedOnSubscription(user);
    }
  }

  @override
  void onClose() {
    _cancelMessagesStream();
    scrollController.dispose();
    inputController.dispose();
    _pendingMessages.clear(); // Clean up pending messages tracking
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
      
      // Clean up old pending messages (older than 30 seconds)
      final now = DateTime.now();
      _pendingMessages.removeWhere((key, value) {
        // Extract timestamp from key (format: "content|type|timestamp")
        final parts = key.split('|');
        if (parts.length >= 3) {
          try {
            final timestamp = DateTime.parse(parts[2]);
            return now.difference(timestamp).inSeconds > 30;
          } catch (e) {
            return true; // Remove invalid keys
          }
        }
        return true; // Remove malformed keys
      });
      
      // Start with Firestore messages (source of truth)
      final mergedMessages = List<ChatMessageModel>.from(newMessages);
      
      // Find local temp messages that need to be checked
      final currentMessages = List<ChatMessageModel>.from(messages);
      final localTempMessages = currentMessages.where((localMsg) {
        // Temp messages have IDs starting with "temp_"
        final isTemp = localMsg.id.startsWith('temp_');
        // Only consider recent temp messages (within last 15 seconds)
        final isRecent = now.difference(localMsg.timestamp).inSeconds < 15;
        return isTemp && isRecent;
      }).toList();
      
      // Check each temp message against Firestore messages
      for (var tempMsg in localTempMessages) {
        // Try to find matching Firestore message by content, type, and timestamp
        final matchingFirestoreMsg = newMessages.firstWhere(
          (fsMsg) {
            // Match by content and type
            final contentMatch = fsMsg.message.trim() == tempMsg.message.trim();
            final typeMatch = fsMsg.type == tempMsg.type;
            // Match by timestamp (within 10 seconds window)
            final timeDiff = fsMsg.timestamp.difference(tempMsg.timestamp).inSeconds.abs();
            final timeMatch = timeDiff < 10;
            
            return contentMatch && typeMatch && timeMatch;
          },
          orElse: () => ChatMessageModel(
            id: '',
            userId: '',
            message: '',
            type: '',
            timestamp: DateTime.now(),
          ),
        );
        
        // If we found a match, remove the temp message from pending tracking
        if (matchingFirestoreMsg.id.isNotEmpty) {
          // Create key for pending message tracking
          final pendingKey = _createPendingMessageKey(
            tempMsg.message.trim(),
            tempMsg.type,
            tempMsg.timestamp,
          );
          _pendingMessages.remove(pendingKey);
          
          if (kDebugMode) {
            print('✅ Matched temp message with Firestore message: ${tempMsg.message.substring(0, tempMsg.message.length > 30 ? 30 : tempMsg.message.length)}...');
          }
          // Don't add temp message - Firestore version is already in mergedMessages
        } else {
          // No match found yet, keep temp message
          // But check if we already have this temp message in merged list
          final alreadyInList = mergedMessages.any((msg) => msg.id == tempMsg.id);
          if (!alreadyInList) {
            mergedMessages.add(tempMsg);
          }
        }
      }
      
      // Remove duplicates by content + type + timestamp (within 2 seconds)
      // This is a safety net in case matching logic misses something
      final deduplicatedMessages = <ChatMessageModel>[];
      final seenKeys = <String>{};
      
      for (var msg in mergedMessages) {
        final key = _createMessageKey(msg.message.trim(), msg.type, msg.timestamp);
        
        // Check if we've seen a similar message recently
        bool isDuplicate = false;
        for (var seenKey in seenKeys) {
          final parts = seenKey.split('|');
          if (parts.length >= 3) {
            final seenContent = parts[0];
            final seenType = parts[1];
            final seenTimestamp = DateTime.parse(parts[2]);
            
            // Same content and type, and within 2 seconds
            if (seenContent == msg.message.trim() &&
                seenType == msg.type &&
                msg.timestamp.difference(seenTimestamp).inSeconds.abs() < 2) {
              isDuplicate = true;
              break;
            }
          }
        }
        
        if (!isDuplicate) {
          deduplicatedMessages.add(msg);
          seenKeys.add(key);
        }
      }
      
      // Sort by timestamp
      deduplicatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      if (kDebugMode) {
        print('  - Merged: ${deduplicatedMessages.length} messages (${newMessages.length} from Firestore, ${localTempMessages.length} temp, removed ${mergedMessages.length - deduplicatedMessages.length} duplicates)');
      }
      
      // Update messages list
      messages.value = deduplicatedMessages;
      
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
    // Check subscription status first
    final isSubscribed = user?.isSubscribed ?? false;
    // Check free trial status
    final isInTrial = user != null && FreeTrialUtils.isWithinFreeTrial(user);
    final hasUnlimited = isSubscribed || isInTrial;
    
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
      
      // Track this pending message
      final pendingKey = _createPendingMessageKey(
        messageText.trim(),
        'user',
        userMessageTimestamp,
      );
      _pendingMessages[pendingKey] = tempUserMessageId;
      
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
      final isSubscribed = user?.isSubscribed ?? false;
      final isInTrial = user != null && FreeTrialUtils.isWithinFreeTrial(user);
      final hasUnlimited = isSubscribed || isInTrial;
      
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
    // API returns: { "message": string, "thread_id": string }
    final response = await _chatApiService.sendMessageToAI(
      userId: userId!,
      message: message,
      // chatSessionId is optional - API manages conversation history automatically
    );

    // Extract response data
    // New API format: { "message": string, "thread_id": string }
    // Also supports legacy formats for backward compatibility
    String aiResponseText = '';
    String? threadId;
    
    if (kDebugMode) {
      print('🔍 Parsing API response...');
      print('  - response[\'message\']: ${response['message']}');
      print('  - response[\'thread_id\']: ${response['thread_id']}');
      print('  - response[\'data\']: ${response['data']}');
    }
    
    // New API format: direct message field
    if (response['message'] != null) {
      aiResponseText = response['message'].toString();
      threadId = response['thread_id']?.toString();
      if (kDebugMode) {
        print('✅ Found message in response[\'message\']: ${aiResponseText.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length)}...');
        if (threadId != null) {
          print('✅ Thread ID: $threadId');
        }
      }
    }
    
    // Fallback: Try data.message field (legacy format)
    if (aiResponseText.isEmpty && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null && data['message'] != null) {
        aiResponseText = data['message'].toString();
        if (kDebugMode) {
          print('✅ Found message in response[\'data\'][\'message\']: ${aiResponseText.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length)}...');
        }
      }
    }
    
    // Fallback: Try extracting from history array (legacy format)
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
      print('  - AI Message: ${aiResponseText.isNotEmpty ? aiResponseText.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length) : "EMPTY"}...');
      if (threadId != null) {
        print('  - Thread ID: $threadId');
      }
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
    // Check subscription status first
    final isSubscribed = user?.isSubscribed ?? false;
    // Check free trial status
    final isInTrial = user != null && FreeTrialUtils.isWithinFreeTrial(user);
    final hasUnlimited = isSubscribed || isInTrial;
    
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

  /// Create a key for tracking pending messages
  /// Format: "content|type|timestamp_rounded_to_seconds"
  String _createPendingMessageKey(String content, String type, DateTime timestamp) {
    // Round timestamp to seconds to allow matching within a time window
    final roundedTimestamp = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      timestamp.hour,
      timestamp.minute,
      timestamp.second,
    );
    return '$content|$type|${roundedTimestamp.toIso8601String()}';
  }

  /// Create a key for message deduplication
  /// Format: "content|type|timestamp"
  String _createMessageKey(String content, String type, DateTime timestamp) {
    return '$content|$type|${timestamp.toIso8601String()}';
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

