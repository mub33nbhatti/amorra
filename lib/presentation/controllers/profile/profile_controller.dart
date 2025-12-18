import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/data/repositories/auth_repository.dart';
import 'package:amorra/core/config/routes.dart';
import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/core/utils/free_trial_utils.dart';
import 'package:amorra/core/utils/validators.dart';
import 'package:amorra/presentation/controllers/base_controller.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';
import 'package:amorra/presentation/controllers/subscription/subscription_controller.dart';
import 'package:amorra/presentation/controllers/main/main_navigation_controller.dart';
import 'package:amorra/presentation//widgets/common/app_alert_dialog.dart';
import 'package:amorra/presentation//widgets/common/app_password_dialog.dart';

/// Profile Controller
/// Handles profile screen logic and state
class ProfileController extends BaseController {
  final AuthRepository _authRepository = AuthRepository();

  // State
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isEditingName = false.obs;
  final RxString editedName = ''.obs;
  final RxBool showNameUpdateAnimation = false.obs;
  final TextEditingController nameController = TextEditingController();
  final RxBool isLogoutLoading = false.obs;
  final RxBool isDeleteAccountLoading = false.obs;
  
  // Reactive remaining messages (synced with SubscriptionController)
  final RxInt remainingFreeMessagesReactive = AppConfig.freeMessageLimit.obs;

