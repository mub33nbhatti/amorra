import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import 'profile_info_row.dart';

/// Profile User Info Card Widget
/// Displays user information (age and email) in a card
class ProfileUserInfoCard extends StatelessWidget {
  final String ageDisplayText;
  final String email;

  const ProfileUserInfoCard({
    super.key,
    required this.ageDisplayText,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age Section
          ProfileInfoRow(
            icon: Iconsax.calendar,
            label: AppTexts.profileAgeLabel,
            value: ageDisplayText,
          ),
          Divider(
            height: AppResponsive.screenHeight(context) * 0.03,
            color: AppColors.lightGrey,
          ),

          // Email Section
          ProfileInfoRow(
            icon: Iconsax.sms,
            label: AppTexts.profileEmailLabel,
            value: email,
          ),
        ],
      ),
    );
  }
}

