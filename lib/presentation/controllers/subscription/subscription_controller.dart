import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:amorra/data/models/subscription_model.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/core/constants/app_constants.dart';
import 'package:amorra/core/utils/free_trial_utils.dart';
import 'package:amorra/data/services/firebase_service.dart';
import 'package:amorra/presentation/controllers/base_controller.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';

/// Subscription Controller
/// Handles subscription logic and state
class SubscriptionController extends BaseController {
  final FirebaseService _firebaseService = FirebaseService();

  // State
  final Rx<SubscriptionModel?> subscription = Rx<SubscriptionModel?>(null);
  final RxBool isSubscribed = false.obs;
  final RxInt remainingFreeMessages = AppConfig.freeMessageLimit.obs;
  final RxBool isWithinFreeTrial = false.obs;

  // Get current user
  UserModel? get currentUser {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().currentUser.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _checkFreeTrialStatus();
    checkSubscriptionStatus();
    _setupSubscriptionListener();
    _setupUserListener();
  }

  /// Setup listener for user changes to update free trial status
  void _setupUserListener() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        ever(authController.currentUser, (UserModel? user) {
          _checkFreeTrialStatus();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up user listener: $e');
      }
    }
  }

  /// Check if user is within free trial period
  void _checkFreeTrialStatus() {
    final user = currentUser;
    if (user != null) {
      isWithinFreeTrial.value = FreeTrialUtils.isWithinFreeTrial(user);
      // If within free trial, set unlimited messages
      if (isWithinFreeTrial.value) {
        remainingFreeMessages.value = 999; // Unlimited indicator
      }
    }
  }

  /// Setup listener for subscription changes
  void _setupSubscriptionListener() {
    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) return;

      _firebaseService
          .collection(AppConstants.collectionSubscriptions)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data() as Map<String, dynamic>;
          subscription.value = SubscriptionModel.fromJson({
            'id': snapshot.docs.first.id,
            ...data,
          });
          isSubscribed.value = subscription.value?.isActive ?? false;
        } else {
          subscription.value = null;
          isSubscribed.value = false;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up subscription listener: $e');
      }
    }
  }

  /// Check subscription status
  Future<void> checkSubscriptionStatus() async {
    try {
      setLoading(true);
      final userId = _firebaseService.currentUserId;
      if (userId == null) {
        subscription.value = null;
        isSubscribed.value = false;
        return;
      }

      final snapshot = await _firebaseService
          .collection(AppConstants.collectionSubscriptions)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        subscription.value = SubscriptionModel.fromJson({
          'id': snapshot.docs.first.id,
          ...data,
        });
        isSubscribed.value = subscription.value?.isActive ?? false;
      } else {
        subscription.value = null;
        isSubscribed.value = false;
      }
    } catch (e) {
      setError(e.toString());
      if (kDebugMode) {
        print('Error checking subscription status: $e');
      }
    } finally {
      setLoading(false);
    }
  }

  /// Check if user can send message (free tier limit)
  bool canSendMessage() {
    // Subscribed users always can send
    if (isSubscribed.value) return true;
    
    // Free trial users can send unlimited
    if (isWithinFreeTrial.value) return true;
    
    // After trial, check remaining messages
    return remainingFreeMessages.value > 0;
  }

  /// Decrement free message count
  void decrementFreeMessages() {
    // Don't decrement if subscribed or in free trial
    if (isSubscribed.value || isWithinFreeTrial.value) return;
    
    if (remainingFreeMessages.value > 0) {
      remainingFreeMessages.value--;
    }
  }

  /// Show paywall if needed
  void showPaywallIfNeeded() {
    if (!canSendMessage()) {
      // Navigate to subscription screen
      Get.toNamed('/subscription-plans');
    }
  }

  /// Handle subscription purchase
  Future<bool> purchaseSubscription(String planId) async {
    try {
      setLoading(true);
      // TODO: Implement Stripe checkout
      // await _stripeService.createSubscription(...);
      showSuccess('Subscription Activated!', subtitle: 'Congratulations! Your subscription is now active. Enjoy unlimited access!');
      isSubscribed.value = true;
      return true;
    } catch (e) {
      setError(e.toString());
      showError('Subscription Failed', subtitle: 'We couldn\'t process your subscription. Please try again or contact support.');
      return false;
    } finally {
      setLoading(false);
    }
  }
}

