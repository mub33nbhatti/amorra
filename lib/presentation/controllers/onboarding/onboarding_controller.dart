import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import '../base_controller.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/firebase_service.dart';

/// Onboarding Controller
/// Handles onboarding screen logic and navigation
class OnboardingController extends BaseController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final int totalPages = 3;
  final _storage = GetStorage();
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(_onPageChanged);
  }

  @override
  void onClose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.onClose();
  }

  /// Handle page change
  void _onPageChanged() {
    if (pageController.page != null) {
      currentPage.value = pageController.page!.round();
    }
  }

  /// Navigate to next page
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Complete onboarding and navigate to sign in
  Future<void> _completeOnboarding() async {
    try {
      // Save onboarding completion to local storage
      await _storage.write(AppConstants.storageKeyOnboardingCompleted, true);

      // If user is authenticated, also save to Firestore
      final currentUser = _firebaseService.currentUser;
      if (currentUser != null) {
        try {
          await _authRepository.updateOnboardingCompletion(currentUser.uid);
          if (kDebugMode) {
            print('✅ Onboarding completion saved to Firestore');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to save onboarding to Firestore: $e');
          }
          // Continue anyway, local storage is saved
        }
      }

      if (kDebugMode) {
        print('✅ Onboarding completed, navigating to signin');
      }

      navigateToSignIn();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error completing onboarding: $e');
      }
      // Navigate anyway
      navigateToSignIn();
    }
  }

  /// Navigate to sign in screen
  void navigateToSignIn() {
    Get.offAllNamed(AppRoutes.signin);
  }

  /// Skip onboarding and go to sign in
  void skipOnboarding() {
    _completeOnboarding();
  }

  /// Check if current page is last page
  bool get isLastPage => currentPage.value == totalPages - 1;
}

