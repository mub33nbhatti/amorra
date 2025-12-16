import 'dart:convert';
import 'dart:io';
import 'package:amorra/core/config/app_config.dart';
import 'package:amorra/core/constants/api_constants.dart';
import 'package:amorra/data/services/firebase_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Chat API Service
/// Handles chat-related API calls to backend
class ChatApiService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Send message to AI via backend API
  /// 
  /// Request: POST /api/chat
  /// Body: { "user_id": string, "message": string, "chat_session_id"?: string (optional) }
  /// Headers: X-API-Key: <API_KEY>
  /// Response: { "message": string, "thread_id": string }
  /// 
  /// The API automatically manages conversation history and memory.
  /// Includes retry logic with exponential backoff
  Future<Map<String, dynamic>> sendMessageToAI({
    required String userId,
    required String message,
    String? chatSessionId,
  }) async {
    // Use the correct backend URL (override .env if it has wrong value)
    final baseUrl = ApiConstants.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConstants.endpointChat}');
    
    final requestBody = <String, dynamic>{
      'user_id': userId,
      'message': message,
    };
    
    // Add chat_session_id only if provided (optional)
    if (chatSessionId != null && chatSessionId.isNotEmpty) {
      requestBody['chat_session_id'] = chatSessionId;
    }

    // Get API key from environment or use default test key
    // Backend expects X-API-Key header with value "321" for testing
    final apiKey = dotenv.env['BACKEND_API_KEY'] ?? '321';
    
    // Prepare headers
    final headers = <String, String>{
      ApiConstants.headerContentType: ApiConstants.contentTypeJson,
      ApiConstants.headerApiKey: apiKey, // Backend requires X-API-Key header
    };

    int attempt = 0;
    Exception? lastException;

    while (attempt < AppConfig.maxRetryAttempts) {
      try {
        if (kDebugMode && attempt > 0) {
          print('Retrying chat API call (attempt ${attempt + 1}/${AppConfig.maxRetryAttempts})');
        }

        final response = await http
            .post(
              url,
              headers: headers,
              body: jsonEncode(requestBody),
            )
            .timeout(ApiConstants.connectTimeout);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          
          // API response format: { "data": { "message": string, "thread_id": string, ... }, "success": bool }
          // Extract the actual data object
          Map<String, dynamic>? messageData;
          
          if (responseData['data'] != null) {
            messageData = responseData['data'] as Map<String, dynamic>?;
          } else if (responseData['message'] != null) {
            // Fallback: direct message format (for backward compatibility)
            messageData = responseData;
          }
          
          // Validate response has required fields
          if (messageData == null || messageData['message'] == null) {
            if (kDebugMode) {
              print('⚠️ API response missing "message" field');
              print('Response body: ${response.body}');
              print('Parsed data: $responseData');
            }
            throw Exception('Invalid API response: missing message field');
          }
          
          // Extract message and thread_id from the data object
          final message = messageData['message'].toString();
          final threadId = messageData['thread_id']?.toString();
          
          if (kDebugMode) {
            print('✅ Chat API response received');
            print('  - Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
            print('  - Thread ID: ${threadId ?? 'not provided'}');
          }
          
          // Return normalized response format: { "message": string, "thread_id": string }
          return {
            'message': message,
            if (threadId != null) 'thread_id': threadId,
          };
        } else {
          // Log response for debugging
          if (kDebugMode) {
            print('API Error - Status: ${response.statusCode}');
            print('Response body: ${response.body}');
            print('Request headers sent: $headers');
          }
          
          // Non-200 status code - retry if it's a server error (5xx)
          if (response.statusCode >= 500 && attempt < AppConfig.maxRetryAttempts - 1) {
            lastException = Exception('Server error: ${response.statusCode}');
            await Future.delayed(AppConfig.retryDelay * (attempt + 1));
            attempt++;
            continue;
          }
          
          // Client error (4xx) or final retry attempt - don't retry
          final errorBody = response.body.isNotEmpty 
              ? jsonDecode(response.body) 
              : {'error': 'HTTP ${response.statusCode}'};
          throw Exception(errorBody['error'] ?? 'HTTP ${response.statusCode}');
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        // Don't retry on timeout or network errors if it's the last attempt
        if (attempt >= AppConfig.maxRetryAttempts - 1) {
          rethrow;
        }
        
        // Wait before retrying with exponential backoff
        await Future.delayed(AppConfig.retryDelay * (attempt + 1));
        attempt++;
      }
    }

    // Should never reach here, but just in case
    throw lastException ?? Exception('Failed to send message after ${AppConfig.maxRetryAttempts} attempts');
  }

  /// Get AI response for a message
  /// TODO: Replace with actual GET endpoint
  /// Expected endpoint: GET /api/chat/response/{messageId}
  /// Response: { "response": string, "messageId": string }
  Future<String> getAIResponse(String messageId) async {
    // TODO: Replace with actual API call
    // Example implementation:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/chat/response/$messageId'),
    // );
    // final data = jsonDecode(response.body);
    // return data['response'];

    // Placeholder return
    await Future.delayed(const Duration(seconds: 2));
    return 'This is a placeholder AI response. The actual API integration will be implemented later.';
  }

  /// Moderate content for safety
  /// TODO: Replace with actual POST endpoint
  /// Expected endpoint: POST /api/chat/moderate
  /// Request body: { "content": string }
  /// Response: { "isSafe": boolean, "reason": string? }
  Future<bool> moderateContent(String content) async {
    // TODO: Replace with actual API call
    // Example implementation:
    // final response = await http.post(
    //   Uri.parse('$baseUrl/api/chat/moderate'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'content': content}),
    // );
    // final data = jsonDecode(response.body);
    // return data['isSafe'] ?? false;

    // Placeholder return (always safe for now)
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  /// Check daily message limit
  /// TODO: Replace with actual GET endpoint
  /// Expected endpoint: GET /api/chat/limit/{userId}
  /// Response: { "remaining": number, "limit": number, "resetAt": timestamp }
  /// Note: This should check if user is within free trial period
  /// If within trial, return 999 (unlimited indicator)
  Future<int> checkDailyLimit(String userId) async {
    // TODO: Replace with actual API call
    // Example implementation:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/chat/limit/$userId'),
    // );
    // final data = jsonDecode(response.body);
    // return data['remaining'] ?? 0;
    // 
    // The API should check:
    // 1. If user is subscribed -> return 999 (unlimited)
    // 2. If user is within 7-day free trial -> return 999 (unlimited)
    // 3. Otherwise -> return remaining messages from daily limit

    // Placeholder return (default to free tier limit)
    // In production, this should check free trial status from backend
    await Future.delayed(const Duration(milliseconds: 200));
    return AppConfig.freeMessageLimit;
  }

  /// Update AI context when user preferences change
  /// 
  /// Request: POST /api/update-context
  /// Body: { "user_id": string }
  /// Headers: X-API-Key: <API_KEY>
  /// Response: { "success": bool, "message": string }
  /// 
  /// Call this immediately after a user saves new profile settings
  /// to notify the active AI conversation that preferences have changed.
  Future<Map<String, dynamic>> updateContext({
    required String userId,
  }) async {
    try {
      final baseUrl = ApiConstants.baseUrl;
      final url = Uri.parse('$baseUrl${ApiConstants.endpointUpdateContext}');
      
      // Get API key from environment or use default
      final apiKey = dotenv.env['BACKEND_API_KEY'] ?? '321';
      
      final requestBody = {
        'user_id': userId,
      };
      
      if (kDebugMode) {
        print('🔄 Updating AI context for user: $userId');
        print('  - URL: $url');
      }
      
      final response = await http.post(
        url,
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          ApiConstants.headerApiKey: apiKey,
        },
        body: jsonEncode(requestBody),
      ).timeout(ApiConstants.connectTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (kDebugMode) {
          print('✅ AI context updated successfully');
          print('  - Response: ${data['message'] ?? 'Success'}');
        }
        
        return data;
      } else {
        // Try to parse error message from response
        String errorMessage = 'Failed to update AI context';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['error']?.toString() ?? errorData['message']?.toString() ?? errorMessage;
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        if (kDebugMode) {
          print('❌ Failed to update AI context: $errorMessage');
          print('  - Status: ${response.statusCode}');
          print('  - Body: ${response.body}');
        }
        
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      final errorMessage = 'Cannot connect to backend server: ${e.message}';
      if (kDebugMode) {
        print('❌ Network error updating context: $errorMessage');
      }
      throw Exception('$errorMessage\n\nPlease check:\n1. Backend server is running\n2. API_BASE_URL in .env file is correct\n3. Internet connection is active');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update context error: $e');
      }
      rethrow;
    }
  }
}

