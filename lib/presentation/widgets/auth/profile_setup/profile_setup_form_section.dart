import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/app_responsive/app_responsive.dart';
import '../../../../core/utils/app_spacing/app_spacing.dart';
import '../../../../core/utils/app_styles/app_text_styles.dart';

/// Profile Setup Form Section Widget
/// Wrapper for form sections with label, optional hint, and field
class ProfileSetupFormSection extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget field;
  final bool isOptional;

  const ProfileSetupFormSection({
    super.key,
    required this.label,
    this.hint,
    required this.field,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          isOptional ? '$label (Optional)' : label,
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 16),
          ),
        ),
        AppSpacing.vertical(context, 0.005),

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

