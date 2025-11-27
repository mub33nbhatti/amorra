import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';

/// Subscription Screen
/// Placeholder screen for subscription tab
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          AppTexts.subscriptionTitle,
          style: AppTextStyles.headline(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership_outlined,
              size: AppResponsive.iconSize(context, factor: 5),
              color: AppColors.secondary,
            ),
            AppSpacing.vertical(context, 0.03),
            Text(
              'Subscription Screen',
              style: AppTextStyles.headline(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            AppSpacing.vertical(context, 0.01),
            Text(
              AppTexts.placeholderText,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

