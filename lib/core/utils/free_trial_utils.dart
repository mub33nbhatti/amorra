import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/data/models/user_model.dart';

/// Free Trial Utilities
/// Helper functions for checking free trial status
class FreeTrialUtils {
  /// Check if user is within the free trial period (7 days)
  /// Returns true if user signed up within the last 7 days
  static bool isWithinFreeTrial(UserModel? user) {
    if (user == null) return false;
    
    final now = DateTime.now();
    final signupDate = user.createdAt;
    final daysSinceSignup = now.difference(signupDate).inDays;
    
    return daysSinceSignup < AppConfig.freeTrialDays;
  }

  /// Get days remaining in free trial
  /// Returns 0 if trial has ended
  static int getDaysRemainingInTrial(UserModel? user) {
    if (user == null) return 0;
    
    final now = DateTime.now();
    final signupDate = user.createdAt;
    final daysSinceSignup = now.difference(signupDate).inDays;
    final daysRemaining = AppConfig.freeTrialDays - daysSinceSignup;
    
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  /// Check if user should have unlimited messages
  /// Returns true if: subscribed OR within free trial
  static bool hasUnlimitedMessages(UserModel? user) {
    if (user == null) return false;
    
    // Subscribed users always have unlimited
    if (user.isSubscribed) return true;
    
    // Free trial users have unlimited for 7 days
    return isWithinFreeTrial(user);
  }
}

