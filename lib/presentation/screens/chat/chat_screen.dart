import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';
import 'package:amorra/presentation/widgets/chat/chat_message_bubble.dart';
import 'package:amorra/presentation/widgets/chat/chat_typing_indicator.dart';
import 'package:amorra/presentation/widgets/chat/chat_input_field.dart';
import 'package:amorra/presentation/widgets/chat/chat_header.dart';
import 'package:amorra/presentation/widgets/chat/chat_empty_state.dart';
import 'package:amorra/presentation/widgets/chat/chat_daily_limit_info.dart';
import 'package:amorra/presentation/widgets/chat/chat_dummy_messages.dart';
import 'package:amorra/presentation/widgets/chat/chat_date_label.dart';
import 'package:amorra/presentation/widgets/common/app_snackbar.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';

/// Chat Screen
/// Full chat interface with messages, typing indicator, and input field
class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header with AI name and status
            const ChatHeader(),

            // Messages List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: AppLoadingIndicator());
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView(
                  controller: scrollController,
                  padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
                  children: [
                    // Dummy messages at the top
                    const ChatDummyMessages(),

                    // Actual messages (if any) with date labels
                    ..._buildMessagesWithDateLabels(context),

                    // Typing indicator
                    if (controller.isTyping.value)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: AppResponsive.screenHeight(context) * 0.015,
                        ),
                        child: Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    AppResponsive.screenWidth(context) * 0.7,
                              ),
                              padding: AppSpacing.symmetric(
                                context,
                                h: 0.04,
                                v: 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                    AppResponsive.radius(context, factor: 2),
                                  ),
                                  topRight: Radius.circular(
                                    AppResponsive.radius(context, factor: 2),
                                  ),
                                  bottomLeft: Radius.circular(
                                    AppResponsive.radius(context, factor: 0.5),
                                  ),
                                  bottomRight: Radius.circular(
                                    AppResponsive.radius(context, factor: 2),
                                  ),
                                ),
                              ),
                              child: const ChatTypingIndicator(),
                            ),
                          ],
                        ),
                      ),

                    // Empty state at the bottom
                    if (controller.messages.isEmpty &&
                        !controller.isTyping.value)
                      const ChatEmptyState(),
                  ],
                );
              }),
            ),

            // Daily Limit Info
            Obx(
              () => ChatDailyLimitInfo(
                remainingMessages: controller.remainingMessages.value,
                isLimitReached: !controller.canSendMessage,
                isWithinFreeTrial: controller.isWithinFreeTrial.value,
              ),
            ),

            // Input Field
            Obx(
              () => ChatInputField(
                controller: controller.inputController,
                onSend: () {
                  AppSnackbar.showInfo(
                    title: 'Coming Soon',
                    subtitle: 'This functionality is coming soon!',
                  );
                },
                isLimitReached: !controller.canSendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build messages list with date labels
  List<Widget> _buildMessagesWithDateLabels(BuildContext context) {
    if (controller.messages.isEmpty) {
      return [];
    }

    final List<Widget> widgets = [];
    DateTime? previousDate;

    for (int index = 0; index < controller.messages.length; index++) {
      final message = controller.messages[index];
      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      // Check if we need to show a date tag
      if (previousDate == null || !_isSameDay(previousDate, messageDate)) {
        widgets.add(ChatDateLabel(date: messageDate, showDividers: true));
        previousDate = messageDate;
      }

      // Determine if we should show timestamp
      final showTimestamp =
          index == 0 ||
          index == controller.messages.length - 1 ||
          (index > 0 &&
              message.timestamp
                      .difference(controller.messages[index - 1].timestamp)
                      .inMinutes >
                  5);

      // Add message bubble
      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: AppResponsive.screenHeight(context) * 0.015,
          ),
          child: ChatMessageBubble(
            message: message.message,
            type: message.type,
            timestamp: message.timestamp,
            showTimestamp: showTimestamp,
            userAge: controller.userAge,
          ),
        ),
      );
    }

    return widgets;
  }

  /// Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
