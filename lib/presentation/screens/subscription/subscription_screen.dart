import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/presentation/widgets/common/app_screen_header.dart';
import 'package:amorra/presentation/widgets/subscription/subscription_plan_card.dart';
import 'package:amorra/presentation/widgets/subscription/subscription_header_section.dart';
import 'package:amorra/presentation/controllers/subscription/subscription_controller.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';

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
          return const Center(child: AppLoadingIndicator());
        }

        return Column(
          children: [
            // Fixed Header
            Padding(
              padding: AppSpacing.symmetric(
                context,
                h: 0.04,
                v: 0.02,
              ).copyWith(bottom: 0),
              child: const AppScreenHeader(title: AppTexts.subscriptionTitle),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.symmetric(
                  context,
                  h: 0.04,
                  v: 0.02,
                ).copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          : () => controller.purchaseSubscription(
                              'premium_monthly',
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
