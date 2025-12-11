import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import '../../widgets/common/app_large_button.dart';

/// Profile Action Buttons Widget
/// Displays logout and delete account buttons
class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final bool isLogoutLoading;
  final bool isDeleteAccountLoading;

  const ProfileActionButtons({
    super.key,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.isLogoutLoading,
    required this.isDeleteAccountLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logout Button
        AppLargeButton(
          text: AppTexts.profileLogoutButton,
          onPressed: onLogout,
          isLoading: isLogoutLoading,
        ),
        AppSpacing.vertical(context, 0.01),

        // Delete Account Button
        AppLargeButton(
          text: AppTexts.profileDeleteAccountButton,
          onPressed: onDeleteAccount,
          isLoading: isDeleteAccountLoading,
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        ),
      ],
    );
  }
}

