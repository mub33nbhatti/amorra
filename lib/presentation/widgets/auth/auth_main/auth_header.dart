import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';

/// Auth Header Widget
/// Reusable header for auth screens containing Logo, Title, and Subtitle
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Image.asset(
          AppImages.splashLogo,
          width: AppResponsive.screenWidth(context) * 0.35,
          height: AppResponsive.screenWidth(context) * 0.35,
          fit: BoxFit.contain,
        ),

        // Title
        Text(
          title,
          style: AppTextStyles.headline(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 24),
            height: 1.3,
          ),
        ),

        // Subtitle
        Text(
          subtitle,
          style: AppTextStyles.bodyText(context).copyWith(
            color: AppColors.grey,
            fontSize: AppResponsive.scaleSize(context, 14),
            height: 1.3,
          ),
        ),
        AppSpacing.vertical(context, 0.02),
      ],
    );
  }
}
