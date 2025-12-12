import 'package:amorra/core/utils/app_gradient/app_gradient.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_large_button.dart';

/// Home Chat CTA Card
/// Main card with different UI based on hasActiveChat status
class HomeChatCtaCard extends StatelessWidget {
  final bool hasActiveChat;
  final String? lastMessageSnippet;
  final DateTime? lastMessageTime;
  final VoidCallback onTap;

  const HomeChatCtaCard({
    super.key,
    required this.hasActiveChat,
    this.lastMessageSnippet,
    this.lastMessageTime,
    required this.onTap,
  });

  /// Get message snippet (truncated)
  String _getMessageSnippet(String message) {
    if (message.length <= 50) return message;
    return '${message.substring(0, 50)}...';
  }

  /// Format last message time
  String _formatLastMessageTime(DateTime timestamp) {
    return timeago.format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 2),
        ),
      ).withAppGradient(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            hasActiveChat
                ? AppTexts.chatCtaContinueTitle
                : AppTexts.chatCtaStartTitle,
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              fontSize: AppResponsive.scaleSize(context, 16),
            ),
          ),

          AppSpacing.vertical(context, 0.005),

          // Subtitle or Last Message Info
          if (!hasActiveChat)
            Text(
              AppTexts.chatCtaStartSubtitle,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: AppResponsive.scaleSize(context, 14),
              ),
            )
          else ...[
            // Last message snippet
            if (lastMessageSnippet != null)
              Text(
                _getMessageSnippet(lastMessageSnippet!),
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.white,
                  fontSize: AppResponsive.scaleSize(context, 14),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            AppSpacing.vertical(context, 0.005),

            // Last message time
            if (lastMessageTime != null)
              Text(
                _formatLastMessageTime(lastMessageTime!),
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
          ],

          AppSpacing.vertical(context, 0.01),

          // Button
          AppLargeButton(
            text: hasActiveChat
                ? AppTexts.chatCtaButtonContinue
                : AppTexts.chatCtaButtonStart,
            onPressed: onTap,
            backgroundColor: AppColors.white,
            textColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
