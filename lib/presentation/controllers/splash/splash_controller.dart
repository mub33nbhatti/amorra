import 'package:get/get.dart';
import 'dart:async';
import '../base_controller.dart';
import '../../../core/config/routes.dart';

/// Splash Controller
/// Handles splash screen logic and navigation
class SplashController extends BaseController {
  final RxDouble logoScale = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
    _navigateToNext();
  }

  /// Start logo animation
  void _startAnimation() {
    // Start with scale 0
    logoScale.value = 0.0;
    
    // Animate to scale 1
    Future.delayed(const Duration(milliseconds: 100), () {
      logoScale.value = 1.0;
    });
  }

  /// Navigate to next screen after delay
  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () {
      // TODO: Check if user is authenticated or has seen onboarding
      // For now, navigate to onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    });
  }
}

