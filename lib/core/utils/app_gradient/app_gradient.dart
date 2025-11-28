import 'package:flutter/material.dart';
import '../app_colors/app_colors.dart';

/// App Gradient Extension
/// Provides reusable gradient decoration extension
extension AppGradientExtension on BoxDecoration {
  /// Apply app gradient to BoxDecoration
  /// Returns a new BoxDecoration with gradient from primary to secondary color
  BoxDecoration withAppGradient() {
    return copyWith(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.secondary,
        ],
      ),
    );
  }
}
