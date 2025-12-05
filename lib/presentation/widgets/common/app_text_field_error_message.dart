import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// App Text Field Error Message Widget
/// Reusable error message widget matching AppTextField error style
class AppTextFieldErrorMessage extends StatelessWidget {
  final String errorText;

  const AppTextFieldErrorMessage({
    super.key,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (errorText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: AppResponsive.screenHeight(context) * 0.008,
        left: AppResponsive.screenWidth(context) * 0.01,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppResponsive.scaleSize(context, 2),
            ),
            child: Icon(
              Iconsax.info_circle,
              size: AppResponsive.scaleSize(context, 14),
              color: AppColors.error,
            ),
          ),
          AppSpacing.horizontal(context, 0.01),
          Expanded(
            child: Text(
              errorText,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.error,
                fontSize: AppResponsive.scaleSize(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

