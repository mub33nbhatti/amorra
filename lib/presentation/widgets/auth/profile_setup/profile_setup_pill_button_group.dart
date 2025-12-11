import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/presentation/widgets/auth/profile_setup/profile_setup_pill_button.dart';

/// Profile Setup Pill Button Group Widget
/// Displays multiple pill buttons in a wrap layout
class ProfileSetupPillButtonGroup extends StatelessWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(String?)? onSelect;
  final String? errorText;

  const ProfileSetupPillButtonGroup({
    super.key,
    required this.options,
    required this.selectedOptions,
    this.onSelect,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.02, v: 0.01),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError ? AppColors.error : AppColors.lightGrey,
            width: hasError ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
        ),
        child: Wrap(
        spacing: AppResponsive.screenWidth(context) * 0.01,
        runSpacing: AppResponsive.screenHeight(context) * 0.005,
        children: options.map((option) {
          final isSelected = selectedOptions.contains(option);
          return ProfileSetupPillButton(
            label: option,
            isSelected: isSelected,
            onTap: () {
              // Always pass the option - controller will handle toggle logic
              if (onSelect != null) {
                onSelect!(option);
              }
            },
            errorText: hasError ? errorText : null,
          );
        }).toList(),
        ),
      ),
    );
  }
}

