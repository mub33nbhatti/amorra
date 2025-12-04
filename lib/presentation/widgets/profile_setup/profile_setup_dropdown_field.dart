import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Profile Setup Dropdown Field Widget
/// Reusable dropdown field for profile setup form
class ProfileSetupDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String hint;

  const ProfileSetupDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hintText(context).copyWith(
            color: AppColors.grey,
          ),
          contentPadding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: AppTextStyles.bodyText(context).copyWith(
          color: AppColors.black,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.grey,
          size: AppResponsive.iconSize(context),
        ),
      ),
    );
  }
}

