import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Home Top Section
/// Displays warm greeting with userName and time-based greeting
class HomeTopSection extends StatelessWidget {
  final String userName;
  final String greeting;
  final String introText;

  const HomeTopSection({
    super.key,
    required this.userName,
    required this.greeting,
    required this.introText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greeting with userName
        Text(
          '$greeting,',
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 18),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$userName!',
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 16),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        AppSpacing.vertical(context, 0.01),

        // Intro text
        Text(
          introText,
          style: AppTextStyles.hintText(context).copyWith(
            color: AppColors.grey,
            fontSize: AppResponsive.scaleSize(context, 12),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
