import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import 'subscription_plan_header.dart';
import 'subscription_plan_features.dart';
import 'subscription_plan_action.dart';

/// Subscription Plan Card Widget
/// Displays a subscription plan with features and pricing
class SubscriptionPlanCard extends StatelessWidget {
  final String planName;
  final String price;
  final String? period;
  final String description;
  final List<String> features;
  final bool isPremium;
  final bool isCurrentPlan;
  final VoidCallback? onSelect;

  const SubscriptionPlanCard({
    super.key,
    required this.planName,
    required this.price,
    this.period,
    required this.description,
    required this.features,
    this.isPremium = false,
    this.isCurrentPlan = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: AppResponsive.screenHeight(context) * 0.02,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
        border: Border.all(
          color: isPremium
              ? AppColors.primary
              : AppColors.grey,
          width: isPremium ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPremium
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.grey.withValues(alpha: 0.5),
            blurRadius: isPremium ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SubscriptionPlanHeader(
            planName: planName,
            price: price,
            period: period,
            description: description,
            isPremium: isPremium,
          ),

          // Features
          SubscriptionPlanFeatures(
            features: features,
            isPremium: isPremium,
          ),

          // Action
          SubscriptionPlanAction(
            isCurrentPlan: isCurrentPlan,
            isPremium: isPremium,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

