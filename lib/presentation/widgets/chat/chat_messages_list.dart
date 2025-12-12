import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';
import 'package:amorra/presentation/widgets/chat/chat_message_bubble.dart';
import 'package:amorra/presentation/widgets/chat/chat_empty_state.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';
import 'package:amorra/core/constants/app_constants.dart';

/// Chat Messages List Widget
/// Displays the list of chat messages with scrolling functionality
class ChatMessagesList extends StatelessWidget {
  final ChatController controller;

  const ChatMessagesList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: AppLoadingIndicator());
      }

      // Scroll to bottom when messages are first loaded or when new messages arrive
      if (controller.messages.isNotEmpty) {
        // Scroll to bottom after messages are rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.scrollToBottom();
        });
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Update visible date with context when scrolling
          if (notification is ScrollUpdateNotification) {
            controller.updateVisibleDateWithContext(context);
          }
          return false;
        },
        child: ListView(
          controller: controller.scrollController,
          padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
          children: [
            // Actual messages
            ..._buildMessages(context),

            // Typing indicator as message bubble
            if (controller.isTyping.value)
              ChatMessageBubble(
                message: '', // Not used when isTyping is true
                type: AppConstants.messageTypeAI,
                timestamp: DateTime.now(),
                showTimestamp: false, // Don't show timestamp for typing
                isTyping: true,
              ),

            // Empty state at the bottom
            if (controller.messages.isEmpty && !controller.isTyping.value)
              const ChatEmptyState(),
          ],
        ),
      );
    });
  }

  /// Build messages list
  List<Widget> _buildMessages(BuildContext context) {
    if (controller.messages.isEmpty) {
      return [];
    }

    final List<Widget> widgets = [];

    for (final message in controller.messages) {
      // Add message bubble - always show timestamp
      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: AppResponsive.screenHeight(context) * 0.015,
          ),
          child: ChatMessageBubble(
            message: message.message,
            type: message.type,
            timestamp: message.timestamp,
            showTimestamp: true, // Always show timestamp
            userAge: controller.userAge,
          ),
        ),
      );
    }

    return widgets;
  }
}
