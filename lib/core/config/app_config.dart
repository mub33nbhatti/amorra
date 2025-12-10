/// App Configuration
/// Contains app-wide configuration constants and settings
class AppConfig {
  // App Information
  static const String appName = 'Amorra';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'AI Companion for Men 50+ - Emotional & Romantic Support Chat Partner';

  // Environment
  static const bool isDevelopment = true; // Change to false for production

  // Free Tier Limits
  static const int freeMessageLimit = 10; // Free messages per day
  static const int freeDailyLimit = 10;

  // Subscription
  static const String subscriptionProductId = 'amorra_monthly_subscription';
  static const double monthlySubscriptionPrice = 9.99;

  // AI Configuration
  static const int maxContextMessages = 20; // Number of messages to retain in context
  static const Duration aiResponseTimeout = Duration(seconds: 30);

  // Chat Configuration
  static const int maxMessageLength = 1000;
  static const Duration typingIndicatorDuration = Duration(milliseconds: 1500);

  // Age Verification
  static const int minimumAge = 40;

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}

