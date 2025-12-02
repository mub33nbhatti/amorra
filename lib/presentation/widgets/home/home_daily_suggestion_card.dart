import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../../data/models/daily_suggestion_model.dart';
import '../../widgets/common/app_text_button.dart';

/// Home Daily Suggestion Card
/// Individual suggestion card with title, description, and button
class HomeDailySuggestionCard extends StatelessWidget {
  final DailySuggestionModel suggestion;
  final VoidCallback onTap;

  const HomeDailySuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: AppResponsive.screenHeight(context) * 0.01,
      ),
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
          // Title
          Text(
            suggestion.title,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 16),
            ),
          ),

          // Description
          Text(
            suggestion.description,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.grey,
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
          ),

          AppSpacing.vertical(context, 0.005),

          // Button
          Align(
            alignment: Alignment.centerRight,
            child: AppTextButton(
              text: AppTexts.suggestionButtonText,
              onPressed: onTap,
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
          ),
        ],
      ),
    );
  }
}
