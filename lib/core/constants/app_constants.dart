/// App-wide Constants
class AppConstants {
  // Storage Keys
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyUserEmail = 'user_email';
  static const String storageKeyUserName = 'user_name';
  static const String storageKeyAgeVerified = 'age_verified';
  static const String storageKeyOnboardingCompleted = 'onboarding_completed';
  static const String storageKeyProfileSetupCompleted = 'profile_setup_completed';
  static const String storageKeySubscriptionStatus = 'subscription_status';
  static const String storageKeyThemeMode = 'theme_mode';
  static const String storageKeyAuthToken = 'auth_token';

  // Firestore Collection Names
  static const String collectionUsers = 'users';
  static const String collectionMessages = 'messages';
  static const String collectionSubscriptions = 'subscriptions';
  static const String collectionUserPreferences = 'preferences';
  static const String collectionChatSessions = 'chat_sessions';
  static const String collectionDailySuggestions = 'daily_suggestions';

  // Message Types
  static const String messageTypeUser = 'user';
  static const String messageTypeAI = 'ai';
  static const String messageTypeSystem = 'system';

  // Subscription Status
  static const String subscriptionStatusFree = 'free';
  static const String subscriptionStatusActive = 'active';
  static const String subscriptionStatusCancelled = 'cancelled';
  static const String subscriptionStatusExpired = 'expired';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorSubscription = 'Subscription error. Please try again.';
  static const String errorAgeVerification = 'You must be 18 or older to use this app.';

  // Success Messages
  static const String successAgeVerified = 'Age verified successfully';
  static const String successOnboardingComplete = 'Welcome to Amorra!';
  static const String successSubscriptionActive = 'Subscription activated successfully';
  static const String successMessageSent = 'Message sent';

  // Age Verification
  static const int minimumAge = 18;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxMessageLength = 1000;
}

