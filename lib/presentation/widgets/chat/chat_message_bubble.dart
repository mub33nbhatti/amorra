import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import 'chat_timestamp_widget.dart';

/// Chat Message Bubble Widget
/// Displays a chat message with rounded bubble and timestamp
class ChatMessageBubble extends StatelessWidget {
  final String message;
  final String type; // 'user' or 'ai'
  final DateTime timestamp;
  final bool showTimestamp;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.type,
    required this.timestamp,
    this.showTimestamp = true,
  });

  bool get isUser => type == AppConstants.messageTypeUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: AppResponsive.screenWidth(context) * 0.75,
          ),
          padding: AppSpacing.symmetric(context, h: 0.03, v: 0.02),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : AppColors.secondary,
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
          child: Text(
            message,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.white,
              fontSize: AppResponsive.scaleSize(context, 15),
            ),
          ),
        ),
        if (showTimestamp)
          Padding(
            padding: EdgeInsets.only(
              top: AppResponsive.screenHeight(context) * 0.005,
              left: isUser ? 0 : AppResponsive.screenWidth(context) * 0.02,
              right: isUser ? AppResponsive.screenWidth(context) * 0.02 : 0,
            ),
            child: ChatTimestampWidget(timestamp: timestamp),
          ),
      ],
    );
  }
}

