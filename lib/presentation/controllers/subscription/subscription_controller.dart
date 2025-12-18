import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amorra/data/models/subscription_model.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/core/constants/app_constants.dart';
import 'package:amorra/core/utils/free_trial_utils.dart';
import 'package:amorra/data/services/firebase_service.dart';
import 'package:amorra/data/services/stripe_service.dart';
import 'package:amorra/data/services/chat_api_service.dart';
import 'package:amorra/data/repositories/auth_repository.dart';
import 'package:amorra/presentation/controllers/base_controller.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';

/// Subscription Controller
/// Handles subscription logic and state
class SubscriptionController extends BaseController {
  final FirebaseService _firebaseService = FirebaseService();
  final StripeService _stripeService = StripeService();
  final AuthRepository _authRepository = AuthRepository();
  final ChatApiService _chatApiService = ChatApiService();

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
    _checkDailyLimit();
  }

  /// Setup listener for user changes to update free trial status
  void _setupUserListener() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        ever(authController.currentUser, (UserModel? user) {
          _checkFreeTrialStatus();
          // Also check daily limit when user changes
          if (user != null) {
            _checkDailyLimit();
          }
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
      } else {
        // If not in trial, check daily limit
        _checkDailyLimit();
      }
    }
  }

  /// Check daily message limit from Firestore
  Future<void> _checkDailyLimit() async {
    final user = currentUser;
    if (user == null) return;

    // Don't check if subscribed or in free trial
    if (isSubscribed.value || isWithinFreeTrial.value) {
      remainingFreeMessages.value = 999;
      return;
    }

    try {
      final userId = user.id;
      final remaining = await _chatApiService.checkDailyLimit(userId);
      remainingFreeMessages.value = remaining;
      
      if (kDebugMode) {
        print('📊 SubscriptionController: Updated remaining messages to $remaining');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking daily limit in SubscriptionController: $e');
      }
      // On error, keep current value or set to default
      if (remainingFreeMessages.value >= 999) {
        remainingFreeMessages.value = AppConfig.freeMessageLimit;
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
          
          // Sync user subscription status in local state
          if (isSubscribed.value) {
            _syncUserSubscriptionStatus(true, AppConstants.subscriptionStatusActive);
          } else {
            // Subscription exists but is not active (cancelled/expired)
            final status = subscription.value?.status ?? AppConstants.subscriptionStatusFree;
            _syncUserSubscriptionStatus(false, status);
          }
        } else {
          subscription.value = null;
          isSubscribed.value = false;
          
          // Sync user subscription status in local state
          _syncUserSubscriptionStatus(false, AppConstants.subscriptionStatusFree);
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

  /// Handle subscription purchase (TEST MODE ONLY)
  /// 
  /// Payment Flow (Updated):
  /// 1. User clicks "Subscribe" → This method is called
  /// 2. Stripe Payment Sheet UI is shown FIRST (built-in from flutter_stripe package)
  /// 3. User enters payment details (card number, expiry, CVC) in the Payment Sheet
  /// 4. User taps "Confirm Payment" button
  /// 5. Backend API is called to create payment intent (TEST MODE) → Returns clientSecret
  /// 6. Payment is processed with the clientSecret (TEST MODE - no real charges)
  /// 7. Backend webhook receives payment confirmation and creates subscription
  /// 8. Subscription status is refreshed
  /// 
  /// [planId] - Subscription plan ID (e.g., 'premium_monthly')
  /// 
  /// Returns true if payment was successful, false otherwise
  Future<bool> purchaseSubscription(String planId) async {
    try {
      setLoading(true);
      
      // Get current user
      final user = currentUser;
      final userId = _firebaseService.currentUserId;
      
      if (user == null || userId == null) {
        showError('Authentication Required', subtitle: 'Please sign in to purchase a subscription.');
        return false;
      }
      
      // Get subscription price from config
      final amount = AppConfig.monthlySubscriptionPrice;
      const currency = 'usd';
      
      if (kDebugMode) {
        print('💳 Starting subscription purchase (TEST MODE):');
        print('  - Plan ID: $planId');
        print('  - Amount: \$$amount');
        print('  - User ID: $userId');
        print('  - Mode: TEST MODE (use test card: 4242 4242 4242 4242)');
      }
      
      // IMPORTANT: Stripe Payment Sheet Technical Requirement
      // 
      // Stripe Payment Sheet REQUIRES a clientSecret to initialize.
      // The clientSecret comes from creating a payment intent (backend call).
      // 
      // However, creating a payment intent does NOT charge the card.
      // The actual charge happens ONLY when the user confirms in the Payment Sheet.
      //
      // So the flow is:
      // 1. Create payment intent (backend) → Get clientSecret (NO CHARGE YET)
      // 2. Show Payment Sheet with clientSecret
      // 3. User enters card details
      // 4. User taps "Confirm Payment"
      // 5. Payment is processed (CHARGE HAPPENS HERE)
      //
      // This is the secure and standard Stripe flow.
      
      // Step 1: Create payment intent via backend (required to get clientSecret)
      // NOTE: This does NOT charge the card - it just prepares the payment
      // The actual charge happens when user confirms in Step 3
      if (kDebugMode) {
        print('📡 Step 1: Creating payment intent (backend call)...');
        print('  - This prepares the payment but does NOT charge the card');
        print('  - Returns clientSecret needed for Payment Sheet');
      }
      
      String? clientSecret;
      String? publishableKey;
      
      try {
        final paymentData = await _stripeService.createPaymentIntent(
          amount: amount,
          currency: currency,
          userId: userId,
        );
        
        clientSecret = paymentData['clientSecret']!;
        publishableKey = paymentData['publishableKey'];
        
        // Initialize Stripe with publishable key if provided
        // Also get merchant identifier for iOS Apple Pay (optional)
        if (publishableKey != null && publishableKey.isNotEmpty) {
          try {
            // Get merchant identifier from environment (for Apple Pay on iOS)
            final merchantId = dotenv.env['STRIPE_MERCHANT_IDENTIFIER'];
            await _stripeService.initialize(
              publishableKey,
              merchantIdentifier: merchantId,
            );
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Warning: Could not initialize Stripe with provided key: $e');
              print('  Continuing with existing Stripe configuration...');
            }
          }
        }
      } catch (e) {
        // Backend is not available - show error
        if (kDebugMode) {
          print('❌ Backend not available: $e');
        }
        showError(
          'Backend Not Available',
          subtitle: 'Cannot connect to payment server. Please ensure:\n'
              '1. Backend server is running\n'
              '2. API_BASE_URL in .env is correct\n'
              '3. Internet connection is active\n\n'
              'Note: Stripe Payment Sheet requires backend connection to initialize.',
        );
        return false;
      }
      
      // Step 2: Show Payment Sheet with clientSecret
      // User enters card details here
      if (kDebugMode) {
        print('📱 Step 2: Showing Stripe Payment Sheet to user...');
        print('  - User will enter card: 4242 4242 4242 4242');
        print('  - User will enter expiry and CVC');
        print('  - User will tap "Confirm Payment" button');
      }
      
      // Step 3: User confirms payment in the Payment Sheet
      // THIS IS WHERE THE ACTUAL CHARGE HAPPENS
      // The backend webhook will receive the payment confirmation
      if (kDebugMode) {
        print('💳 Step 3: Waiting for user to confirm payment...');
        print('  - When user confirms, payment will be processed');
        print('  - Backend webhook will receive confirmation');
      }
      
      final paymentSuccess = await _stripeService.confirmPayment(
        clientSecret: clientSecret,
      );
      
      if (paymentSuccess) {
        if (kDebugMode) {
          print('✅ Payment successful! (TEST MODE)');
          print('  - Backend webhook will receive confirmation');
          print('  - Creating subscription in Firebase...');
        }
        
        // Step 4: Create/update subscription in Firebase
        await _createOrUpdateSubscription(
          userId: userId,
          planId: planId,
          amount: amount,
          stripeSubscriptionId: null, // Will be set by backend webhook
        );
        
        // Step 5: Update user's subscription status in Firebase
        await _updateUserSubscriptionStatus(
          userId: userId,
          isSubscribed: true,
          subscriptionStatus: AppConstants.subscriptionStatusActive,
        );
        
        // Step 6: Refresh subscription status and user data
        await checkSubscriptionStatus();
        await _refreshUserData();
        
        if (kDebugMode) {
          print('✅ Subscription activated and saved to Firebase');
        }
        
        // Show success message
        showSuccess(
          'Subscription Activated!',
          subtitle: 'Congratulations! Your subscription is now active. Enjoy unlimited access!',
        );
        
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Payment was cancelled or failed');
        }
        showError(
          'Payment Cancelled',
          subtitle: 'The payment was cancelled. Please try again when you\'re ready.',
        );
        return false;
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('❌ Subscription purchase error: $e');
      }
      setError(e.toString());
      
      // Show user-friendly error message
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      showError(
        'Subscription Failed',
        subtitle: errorMessage.isNotEmpty
            ? errorMessage
            : 'We couldn\'t process your subscription. Please try again or contact support.',
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error during subscription purchase: $e');
      }
      setError(e.toString());
      showError(
        'Subscription Failed',
        subtitle: 'An unexpected error occurred. Please try again or contact support.',
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Create or update subscription document in Firebase
  Future<void> _createOrUpdateSubscription({
    required String userId,
    required String planId,
    required double amount,
    String? stripeSubscriptionId,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 Creating/updating subscription in Firebase...');
      }

      // Check if subscription already exists
      final existingSubs = await _firebaseService
          .collection(AppConstants.collectionSubscriptions)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + 1, now.day); // 1 month from now

      final subscriptionData = {
        'userId': userId,
        'status': AppConstants.subscriptionStatusActive,
        'stripeSubscriptionId': stripeSubscriptionId,
        'price': amount,
        'planName': planId,
        'startDate': now,
        'endDate': endDate,
        'updatedAt': now,
      };

      if (existingSubs.docs.isNotEmpty) {
        // Update existing subscription
        await _firebaseService
            .collection(AppConstants.collectionSubscriptions)
            .doc(existingSubs.docs.first.id)
            .update(subscriptionData);
        
        if (kDebugMode) {
          print('✅ Updated existing subscription: ${existingSubs.docs.first.id}');
        }
      } else {
        // Create new subscription
        subscriptionData['createdAt'] = now;
        await _firebaseService
            .collection(AppConstants.collectionSubscriptions)
            .add(subscriptionData);
        
        if (kDebugMode) {
          print('✅ Created new subscription document');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating/updating subscription: $e');
      }
      rethrow;
    }
  }

  /// Update user's subscription status in Firebase
  Future<void> _updateUserSubscriptionStatus({
    required String userId,
    required bool isSubscribed,
    required String subscriptionStatus,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 Updating user subscription status in Firebase...');
      }

      final user = currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ Cannot update user: currentUser is null');
        }
        return;
      }

      // Update user model
      final updatedUser = user.copyWith(
        isSubscribed: isSubscribed,
        subscriptionStatus: subscriptionStatus,
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await _authRepository.updateUser(updatedUser);

      // Update AuthController's current user
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        authController.currentUser.value = updatedUser;
      }

      if (kDebugMode) {
        print('✅ User subscription status updated');
        print('  - isSubscribed: $isSubscribed');
        print('  - subscriptionStatus: $subscriptionStatus');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user subscription status: $e');
      }
      rethrow;
    }
  }

  /// Refresh user data from Firebase
  Future<void> _refreshUserData() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.checkAuthState();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error refreshing user data: $e');
      }
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      setLoading(true);

      final userId = _firebaseService.currentUserId;
      if (userId == null) {
        showError('Authentication Required', subtitle: 'Please sign in to manage your subscription.');
        return false;
      }

      if (kDebugMode) {
        print('🛑 Cancelling subscription...');
      }

      // Update subscription status to cancelled
      final existingSubs = await _firebaseService
          .collection(AppConstants.collectionSubscriptions)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingSubs.docs.isNotEmpty) {
        await _firebaseService
            .collection(AppConstants.collectionSubscriptions)
            .doc(existingSubs.docs.first.id)
            .update({
          'status': AppConstants.subscriptionStatusCancelled,
          'cancelledAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
      }

      // Update user's subscription status
      await _updateUserSubscriptionStatus(
        userId: userId,
        isSubscribed: false,
        subscriptionStatus: AppConstants.subscriptionStatusCancelled,
      );

      // Refresh subscription status
      await checkSubscriptionStatus();
      await _refreshUserData();

      if (kDebugMode) {
        print('✅ Subscription cancelled');
      }

      showSuccess(
        'Subscription Cancelled',
        subtitle: 'Your subscription has been cancelled. You can resubscribe anytime.',
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling subscription: $e');
      }
      showError(
        'Cancellation Failed',
        subtitle: 'We couldn\'t cancel your subscription. Please try again or contact support.',
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Sync user subscription status in local state (without Firebase update)
  void _syncUserSubscriptionStatus(bool isSubscribed, String subscriptionStatus) {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        final user = authController.currentUser.value;
        if (user != null) {
          final updatedUser = user.copyWith(
            isSubscribed: isSubscribed,
            subscriptionStatus: subscriptionStatus,
          );
          authController.currentUser.value = updatedUser;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error syncing user subscription status: $e');
      }
    }
  }
}

