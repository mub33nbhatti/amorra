import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Subscription Plan Features Widget
/// Displays list of plan features
class SubscriptionPlanFeatures extends StatelessWidget {
  final List<String> features;
  final bool isPremium;

  const SubscriptionPlanFeatures({
    super.key,
    required this.features,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Features Title
          Text(
            'Features:',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 14),
            ),
          ),
          AppSpacing.vertical(context, 0.01),
          // Features List
          ...features.map((feature) => Padding(
                padding: EdgeInsets.only(
                  bottom: AppResponsive.screenHeight(context) * 0.01,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.tick_circle,
                      size: AppResponsive.iconSize(context),
                      color: isPremium
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.black,
                          fontSize: AppResponsive.scaleSize(context, 14),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

