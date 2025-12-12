import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amorra/presentation/controllers/base_controller.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';
import 'package:amorra/presentation/controllers/home/home_controller.dart';
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';

/// Main Navigation Controller
/// Handles bottom navigation bar state and coordinates controller refreshes
class MainNavigationController extends BaseController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupUserListener();
  }

  /// Setup listener for user changes to refresh all controllers
  void _setupUserListener() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        
        // Listen to currentUser changes and refresh all controllers
        ever(authController.currentUser, (user) {
          if (kDebugMode) {
            print('🔄 MainNavigationController: User changed, refreshing all controllers');
          }
          _refreshAllControllers();
        });
        
        // Immediately refresh if user is already logged in
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authController.currentUser.value != null) {
            _refreshAllControllers();
          }
        });
      } else {
        // Retry if AuthController not ready yet
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isRegistered<AuthController>()) {
            _setupUserListener();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting up user listener in MainNavigationController: $e');
      }
    }
  }

  /// Refresh all controllers when user changes
  void _refreshAllControllers() {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing all controllers...');
      }

      // Get current user from AuthController
      final authController = Get.find<AuthController>();
      final user = authController.currentUser.value;

      // Refresh HomeController immediately (don't delay)
      if (Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          // Directly handle user change instead of calling refresh
          homeController.handleUserChange(user);
          if (kDebugMode) {
            print('✅ HomeController refreshed for user: ${user?.name ?? 'null'}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error refreshing HomeController: $e');
          }
        }
      }

      // Refresh ChatController immediately (don't delay)
      if (Get.isRegistered<ChatController>()) {
        try {
          final chatController = Get.find<ChatController>();
          // Directly handle user change instead of calling refreshChat
          chatController.handleUserChange(user);
          if (kDebugMode) {
            print('✅ ChatController refreshed for user: ${user?.name ?? 'null'}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error refreshing ChatController: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing controllers: $e');
      }
    }
  }

  /// Change tab index
  void changeTab(int index) {
    currentIndex.value = index;
  }
}

