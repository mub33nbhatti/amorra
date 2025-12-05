import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../../base_controller.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/firebase_error_handler.dart';
import '../../../../core/config/routes.dart' as routes;
import '../../../../core/constants/app_constants.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/firebase_service.dart';

/// Sign In Controller
/// Handles sign in form logic and validation
class SigninController extends BaseController {
  // Repository - use Get.find to reuse existing instance
  AuthRepository get _authRepository => Get.find<AuthRepository>();
  final FirebaseService _firebaseService = FirebaseService();
  final _storage = GetStorage();

  // Form key - unique instance
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State
  final RxBool isPasswordVisible = false.obs;
  final RxBool isFormValid = false.obs;

  // Track if disposed
  bool _isDisposed = false;

  // Track if currently navigating
  bool _isNavigating = false;

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;
    _isNavigating = false;
    _setupValidation();
  }

  /// Setup form validation listeners
  void _setupValidation() {
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  /// Validate entire form
  void _validateForm() {
    if (_isDisposed) return;

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
    if (_isDisposed) return;
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Sign in user
  Future<void> signIn() async {
    if (_isDisposed || _isNavigating) return;

    if (!isFormValid.value) {
      showError('Oops! Something\'s missing',
          subtitle: 'Please fill in all fields to continue');
      return;
    }

    try {
      setLoading(true);

      // Unfocus to dismiss keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      await _authRepository.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (_isDisposed || _isNavigating) return;

      // Mark onboarding as completed (in case user bypassed it)
      await _markOnboardingCompleted();

      // Check age verification and profile setup status
      final currentUser = _firebaseService.currentUser;
      if (currentUser != null) {
        final verificationStatus = await _authRepository.getAgeVerificationStatus(currentUser.uid);
        
        if (verificationStatus == null || verificationStatus['isAgeVerified'] != true) {
          // Not verified, navigate to age verification
          if (kDebugMode) {
            print('⚠️ User not age verified, navigating to age verification');
          }
          
          _isNavigating = true;
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (!_isDisposed) {
            Get.offAllNamed(routes.AppRoutes.ageVerification);
          }
          return;
        }

        // Age verified, check profile setup status
        final isProfileSetupCompleted = await _authRepository.getProfileSetupStatus(currentUser.uid);
        
        if (!isProfileSetupCompleted) {
          // Profile setup not completed, navigate to profile setup
          if (kDebugMode) {
            print('⚠️ User age verified but profile setup not completed, navigating to profile setup');
          }
          
          _isNavigating = true;
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (!_isDisposed) {
            Get.offAllNamed(routes.AppRoutes.profileSetup);
          }
          return;
        }
      }

      showSuccess('Welcome back!',
          subtitle: 'You\'ve successfully signed in. Let\'s get started!');

      _isNavigating = true;

      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_isDisposed) {
        Get.offAllNamed(routes.AppRoutes.mainNavigation);
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

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    if (_isDisposed || _isNavigating) return;

    try {
      setLoading(true);

      // Unfocus to dismiss keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      await _authRepository.signInWithGoogle();

      if (_isDisposed || _isNavigating) return;

      // Mark onboarding as completed (in case user bypassed it)
      await _markOnboardingCompleted();

      // Check age verification and profile setup status
      final currentUser = _firebaseService.currentUser;
      if (currentUser != null) {
        final verificationStatus = await _authRepository.getAgeVerificationStatus(currentUser.uid);
        
        if (verificationStatus == null || verificationStatus['isAgeVerified'] != true) {
          // Not verified, navigate to age verification
          if (kDebugMode) {
            print('⚠️ User not age verified, navigating to age verification');
          }
          
          _isNavigating = true;
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (!_isDisposed) {
            Get.offAllNamed(routes.AppRoutes.ageVerification);
          }
          return;
        }

        // Age verified, check profile setup status
        final isProfileSetupCompleted = await _authRepository.getProfileSetupStatus(currentUser.uid);
        
        if (!isProfileSetupCompleted) {
          // Profile setup not completed, navigate to profile setup
          if (kDebugMode) {
            print('⚠️ User age verified but profile setup not completed, navigating to profile setup');
          }
          
          _isNavigating = true;
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (!_isDisposed) {
            Get.offAllNamed(routes.AppRoutes.profileSetup);
          }
          return;
        }
      }

      showSuccess('Welcome!',
          subtitle: 'You\'ve successfully signed in with Google. Enjoy your experience!');

      _isNavigating = true;

      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_isDisposed) {
        Get.offAllNamed(routes.AppRoutes.mainNavigation);
      }

    } on SignupRequiredException catch (e) {
      if (_isDisposed) return;

      setLoading(false);
      _isNavigating = true;

      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_isDisposed) {
        // Navigate to signup with Google credential info
        Get.toNamed(
          routes.AppRoutes.signup,
          arguments: {
            'email': e.email,
            'displayName': e.displayName,
            'fromGoogle': true,
          },
        );

        showInfo(
          'Complete Your Signup',
          subtitle: 'Please enter your name and create a password to complete your account setup with Google.',
        );
      }
      _isNavigating = false;
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

  /// Forgot password
  void forgotPassword() {
    if (_isDisposed) return;
    showInfo('Coming Soon',
        subtitle: 'Password recovery feature will be available shortly. Stay tuned!');
  }

  /// Mark onboarding as completed
  Future<void> _markOnboardingCompleted() async {
    try {
      // Save to local storage
      await _storage.write(AppConstants.storageKeyOnboardingCompleted, true);

      // Save to Firestore if user is authenticated
      final currentUser = _firebaseService.currentUser;
      if (currentUser != null) {
        try {
          await _authRepository.updateOnboardingCompletion(currentUser.uid);
          if (kDebugMode) {
            print('✅ Onboarding completion marked after signin');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to save onboarding to Firestore: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error marking onboarding completion: $e');
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}