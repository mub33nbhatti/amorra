import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';

/// Social Login Button Widget
class AppSocialButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? imagePath;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isLoading;

  const AppSocialButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.imagePath,
    this.iconColor,
    this.backgroundColor,
    this.isLoading = false,
  }) : assert(
         icon != null || imagePath != null,
         'Either icon or imagePath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppResponsive.screenHeight(context) * 0.05,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.white,
          foregroundColor: AppColors.black,
          side: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, factor: 1.5),
            ),
          ),
        ),
        child: isLoading
            ? Center(child: AppLoadingIndicator())
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imagePath != null)
                    Image.asset(
                      imagePath!,
                      width: AppResponsive.iconSize(context, factor: 1.2),
                      height: AppResponsive.iconSize(context, factor: 1.2),
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        if (icon != null) {
                          return Icon(
                            icon,
                            color: iconColor,
                            size: AppResponsive.iconSize(context, factor: 1.2),
                          );
                        }
                        return SizedBox(
                          width: AppResponsive.iconSize(context, factor: 1.2),
                          height: AppResponsive.iconSize(context, factor: 1.2),
                        );
                      },
                    )
                  else if (icon != null)
                    Icon(
                      icon,
                      color: iconColor,
                      size: AppResponsive.iconSize(context, factor: 1.2),
                    ),
                  AppSpacing.horizontal(context, 0.02),
                  Text(
                    text,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(color: AppColors.black),
                  ),
                ],
              ),
      ),
    );
  }
}
