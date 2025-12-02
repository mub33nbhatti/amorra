import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';

/// Home Safety Section
/// Displays safety and privacy information
class HomeSafetySection extends StatelessWidget {
  const HomeSafetySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppTexts.safetySectionTitle,
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 16),
            ),
          ),

          AppSpacing.vertical(context, 0.01),

          // Bullet Points
          _buildBulletPoint(context, AppTexts.safetyBullet1),
          AppSpacing.vertical(context, 0.005),
          _buildBulletPoint(context, AppTexts.safetyBullet2),
          AppSpacing.vertical(context, 0.005),
          _buildBulletPoint(context, AppTexts.safetyBullet3),
        ],
      ),
    );
  }

  /// Build bullet point row
  Widget _buildBulletPoint(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bullet
        Container(
          margin: EdgeInsets.only(
            top: AppResponsive.screenHeight(context) * 0.008,
            right: AppResponsive.screenWidth(context) * 0.02,
          ),
          width: AppResponsive.screenWidth(context) * 0.015,
          height: AppResponsive.screenWidth(context) * 0.015,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        // Text
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 14),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
