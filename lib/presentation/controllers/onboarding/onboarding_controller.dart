import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../base_controller.dart';
import '../../../core/config/routes.dart';

/// Onboarding Controller
/// Handles onboarding screen logic and navigation
class OnboardingController extends BaseController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final int totalPages = 3;

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
      navigateToSignIn();
    }
  }

  /// Navigate to sign in screen
  void navigateToSignIn() {
    Get.offAllNamed(AppRoutes.signin);
  }

  /// Skip onboarding and go to sign in
  void skipOnboarding() {
    navigateToSignIn();
  }

  /// Check if current page is last page
  bool get isLastPage => currentPage.value == totalPages - 1;
}

