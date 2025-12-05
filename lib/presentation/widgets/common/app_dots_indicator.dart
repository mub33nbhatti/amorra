import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';

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
  final bool fullWidth;
  final double? height;

  const AppDotsIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
    this.dotSize,
    this.activeDotWidth,
    this.animationDuration = const Duration(milliseconds: 300),
    this.fullWidth = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double margin = AppResponsive.screenWidth(context) * 0.01;
    final double radius = AppResponsive.radius(context, factor: 1);

    Widget indicator = Row(
      mainAxisAlignment: fullWidth
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => _buildDot(context, index, margin, radius),
      ),
    );

    return fullWidth
        ? Padding(
            padding: AppSpacing.symmetric(
              context,
              h: 0.04,
              v: 0.02,
            ).copyWith(bottom: 0),
            child: indicator,
          )
        : indicator;
  }

  Widget _buildDot(
    BuildContext context,
    int index,
    double margin,
    double radius,
  ) {
    final bool isActive = fullWidth
        ? index < currentPage
        : currentPage == index;
    final Color color = _getColor(isActive);

    final container = AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: margin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      width: fullWidth
          ? null
          : (isActive
                ? (activeDotWidth ?? AppResponsive.screenWidth(context) * 0.08)
                : (dotSize ?? AppResponsive.screenWidth(context) * 0.02)),
      height: fullWidth
          ? (height ?? 6.0)
          : (dotSize ?? AppResponsive.screenWidth(context) * 0.02),
    );

    return fullWidth ? Expanded(child: container) : container;
  }

  Color _getColor(bool isActive) {
    if (isActive) return activeColor ?? AppColors.primary;
    if (inactiveColor != null) return inactiveColor!;
    return fullWidth ? AppColors.black : AppColors.grey.withValues(alpha: 0.3);
  }
}
