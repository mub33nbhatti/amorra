import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_large_button.dart';

/// Profile Action Buttons Widget
/// Displays logout and delete account buttons
class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final bool isLoading;

  const ProfileActionButtons({
    super.key,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logout Button
        AppLargeButton(
          text: AppTexts.profileLogoutButton,
          onPressed: onLogout,
          isLoading: isLoading,
        ),
        AppSpacing.vertical(context, 0.01),

        // Delete Account Button
        AppLargeButton(
          text: AppTexts.profileDeleteAccountButton,
          onPressed: onDeleteAccount,
          isLoading: isLoading,
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        ),
      ],
    );
  }
}

