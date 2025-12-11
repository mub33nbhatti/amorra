import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:amorra/core/utils/app_lotties/app_lotties.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';

/// App Loading Indicator Widget
/// Reusable loading indicator using Lottie animations
class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const AppLoadingIndicator({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which lottie to use based on color
    // Default to primary if no color specified
    final lottiePath = color == AppColors.white
        ? AppLotties.loadingWhite
        : AppLotties.loadingPrimary;

    final indicatorSize = size ?? AppResponsive.iconSize(context, factor: 4);

    return SizedBox(
      width: indicatorSize,
      child: Lottie.asset(
        lottiePath,
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}

