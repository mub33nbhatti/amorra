import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Reusable Text Button Widget
/// Used for text-based buttons like Skip, etc.
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: AppTextStyles.buttonText(context).copyWith(
          color: textColor ?? AppColors.secondary,
          fontSize: fontSize ?? AppResponsive.scaleSize(context, 16),
          fontWeight: fontWeight ?? FontWeight.w600,
        ),
      ),
    );
  }
}
