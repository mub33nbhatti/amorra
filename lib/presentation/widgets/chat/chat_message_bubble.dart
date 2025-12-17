import 'package:amorra/presentation/widgets/chat/chat_processing_messages.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/text_formatter.dart';
import 'package:amorra/core/constants/app_constants.dart';
import 'package:amorra/core/utils/app_lotties/app_lotties.dart';
import 'package:amorra/presentation/widgets/common/ai_avatar.dart';
import 'package:amorra/presentation/widgets/common/user_avatar.dart';
import 'chat_timestamp_widget.dart';

/// Chat Message Bubble Widget
/// Displays a chat message with rounded bubble and timestamp
/// Can also display typing animation when isTyping is true
class ChatMessageBubble extends StatelessWidget {
  final String message;
  final String type; // 'user' or 'ai'
  final DateTime timestamp;
  final bool showTimestamp;
  final int? userAge; // For user avatar
  final bool isTyping; // Show typing animation instead of message

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.type,
    required this.timestamp,
    this.showTimestamp = true,
    this.userAge,
    this.isTyping = false,
  });

  bool get isUser => type == AppConstants.messageTypeUser;

  @override
  Widget build(BuildContext context) {
    final avatarSize = AppResponsive.iconSize(context, factor: 1.5);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        // Avatar (only for AI, on the left)
        if (!isUser) ...[
          AIAvatar(size: avatarSize),
          AppSpacing.horizontal(context, 0.015),
        ],

        // Message bubble
        Flexible(
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: AppResponsive.screenWidth(context) * 0.7,
                ),
                padding: AppSpacing.symmetric(context, h: 0.02, v: 0.01),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.secondary : AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      AppResponsive.radius(context, factor: 2),
                    ),
                    topRight: Radius.circular(
                      AppResponsive.radius(context, factor: 2),
                    ),
                    bottomLeft: Radius.circular(
                      isUser
                          ? AppResponsive.radius(context, factor: 2)
                          : AppResponsive.radius(context, factor: 0.5),
                    ),
                    bottomRight: Radius.circular(
                      isUser
                          ? AppResponsive.radius(context, factor: 0.5)
                          : AppResponsive.radius(context, factor: 2),
                    ),
                  ),
                ),
                child: isTyping
                    ? SizedBox(
                        width: AppResponsive.screenWidth(context) * 0.1,
                        height: AppResponsive.screenHeight(context) * 0.03,
                        child: Lottie.asset(
                          AppLotties.typing,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      )
                    : RichText(
                        text: TextFormatter.parseMarkdown(
                          message,
                          baseStyle: AppTextStyles.bodyText(context).copyWith(
                            color: AppColors.white,
                            fontSize: AppResponsive.scaleSize(context, 14),
                            height: 1.3,
                          ),
                          boldStyle: AppTextStyles.bodyText(context).copyWith(
                            color: AppColors.white,
                            fontSize: AppResponsive.scaleSize(context, 14),
                            height: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                          italicStyle: AppTextStyles.bodyText(context).copyWith(
                            color: AppColors.white,
                            fontSize: AppResponsive.scaleSize(context, 14),
                            height: 1.3,
                            fontStyle: FontStyle.italic,
                          ),
                          codeStyle: AppTextStyles.bodyText(context).copyWith(
                            color: AppColors.white,
                            fontSize: AppResponsive.scaleSize(context, 13),
                            height: 1.3,
                            fontFamily: 'monospace',
                            backgroundColor: AppColors.white.withOpacity(0.2),
                          ),
                          strikethroughStyle: AppTextStyles.bodyText(context).copyWith(
                            color: AppColors.white,
                            fontSize: AppResponsive.scaleSize(context, 14),
                            height: 1.3,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
              ),
              if (showTimestamp && !isTyping)
                Padding(
                  padding: EdgeInsets.only(
                    top: AppResponsive.screenHeight(context) * 0.002,
                    left: isUser
                        ? 0
                        : AppResponsive.screenWidth(context) * 0.002,
                    right: isUser
                        ? AppResponsive.screenWidth(context) * 0.002
                        : 0,
                  ),
                  child: ChatTimestampWidget(timestamp: timestamp),
                ),
              if (isTyping)
                Padding(
                  padding: EdgeInsets.only(
                    top: AppResponsive.screenHeight(context) * 0.002,
                    left: AppResponsive.screenWidth(context) * 0.002,
                  ),
                  child: const ChatProcessingMessages(),
                ),
            ],
          ),
        ),

        // Avatar (only for user, on the right)
        if (isUser) ...[
          AppSpacing.horizontal(context, 0.015),
          UserAvatar(age: userAge, size: avatarSize),
        ],
      ],
    );
  }
}
