import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:amorra/presentation/controllers/auth/blocked/blocked_user_controller.dart';
import 'package:amorra/presentation/widgets/common/app_large_button.dart';

/// Blocked User Screen
/// Shown when a user's account has been blocked by an admin
class BlockedUserScreen extends GetView<BlockedUserController> {
  const BlockedUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Prevent back navigation - user must sign out
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    AppImages.splashLogo,
                    width: AppResponsive.iconSize(context, factor: 5),
                    height: AppResponsive.iconSize(context, factor: 5),
                    fit: BoxFit.contain,
                  ),
                  AppSpacing.vertical(context, 0.02),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Blocked Icon
                      Container(
                        padding: AppSpacing.all(context),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.lock,
                          size: AppResponsive.iconSize(context, factor: 1),
                          color: AppColors.error,
                        ),
                      ),
                      AppSpacing.horizontal(context, 0.02),
                      Text(
                        'Account Blocked',
                        style: AppTextStyles.headline(context).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: AppResponsive.scaleSize(context, 24),
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Message
                  Text(
                    'Your account has been temporarily blocked by an administrator.',
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.black,
                      fontSize: AppResponsive.scaleSize(context, 14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vertical(context, 0.02),

                  // Additional Info
                  Text(
                    'If you believe this is an error, please contact support.',
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.grey,
                      fontSize: AppResponsive.scaleSize(context, 12),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vertical(context, 0.04),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: AppLargeButton(
                      text: 'Sign Out',
                      onPressed: controller.signOut,
                      isLoading: controller.isSigningOut.value,
                      backgroundColor: AppColors.error,
                      textColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
