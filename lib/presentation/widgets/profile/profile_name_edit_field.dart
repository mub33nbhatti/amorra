import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_large_button.dart';

/// Profile Name Edit Field Widget
/// Editable name field with save and cancel buttons
class ProfileNameEditField extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ProfileNameEditField({
    super.key,
    required this.nameController,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, factor: 1.5),
            ),
          ),
          child: TextField(
            controller: nameController,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 16),
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: AppSpacing.symmetric(context, h: 0.03, v: 0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppResponsive.radius(context, factor: 1.5),
                ),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
        ),
        AppSpacing.vertical(context, 0.02),
        // Buttons Row
        Row(
          children: [
            // Cancel Button
            Expanded(
              child: AppLargeButton(
                text: AppTexts.profileCancelEdit,
                onPressed: onCancel,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                textColor: AppColors.white,
              ),
            ),
            AppSpacing.horizontal(context, 0.02),
            // Save Button
            Expanded(
              child: AppLargeButton(
                text: AppTexts.profileSaveName,
                onPressed: onSave,
                backgroundColor: AppColors.white,
                textColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

