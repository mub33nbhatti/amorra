import 'package:get/get.dart';
import '../../../data/models/subscription_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../base_controller.dart';

/// Subscription Controller
/// Handles subscription logic and state
class SubscriptionController extends BaseController {
  // State
  final Rx<SubscriptionModel?> subscription = Rx<SubscriptionModel?>(null);
  final RxBool isSubscribed = false.obs;
  final RxInt remainingFreeMessages = AppConfig.freeMessageLimit.obs;

  @override
  void onInit() {
    super.onInit();
    checkSubscriptionStatus();
  }

  /// Check subscription status
  Future<void> checkSubscriptionStatus() async {
    try {
      setLoading(true);
      // TODO: Fetch subscription from repository
      // final userId = Get.find<AuthController>().currentUser.value?.id;
      // if (userId != null) {
      //   subscription.value = await _subscriptionRepository.getSubscription(userId);
      //   isSubscribed.value = subscription.value?.isActive ?? false;
      // }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Check if user can send message (free tier limit)
  bool canSendMessage() {
    if (isSubscribed.value) return true;
    return remainingFreeMessages.value > 0;
  }

  /// Decrement free message count
  void decrementFreeMessages() {
    if (!isSubscribed.value && remainingFreeMessages.value > 0) {
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

