import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_gradient/app_gradient.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';

/// Profile Setup Pill Button Widget
/// Reusable pill-shaped button for profile setup form
class ProfileSetupPillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? errorText;

  const ProfileSetupPillButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderRadius = BorderRadius.circular(
      AppResponsive.radius(context, factor: 2),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.02, v: 0.005),
        decoration: isSelected
            ? BoxDecoration(borderRadius: borderRadius).withAppGradient()
            : BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.lightGrey,
                  width: hasError ? 1.5 : 1,
                ),
                borderRadius: borderRadius,
              ),
        child: Text(
          label,
          style: AppTextStyles.bodyText(context).copyWith(
            color: isSelected ? AppColors.white : AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 14),
          ),
        ),
      ),
    );
  }
}
