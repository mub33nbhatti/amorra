import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';

/// Subscription Header Section Widget
/// Displays title and subtitle for subscription screen
class SubscriptionHeaderSection extends StatelessWidget {
  const SubscriptionHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.subscriptionScreenTitle,
          style: AppTextStyles.headline(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            height: 1.3,
          ),
        ),
        Text(
          AppTexts.subscriptionScreenSubtitle,
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 14),
            color: AppColors.grey,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
