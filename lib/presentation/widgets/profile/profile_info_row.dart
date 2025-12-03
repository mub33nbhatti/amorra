import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Profile Info Row Widget
/// Reusable widget for displaying icon, label, and value
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.all(context),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, factor: 1.5),
            ),
          ),
          child: Icon(
            icon,
            size: AppResponsive.iconSize(context, factor: 1.2),
            color: AppColors.primary,
          ),
        ),
        AppSpacing.horizontal(context, 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.black,
                  fontSize: AppResponsive.scaleSize(context, 12),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.black,
                  fontSize: AppResponsive.scaleSize(context, 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

