import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Storage Service
/// Handles Firebase Storage operations for file uploads
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      if (kDebugMode) {
        print('📤 Uploading profile image for user: $userId');
      }

      // Create reference to the profile image path
      final ref = _storage.ref().child('profile_images/$userId/profile.jpg');

      // Upload the file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ Profile image uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading profile image: $e');
      }
      rethrow;
    }
  }

  /// Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String userId) async {
    try {
      if (kDebugMode) {
        print('🗑️ Deleting profile image for user: $userId');
      }

      final ref = _storage.ref().child('profile_images/$userId/profile.jpg');
      await ref.delete();

      if (kDebugMode) {
        print('✅ Profile image deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting profile image: $e');
      }
      // Don't rethrow - if image doesn't exist, that's fine
      if (e.toString().contains('not found')) {
        if (kDebugMode) {
          print('ℹ️ Profile image not found, skipping deletion');
        }
        return;
      }
      rethrow;
    }
  }

  /// Get profile image URL (if exists)
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId/profile.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Profile image not found for user: $userId');
      }
      return null;
    }
  }
}