  // Get AuthController
  AuthController? get _authController {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get SubscriptionController
  SubscriptionController? get _subscriptionController {
    try {
      return Get.find<SubscriptionController>();
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _setupUserListener();
    _setupSubscriptionListener();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  /// Setup listener for user changes
  void _setupUserListener() {
    try {
      // Listen to currentUser changes reactively
      final authController = _authController;
      if (authController == null) {
        if (kDebugMode) {
          print('⚠️ AuthController not available in ProfileController');
        }
        return;
      }
      
      ever(authController.currentUser, (UserModel? updatedUser) {
        if (updatedUser != null) {
          user.value = updatedUser;
          editedName.value = updatedUser.name;
          nameController.text = updatedUser.name;
          // Update remaining messages when user changes
          _updateRemainingMessages();
        } else {
          user.value = null;
          _updateRemainingMessages();
        }
      });

      // Set initial user if available
      if (authController.currentUser.value != null) {
        user.value = authController.currentUser.value;
        editedName.value = authController.currentUser.value!.name;
        nameController.text = authController.currentUser.value!.name;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up user listener: $e');
      }
    }
  }

  /// Setup listener for subscription controller changes
  void _setupSubscriptionListener() {
    try {
      final subscriptionController = _subscriptionController;
      if (subscriptionController == null) {
        if (kDebugMode) {
          print('⚠️ SubscriptionController not available in ProfileController');
        }
        return;
      }
      
      // Listen to remainingFreeMessages changes
      ever(subscriptionController.remainingFreeMessages, (int remaining) {
        remainingFreeMessagesReactive.value = remaining;
      });
      
      // Listen to isSubscribed changes
      ever(subscriptionController.isSubscribed, (bool subscribed) {
        // Update remaining messages when subscription status changes
        _updateRemainingMessages();
      });
      
      // Listen to isWithinFreeTrial changes
      ever(subscriptionController.isWithinFreeTrial, (bool inTrial) {
        // Update remaining messages when trial status changes
        _updateRemainingMessages();
      });
      
      // Set initial value
      _updateRemainingMessages();
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up subscription listener: $e');
      }
    }
  }

  /// Update remaining messages based on current state
  void _updateRemainingMessages() {
    // Check subscription status first - subscribed users have unlimited
    if (isSubscribed) {
      remainingFreeMessagesReactive.value = 999;
      return;
    }
    
    final currentUser = user.value;
    final isInTrial = currentUser != null && FreeTrialUtils.isWithinFreeTrial(currentUser);
    
    // If in free trial, return unlimited indicator
    if (isInTrial) {
      remainingFreeMessagesReactive.value = 999;
      return;
    }
    
    // Get from subscription controller
    final subscriptionController = _subscriptionController;
    if (subscriptionController != null) {
      remainingFreeMessagesReactive.value = subscriptionController.remainingFreeMessages.value;
    } else {
      remainingFreeMessagesReactive.value = AppConfig.freeMessageLimit;
    }
  }

  /// Load user data
  Future<void> _loadUserData() async {
    try {
      setLoading(true);
      final authController = _authController;
      if (authController == null) {
        if (kDebugMode) {
          print('⚠️ AuthController not available, cannot load user data');
        }
        setError('AuthController not available');
        return;
      }
      
      final currentUser = authController.currentUser.value;
      if (currentUser != null) {
        user.value = currentUser;
        editedName.value = currentUser.name;
        nameController.text = currentUser.name;
      } else {
        // Try to fetch from repository
        final fetchedUser = await _authRepository.getCurrentUser();
        if (fetchedUser != null) {
          user.value = fetchedUser;
          authController.currentUser.value = fetchedUser;
          editedName.value = fetchedUser.name;
          nameController.text = fetchedUser.name;
        }
      }
    } catch (e) {
      setError(e.toString());
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    } finally {
      setLoading(false);
    }
  }

  /// Start editing name
  void startEditingName() {
    if (user.value == null) return;
    isEditingName.value = true;
    editedName.value = user.value!.name;
    nameController.text = user.value!.name;
  }

  /// Cancel editing name
  void cancelEditingName() {
    if (user.value == null) return;
    isEditingName.value = false;
    editedName.value = user.value!.name;
    nameController.text = user.value!.name;
  }

  /// Save name changes
  Future<void> saveName() async {
    if (user.value == null) return;

    final newName = nameController.text.trim();
    
    // Use Validators to validate name
    final nameValidationError = Validators.validateName(newName);
    if (nameValidationError != null) {
      showError('Invalid Name', subtitle: nameValidationError);
      return;
    }

    if (newName == user.value!.name) {
      isEditingName.value = false;
      return;
    }

    try {
      setLoading(true);
      final updatedUser = user.value!.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );

      final authController = _authController;
      if (authController == null) {
        throw Exception('AuthController not available');
      }
      await authController.updateUser(updatedUser);
      isEditingName.value = false;
      editedName.value = newName;

      // Show completion animation
      showNameUpdateAnimation.value = true;

      // Wait for animation to complete (typically 2-3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      // Hide animation
      showNameUpdateAnimation.value = false;
    } catch (e) {
      setError(e.toString());
      showError(
        'Update Failed',
        subtitle: 'Failed to update name. Please try again.',
      );
    } finally {
      setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AppAlertDialog(
        title: AppTexts.profileLogoutTitle,
        subtitle: AppTexts.profileLogoutMessage,
        primaryButtonText: AppTexts.profileLogoutConfirm,
        secondaryButtonText: AppTexts.profileDeleteCancel,
        onPrimaryPressed: () => Get.back(result: true),
        onSecondaryPressed: () => Get.back(result: false),
      ),
    );

    if (confirmed != true) return;

    try {
      isLogoutLoading.value = true;
      final authController = _authController;
      if (authController == null) {
        throw Exception('AuthController not available');
      }
      await authController.signOut();

      // Navigate to signin screen
      Get.offAllNamed(AppRoutes.signin);
    } catch (e) {
      setError(e.toString());
      showError(
        'Logout Failed',
        subtitle: 'Failed to logout. Please try again.',
      );
    } finally {
      isLogoutLoading.value = false;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    if (user.value == null) return;

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AppAlertDialog(
        title: AppTexts.profileDeleteAccountTitle,
        subtitle: AppTexts.profileDeleteAccountMessage,
        primaryButtonText: AppTexts.profileDeleteConfirm,
        secondaryButtonText: AppTexts.profileDeleteCancel,
        onPrimaryPressed: () => Get.back(result: true),
        onSecondaryPressed: () => Get.back(result: false),
        primaryButtonColor: AppColors.error,
        primaryButtonTextColor: AppColors.white,
      ),
    );

    if (confirmed != true) return;

    try {
      isDeleteAccountLoading.value = true;
      await _authRepository.deleteAccount(user.value!.id);

      // Navigate to signin screen
      Get.offAllNamed(AppRoutes.signin);

      showSuccess(
        'Account Deleted',
        subtitle: 'Your account has been permanently deleted.',
      );
    } on ReauthenticationRequiredException {
      isDeleteAccountLoading.value = false;

      // Show password dialog for re-authentication
      final passwordResult = await Get.dialog<String>(
        AppPasswordDialog(
          title: AppTexts.profileReauthenticateTitle,
          subtitle: AppTexts.profileReauthenticateMessage,
          confirmButtonText: AppTexts.profileReauthenticateConfirm,
          cancelButtonText: AppTexts.profileDeleteCancel,
          onConfirm: (enteredPassword) {
            Get.back(result: enteredPassword);
          },
          onCancel: () => Get.back(result: null),
        ),
      );

      if (passwordResult == null) {
        // User canceled re-authentication
        return;
      }

      // Retry deletion with password
      try {
        setLoading(true);
        await _authRepository.deleteAccount(
          user.value!.id,
          password: passwordResult,
        );

        // Navigate to signin screen
        Get.offAllNamed(AppRoutes.signin);

        showSuccess(
          'Account Deleted',
          subtitle: 'Your account has been permanently deleted.',
        );
      } catch (retryError) {
        setError(retryError.toString());
        if (retryError.toString().contains('wrong-password') ||
            retryError.toString().contains('invalid-credential')) {
          showError(
            'Invalid Password',
            subtitle:
                'The password you entered is incorrect. Please try again.',
          );
        } else {
          showError(
            'Delete Failed',
            subtitle: 'Failed to delete account. Please try again.',
          );
        }
      } finally {
        setLoading(false);
      }
    } catch (e) {
      setError(e.toString());
      showError(
        'Delete Failed',
        subtitle: 'Failed to delete account. Please try again.',
      );
    } finally {
      setLoading(false);
    }
  }

  /// Get user name
  String get userName => user.value?.name ?? '';

  /// Get user email
  String get userEmail => user.value?.email ?? '';

  /// Get user age
  int? get userAge => user.value?.age;

  /// Get age display text
  String get ageDisplayText {
    final age = userAge;
    if (age == null) return 'Not set';
    return '$age years old';
  }

  /// Check if user is subscribed
  bool get isSubscribed {
    // First check subscription controller, then fallback to user model
    final subscriptionController = _subscriptionController;
    if (subscriptionController != null && subscriptionController.isSubscribed.value) {
      return true;
    }
    // Fallback to user model subscription status
    return user.value?.isSubscribed ?? false;
  }

  /// Get remaining free messages (reactive)
  int get remainingFreeMessages => remainingFreeMessagesReactive.value;

  /// Get used messages (for progress indicator)
  int get usedMessages {
    // Subscribed users have unlimited, so no usage tracking
    if (isSubscribed) return 0;
    
    final currentUser = user.value;
    final isInTrial = currentUser != null && FreeTrialUtils.isWithinFreeTrial(currentUser);
    
    // If in free trial, return 0 (no usage tracking)
    if (isInTrial) return 0;
    
    return AppConfig.freeDailyLimit - remainingFreeMessages;
  }

  /// Get daily limit
  int get dailyLimit {
    // Subscribed users have unlimited
    if (isSubscribed) return 999;
    
    final currentUser = user.value;
    final isInTrial = currentUser != null && FreeTrialUtils.isWithinFreeTrial(currentUser);
    
    // If in free trial, return unlimited indicator
    if (isInTrial) return 999;
    
    return AppConfig.freeDailyLimit;
  }

  /// Check if user is within free trial
  bool get isWithinFreeTrial {
    final currentUser = user.value;
    return currentUser != null && FreeTrialUtils.isWithinFreeTrial(currentUser);
  }

  /// Get days remaining in free trial
  int get freeTrialDaysRemaining {
    final currentUser = user.value;
    return FreeTrialUtils.getDaysRemainingInTrial(currentUser);
  }

  /// Get next billing date (if subscribed)
  DateTime? get nextBillingDate {
    final subscription = _subscriptionController?.subscription.value;
    return subscription?.endDate;
  }

  /// Navigate to subscription screen
  void navigateToSubscription() {
    try {
      // Get MainNavigationController and change to subscription tab (index 2)
      final mainNavController = Get.find<MainNavigationController>();
      mainNavController.changeTab(2); // Subscription tab index
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to subscription: $e');
      }
      // Fallback: try to navigate using route
      Get.toNamed(AppRoutes.subscription);
    }
  }
}
