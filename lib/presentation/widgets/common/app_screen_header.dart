import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_images/app_images.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// App Screen Header Widget
/// Reusable header widget for screens with consistent styling
/// 
/// - For home screen: Pass null or empty title to show logo
/// - For other screens: Pass the screen title to display
/// - Has default values for all optional parameters
class AppScreenHeader extends StatelessWidget {
  final String? title;
  final double? logoWidth;
  final double? logoHeight;
  final List<Widget>? actions;
  final Widget? leading;

  const AppScreenHeader({
    super.key,
    this.title,
    this.logoWidth,
    this.logoHeight,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.lightBackground,
        padding: AppSpacing.symmetric(context, h: 0.02, v: 0.02),
        child: Row(
          children: [
            if (leading != null) leading!,
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: title == null || title!.isEmpty
                    ? Image.asset(
                        AppImages.splashLogo,
                        width: logoWidth ?? AppResponsive.iconSize(context, factor: 3),
                        height: logoHeight,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        title!,
                        style: AppTextStyles.headline(context).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: AppResponsive.scaleSize(context, 20),
                          color: AppColors.black,
                        ),
                      ),
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              ...actions!,
          ],
        ),
      ),
    );
  }
}

