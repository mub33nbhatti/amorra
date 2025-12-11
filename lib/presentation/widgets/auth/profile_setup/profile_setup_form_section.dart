import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';

/// Profile Setup Form Section Widget
/// Wrapper for form sections with label, optional hint, and field
class ProfileSetupFormSection extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget field;

  const ProfileSetupFormSection({
    super.key,
    required this.label,
    this.hint,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 16),
          ),
        ),

        // Hint (if provided)
        if (hint != null) ...[
          Text(
            hint!,
            style: AppTextStyles.hintText(context).copyWith(
              color: AppColors.grey,
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
          ),
          AppSpacing.vertical(context, 0.01),
        ],

        // Field
        field,
      ],
    );
  }
}

