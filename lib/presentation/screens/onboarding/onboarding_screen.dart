import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_images/app_images.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../controllers/onboarding/onboarding_controller.dart';
import '../../widgets/common/app_dots_indicator.dart';
import '../../widgets/common/app_large_button.dart';
import '../../widgets/common/app_text_button.dart';
import '../../widgets/onboarding/onboarding_page_widget.dart';

/// Onboarding Screen
/// Displays 3 onboarding screens with swipe functionality
class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button Area (always reserves space to maintain layout)
            SizedBox(
              height: AppResponsive.screenHeight(context) * 0.08,
              child: Obx(
                () => controller.currentPage.value < controller.totalPages - 1
                    ? Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
                          child: AppTextButton(
                            text: AppTexts.skip,
                            onPressed: controller.skipOnboarding,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // PageView for onboarding pages
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                },
                children: [
                  // Screen 1
                  OnboardingPageWidget(
                    imagePath: AppImages.onboarding1,
                    title: AppTexts.onboarding1Title,
                    subtitle: AppTexts.onboarding1Subtitle,
                  ),

                  // Screen 2
                  OnboardingPageWidget(
                    imagePath: AppImages.onboarding2,
                    title: AppTexts.onboarding2Title,
                    subtitle: AppTexts.onboarding2Subtitle,
                  ),

                  // Screen 3
                  OnboardingPageWidget(
                    imagePath: AppImages.onboarding3,
                    title: AppTexts.onboarding3Title,
                    subtitle: AppTexts.onboarding3Subtitle,
                  ),
                ],
              ),
            ),

            // Page Indicator and Button
            Padding(
              padding: AppSpacing.symmetric(context, h: 0.04, v: 0.03),
              child: Column(
                children: [
                  // Page Indicator
                  Obx(
                    () => AppDotsIndicator(
                      totalPages: controller.totalPages,
                      currentPage: controller.currentPage.value,
                    ),
                  ),

                  AppSpacing.vertical(context, 0.04),

                  // Next/Get Started Button
                  Obx(
                    () => AppLargeButton(
                      text: controller.isLastPage
                          ? AppTexts.getStarted
                          : AppTexts.next,
                      onPressed: controller.nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

