import 'package:amorra/core/config/routes.dart';
import 'package:amorra/core/utils/app_gradient/app_gradient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:iconsax/iconsax.dart';

/// Chat Daily Limit Info Widget
/// Shows daily message limit information
class ChatDailyLimitInfo extends StatelessWidget {
  final int remainingMessages;
  final bool isLimitReached;
  final bool isWithinFreeTrial;

  const ChatDailyLimitInfo({
    super.key,
    required this.remainingMessages,
    required this.isLimitReached,
    this.isWithinFreeTrial = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLimitReached) {
      return Container(
        padding: AppSpacing.symmetric(context, h: 0.04, v: 0.01),
        decoration: BoxDecoration(
          color: AppColors.error,
          border: Border(
            top: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppResponsive.radius(context, factor: 3)),
            topRight: Radius.circular(AppResponsive.radius(context, factor: 3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Iconsax.close_circle,
              color: AppColors.white,
              size: AppResponsive.iconSize(context),
            ),
            AppSpacing.horizontal(context, 0.02),
            Expanded(
              child: Text(
                AppTexts.chatDailyLimitReached,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.white,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.subscription),
              child: Text(
                'Upgrade',
                style: AppTextStyles.buttonText(context).copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppResponsive.radius(context, factor: 3)),
          topRight: Radius.circular(AppResponsive.radius(context, factor: 3)),
        ),
      ).withAppGradient(),
      child: Row(
        children: [
          Icon(
            Iconsax.tick_circle,
            color: AppColors.white,
            size: AppResponsive.iconSize(context),
          ),
          AppSpacing.horizontal(context, 0.02),
          Expanded(
            child: Text(
              isWithinFreeTrial
                  ? AppTexts.chatFreeTrialActive
                  : AppTexts.chatMessagesRemaining.replaceAll(
                      '{count}',
                      remainingMessages.toString(),
                    ),
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.white,
                fontSize: AppResponsive.scaleSize(context, 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
