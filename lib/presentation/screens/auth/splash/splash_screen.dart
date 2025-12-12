import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/presentation/controllers/splash/splash_controller.dart';

/// Splash Screen
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: AnimatedScale(
          scale: controller.logoScale.value,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
          child: Image.asset(
            AppImages.splashLogo,
            width: AppResponsive.screenWidth(context) * 0.4,
            height: AppResponsive.screenWidth(context) * 0.4,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

