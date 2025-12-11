import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/core/utils/app_lotties/app_lotties.dart';
import 'package:amorra/presentation/widgets/auth/profile_setup/profile_setup_form_content.dart';
import 'package:amorra/presentation/widgets/common/app_lottie_message.dart';
import 'package:amorra/presentation/controllers/auth/profile_setup/profile_setup_controller.dart';

/// Profile Setup Bottom Sheet Widget
/// Reusable bottom sheet for updating profile preferences
class ProfileSetupBottomSheet extends GetView<ProfileSetupController> {
  const ProfileSetupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppResponsive.radius(context, factor: 2)),
              ),
            ),
            child: Column(
              children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(
                top: AppResponsive.screenHeight(context) * 0.01,
                bottom: AppResponsive.screenHeight(context) * 0.01,
              ),
              width: AppResponsive.screenWidth(context) * 0.15,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with title, subtitle, and close button
            Padding(
              padding: AppSpacing.symmetric(
                context,
                h: 0.04,
                v: 0.02,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.profileSetupUpdateTitle,
                          style: AppTextStyles.headline(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontSize: AppResponsive.scaleSize(context, 24),
                            height: 1.3
                          ),
                        ),
                        AppSpacing.vertical(context, 0.005),
                        Text(
                          AppTexts.profileSetupUpdateSubtitle,
                          style: AppTextStyles.bodyText(context).copyWith(
                            color: AppColors.grey,
                            fontSize: AppResponsive.scaleSize(context, 14),
                            height: 1.3
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  IconButton(
                    icon: Icon(
                      Iconsax.close_circle,
                      color: AppColors.black,
                      size: AppResponsive.iconSize(context, factor: 1.5),
                    ),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

                // Form content
                Expanded(child: ProfileSetupFormContent(showSaveButton: true)),
              ],
            ),
          ),
          // Lottie Animation Overlay
          Obx(
            () => controller.showUpdateAnimation.value
                ? AppLottieMessage(
                    lottiePath: AppLotties.completed,
                    message: AppTexts.profilePreferencesUpdatedMessage,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
