import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_screen_header.dart';
import '../../widgets/subscription/subscription_plan_card.dart';
import '../../widgets/subscription/subscription_header_section.dart';
import '../../controllers/subscription/subscription_controller.dart';

/// Subscription Screen
/// Eye-catching subscription screen with plan selection
class SubscriptionScreen extends GetView<SubscriptionController> {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.subscription.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppScreenHeader(title: AppTexts.subscriptionTitle),
              AppSpacing.vertical(context, 0.02),

              // Header Section
              const SubscriptionHeaderSection(),
              AppSpacing.vertical(context, 0.02),

              // Free Plan Card
              SubscriptionPlanCard(
                planName: AppTexts.freePlanName,
                price: AppTexts.freePlanPrice,
                description: AppTexts.freePlanDescription,
                features: [
                  AppTexts.freePlanFeature1,
                  AppTexts.freePlanFeature2,
                  AppTexts.freePlanFeature3,
                ],
                isPremium: false,
                isCurrentPlan: !controller.isSubscribed.value,
                onSelect: null, // Free plan is always available
              ),

              // Premium Plan Card
              SubscriptionPlanCard(
                planName: AppTexts.premiumPlanName,
                price: AppTexts.premiumPlanPrice,
                period: AppTexts.premiumPlanPeriod,
                description: AppTexts.premiumPlanDescription,
                features: [
                  AppTexts.premiumPlanFeature1,
                  AppTexts.premiumPlanFeature2,
                  AppTexts.premiumPlanFeature3,
                  AppTexts.premiumPlanFeature4,
                  AppTexts.premiumPlanFeature5,
                  AppTexts.premiumPlanFeature6,
                ],
                isPremium: true,
                isCurrentPlan: controller.isSubscribed.value,
                onSelect: controller.isSubscribed.value
                    ? null
                    : () => controller.purchaseSubscription('premium_monthly'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
