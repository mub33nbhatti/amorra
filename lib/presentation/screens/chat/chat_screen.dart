import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';
import 'package:amorra/presentation/controllers/subscription/subscription_controller.dart';
import 'package:amorra/presentation/widgets/chat/chat_input_field.dart';
import 'package:amorra/presentation/widgets/chat/chat_header.dart';
import 'package:amorra/presentation/widgets/chat/chat_daily_limit_info.dart';
import 'package:amorra/presentation/widgets/chat/chat_messages_list.dart';
import 'package:amorra/presentation/widgets/chat/chat_keyboard_handler.dart';

/// Chat Screen
/// Full chat interface with messages, typing indicator, and input field
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.find<ChatController>();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ChatKeyboardHandler(
          inputFocusNode: _inputFocusNode,
          child: Column(
            children: [
              // Header with AI name and status
              const ChatHeader(),

              // Messages List
              Expanded(
                child: ChatMessagesList(controller: controller),
              ),

              // Daily Limit Info
              Obx(
                () {
                  // Get subscription status - check SubscriptionController first (most up-to-date)
                  bool isSubscribed = false;
                  try {
                    if (Get.isRegistered<SubscriptionController>()) {
                      final subscriptionController = Get.find<SubscriptionController>();
                      // Accessing .value makes Obx reactive to changes
                      isSubscribed = subscriptionController.isSubscribed.value;
                    }
                  } catch (e) {
                    // SubscriptionController not available, fallback to user model
                  }
                  
                  // Fallback to user model if SubscriptionController not available
                  if (!isSubscribed) {
                    final user = controller.currentUser;
                    isSubscribed = user?.isSubscribed ?? false;
                  }
                  
                  return ChatDailyLimitInfo(
                    remainingMessages: controller.remainingMessages.value,
                    isLimitReached: !controller.canSendMessage,
                    isWithinFreeTrial: controller.isWithinFreeTrial.value,
                    isSubscribed: isSubscribed,
                  );
                },
              ),

              // Input Field - wrapped in Flexible to prevent overflow
              Obx(
                () => ChatInputField(
                  controller: controller.inputController,
                  onSend: () => controller.sendMessage(),
                  isLimitReached: !controller.canSendMessage,
                  isReplying: controller.isTyping.value,
                  focusNode: _inputFocusNode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
