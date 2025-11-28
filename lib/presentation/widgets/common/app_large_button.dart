import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_gradient/app_gradient.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Large Primary Button Widget with Gradient
class AppLargeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppLargeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      AppResponsive.radius(context, factor: 1.5),
    );
    final isDisabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: AppResponsive.screenHeight(context) * 0.065,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Container(
            decoration: isDisabled
                ? BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.5),
                    borderRadius: borderRadius,
                  )
                : BoxDecoration(borderRadius: borderRadius).withAppGradient(),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: AppResponsive.iconSize(context),
                      width: AppResponsive.iconSize(context),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: AppTextStyles.buttonText(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
