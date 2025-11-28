import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../base_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/firebase_error_handler.dart';
import '../../../core/config/routes.dart' as routes;
import '../../../data/repositories/auth_repository.dart';

/// Sign Up Controller
/// Handles sign up form logic and validation
class SignupController extends BaseController {
  // Repository
  final AuthRepository _authRepository = AuthRepository();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form controllers
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State
  final RxBool isPasswordVisible = false.obs;
  final RxBool isAgeVerified = false.obs;
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupValidation();
  }

  /// Setup form validation listeners
  void _setupValidation() {
    // Listen to all fields for validation
    fullnameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    
    // Listen to age verification
    ever(isAgeVerified, (_) => _validateForm());
  }

  /// Validate entire form
  void _validateForm() {
    // Check if all fields are filled (not empty)
    final fullnameFilled = fullnameController.text.trim().isNotEmpty;
    final emailFilled = emailController.text.trim().isNotEmpty;
    final passwordFilled = passwordController.text.isNotEmpty;
    
    isFormValid.value = fullnameFilled && emailFilled && passwordFilled && isAgeVerified.value;
  }

  /// Validate fullname
  String? validateFullname(String? value) {
    return Validators.validateName(value);
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

  /// Set age verification
  void setAgeVerified(bool? value) {
    if (value != null) {
      isAgeVerified.value = value;
    }
  }

  /// Sign up user
  Future<void> signUp() async {
    if (!isFormValid.value) {
      showError('Oops! Something\'s missing', subtitle: 'Please fill in all fields to create your account');
      return;
    }

    if (!isAgeVerified.value) {
      showError('Age Verification Required', subtitle: 'You must be 18 years or older to create an account');
      return;
    }

    try {
      setLoading(true);
      
      await _authRepository.signUpWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: fullnameController.text.trim(),
      );

      showSuccess('Account Created!', subtitle: 'Welcome to Amorra! Your account has been created successfully.');
      
      // Navigate to main navigation screen
      Get.offAllNamed(routes.AppRoutes.mainNavigation);
      
    } catch (e) {
      final errorInfo = FirebaseErrorHandler.parseError(e);
      showError(errorInfo['title']!, subtitle: errorInfo['subtitle']!);
    } finally {
      setLoading(false);
    }
  }

  /// Sign up with Google
  Future<void> signUpWithGoogle() async {
    try {
      setLoading(true);
      
      await _authRepository.signInWithGoogle();

      showSuccess('Welcome to Amorra!', subtitle: 'Your account has been created with Google. Let\'s get started!');
      
      // Navigate to main navigation screen
      Get.offAllNamed(routes.AppRoutes.mainNavigation);
      
    } catch (e) {
      final errorInfo = FirebaseErrorHandler.parseError(e);
      showError(errorInfo['title']!, subtitle: errorInfo['subtitle']!);
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

