import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Reusable Text Field Widget
class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTogglePassword;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: AppTextStyles.bodyText(context).copyWith(
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.hintText(context).copyWith(
              color: AppColors.grey,
            ),
            suffixIcon: showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      obscureText ? Iconsax.eye_slash : Iconsax.eye,
                      color: AppColors.grey,
                      size: AppResponsive.iconSize(context),
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            contentPadding: AppSpacing.symmetric(context, h: 0.03, v: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

