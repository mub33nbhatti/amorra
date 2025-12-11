import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/presentation/widgets/common/app_screen_header.dart';
import 'package:amorra/presentation/controllers/home/home_controller.dart';
import 'package:amorra/presentation/widgets/home/home_top_section.dart';
import 'package:amorra/presentation/widgets/home/home_chat_cta_card.dart';
import 'package:amorra/presentation/widgets/home/home_suggestions_section.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppScreenHeader(),
                  AppSpacing.vertical(context, 0.01),

                  // TopSection
                  Obx(
                    () => HomeTopSection(
                      userName: controller.userName.value,
                      greeting: controller.greeting.value,
                      introText: AppTexts.homeIntroText,
                      isLoading: controller.isUserNameLoading.value,
                    ),
                  ),
                ],
              ),
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
                    Obx(
                      () => HomeSuggestionsSection(
                        suggestions: controller.dailySuggestions.toList(),
                        onSuggestionTap: (starterMessage) => controller
                            .navigateToChat(starterMessage: starterMessage),
                        isLoading: controller.isSuggestionsLoading.value,
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
