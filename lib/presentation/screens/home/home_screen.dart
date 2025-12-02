import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_screen_header.dart';
import '../../controllers/home/home_controller.dart';
import '../../widgets/home/home_top_section.dart';
import '../../widgets/home/home_chat_cta_card.dart';
import '../../widgets/home/home_suggestions_section.dart';
import '../../widgets/home/home_subscription_usage_card.dart';
import '../../widgets/home/home_safety_section.dart';

/// Home Screen
/// Main home screen with greeting, chat CTA, suggestions, and safety info
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppScreenHeader(),
              AppSpacing.vertical(context, 0.01),

              // TopSection
              HomeTopSection(
                userName: controller.userName.value,
                greeting: controller.greeting.value,
                introText: AppTexts.homeIntroText,
              ),

              AppSpacing.vertical(context, 0.02),

              // ChatCtaCard
              HomeChatCtaCard(
                hasActiveChat: controller.hasActiveChat.value,
                lastMessageSnippet: controller.lastMessage.value?.message,
                lastMessageTime: controller.lastMessage.value?.timestamp,
                onTap: () => controller.navigateToChat(),
              ),

              AppSpacing.vertical(context, 0.02),

              // SuggestionsSection
              HomeSuggestionsSection(
                suggestions: controller.dailySuggestions,
                onSuggestionTap: (starterMessage) =>
                    controller.navigateToChat(starterMessage: starterMessage),
              ),

              AppSpacing.vertical(context, 0.02),

              // Subscription Usage Card
              HomeSubscriptionUsageCard(
                isSubscribed: controller.isSubscribed,
                remainingMessages: controller.remainingFreeMessages,
                usedMessages: controller.usedMessages,
                dailyLimit: controller.dailyLimit,
                nextBillingDate: controller.nextBillingDate,
                onUpgradeTap: () => controller.navigateToSubscription(),
                onManageTap: () => controller.navigateToSubscription(),
              ),

              AppSpacing.vertical(context, 0.02),

              // SafetySection
              HomeSafetySection(),

              AppSpacing.vertical(context, 0.04), // Bottom padding
            ],
          ),
        );
      }),
    );
  }
}
