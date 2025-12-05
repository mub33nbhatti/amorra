import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/config/routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../base_controller.dart';
import '../auth/auth_controller.dart';
import '../subscription/subscription_controller.dart';
import '../../widgets/common/app_alert_dialog.dart';
import '../../widgets/common/app_password_dialog.dart';

/// Profile Controller
/// Handles profile screen logic and state
class ProfileController extends BaseController {
  final AuthRepository _authRepository = AuthRepository();

  // State
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isEditingName = false.obs;
  final RxString editedName = ''.obs;
  final TextEditingController nameController = TextEditingController();

  // Get AuthController
  AuthController get _authController => Get.find<AuthController>();

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
      ever(_authController.currentUser, (UserModel? updatedUser) {
        if (updatedUser != null) {
          user.value = updatedUser;
          editedName.value = updatedUser.name;
          nameController.text = updatedUser.name;
        } else {
          user.value = null;
        }
      });

      // Set initial user if available
      if (_authController.currentUser.value != null) {
        user.value = _authController.currentUser.value;
        editedName.value = _authController.currentUser.value!.name;
        nameController.text = _authController.currentUser.value!.name;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up user listener: $e');
      }
    }
  }

  /// Load user data
  Future<void> _loadUserData() async {
    try {
      setLoading(true);
      final currentUser = _authController.currentUser.value;
      if (currentUser != null) {
        user.value = currentUser;
        editedName.value = currentUser.name;
        nameController.text = currentUser.name;
      } else {
        // Try to fetch from repository
        final fetchedUser = await _authRepository.getCurrentUser();
        if (fetchedUser != null) {
          user.value = fetchedUser;
          _authController.currentUser.value = fetchedUser;
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
    if (newName.isEmpty) {
      showError('Invalid Name', subtitle: 'Name cannot be empty');
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

      await _authController.updateUser(updatedUser);
      isEditingName.value = false;
      editedName.value = newName;
    } catch (e) {
      setError(e.toString());
      showError('Update Failed', subtitle: 'Failed to update name. Please try again.');
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
      setLoading(true);
      await _authController.signOut();
      
      // Navigate to signin screen
      Get.offAllNamed(AppRoutes.signin);
    } catch (e) {
      setError(e.toString());
      showError('Logout Failed', subtitle: 'Failed to logout. Please try again.');
    } finally {
      setLoading(false);
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
      setLoading(true);
      await _authRepository.deleteAccount(user.value!.id);
      
      // Navigate to signin screen
      Get.offAllNamed(AppRoutes.signin);
      
      showSuccess(
        'Account Deleted',
        subtitle: 'Your account has been permanently deleted.',
      );
    } on ReauthenticationRequiredException {
      setLoading(false);
      
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
        await _authRepository.deleteAccount(user.value!.id, password: passwordResult);
        
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
          showError('Invalid Password', subtitle: 'The password you entered is incorrect. Please try again.');
        } else {
          showError('Delete Failed', subtitle: 'Failed to delete account. Please try again.');
        }
      } finally {
        setLoading(false);
      }
    } catch (e) {
      setError(e.toString());
      showError('Delete Failed', subtitle: 'Failed to delete account. Please try again.');
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
    return _subscriptionController?.isSubscribed.value ?? false;
  }

  /// Get remaining free messages
  int get remainingFreeMessages {
    return _subscriptionController?.remainingFreeMessages.value ?? AppConfig.freeMessageLimit;
  }

  /// Get used messages (for progress indicator)
  int get usedMessages {
    return AppConfig.freeDailyLimit - remainingFreeMessages;
  }

  /// Get daily limit
  int get dailyLimit => AppConfig.freeDailyLimit;

  /// Get next billing date (if subscribed)
  DateTime? get nextBillingDate {
    final subscription = _subscriptionController?.subscription.value;
    return subscription?.endDate;
  }

  /// Navigate to subscription screen
  void navigateToSubscription() {
    // TODO: Implement navigation to subscription screen
  }
}

