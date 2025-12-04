import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../base_controller.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/firebase_service.dart';

/// Splash Controller
/// Handles splash screen logic and navigation
class SplashController extends BaseController {
  final RxDouble logoScale = 0.0.obs;
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseService _firebaseService = FirebaseService();
  final _storage = GetStorage();

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
  void _navigateToNext() async {
    Timer(const Duration(seconds: 3), () async {
      try {
        // Check if user is authenticated
        final currentUser = _firebaseService.currentUser;
        
        if (currentUser != null) {
          // User is authenticated, check age verification
          if (kDebugMode) {
            print('✅ User authenticated, checking age verification');
          }
          
          final verificationStatus = await _authRepository.getAgeVerificationStatus(currentUser.uid);
          
          if (verificationStatus != null && verificationStatus['isAgeVerified'] == true) {
            // User is verified, check profile setup status
            final isProfileSetupCompleted = await _authRepository.getProfileSetupStatus(currentUser.uid);
            
            if (isProfileSetupCompleted) {
              // Profile setup completed, navigate to main
              if (kDebugMode) {
                print('✅ User age verified and profile setup completed, navigating to main');
              }
              Get.offAllNamed(AppRoutes.mainNavigation);
            } else {
              // Profile setup not completed, navigate to profile setup
              if (kDebugMode) {
                print('⚠️ User age verified but profile setup not completed, navigating to profile setup');
              }
              Get.offAllNamed(AppRoutes.profileSetup);
            }
          } else {
            // User not verified, navigate to age verification
            if (kDebugMode) {
              print('⚠️ User not age verified, navigating to age verification');
            }
            Get.offAllNamed(AppRoutes.ageVerification);
          }
        } else {
          // User not authenticated, check onboarding completion status
          final onboardingCompleted = _storage.read<bool>(AppConstants.storageKeyOnboardingCompleted) ?? false;
          
          if (onboardingCompleted) {
            // Onboarding already completed, navigate to signin
            if (kDebugMode) {
              print('📚 Onboarding completed, navigating to signin');
            }
            Get.offAllNamed(AppRoutes.signin);
          } else {
            // Onboarding not completed, navigate to onboarding
            if (kDebugMode) {
              print('👤 First time user, navigating to onboarding');
            }
            Get.offAllNamed(AppRoutes.onboarding);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error checking auth/verification status: $e');
        }
        // On error, check local storage for onboarding
        final onboardingCompleted = _storage.read<bool>(AppConstants.storageKeyOnboardingCompleted) ?? false;
        if (onboardingCompleted) {
          Get.offAllNamed(AppRoutes.signin);
        } else {
          Get.offAllNamed(AppRoutes.onboarding);
        }
      }
    });
  }
}

