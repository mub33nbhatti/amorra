import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/app_responsive/app_responsive.dart';
import '../../../../core/utils/app_spacing/app_spacing.dart';
import '../../../../core/utils/app_styles/app_text_styles.dart';
import '../../../../core/utils/app_texts/app_texts.dart';

/// Age Display Widget
/// Displays calculated age with validation styling
class AgeDisplay extends StatelessWidget {
  final int age;
  final bool isValidAge;

  const AgeDisplay({
    super.key,
    required this.age,
    required this.isValidAge,
  });

  @override
  Widget build(BuildContext context) {
    final hasAge = age > 0;
    
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.03, v: 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
        border: Border.all(
          color: hasAge 
              ? (isValidAge ? AppColors.lightGrey : AppColors.error)
              : AppColors.lightGrey,
          width: hasAge && !isValidAge ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            '${AppTexts.ageLabel}: ',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 16),
            ),
          ),
          Text(
            hasAge ? '$age ${AppTexts.ageYears}' : '--',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.bold,
              color: hasAge
                  ? (isValidAge ? AppColors.primary : AppColors.error)
                  : AppColors.grey,
              fontSize: AppResponsive.scaleSize(context, 16),
            ),
          ),
        ],
      ),
    );
  }
}

