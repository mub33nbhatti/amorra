import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import '../../base_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/utils/app_texts/app_texts.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/firebase_service.dart';

/// Age Verification Controller
/// Handles age verification logic with date picker and Firestore sync
class AgeVerificationController extends BaseController {
  final _storage = GetStorage();
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseService _firebaseService = FirebaseService();

  // Date selection
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  
  // Calculated age
  final RxInt calculatedAge = 0.obs;
  
  // Validation states
  final RxBool isDateSelected = false.obs;
  final RxBool isValidAge = false.obs;
  final RxString ageError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Start with no date selected (empty/placeholder)
    selectedDate.value = null;
    isDateSelected.value = false;
    calculatedAge.value = 0;
    _checkVerificationStatus();
  }

  /// Check if user is already verified (from Firestore or local storage)
  Future<void> _checkVerificationStatus() async {
    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        return;
      }

      // Check Firestore first (source of truth)
      final verificationStatus = await _authRepository.getAgeVerificationStatus(currentUser.uid);
      
      if (verificationStatus != null && verificationStatus['isAgeVerified'] == true) {
        // User is verified, check profile setup status
        final isProfileSetupCompleted = await _authRepository.getProfileSetupStatus(currentUser.uid);
        
        if (isProfileSetupCompleted) {
          // Profile setup completed, navigate to main
          if (kDebugMode) {
            print('✅ User age verified and profile setup completed, navigating to main');
          }
          _navigateToMain();
        } else {
          // Profile setup not completed, navigate to profile setup
          if (kDebugMode) {
            print('⚠️ User age verified but profile setup not completed, navigating to profile setup');
          }
          _navigateToProfileSetup();
        }
        return;
      }

      // Check local storage as fallback
      final localVerified = _storage.read<bool>(AppConstants.storageKeyAgeVerified) ?? false;
      if (localVerified) {
        // If local says verified but Firestore doesn't, re-verify
        // But for now, if local says verified, trust it (will sync on next verification)
        if (kDebugMode) {
          print('📱 Local storage says verified, but Firestore check needed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error checking verification status: $e');
      }
    }
  }

  /// Update selected date from date picker
  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
    isDateSelected.value = true;
    _calculateAge(date);
  }

  /// Calculate age from date of birth
  void _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    
    // Adjust if birthday hasn't occurred this year
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    
    calculatedAge.value = age;
    _validateAge(age);
  }

  /// Validate age (must be between 18 and 120)
  void _validateAge(int age) {
    if (age == 0) {
      // No date selected yet - don't show error, just keep invalid
      isValidAge.value = false;
      ageError.value = '';
    } else if (age < AppConstants.minimumAge) {
      isValidAge.value = false;
      ageError.value = AppTexts.ageVerificationErrorUnder18;
    } else if (age > 120) {
      isValidAge.value = false;
      ageError.value = AppTexts.ageVerificationErrorMaxAge;
    } else {
      isValidAge.value = true;
      ageError.value = '';
    }
  }

  /// Verify age and save to Firestore
  Future<void> verifyAge() async {
    if (!isDateSelected.value || selectedDate.value == null) {
      showError(
        'Date Required',
        subtitle: 'Please select your date of birth',
      );
      return;
    }

    if (!isValidAge.value) {
      showError(
        'Invalid Age',
        subtitle: ageError.value.isNotEmpty
            ? ageError.value
            : AppTexts.ageVerificationErrorInvalid,
      );
      return;
    }

    try {
      setLoading(true);
      clearError();

      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        showError(
          'Authentication Required',
          subtitle: 'Please sign in to verify your age',
        );
        setLoading(false);
        return;
      }

      final dateOfBirth = selectedDate.value!;
      final age = calculatedAge.value;

      if (kDebugMode) {
        print('🔐 Verifying age for user: ${currentUser.uid}');
        print('   Age: $age, DOB: $dateOfBirth');
      }

      // Save to Firestore
      await _authRepository.updateAgeVerification(
        userId: currentUser.uid,
        age: age,
        dateOfBirth: dateOfBirth,
      );

      // Save to local storage
      await _storage.write(AppConstants.storageKeyAgeVerified, true);
      await _storage.write('user_age', age);
      await _storage.write('date_of_birth', dateOfBirth.toIso8601String());

      if (kDebugMode) {
        print('✅ Age verification saved successfully');
      }

      showSuccess(
        'Age Verified!',
        subtitle: 'Thank you for verifying your age. You\'re all set to continue!',
      );

      // Wait a bit for user to see success message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to profile setup (after age verification)
      _navigateToProfileSetup();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Age verification error: $e');
      }
      showError(
        'Verification Failed',
        subtitle: 'We couldn\'t verify your age. Please check your connection and try again.',
      );
    } finally {
      setLoading(false);
    }
  }

  /// Navigate to profile setup screen
  void _navigateToProfileSetup() {
    Get.offAllNamed(AppRoutes.profileSetup);
  }

  /// Navigate to main navigation screen (for already verified users)
  void _navigateToMain() {
    Get.offAllNamed(AppRoutes.mainNavigation);
  }

  /// Get stored age from local storage
  int? getStoredAge() {
    return _storage.read<int>('user_age');
  }
}
