import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Constants
/// Contains API endpoints and configuration
class ApiConstants {
  // Base URLs - Load from environment variables with fallback defaults
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.amorra.app';
  static String get aiApiBaseUrl => dotenv.env['AI_API_BASE_URL'] ?? 'https://api.openai.com/v1';

  // API Endpoints
  static const String endpointChat = '/chat/completions';
  static const String endpointModeration = '/moderations';

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerBearer = 'Bearer';
  static const String contentTypeJson = 'application/json';

  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}

