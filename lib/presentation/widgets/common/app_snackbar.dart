import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_images/app_images.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Snackbar Type Enum
enum AppSnackbarType { error, success, info, warning }

/// Reusable Snackbar Widget
class AppSnackbar extends StatelessWidget {
  final String title;
  final String subtitle;
  final AppSnackbarType type;
  final VoidCallback? onClose;

  const AppSnackbar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
    this.onClose,
  });

  /// Get border color based on type
  Color get _borderColor {
    switch (type) {
      case AppSnackbarType.error:
        return AppColors.error;
      case AppSnackbarType.success:
        return AppColors.success;
      case AppSnackbarType.info:
        return AppColors.information;
      case AppSnackbarType.warning:
        return AppColors.warning;
    }
  }

  /// Get cross icon color based on type
  Color get _iconColor {
    switch (type) {
      case AppSnackbarType.error:
        return AppColors.error;
      case AppSnackbarType.success:
        return AppColors.success;
      case AppSnackbarType.info:
        return AppColors.information;
      case AppSnackbarType.warning:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.02, v: 0.01),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
        border: Border.all(color: _borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: _borderColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App Logo
          Image.asset(
            AppImages.splashLogo,
            width: AppResponsive.screenWidth(context) * 0.1,
            height: AppResponsive.screenWidth(context) * 0.1,
            fit: BoxFit.contain,
          ),
          AppSpacing.horizontal(context, 0.03),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontSize: AppResponsive.scaleSize(context, 14),
                  ),
                ),
                AppSpacing.vertical(context, 0.005),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.grey,
                    fontSize: AppResponsive.scaleSize(context, 12),
                  ),
                ),
              ],
            ),
          ),

          // Cross Icon
          IconButton(
            icon: Icon(
              Iconsax.close_circle,
              color: _iconColor,
              size: AppResponsive.iconSize(context),
            ),
            onPressed: onClose ?? () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showError({
    required String title,
    required String subtitle,
    Duration? duration,
    BuildContext? context,
  }) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: AppSnackbar(
        title: title,
        subtitle: subtitle,
        type: AppSnackbarType.error,
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.screenWidth(ctx) * 0.04,
        vertical: AppResponsive.screenHeight(ctx) * 0.02,
      ),
      padding: EdgeInsets.zero,
    );
  }

  /// Show success snackbar
  static void showSuccess({
    required String title,
    required String subtitle,
    Duration? duration,
    BuildContext? context,
  }) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: AppSnackbar(
        title: title,
        subtitle: subtitle,
        type: AppSnackbarType.success,
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: duration ?? const Duration(seconds: 2),
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.screenWidth(ctx) * 0.04,
        vertical: AppResponsive.screenHeight(ctx) * 0.02,
      ),
      padding: EdgeInsets.zero,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required String title,
    required String subtitle,
    Duration? duration,
    BuildContext? context,
  }) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: AppSnackbar(
        title: title,
        subtitle: subtitle,
        type: AppSnackbarType.info,
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.screenWidth(ctx) * 0.04,
        vertical: AppResponsive.screenHeight(ctx) * 0.02,
      ),
      padding: EdgeInsets.zero,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required String title,
    required String subtitle,
    Duration? duration,
    BuildContext? context,
  }) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: AppSnackbar(
        title: title,
        subtitle: subtitle,
        type: AppSnackbarType.warning,
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.screenWidth(ctx) * 0.04,
        vertical: AppResponsive.screenHeight(ctx) * 0.02,
      ),
      padding: EdgeInsets.zero,
    );
  }
}
