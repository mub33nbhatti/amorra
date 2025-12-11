import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import '../../../data/models/daily_suggestion_model.dart';
import 'home_daily_suggestion_card.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';

/// Home Suggestions Section
/// Displays list of daily suggestions
class HomeSuggestionsSection extends StatelessWidget {
  final List<DailySuggestionModel> suggestions;
  final Function(String starterMessage) onSuggestionTap;
  final bool isLoading;

  const HomeSuggestionsSection({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          AppTexts.suggestionsSectionTitle,
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 16),
          ),
          textAlign: TextAlign.left,
        ),

        AppSpacing.vertical(context, 0.01),

        // Loading indicator or Suggestions List
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: AppLoadingIndicator(),
            ),
          )
        else
          ...suggestions.map(
            (suggestion) => HomeDailySuggestionCard(
              suggestion: suggestion,
              onTap: () => onSuggestionTap(suggestion.starterMessage),
            ),
          ),
      ],
    );
  }
}
