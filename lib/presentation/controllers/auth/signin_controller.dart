import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../base_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/firebase_error_handler.dart';
import '../../../core/config/routes.dart' as routes;
import '../../../data/repositories/auth_repository.dart';

/// Sign In Controller
/// Handles sign in form logic and validation
class SigninController extends BaseController {
  // Repository
  final AuthRepository _authRepository = AuthRepository();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State
  final RxBool isPasswordVisible = false.obs;
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupValidation();
  }

  /// Setup form validation listeners
  void _setupValidation() {
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  /// Validate entire form
  void _validateForm() {
    // Check if all fields are filled (not empty)
    final emailFilled = emailController.text.trim().isNotEmpty;
    final passwordFilled = passwordController.text.isNotEmpty;
    
    isFormValid.value = emailFilled && passwordFilled;
  }

  /// Validate email
  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  /// Validate password
  String? validatePassword(String? value) {
    return Validators.validatePassword(value);
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Sign in user
  Future<void> signIn() async {
    if (!isFormValid.value) {
      showError('Oops! Something\'s missing', subtitle: 'Please fill in all fields to continue');
      return;
    }

    try {
      setLoading(true);
      
      await _authRepository.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      showSuccess('Welcome back!', subtitle: 'You\'ve successfully signed in. Let\'s get started!');
      
      // Navigate to main navigation screen
      Get.offAllNamed(routes.AppRoutes.mainNavigation);
      
    } catch (e) {
      final errorInfo = FirebaseErrorHandler.parseError(e);
      showError(errorInfo['title']!, subtitle: errorInfo['subtitle']!);
    } finally {
      setLoading(false);
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      setLoading(true);
      
      await _authRepository.signInWithGoogle();

      showSuccess('Welcome!', subtitle: 'You\'ve successfully signed in with Google. Enjoy your experience!');
      
      // Navigate to main navigation screen
      Get.offAllNamed(routes.AppRoutes.mainNavigation);
      
    } catch (e) {
      final errorInfo = FirebaseErrorHandler.parseError(e);
      showError(errorInfo['title']!, subtitle: errorInfo['subtitle']!);
    } finally {
      setLoading(false);
    }
  }

  /// Forgot password
  void forgotPassword() {
    // TODO: Navigate to forgot password screen or show dialog
    showInfo('Coming Soon', subtitle: 'Password recovery feature will be available shortly. Stay tuned!');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

