import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../base_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../core/config/routes.dart' as routes;

/// Sign In Controller
/// Handles sign in form logic and validation
class SigninController extends BaseController {
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
      showError('Please fill all fields correctly');
      return;
    }

    try {
      setLoading(true);
      
      // TODO: Implement actual sign in logic
      // await _authRepository.signInWithEmailAndPassword(
      //   email: emailController.text.trim(),
      //   password: passwordController.text,
      // );

      showSuccess('Signed in successfully!');
      
      // Navigate to main navigation screen
      Get.offAllNamed(routes.AppRoutes.mainNavigation);
      
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      setLoading(true);
      
      // TODO: Implement Google sign in
      // await _authRepository.signInWithGoogle();

      showSuccess('Signed in with Google successfully!');
      
      // Navigate to main navigation screen
      Get.offAllNamed(routes.AppRoutes.mainNavigation);
      
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Forgot password
  void forgotPassword() {
    // TODO: Navigate to forgot password screen or show dialog
    showError('Forgot password functionality coming soon');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

