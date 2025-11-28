/// Firebase Error Handler
/// Provides user-friendly error messages for Firebase errors
class FirebaseErrorHandler {
  FirebaseErrorHandler._();

  /// Parse Firebase error and return user-friendly title and subtitle
  static Map<String, String> parseError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Firebase Auth Errors
    if (errorString.contains('invalid-credential') || 
        errorString.contains('wrong-password') ||
        errorString.contains('incorrect') ||
        errorString.contains('malformed') ||
        errorString.contains('expired')) {
      return {
        'title': 'Invalid Credentials',
        'subtitle': 'The email or password you entered is incorrect. Please double-check and try again.',
      };
    }
    
    if (errorString.contains('user-not-found')) {
      return {
        'title': 'Account Not Found',
        'subtitle': 'No account exists with this email. Please sign up to create a new account.',
      };
    }
    
    if (errorString.contains('email-already-in-use')) {
      return {
        'title': 'Email Already Registered',
        'subtitle': 'This email is already in use. Please sign in instead or use a different email address.',
      };
    }
    
    if (errorString.contains('weak-password')) {
      return {
        'title': 'Weak Password',
        'subtitle': 'Your password is too weak. Please choose a stronger password with at least 6 characters.',
      };
    }
    
    if (errorString.contains('invalid-email')) {
      return {
        'title': 'Invalid Email',
        'subtitle': 'Please enter a valid email address and try again.',
      };
    }
    
    if (errorString.contains('user-disabled')) {
      return {
        'title': 'Account Disabled',
        'subtitle': 'This account has been disabled. Please contact support for assistance.',
      };
    }
    
    if (errorString.contains('too-many-requests')) {
      return {
        'title': 'Too Many Attempts',
        'subtitle': 'You\'ve made too many failed attempts. Please wait a moment and try again later.',
      };
    }
    
    if (errorString.contains('network-request-failed') || 
        errorString.contains('network')) {
      return {
        'title': 'Connection Problem',
        'subtitle': 'Unable to connect. Please check your internet connection and try again.',
      };
    }
    
    if (errorString.contains('operation-not-allowed')) {
      return {
        'title': 'Operation Not Allowed',
        'subtitle': 'This sign-in method is not enabled. Please contact support.',
      };
    }
    
    if (errorString.contains('requires-recent-login')) {
      return {
        'title': 'Re-authentication Required',
        'subtitle': 'For security, please sign in again to continue.',
      };
    }
    
    // Google Sign-In Errors
    if (errorString.contains('canceled') || errorString.contains('cancelled')) {
      return {
        'title': 'Sign In Canceled',
        'subtitle': 'You canceled the sign-in process. Please try again when ready.',
      };
    }
    
    // Generic Firebase errors
    if (errorString.contains('firebase') || errorString.contains('firestore')) {
      return {
        'title': 'Service Error',
        'subtitle': 'We\'re experiencing some technical difficulties. Please try again in a moment.',
      };
    }
    
    // Default error
    String errorMessage = error.toString();
    errorMessage = errorMessage.replaceAll('Exception: ', '');
    errorMessage = errorMessage.replaceAll('[firebase_auth/', '');
    errorMessage = errorMessage.replaceAll(']', '');
    
    return {
      'title': 'Something Went Wrong',
      'subtitle': errorMessage.isNotEmpty 
          ? 'Please try again. If the problem persists, contact support.'
          : 'An unexpected error occurred. Please try again.',
    };
  }
  
  /// Get error title
  static String getErrorTitle(dynamic error) {
    return parseError(error)['title'] ?? 'Error';
  }
  
  /// Get error subtitle
  static String getErrorSubtitle(dynamic error) {
    return parseError(error)['subtitle'] ?? 'An error occurred. Please try again.';
  }
}

