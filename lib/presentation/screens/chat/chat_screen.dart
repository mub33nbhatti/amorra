import 'package:amorra/core/utils/app_gradient/app_gradient.dart';
import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_typing_indicator.dart';
import '../../widgets/chat/chat_input_field.dart';

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
            _buildChatHeader(context),

            // // Messages List
            // Expanded(
            //   child: Obx(
            //     () {
            //       if (controller.isLoading.value) {
            //         return Center(
            //           child: CircularProgressIndicator(
            //             color: AppColors.primary,
            //           ),
            //         );
            //       }
            //
            //       if (controller.messages.isEmpty && !controller.isTyping.value) {
            //         return _buildEmptyState(context);
            //       }
            //
            //       // Auto-scroll to bottom when new messages arrive
            //       WidgetsBinding.instance.addPostFrameCallback((_) {
            //         if (scrollController.hasClients) {
            //           scrollController.animateTo(
            //             scrollController.position.maxScrollExtent,
            //             duration: const Duration(milliseconds: 300),
            //             curve: Curves.easeOut,
            //           );
            //         }
            //       });
            //
            //       return ListView.builder(
            //         controller: scrollController,
            //         padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
            //         itemCount: controller.messages.length +
            //             (controller.isTyping.value ? 1 : 0),
            //         itemBuilder: (context, index) {
            //           if (index == controller.messages.length &&
            //               controller.isTyping.value) {
            //             // Typing indicator
            //             return Padding(
            //               padding: EdgeInsets.only(
            //                 bottom: AppResponsive.screenHeight(context) * 0.02,
            //               ),
            //               child: Row(
            //                 children: [
            //                   Container(
            //                     padding: AppSpacing.symmetric(
            //                       context,
            //                       h: 0.03,
            //                       v: 0.02,
            //                     ),
            //                     decoration: BoxDecoration(
            //                       color: AppColors.secondary,
            //                       borderRadius: BorderRadius.circular(
            //                         AppResponsive.radius(context, factor: 2),
            //                       ),
            //                     ),
            //                     child: const ChatTypingIndicator(),
            //                   ),
            //                 ],
            //               ),
            //             );
            //           }
            //
            //           final message = controller.messages[index];
            //           final showTimestamp = index == 0 ||
            //               index == controller.messages.length - 1 ||
            //               message.timestamp.difference(
            //                     controller.messages[index - 1].timestamp,
            //                   ).inMinutes >
            //                   5;
            //
            //           return Padding(
            //             padding: EdgeInsets.only(
            //               bottom: AppResponsive.screenHeight(context) * 0.015,
            //             ),
            //             child: Align(
            //               alignment: message.type == AppConstants.messageTypeUser
            //                   ? Alignment.centerRight
            //                   : Alignment.centerLeft,
            //               child: ChatMessageBubble(
            //                 message: message.message,
            //                 type: message.type,
            //                 timestamp: message.timestamp,
            //                 showTimestamp: showTimestamp,
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
            //
            // // Daily Limit Info (if free tier)
            // Obx(
            //   () => _buildDailyLimitInfo(context),
            // ),
            //
            // // Input Field
            // Obx(
            //   () => ChatInputField(
            //     controller: controller.inputController,
            //     onSend: controller.canSendMessage
            //         ? () => controller.sendMessage()
            //         : null,
            //     isEnabled: controller.canSendMessage,
            //     hintText: controller.canSendMessage
            //         ? null
            //         : AppTexts.chatDailyLimitReached,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGrey, width: 1),
        ),
      ),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: AppResponsive.iconSize(context, factor: 2),
            height: AppResponsive.iconSize(context, factor: 2),
            padding: AppSpacing.all(context,factor: 0.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ).withAppGradient(),
            child: Image.asset(
              AppImages.chatbotLogo,
              height: AppResponsive.iconSize(context, factor: 0.8),
              width: AppResponsive.iconSize(context, factor: 0.8),
              color: AppColors.white,
            ),
          ),
          AppSpacing.horizontal(context, 0.02),

          // AI Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTexts.chatAIPersonaName,
                  style: AppTextStyles.heading(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontSize: AppResponsive.scaleSize(context, 18),
                  ),
                ),
                Text(
                  AppTexts.chatAIStatus,
                  style: AppTextStyles.hintText(context).copyWith(
                    color: AppColors.success,
                    fontSize: AppResponsive.scaleSize(context, 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: AppResponsive.iconSize(context, factor: 5),
            color: AppColors.grey,
          ),
          AppSpacing.vertical(context, 0.02),
          Text(
            AppTexts.chatEmptyStateTitle,
            style: AppTextStyles.headline(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: AppColors.black),
          ),
          AppSpacing.vertical(context, 0.01),
          Text(
            AppTexts.chatEmptyStateSubtitle,
            style: AppTextStyles.bodyText(
              context,
            ).copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLimitInfo(BuildContext context) {
    final remainingCount = controller.remainingMessages.value;
    final isLimitReached = remainingCount <= 0;

    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.015),
      decoration: BoxDecoration(
        color: isLimitReached
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.information.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: isLimitReached
                ? AppColors.error.withValues(alpha: 0.3)
                : AppColors.information.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLimitReached ? Icons.info_outline : Icons.check_circle_outline,
            color: isLimitReached ? AppColors.error : AppColors.information,
            size: AppResponsive.iconSize(context),
          ),
          AppSpacing.horizontal(context, 0.02),
          Expanded(
            child: Text(
              isLimitReached
                  ? AppTexts.chatDailyLimitReached
                  : AppTexts.chatMessagesRemaining.replaceAll(
                      '{count}',
                      remainingCount.toString(),
                    ),
              style: AppTextStyles.bodyText(context).copyWith(
                color: isLimitReached ? AppColors.error : AppColors.information,
                fontSize: AppResponsive.scaleSize(context, 12),
              ),
            ),
          ),
          if (isLimitReached)
            TextButton(
              onPressed: () {
                // TODO: Navigate to subscription screen
                Get.toNamed('/subscription');
              },
              child: Text(
                AppTexts.chatUpgradePrompt,
                style: AppTextStyles.buttonText(context).copyWith(
                  color: AppColors.primary,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
