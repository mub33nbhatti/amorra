import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App Configuration
/// Contains app-wide configuration constants and settings
class AppConfig {
  // App Information
  static const String appName = 'Amorra';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'AI Companion for Men 50+ - Emotional & Romantic Support Chat Partner';

  // Environment - Load from environment variables
  static bool get isDevelopment {
    final env = dotenv.env['APP_ENV'] ?? 'development';
    return env.toLowerCase() == 'development';
  }

  // Free Trial Configuration
  static const int freeTrialDays = 7; // 7 days of unlimited messages

  // Free Tier Limits - Load from environment variables with fallback
  // Applied after free trial period ends
  static int get freeMessageLimit {
    return int.tryParse(dotenv.env['FREE_MESSAGE_LIMIT'] ?? '10') ?? 10;
  }

  static int get freeDailyLimit => freeMessageLimit;

  // Subscription - Load from environment variables with fallback
  static String get subscriptionProductId {
    return dotenv.env['SUBSCRIPTION_PRODUCT_ID'] ?? 'amorra_monthly_subscription';
  }

  static double get monthlySubscriptionPrice {
    return double.tryParse(dotenv.env['SUBSCRIPTION_PRICE'] ?? '9.99') ?? 9.99;
  }

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

