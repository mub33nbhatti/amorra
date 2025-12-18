import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_lotties/app_lotties.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/presentation/widgets/common/app_screen_header.dart';
import 'package:amorra/presentation/widgets/common/app_lottie_message.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';
import 'package:amorra/presentation/widgets/profile/profile_header_card.dart';
import 'package:amorra/presentation/widgets/profile/profile_user_info_card.dart';
import 'package:amorra/presentation/widgets/profile/profile_action_buttons.dart';
import 'package:amorra/presentation/widgets/profile/profile_subscription_card.dart';
import 'package:amorra/presentation/widgets/profile/profile_safety_section.dart';
import 'package:amorra/presentation/controllers/profile/profile_controller.dart';

/// Profile Screen
/// Eye-catching profile screen with user information and account management
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: AppLoadingIndicator());
        }

        if (controller.user.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.profile_2user,
                  size: AppResponsive.iconSize(context, factor: 5),
                  color: AppColors.grey,
                ),
                AppSpacing.vertical(context, 0.02),
                Text(
                  'No user data available',
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                // Fixed Header
                Padding(
                  padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02).copyWith(bottom: 0),
                  child: const AppScreenHeader(title: AppTexts.profileTitle),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02).copyWith(top: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.vertical(context, 0.01),

                        // Profile Header Card with Gradient
                        Obx(() => ProfileHeaderCard(
                              userName: controller.userName,
                              userAge: controller.userAge,
                              isEditingName: controller.isEditingName.value,
                              nameController: controller.nameController,
                              onEditTap: controller.startEditingName,
                              onSave: controller.saveName,
                              onCancel: controller.cancelEditingName,
                            )),
                        AppSpacing.vertical(context, 0.02),

                        // User Information Card
                        ProfileUserInfoCard(
                          ageDisplayText: controller.ageDisplayText,
                          email: controller.userEmail,
                        ),
                        AppSpacing.vertical(context, 0.02),

                        // Subscription Card
                        Obx(() => ProfileSubscriptionCard(
                              isSubscribed: controller.isSubscribed,
                              remainingMessages: controller.remainingFreeMessagesReactive.value,
                              usedMessages: controller.usedMessages,
                              dailyLimit: controller.dailyLimit,
                              nextBillingDate: controller.nextBillingDate,
                              onUpgradeTap: controller.navigateToSubscription,
                              onManageTap: controller.navigateToSubscription,
                            )),
                        AppSpacing.vertical(context, 0.02),

                        // Safety Section
                        const ProfileSafetySection(),
                        AppSpacing.vertical(context, 0.02),

                        // Action Buttons
                        Obx(() => ProfileActionButtons(
                              onLogout: controller.logout,
                              onDeleteAccount: controller.deleteAccount,
                              isLogoutLoading: controller.isLogoutLoading.value,
                              isDeleteAccountLoading: controller.isDeleteAccountLoading.value,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Name Update Animation Overlay
            Obx(
              () => controller.showNameUpdateAnimation.value
                  ? AppLottieMessage(
                      lottiePath: AppLotties.completed,
                      message: AppTexts.profileNameUpdatedMessage,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
  }
}
