import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../../core/constants/app_constants.dart';

/// Auth Repository
/// Handles authentication-related data operations
class AuthRepository {
  final FirebaseService _firebaseService = FirebaseService();

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed: User is null');
      }

      // Get user data from Firestore
      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        return UserModel.fromJson({
          'id': credential.user!.uid,
          ...?userData,
        });
      } else {
        // Create user document if it doesn't exist
        final userModel = UserModel(
          id: credential.user!.uid,
          email: credential.user!.email,
          name: credential.user!.displayName ?? '',
          createdAt: DateTime.now(),
        );
        await createUser(userModel);
        return userModel;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential =
          await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed: User is null');
      }

      // Create user document
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await createUser(userModel);
      return userModel;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      rethrow;
    }
  }

  /// Create user document in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Create user error: $e');
      }
      rethrow;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) return null;

      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>?;
      return UserModel.fromJson({
        'id': userId,
        ...?userData,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Get current user error: $e');
      }
      return null;
    }
  }

  /// Update user document
  Future<void> updateUser(UserModel user) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Update user error: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _firebaseService.signOut();
      
      // Also sign out from Google Sign-In if user was signed in with Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('Google sign-in was canceled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseService.auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign-in failed: User is null');
      }

      // Get user data from Firestore
      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        return UserModel.fromJson({
          'id': userCredential.user!.uid,
          ...?userData,
        });
      } else {
        // Create user document if it doesn't exist
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email,
          name: userCredential.user!.displayName ?? googleUser.displayName ?? '',
          createdAt: DateTime.now(),
        );
        await createUser(userModel);
        return userModel;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google sign in error: $e');
      }
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      rethrow;
    }
  }
}

