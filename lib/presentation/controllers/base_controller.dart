import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../presentation/widgets/common/app_snackbar.dart';

/// Base Controller
/// Base class for all controllers with common functionality
abstract class BaseController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Set loading state
  void setLoading(bool value) {
    isLoading.value = value;
  }

  /// Set error message
  void setError(String message) {
    errorMessage.value = message;
    if (kDebugMode) {
      print('Controller Error: $message');
    }
  }

  /// Clear error
  void clearError() {
    errorMessage.value = '';
  }

  /// Show error snackbar
  void showError(String message, {String? title, String? subtitle}) {
    AppSnackbar.showError(
      title: title ?? 'Error',
      subtitle: subtitle ?? message,
    );
  }

  /// Show success snackbar
  void showSuccess(String message, {String? title, String? subtitle}) {
    AppSnackbar.showSuccess(
      title: title ?? 'Success',
      subtitle: subtitle ?? message,
    );
  }

  /// Show info snackbar
  void showInfo(String message, {String? title, String? subtitle}) {
    AppSnackbar.showInfo(
      title: title ?? 'Info',
      subtitle: subtitle ?? message,
    );
  }

  /// Show warning snackbar
  void showWarning(String message, {String? title, String? subtitle}) {
    AppSnackbar.showWarning(
      title: title ?? 'Warning',
      subtitle: subtitle ?? message,
    );
  }

  @override
  void onClose() {
    clearError();
    super.onClose();
  }
}

