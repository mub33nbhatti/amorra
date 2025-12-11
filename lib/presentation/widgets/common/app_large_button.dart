import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_gradient/app_gradient.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';

/// Large Primary Button Widget with Gradient
class AppLargeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const AppLargeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      AppResponsive.radius(context, factor: 1.5),
    );
    final isDisabled = onPressed == null;

    // Build decoration
    final decoration = isDisabled
        ? BoxDecoration(
            color: AppColors.grey.withValues(alpha: 0.5),
            borderRadius: borderRadius,
          )
        : backgroundColor != null
            ? BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              )
            : BoxDecoration(borderRadius: borderRadius).withAppGradient();

    // Determine text color
    final finalTextColor = textColor ??
        (backgroundColor != null ? AppColors.primary : AppColors.white);

    return SizedBox(
      width: double.infinity,
      height: AppResponsive.screenHeight(context) * 0.05,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Container(
            decoration: decoration,
            child: Center(
              child: isLoading
                  ? AppLoadingIndicator(
                      color: finalTextColor,
                    )
                  : Text(
                      text,
                      style: AppTextStyles.buttonText(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: finalTextColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
