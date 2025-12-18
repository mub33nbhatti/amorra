import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../base_controller.dart';
import 'package:amorra/core/config/routes.dart';
import 'package:amorra/core/constants/app_constants.dart';
import 'package:amorra/data/repositories/auth_repository.dart';
import 'package:amorra/data/services/firebase_service.dart';

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
          // User is authenticated, first check if user is blocked
          if (kDebugMode) {
            print('✅ User authenticated, checking if user is blocked');
          }
          
          // Get user data to check isBlocked status
          final userModel = await _authRepository.getCurrentUser();
          
          if (userModel != null && userModel.isBlocked) {
            // User is blocked, navigate to blocked user screen
            if (kDebugMode) {
              print('🚫 User is blocked, navigating to blocked user screen');
            }
            Get.offAllNamed(AppRoutes.blockedUser);
            return;
          }
          
          // User is not blocked, check age verification
          if (kDebugMode) {
            print('✅ User not blocked, checking age verification');
          }
          
          final verificationStatus = await _authRepository.getAgeVerificationStatus(currentUser.uid);
          
          if (verificationStatus != null && verificationStatus['isAgeVerified'] == true) {
            // User is verified, check profile setup status
            final isProfileSetupCompleted = await _authRepository.getProfileSetupStatus(currentUser.uid);
            
            if (isProfileSetupCompleted) {
              // Profile setup completed, check onboarding status
              final onboardingCompleted = _storage.read<bool>(AppConstants.storageKeyOnboardingCompleted) ?? false;
              
              if (onboardingCompleted) {
                // Onboarding completed, navigate to main
                if (kDebugMode) {
                  print('✅ User age verified, profile setup and onboarding completed, navigating to main');
                }
                Get.offAllNamed(AppRoutes.mainNavigation);
              } else {
                // Onboarding not completed, navigate to onboarding
                if (kDebugMode) {
                  print('⚠️ User age verified and profile setup completed but onboarding not completed, navigating to onboarding');
                }
                Get.offAllNamed(AppRoutes.onboarding);
              }
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
          // User not authenticated, navigate to signin
          // Onboarding will be shown after profile setup
          if (kDebugMode) {
            print('👤 User not authenticated, navigating to signin');
          }
          Get.offAllNamed(AppRoutes.signin);
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error checking auth/verification status: $e');
        }
        // On error, navigate to signin (onboarding moved after profile setup)
        Get.offAllNamed(AppRoutes.signin);
      }
    });
  }
}

