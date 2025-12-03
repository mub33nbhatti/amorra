import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Subscription Plan Header Widget
/// Displays plan name, description, and price
class SubscriptionPlanHeader extends StatelessWidget {
  final String planName;
  final String price;
  final String? period;
  final String description;
  final bool isPremium;

  const SubscriptionPlanHeader({
    super.key,
    required this.planName,
    required this.price,
    this.period,
    required this.description,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            AppResponsive.radius(context, factor:1.25),
          ),
          topRight: Radius.circular(
            AppResponsive.radius(context, factor:1.25),
          ),
        ),
      ).copyWith(
        gradient: isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              )
            : null,
        color: isPremium ? null : AppColors.lightGrey,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name
                Text(
                  planName,
                  style: AppTextStyles.headline(context).copyWith(
                    color: isPremium ? AppColors.white : AppColors.black,
                    fontSize: AppResponsive.scaleSize(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Description
                Text(
                  description,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: isPremium
                        ? AppColors.white.withValues(alpha: 0.9)
                        : AppColors.grey,
                    fontSize: AppResponsive.scaleSize(context, 12),
                  ),
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: AppTextStyles.headline(context).copyWith(
                      color: isPremium ? AppColors.white : AppColors.black,
                      fontSize: AppResponsive.scaleSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (period != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.005,
                      ),
                      child: Text(
                        period!,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: isPremium
                              ? AppColors.white.withValues(alpha: 0.9)
                              : AppColors.grey,
                          fontSize: AppResponsive.scaleSize(context, 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

