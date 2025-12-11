import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_large_button.dart';
import '../../widgets/common/app_text_button.dart';

/// Profile Subscription Card Widget
/// Displays subscription status and usage information
class ProfileSubscriptionCard extends StatelessWidget {
  final bool isSubscribed;
  final int remainingMessages;
  final int usedMessages;
  final int dailyLimit;
  final DateTime? nextBillingDate;
  final VoidCallback onUpgradeTap;
  final VoidCallback onManageTap;

  const ProfileSubscriptionCard({
    super.key,
    required this.isSubscribed,
    required this.remainingMessages,
    required this.usedMessages,
    required this.dailyLimit,
    this.nextBillingDate,
    required this.onUpgradeTap,
    required this.onManageTap,
  });

  /// Format next billing date
  String _formatNextBillingDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Get progress value (0.0 to 1.0)
  double get _progressValue {
    if (dailyLimit == 0) return 0.0;
    return (usedMessages / dailyLimit).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Label
          Text(
            isSubscribed
                ? AppTexts.subscriptionPremiumPlanLabel
                : AppTexts.subscriptionFreePlanLabel,
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 16),
            ),
          ),

          AppSpacing.vertical(context, 0.005),

          // Free User Content
          if (!isSubscribed) ...[
            // Check if in free trial (999 = unlimited indicator)
            if (remainingMessages >= 999 || dailyLimit >= 999) ...[
              // Free trial active - show unlimited message
              Text(
                AppTexts.subscriptionFreeTrialActive,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.black,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
            ] else ...[
              // Free trial ended - show messages left
              Text(
                AppTexts.subscriptionMessagesLeft.replaceAll(
                  '{count}',
                  remainingMessages.toString(),
                ),
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.black,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),

              AppSpacing.vertical(context, 0.01),

              // Progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppResponsive.radius(context, factor: 0.5),
                ),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: AppColors.secondary,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: AppResponsive.screenHeight(context) * 0.01,
                ),
              ),
            ],

            AppSpacing.vertical(context, 0.015),

            // Upgrade button
            AppLargeButton(
              text: AppTexts.subscriptionUpgradeButton,
              onPressed: onUpgradeTap,
            ),
          ]
          // Subscribed User Content
          else ...[
            // Unlimited text
            Text(
              AppTexts.subscriptionUnlimitedText,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.grey,
                fontSize: AppResponsive.scaleSize(context, 14),
              ),
            ),

            // Next billing date (if available)
            if (nextBillingDate != null) ...[
              AppSpacing.vertical(context, 0.008),
              Text(
                AppTexts.subscriptionNextBilling.replaceAll(
                  '{date}',
                  _formatNextBillingDate(nextBillingDate!),
                ),
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.grey,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
            ],

            AppSpacing.vertical(context, 0.015),

            // Manage subscription button
            Align(
              alignment: Alignment.centerRight,
              child: AppTextButton(
                text: AppTexts.subscriptionManageButton,
                onPressed: onManageTap,
                textColor: AppColors.primary,
                fontSize: AppResponsive.scaleSize(context, 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

