import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../base_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/firebase_error_handler.dart';
import '../../../core/config/routes.dart' as routes;
import '../../../data/repositories/auth_repository.dart';

/// Sign Up Controller
/// Handles sign up form logic and validation
class SignupController extends BaseController {
  // Repository - use Get.find to reuse existing instance
  AuthRepository get _authRepository => Get.find<AuthRepository>();

  // Form key - unique instance
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form controllers
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State
  final RxBool isPasswordVisible = false.obs;
  final RxBool isAgeVerified = false.obs;
  final RxBool isFormValid = false.obs;
  final RxBool isFromGoogle = false.obs;

  // Track if disposed
  bool _isDisposed = false;

  // Track if navigating
  bool _isNavigating = false;

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;
    _isNavigating = false;
    _setupValidation();
    _loadArguments();
  }

  /// Load route arguments
  void _loadArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      // Pre-fill email from Google
      if (arguments['email'] != null) {
        emailController.text = arguments['email'].toString();
      }

      // Pre-fill name from Google
      if (arguments['displayName'] != null &&
          arguments['displayName'].toString().isNotEmpty) {
        fullnameController.text = arguments['displayName'].toString();
      }

      // Check if coming from Google sign-in
      if (arguments['fromGoogle'] != null) {
        isFromGoogle.value = arguments['fromGoogle'] as bool;
        if (kDebugMode) {
          print('📱 Signup from Google: ${isFromGoogle.value}');
        }
      }

      // Validate after loading arguments
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && Get.isRegistered<SignupController>()) {
          try {
            validateForm();
          } catch (e) {
            if (kDebugMode && !_isDisposed) {
              print('Error validating form: $e');
            }
          }
        }
      });
    }
  }

  /// Setup form validation listeners
  void _setupValidation() {
    fullnameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);

    ever(isAgeVerified, (_) {
      if (!_isDisposed) {
        _validateForm();
      }
    });
  }

  /// Validate entire form
  void validateForm() {
    if (_isDisposed) return;

    final fullnameFilled = fullnameController.text.trim().isNotEmpty;
    final emailFilled = emailController.text.trim().isNotEmpty;
    final passwordFilled = passwordController.text.isNotEmpty;

    isFormValid.value = fullnameFilled &&
        emailFilled &&
        passwordFilled &&
        isAgeVerified.value;
  }

  /// Private validate form
  void _validateForm() {
    if (_isDisposed) return;
    validateForm();
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
    if (_isDisposed) return;
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Set age verification
  void setAgeVerified(bool? value) {
    if (_isDisposed) return;
    if (value != null) {
      isAgeVerified.value = value;
    }
  }

  /// Sign up user
  Future<void> signUp() async {
    if (_isDisposed || _isNavigating) return;

    if (!isFormValid.value) {
      showError('Oops! Something\'s missing',
          subtitle: 'Please fill in all fields to create your account');
      return;
    }

    if (!isAgeVerified.value) {
      showError('Age Verification Required',
          subtitle: 'You must be 18 years or older to create an account');
      return;
    }

    try {
      setLoading(true);

      // Unfocus to dismiss keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      if (kDebugMode) {
        print('🚀 Starting signup - fromGoogle: ${isFromGoogle.value}');
      }

      // Create account (will automatically link Google if credential exists)
      await _authRepository.signUpWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: fullnameController.text.trim(),
      );

      if (_isDisposed || _isNavigating) return;

      if (isFromGoogle.value) {
        // Coming from Google sign-in, show success and navigate to main
        showSuccess('Welcome to Amorra!',
            subtitle: 'Your account has been created with Google. Both email and Google sign-in are now available!');

        _isNavigating = true;

        // Wait for UI to settle
        await Future.delayed(const Duration(milliseconds: 300));

        if (!_isDisposed) {
          Get.offAllNamed(routes.AppRoutes.mainNavigation);
        }
      } else {
        // Regular signup, navigate to signin
        showSuccess('Account Created!',
            subtitle: 'Your account has been created. Please sign in to continue.');

        _isNavigating = true;

        // Wait for UI to settle
        await Future.delayed(const Duration(milliseconds: 300));

        if (!_isDisposed) {
          Get.offAllNamed(routes.AppRoutes.signin);
        }
      }

    } catch (e) {
      if (_isDisposed) return;
      final errorInfo = FirebaseErrorHandler.parseError(e);
      showError(errorInfo['title']!, subtitle: errorInfo['subtitle']!);
      _isNavigating = false;
    } finally {
      if (!_isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Sign up with Google (direct Google signup without email/password)
  Future<void> signUpWithGoogle() async {
    if (_isDisposed || _isNavigating) return;

    try {
      setLoading(true);

      // Unfocus to dismiss keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      await _authRepository.signInWithGoogle();

      if (_isDisposed || _isNavigating) return;

      showSuccess('Welcome to Amorra!',
          subtitle: 'Your account has been created with Google. Let\'s get started!');

      _isNavigating = true;

      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_isDisposed) {
        Get.offAllNamed(routes.AppRoutes.mainNavigation);
      }

    } on SignupRequiredException catch (e) {
      if (_isDisposed) return;

      // This shouldn't happen on signup screen, but handle it
      setLoading(false);
      _isNavigating = false;

      showInfo(
        'Complete Your Profile',
        subtitle: 'Please fill in your details to complete signup.',
      );

      // Pre-fill the form
      if (e.email.isNotEmpty) {
        emailController.text = e.email;
      }
      if (e.displayName != null && e.displayName!.isNotEmpty) {
        fullnameController.text = e.displayName!;
      }
      isFromGoogle.value = true;
      validateForm();

    } catch (e) {
      if (_isDisposed) return;
      final errorInfo = FirebaseErrorHandler.parseError(e);
      showError(errorInfo['title']!, subtitle: errorInfo['subtitle']!);
      _isNavigating = false;
    } finally {
      if (!_isDisposed) {
        setLoading(false);
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    fullnameController.removeListener(_validateForm);
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}