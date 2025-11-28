import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Reusable Onboarding Page Widget
/// Displays image, title, and subtitle for each onboarding screen
class OnboardingPageWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingPageWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.asset(
            imagePath,
            width: AppResponsive.screenWidth(context) * 0.9,
            height: AppResponsive.screenHeight(context) * 0.4,
            fit: BoxFit.contain,
          ),
          
          AppSpacing.vertical(context, 0.05),
          
          // Title
          Text(
            title,
            style: AppTextStyles.headline(context).copyWith(
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 24),
            ),
            textAlign: TextAlign.center,
          ),
          
          AppSpacing.vertical(context, 0.02),
          
          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.grey,
              fontSize: AppResponsive.scaleSize(context, 14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

