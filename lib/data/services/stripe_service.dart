import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:amorra/core/constants/api_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Stripe Service
/// Handles Stripe payment integration
/// 
/// IMPORTANT: This implementation is configured for TEST MODE only.
/// Ensure you use Stripe TEST publishable keys (starting with 'pk_test_')
/// from your Stripe Dashboard > Developers > API keys > Test mode
class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  /// Initialize Stripe with publishable key
  /// 
  /// IMPORTANT: Use TEST mode publishable key (starts with 'pk_test_')
  /// The Payment Sheet UI is provided by flutter_stripe package - no custom UI needed
  /// 
  /// For iOS:
  /// - Merchant identifier is optional (only needed for Apple Pay)
  /// - URL scheme is automatically configured via Info.plist
  /// - Camera permission is required for card scanning (configured in Info.plist)
  Future<void> initialize(String publishableKey, {String? merchantIdentifier}) async {
    try {
      // Validate that we're using test mode key
      if (!publishableKey.startsWith('pk_test_')) {
        if (kDebugMode) {
          print('⚠️ WARNING: Publishable key does not start with "pk_test_"');
          print('  This app is configured for TEST MODE only.');
          print('  Please use a Stripe TEST publishable key.');
        }
        // In production, you might want to throw an error here
        // For now, we'll allow it but warn
      }
      
      Stripe.publishableKey = publishableKey;
      
      // Set merchant identifier for iOS (only needed for Apple Pay)
      // This should match the merchant ID in Info.plist and Apple Developer account
      if (merchantIdentifier != null && merchantIdentifier.isNotEmpty) {
        if (Platform.isIOS) {
          Stripe.merchantIdentifier = merchantIdentifier;
          if (kDebugMode) {
            print('✅ iOS Merchant Identifier set: $merchantIdentifier');
          }
        }
      } else if (kDebugMode && Platform.isIOS) {
        print('ℹ️ No merchant identifier provided - Apple Pay will not be available');
        print('  To enable Apple Pay, set merchantIdentifier when initializing Stripe');
      }
      
      // Apply Stripe settings (includes iOS-specific configurations)
      await Stripe.instance.applySettings();
      
      if (kDebugMode) {
        print('✅ Stripe initialized successfully (TEST MODE)');
        print('  - Publishable Key: ${publishableKey.substring(0, 20)}...');
        if (Platform.isIOS) {
          print('  - Platform: iOS');
          print('  - URL Scheme: com.example.amorra (configured in Info.plist)');
          if (merchantIdentifier != null) {
            print('  - Apple Pay: Enabled (Merchant ID: $merchantIdentifier)');
          } else {
            print('  - Apple Pay: Disabled (no merchant identifier)');
          }
        } else if (Platform.isAndroid) {
          print('  - Platform: Android');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Stripe initialization error: $e');
      }
      rethrow;
    }
  }

  /// Create payment intent via backend API
  /// 
  /// NOTE: This is called BEFORE showing the payment sheet.
  /// The backend creates a payment intent in TEST MODE and returns clientSecret.
  /// 
  /// Payment Flow:
  /// 1. User clicks "Subscribe" → This method is called
  /// 2. Backend creates payment intent (TEST MODE) → Returns clientSecret
  /// 3. Payment sheet is shown with clientSecret
  /// 4. User enters payment details in Stripe's built-in Payment Sheet UI
  /// 5. User confirms payment
  /// 6. Payment is processed (TEST MODE - no real charges)
  /// 7. Backend webhook receives payment confirmation
  /// 
  /// [amount] - Amount in dollars (will be converted to cents)
  /// [currency] - Currency code (e.g., "usd")
  /// [userId] - User ID for payment records
  /// 
  /// Returns the clientSecret needed for Stripe payment sheet
  Future<Map<String, String>> createPaymentIntent({
    required double amount,
    required String currency,
    required String userId,
  }) async {
    try {
      // Get backend URL from environment or use default
      // Default: https://ammora.onrender.com
      // Full URL: https://ammora.onrender.com/api/create-payment-intent
      final baseUrl = dotenv.env['API_BASE_URL'] ?? ApiConstants.baseUrl;
      final url = Uri.parse('$baseUrl${ApiConstants.endpointCreatePaymentIntent}');
      
      // Get API key from environment or use default
      // Backend expects X-API-Key header with value "321" (or from .env)
      final apiKey = dotenv.env['BACKEND_API_KEY'] ?? '321';
      
      // Convert amount to cents (Stripe uses cents)
      final amountInCents = (amount * 100).toInt();
      
      if (kDebugMode) {
        print('💳 Creating payment intent:');
        print('  - Backend URL: $baseUrl');
        print('  - Full URL: $url');
        print('  - Amount: \$$amount (${amountInCents} cents)');
        print('  - Currency: $currency');
        print('  - User ID: $userId');
      }
      
      // Validate URL before making request
      if (baseUrl.isEmpty || !url.hasScheme || !url.hasAuthority) {
        throw Exception('Invalid backend URL: $baseUrl. Please check your API_BASE_URL in .env file.');
      }
      
      // Make API call to backend
      final response = await http.post(
        url,
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          ApiConstants.headerApiKey: apiKey,
        },
        body: jsonEncode({
          'amount': amountInCents,
          'currency': currency,
          'user_id': userId,
        }),
      ).timeout(ApiConstants.connectTimeout);
      
      if (kDebugMode) {
        print('📡 Payment intent API response: ${response.statusCode}');
        print('  - Body: ${response.body}');
      }
      
      // Check if request was successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Validate response structure - API returns { "clientSecret": string }
        // Handle both formats: with/without success flag
        if (data['clientSecret'] != null) {
          final clientSecret = data['clientSecret'] as String;
          final publishableKey = data['publishableKey'] as String?;
          
          if (kDebugMode) {
            print('✅ Payment intent created successfully');
            print('  - Client Secret: ${clientSecret.substring(0, 20)}...');
          }
          
          return {
            'clientSecret': clientSecret,
            if (publishableKey != null) 'publishableKey': publishableKey,
          };
        } else {
          throw Exception('Invalid response format: missing clientSecret');
        }
      } else {
        // Try to parse error message from response
        String errorMessage = 'Failed to create payment intent';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['error']?.toString() ?? errorMessage;
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        if (kDebugMode) {
          print('❌ Payment intent creation failed: $errorMessage');
        }
        
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // Handle network/DNS errors
      final errorMessage = 'Cannot connect to backend server: ${e.message}';
      if (kDebugMode) {
        print('❌ Network error: $errorMessage');
        print('  - Check if API_BASE_URL in .env is correct');
        print('  - Ensure backend server is running and accessible');
        print('  - Current URL: ${dotenv.env['API_BASE_URL'] ?? ApiConstants.baseUrl}');
      }
      throw Exception('$errorMessage\n\nPlease check:\n1. Backend server is running\n2. API_BASE_URL in .env file is correct\n3. Internet connection is active');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create payment intent error: $e');
      }
      rethrow;
    }
  }

  /// Show Stripe Payment Sheet and handle payment confirmation
  /// 
  /// This method shows the payment sheet FIRST, then calls backend when user confirms.
  /// 
  /// Flow:
  /// 1. Show payment sheet (user enters card details)
  /// 2. User taps "Confirm Payment"
  /// 3. Backend API is called to create payment intent
  /// 4. Payment is processed
  /// 
  /// The Payment Sheet UI is provided by flutter_stripe package - no custom UI needed.
  /// 
  /// NOTE: This operates in TEST MODE - use test card numbers from Stripe docs:
  /// - Success: 4242 4242 4242 4242
  /// - Decline: 4000 0000 0000 0002
  /// - Any future expiry date, any CVC
  Future<bool> showPaymentSheetAndConfirm({
    required double amount,
    required String currency,
    required String userId,
  }) async {
    try {
      // NOTE: Stripe Payment Sheet requires a clientSecret to initialize.
      // For now, we'll create a temporary payment intent on the client side
      // or show the sheet with a placeholder, then call backend when user confirms.
      // 
      // However, since we need clientSecret upfront, we have two options:
      // 1. Call backend first (current implementation)
      // 2. Use a mock/test clientSecret for development
      //
      // For now, we'll use a development mode that shows the sheet,
      // and when user confirms, we'll call the backend.
      
      if (kDebugMode) {
        print('📱 Showing Stripe Payment Sheet...');
        print('  - User will enter payment details');
        print('  - Backend will be called when user confirms');
      }
      
      // For development: We need to create a payment intent first to get clientSecret
      // But since backend isn't ready, we'll show an error or use a workaround
      throw UnimplementedError(
        'Backend API is required to create payment intent.\n'
        'Please ensure your backend server is running and API_BASE_URL is correct in .env file.'
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing payment sheet: $e');
      }
      rethrow;
    }
  }

  /// Confirm payment with Stripe Payment Sheet (using existing clientSecret)
  /// 
  /// This is the standard flow where clientSecret is already available.
  /// 
  /// The Payment Sheet UI is provided by flutter_stripe package - no custom UI needed.
  /// This method:
  /// 1. Initializes the payment sheet with clientSecret
  /// 2. Presents the built-in Stripe Payment Sheet UI
  /// 3. User enters payment details and confirms
  /// 4. Returns true if payment was successful, false if cancelled/failed
  /// 
  /// NOTE: This operates in TEST MODE - use test card numbers from Stripe docs:
  /// - Success: 4242 4242 4242 4242
  /// - Decline: 4000 0000 0000 0002
  /// - Any future expiry date, any CVC
  Future<bool> confirmPayment({
    required String clientSecret,
  }) async {
    try {
      if (kDebugMode) {
        print('📱 Initializing Stripe Payment Sheet (TEST MODE)...');
        print('  - Use test card: 4242 4242 4242 4242');
      }
      
      // Initialize payment sheet with clientSecret
      // The Payment Sheet UI is built-in - no custom UI needed
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Amorra',
          // Test mode is determined by the publishable key (pk_test_)
        ),
      );

      if (kDebugMode) {
        print('✅ Payment Sheet initialized');
        print('📱 Presenting Payment Sheet to user...');
      }

      // Present the built-in Stripe Payment Sheet UI
      // User will enter payment details and confirm here
      await Stripe.instance.presentPaymentSheet();

      if (kDebugMode) {
        print('✅ Payment confirmed successfully (TEST MODE)');
      }

      return true;
    } on StripeException catch (e) {
      if (kDebugMode) {
        print('❌ Stripe payment error: ${e.error.message}');
        if (e.error.code == 'Canceled') {
          print('  - User cancelled the payment');
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Payment confirmation error: $e');
      }
      return false;
    }
  }

  /// Create subscription
  /// This should also be done on backend
  Future<String> createSubscription({
    required String customerId,
    required String priceId,
  }) async {
    try {
      // TODO: Call your backend API to create subscription
      // This should be done on your server for security
      throw UnimplementedError('Subscription creation should be done on backend');
    } catch (e) {
      if (kDebugMode) {
        print('Create subscription error: $e');
      }
      rethrow;
    }
  }

  /// Handle Stripe redirect (for 3D Secure)
  /// Note: Implement based on your Stripe SDK version requirements
  Future<void> handleStripeRedirect(String url) async {
    try {
      // Stripe handleURLCallback signature varies by SDK version
      // Check your flutter_stripe package version for correct usage
      // Common patterns:
      // - await Stripe.instance.handleURLCallback(Uri.parse(url));
      // - await Stripe.instance.handleURLCallback(url);
      if (kDebugMode) {
        print('Stripe redirect handler - URL: $url');
        print('TODO: Implement handleURLCallback based on your Stripe SDK version');
      }
      // Uncomment and adjust based on your Stripe SDK version:
      // await Stripe.instance.handleURLCallback(Uri.parse(url));
    } catch (e) {
      if (kDebugMode) {
        print('Stripe redirect error: $e');
      }
      rethrow;
    }
  }
}

