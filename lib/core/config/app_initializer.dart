import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/presentation/controllers/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_config.dart';

/// App Initializer
/// Handles all app initialization logic
class AppInitializer {
  /// Initialize all required services and dependencies
  static Future<void> initialize() async {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Set status bar color globally
    _setStatusBarStyle();

    // Initialize environment variables
    await _initializeEnvironment();

    // Initialize GetStorage
    await _initializeStorage();

    // Initialize Firebase
    await _initializeFirebase();

    // Initialize GetX controllers
    _initializeControllers();
  }

  /// Initialize environment variables from .env file
  static Future<void> _initializeEnvironment() async {
    try {
      await dotenv.load(fileName: '.env');
      if (kDebugMode) {
        debugPrint('Environment variables loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Environment variables initialization error: $e');
        debugPrint('Continuing without .env file (using defaults)');
      }
      // Continue app initialization even if .env fails (for development)
    }
  }

  /// Set status bar style for the whole app
  static void _setStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(
       const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark, // Dark icons for white background
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
  }

  /// Initialize local storage
  static Future<void> _initializeStorage() async {
    try {
      await GetStorage.init();
      if (kDebugMode) {
        debugPrint('GetStorage initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GetStorage initialization error: $e');
      }
    }
  }

  /// Initialize Firebase services
  static Future<void> _initializeFirebase() async {
    try {
      await FirebaseConfig.initialize();
      if (kDebugMode) {
        debugPrint('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase initialization error: $e');
        // Continue app initialization even if Firebase fails (for development)
      }
    }
  }

  /// Initialize GetX controllers
  static void _initializeControllers() {
    // Initialize theme controller
    Get.put(ThemeController(), permanent: true);
    
    if (kDebugMode) {
      debugPrint('GetX controllers initialized');
    }
  }
}

