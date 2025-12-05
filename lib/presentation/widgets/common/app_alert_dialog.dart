import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_images/app_images.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import 'app_large_button.dart';

/// App Alert Dialog Widget
/// Reusable alert dialog with logo, title, subtitle, and two action buttons
class AppAlertDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool isLoading;
  final Color? primaryButtonColor;
  final Color? primaryButtonTextColor;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.isLoading = false,
    this.primaryButtonColor,
    this.primaryButtonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
      ),
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and Title Row
            Row(
              children: [
                // App Logo
                Image.asset(
                  AppImages.splashLogo,
                  width: AppResponsive.iconSize(context, factor: 3),
                  height: AppResponsive.iconSize(context, factor: 2),
                  fit: BoxFit.contain,
                ),
                AppSpacing.horizontal(context, 0.02),
                // Title (centered in remaining space)
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headline(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: AppResponsive.scaleSize(context, 20),
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vertical(context, 0.02),

            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.grey,
                fontSize: AppResponsive.scaleSize(context, 14),
              ),
            ),
            AppSpacing.vertical(context, 0.03),

            // Action Buttons Row
            Row(
              children: [
                // Secondary Button (Cancel)
                Expanded(
                  child: AppLargeButton(
                    text: secondaryButtonText,
                    onPressed: isLoading ? null : onSecondaryPressed,
                    isLoading: false,
                    backgroundColor: AppColors.lightGrey,
                    textColor: AppColors.black,
                  ),
                ),
                AppSpacing.horizontal(context, 0.02),
                // Primary Button (Confirm)
                Expanded(
                  child: AppLargeButton(
                    text: primaryButtonText,
                    onPressed: isLoading ? null : onPrimaryPressed,
                    isLoading: isLoading,
                    backgroundColor: primaryButtonColor,
                    textColor: primaryButtonTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

