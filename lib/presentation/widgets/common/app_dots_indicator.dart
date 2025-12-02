import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';

/// Reusable Dots Indicator Widget
/// Shows page indicators with animated dots
class AppDotsIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? dotSize;
  final double? activeDotWidth;
  final Duration animationDuration;

  const AppDotsIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
    this.dotSize,
    this.activeDotWidth,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final double defaultDotSize = AppResponsive.screenWidth(context) * 0.02;
    final double defaultActiveWidth = AppResponsive.screenWidth(context) * 0.08;
    final double dotSizeValue = dotSize ?? defaultDotSize;
    final double activeWidthValue = activeDotWidth ?? defaultActiveWidth;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(
            horizontal: AppResponsive.screenWidth(context) * 0.01,
          ),
          width: currentPage == index ? activeWidthValue : dotSizeValue,
          height: dotSizeValue,
          decoration: BoxDecoration(
            color: currentPage == index
                ? (activeColor ?? AppColors.primary)
                : (inactiveColor ?? AppColors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, factor: 1),
            ),
          ),
        ),
      ),
    );
  }
}

