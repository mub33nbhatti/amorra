import 'package:flutter/material.dart';
import '../utils/app_colors/app_colors.dart';
import '../utils/app_fonts/app_fonts.dart';

/// App Theme Configuration
/// Contains all theme-related configurations
/// Only Light Theme - No dark theme
class AppTheme {
  /// Light theme configuration (only theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: AppFonts.secondaryFont,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: AppColors.lightText,
        ),
        displayMedium: TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: AppColors.lightText,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppFonts.secondaryFont,
          color: AppColors.lightText,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.secondaryFont,
          color: AppColors.lightText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

