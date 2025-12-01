import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_screen_header.dart';

/// Profile Screen
/// Placeholder screen for profile tab
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          const AppScreenHeader(title: AppTexts.profileTitle),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: AppResponsive.iconSize(context, factor: 5),
                    color: AppColors.primary,
                  ),
                  AppSpacing.vertical(context, 0.03),
                  Text(
                    'Profile Screen',
                    style: AppTextStyles.headline(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  AppSpacing.vertical(context, 0.01),
                  Text(
                    AppTexts.placeholderText,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

