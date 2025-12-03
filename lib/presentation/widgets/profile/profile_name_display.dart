import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Profile Name Display Widget
/// Displays user name with edit button
class ProfileNameDisplay extends StatelessWidget {
  final String userName;
  final VoidCallback onEditTap;

  const ProfileNameDisplay({
    super.key,
    required this.userName,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            userName,
            style: AppTextStyles.headline(context).copyWith(
              color: AppColors.white,
              fontSize: AppResponsive.scaleSize(context, 24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppSpacing.horizontal(context, 0.02),
        GestureDetector(
          onTap: onEditTap,
          child: Container(
            padding: EdgeInsets.all(AppResponsive.screenWidth(context) * 0.02),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.edit_2,
              size: AppResponsive.iconSize(context),
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

