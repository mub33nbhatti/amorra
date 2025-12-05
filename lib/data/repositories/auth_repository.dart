import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../../core/constants/app_constants.dart';

/// Custom exception for when user needs to complete signup
class SignupRequiredException implements Exception {
  final String email;
  final String? displayName;
  final AuthCredential googleCredential;

  SignupRequiredException(this.email, {this.displayName, required this.googleCredential});

  @override
  String toString() => 'Signup required for email: $email';
}

/// Custom exception for when re-authentication is required
class ReauthenticationRequiredException implements Exception {
  final List<String> providers;
  final String? email;

  ReauthenticationRequiredException(this.providers, {this.email});

  @override
  String toString() => 'Re-authentication required for providers: $providers';
}

/// Auth Repository
/// Handles authentication-related data operations
/// Uses UID as document ID for perfect consistency
class AuthRepository {
  final FirebaseService _firebaseService = FirebaseService();

  // Temporary storage for Google credential when signup is required
  AuthCredential? _pendingGoogleCredential;

  /// Get pending Google credential (for linking after signup)
  AuthCredential? get pendingGoogleCredential => _pendingGoogleCredential;

  /// Clear pending Google credential
  void clearPendingGoogleCredential() {
    _pendingGoogleCredential = null;
  }

  /// Normalize email to lowercase and trim whitespace
  String _normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }


  /// Find user document by email (used for email/password signin)
  Future<DocumentSnapshot?> _findUserByEmail(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      if (kDebugMode) {
        print('🔍 Searching Firestore by email: $normalizedEmail');
      }

      final querySnapshot = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          print('✅ User document found: ${querySnapshot.docs.first.id}');
        }
        return querySnapshot.docs.first;
      }

      if (kDebugMode) {
        print('❌ No user document found for: $normalizedEmail');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error finding user by email: $e');
      }
      return null;
    }
  }


  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      final credential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed: User is null');
      }

      User? currentUser = credential.user;

      // If there's a pending Google credential, link it automatically
      if (_pendingGoogleCredential != null && currentUser != null) {
        try {
          await currentUser.linkWithCredential(_pendingGoogleCredential!);
          await currentUser.reload();
          currentUser = _firebaseService.auth.currentUser;

          if (kDebugMode) {
            print('✅ Google provider linked after email sign-in');
          }

          clearPendingGoogleCredential();
        } catch (linkError) {
          if (kDebugMode) {
            print('⚠️ Error linking Google: $linkError');
          }
          clearPendingGoogleCredential();
        }
      }

      final finalUser = currentUser ?? credential.user;
      if (finalUser == null) {
        throw Exception('Sign in failed: User is null after linking');
      }

      // Get user data from Firestore using UID
      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(finalUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        return UserModel.fromJson({
          'id': finalUser.uid,
          ...?userData,
        });
      } else {
        // Create document if missing
        final userModel = UserModel(
          id: finalUser.uid,
          email: normalizedEmail,
          name: finalUser.displayName ?? '',
          createdAt: DateTime.now(),
        );
        await createUser(userModel);
        return userModel;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in error: $e');
      }
      rethrow;
    }
  }

  /// Sign up with email and password
  /// Automatically links Google provider if pendingGoogleCredential exists
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      // Check if there's a pending Google credential to link
      if (_pendingGoogleCredential != null) {
        if (kDebugMode) {
          print('🔗 Pending Google credential found, creating account with BOTH providers');
        }

        // User coming from Google sign-in flow
        // Create account with email/password and link Google
        return await signUpWithEmailPasswordAndLinkGoogle(
          email: normalizedEmail,
          password: password,
          name: name,
          googleCredential: _pendingGoogleCredential!,
        );
      }

      // Regular sign up without Google (email/password only)
      final credential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed: User is null');
      }

      final userModel = UserModel(
        id: credential.user!.uid,
        email: normalizedEmail,
        name: name,
        createdAt: DateTime.now(),
      );

      await createUser(userModel);
      clearPendingGoogleCredential();

      if (kDebugMode) {
        print('✅ User created successfully (email/password only)');
      }

      return userModel;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign up error: $e');
      }
      rethrow;
    }
  }

  /// Sign up with email/password and link Google provider
  /// PRODUCTION-READY: Uses atomic operations with automatic cleanup
  Future<UserModel> signUpWithEmailPasswordAndLinkGoogle({
    required String email,
    required String password,
    required String name,
    required AuthCredential googleCredential,
  }) async {
    User? createdUser;

    try {
      final normalizedEmail = _normalizeEmail(email);

      if (kDebugMode) {
        print('🚀 Starting atomic signup with email + Google');
      }

      // STEP 1: Create Auth account with email/password
      final credential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      createdUser = credential.user;

      if (createdUser == null) {
        throw Exception('Auth account creation failed: User is null');
      }

      if (kDebugMode) {
        print('✅ Auth account created: ${createdUser.uid}');
      }

      // STEP 2: Link Google provider (CRITICAL - must succeed)
      try {
        if (kDebugMode) {
          print('🔗 Linking Google provider...');
        }

        final linkedCredential = await createdUser.linkWithCredential(googleCredential);

        // Reload to get updated provider data
        await linkedCredential.user?.reload();
        final updatedUser = _firebaseService.auth.currentUser;

        if (updatedUser == null) {
          throw Exception('User became null after linking');
        }

        // Verify both providers are linked
        final providers = updatedUser.providerData.map((p) => p.providerId).toList();

        if (!providers.contains('google.com')) {
          throw Exception('Google provider linking verification failed');
        }

        if (!providers.contains('password')) {
          throw Exception('Password provider missing after linking');
        }

        if (kDebugMode) {
          print('✅ Both providers linked: $providers');
        }

        createdUser = updatedUser;

      } catch (linkError) {
        if (kDebugMode) {
          print('❌ Google linking failed: $linkError');
          print('🧹 Cleaning up Auth account...');
        }

        // CLEANUP: Delete the Auth account we just created
        try {
          if (createdUser != null) {
            await createdUser.delete();
            if (kDebugMode) {
              print('✅ Auth account cleaned up successfully');
            }
          }
        } catch (deleteError) {
          if (kDebugMode) {
            print('⚠️ CRITICAL: Failed to cleanup Auth account: $deleteError');
          }
        }

        throw Exception('Failed to link Google provider: $linkError');
      }

      // STEP 3: Create Firestore document (ONLY if Auth + linking succeeded)
      try {
        if (kDebugMode) {
          print('📄 Creating Firestore document...');
        }

        final userModel = UserModel(
          id: createdUser.uid,
          email: normalizedEmail,
          name: name,
          createdAt: DateTime.now(),
        );

        await _firebaseService
            .collection(AppConstants.collectionUsers)
            .doc(createdUser.uid)  // UID as document ID
            .set(userModel.toJson());

        if (kDebugMode) {
          print('✅ Firestore document created: ${createdUser.uid}');
          print('✅ Account creation complete - all steps succeeded');
        }

        clearPendingGoogleCredential();
        return userModel;

      } catch (firestoreError) {
        if (kDebugMode) {
          print('❌ Firestore creation failed: $firestoreError');
          print('🧹 Cleaning up Auth account...');
        }

        // CLEANUP: Delete the Auth account since Firestore failed
        // createdUser is guaranteed to be non-null here since we used it at line 309
        try {
          await createdUser.delete();
          if (kDebugMode) {
            print('✅ Auth account cleaned up successfully');
          }
        } catch (deleteError) {
          if (kDebugMode) {
            print('⚠️ CRITICAL: Failed to cleanup Auth account: $deleteError');
          }
        }

        throw Exception('Failed to create Firestore document: $firestoreError');
      }

    } catch (e) {
      // FINAL SAFETY NET: Ensure cleanup happened
      if (createdUser != null) {
        if (kDebugMode) {
          print('🧹 Final cleanup check...');
        }

        try {
          final currentAuthUser = _firebaseService.auth.currentUser;
          if (currentAuthUser != null && currentAuthUser.uid == createdUser.uid) {
            await currentAuthUser.delete();
            if (kDebugMode) {
              print('✅ Final cleanup successful');
            }
          }
        } catch (finalCleanupError) {
          if (kDebugMode) {
            print('⚠️ CRITICAL: Final cleanup failed');
            print('⚠️ Manual intervention may be required for UID: ${createdUser.uid}');
          }
        }
      }

      clearPendingGoogleCredential();

      if (kDebugMode) {
        print('❌ Signup failed: $e');
      }

      rethrow;
    }
  }

  /// Create user document in Firestore
  /// Uses UID as document ID for perfect consistency
  Future<void> createUser(UserModel user) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(user.id)  // UID as document ID
          .set(user.toJson());

      if (kDebugMode) {
        print('✅ User document created with UID: ${user.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create user error: $e');
      }
      rethrow;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentFirebaseUser = _firebaseService.currentUser;
      if (currentFirebaseUser == null) {
        return null;
      }

      // Direct access by UID
      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(currentFirebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      return UserModel.fromJson({
        'id': currentFirebaseUser.uid,
        ...?userData,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get current user error: $e');
      }
      return null;
    }
  }

  /// Update user document
  Future<void> updateUser(UserModel user) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(user.id)  // Direct access by UID
          .update(user.toJson());

      if (kDebugMode) {
        print('✅ User document updated: ${user.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update user error: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      clearPendingGoogleCredential();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out error: $e');
      }
      rethrow;
    }
  }

  /// Re-authenticate user with email and password
  Future<void> reauthenticateWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      final normalizedEmail = _normalizeEmail(email);

      // Create credential
      final credential = EmailAuthProvider.credential(
        email: normalizedEmail,
        password: password,
      );

      // Re-authenticate
      await currentUser.reauthenticateWithCredential(credential);

      if (kDebugMode) {
        print('✅ Re-authentication successful with email/password');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Re-authentication error: $e');
      }
      rethrow;
    }
  }

  /// Re-authenticate user with Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google re-authentication canceled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Re-authenticate
      await currentUser.reauthenticateWithCredential(googleCredential);

      if (kDebugMode) {
        print('✅ Re-authentication successful with Google');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Re-authentication error: $e');
      }
      rethrow;
    }
  }

  /// Re-authenticate user (automatically detects provider)
  /// Throws ReauthenticationRequiredException if re-authentication method is not available
  Future<void> reauthenticateUser({
    String? password,
  }) async {
    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Get user providers
      await currentUser.reload();
      final updatedUser = _firebaseService.auth.currentUser;
      if (updatedUser == null) {
        throw Exception('User is null after reload');
      }

      final providers = updatedUser.providerData.map((p) => p.providerId).toList();
      final hasPasswordProvider = providers.contains('password');
      final hasGoogleProvider = providers.contains('google.com');

      if (kDebugMode) {
        print('🔍 User providers: $providers');
      }

      // Re-authenticate based on available providers
      if (hasPasswordProvider && password != null) {
        // Re-authenticate with email/password
        final email = updatedUser.email;
        if (email == null || email.isEmpty) {
          throw ReauthenticationRequiredException(providers);
        }
        await reauthenticateWithEmailPassword(
          email: email,
          password: password,
        );
      } else if (hasGoogleProvider) {
        // Re-authenticate with Google
        await reauthenticateWithGoogle();
      } else {
        // Need re-authentication but don't know how
        throw ReauthenticationRequiredException(providers, email: updatedUser.email);
      }
    } catch (e) {
      if (e is ReauthenticationRequiredException) {
        rethrow;
      }
      if (kDebugMode) {
        print('❌ Re-authentication error: $e');
      }
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🚀 Starting Google sign-in');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in canceled');
      }

      final googleEmail = googleUser.email;
      if (googleEmail.isEmpty) {
        throw Exception('Google email not available');
      }

      final normalizedEmail = _normalizeEmail(googleEmail);

      if (kDebugMode) {
        print('📧 Google email: $normalizedEmail');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // CRITICAL FIX: Do NOT sign in with Google immediately
      // First check if this email exists in our system
      // If not, store credential and redirect to signup WITHOUT creating Auth account

      if (kDebugMode) {
        print('🔍 Checking if user exists in our system...');
      }

      // Check if user exists in Firestore (our source of truth for registered users)
      final existingUserDoc = await _findUserByEmail(normalizedEmail);
      final existsInFirestore = existingUserDoc != null && existingUserDoc.exists;

      if (kDebugMode) {
        print('🔍 Firestore check - User exists: $existsInFirestore');
      }

      // NEW USER: User doesn't exist in Firestore
      if (!existsInFirestore) {
        if (kDebugMode) {
          print('👤 New user - storing Google credential WITHOUT signing in');
          print('📝 User must complete signup with password first');
        }

        // Store credential but DON'T sign in yet
        _pendingGoogleCredential = googleCredential;

        // Redirect to signup to collect password
        throw SignupRequiredException(
          normalizedEmail,
          displayName: googleUser.displayName,
          googleCredential: googleCredential,
        );
      }

      // EXISTING USER: User exists in Firestore, now try to sign in
      if (kDebugMode) {
        print('✅ Existing user found, attempting Google sign-in...');
      }

      UserCredential? userCredential;
      User? firebaseUser;

      try {
        // Try to sign in with Google
        userCredential = await _firebaseService.auth.signInWithCredential(googleCredential);
        firebaseUser = userCredential.user;

        if (kDebugMode) {
          print('✅ Google sign-in successful');
        }

      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('⚠️ Google sign-in failed: ${e.code}');
        }

        if (e.code == 'account-exists-with-different-credential') {
          // Account exists with email/password but Google not linked
          if (kDebugMode) {
            print('🔐 Account exists with email/password, Google not linked');
          }

          _pendingGoogleCredential = googleCredential;
          throw Exception(
              'An account already exists with this email. Please sign in with your email and password. Your Google account will be linked automatically.'
          );
        } else {
          rethrow;
        }
      }

      if (firebaseUser == null) {
        throw Exception('Sign-in succeeded but user is null');
      }

      // Verify user has both providers
      await firebaseUser.reload();
      firebaseUser = _firebaseService.auth.currentUser;

      if (firebaseUser == null) {
        throw Exception('User null after reload');
      }

      final providers = firebaseUser.providerData.map((p) => p.providerId).toList();
      final hasGoogleProvider = providers.contains('google.com');
      final hasPasswordProvider = providers.contains('password');

      if (kDebugMode) {
        print('🔍 Providers found: $providers');
        print('   - Google: $hasGoogleProvider');
        print('   - Password: $hasPasswordProvider');
      }

      // User must have BOTH providers
      if (!hasPasswordProvider) {
        if (kDebugMode) {
          print('⚠️ User only has Google provider, missing password');
          print('🔐 This should not happen for registered users');
          print('🔄 Signing out and redirecting to signup');
        }

        // Sign out incomplete account
        await _firebaseService.auth.signOut();

        _pendingGoogleCredential = googleCredential;

        throw SignupRequiredException(
          normalizedEmail,
          displayName: googleUser.displayName,
          googleCredential: googleCredential,
        );
      }

      if (kDebugMode) {
        print('✅ User fully registered with BOTH providers');
        print('✅ Proceeding with sign-in to MainNavigation');
      }

      // Reload and verify providers one more time
      await firebaseUser.reload();
      firebaseUser = _firebaseService.auth.currentUser;

      if (firebaseUser == null) {
        throw Exception('User null after final reload');
      }

      if (kDebugMode) {
        final finalProviders = firebaseUser.providerData.map((p) => p.providerId).toList();
        print('✅ Signed in successfully with providers: $finalProviders');
      }

      // Get Firestore document by UID
      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        // Create document if missing (edge case)
        if (kDebugMode) {
          print('⚠️ Signed in but no Firestore doc, creating...');
        }

        final userModel = UserModel(
          id: firebaseUser.uid,
          email: normalizedEmail,
          name: googleUser.displayName ?? '',
          createdAt: DateTime.now(),
        );

        await createUser(userModel);
        return userModel;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      return UserModel.fromJson({
        'id': firebaseUser.uid,
        ...?userData,
      });
    } on SignupRequiredException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Google sign-in error: $e');
      }
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      await _firebaseService.auth.sendPasswordResetEmail(email: normalizedEmail);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Reset password error: $e');
      }
      rethrow;
    }
  }

  /// Update age verification for user
  /// Saves age, dateOfBirth, and verification status to Firestore
  Future<void> updateAgeVerification({
    required String userId,
    required int age,
    required DateTime dateOfBirth,
  }) async {
    try {
      if (kDebugMode) {
        print('📅 Updating age verification for user: $userId');
        print('   Age: $age, DOB: $dateOfBirth');
      }

      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update({
        'age': age,
        'dateOfBirth': dateOfBirth,
        'isAgeVerified': true,
        'ageVerifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Age verification updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update age verification error: $e');
      }
      rethrow;
    }
  }

  /// Get age verification status from Firestore
  Future<Map<String, dynamic>?> getAgeVerificationStatus(String userId) async {
    try {
      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) {
        return null;
      }

      return {
        'isAgeVerified': userData['isAgeVerified'] ?? false,
        'age': userData['age'],
        'dateOfBirth': userData['dateOfBirth']?.toDate(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get age verification status error: $e');
      }
      return null;
    }
  }

  /// Get profile setup status from Firestore
  /// Returns true if user has completed profile setup (has preferences with required fields)
  /// Reads from users/{userId}/preferences/{userId} subcollection
  Future<bool> getProfileSetupStatus(String userId) async {
    try {
      // Read preferences from subcollection
      final prefDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionUserPreferences)
          .doc(userId)
          .get();

      if (!prefDoc.exists) {
        return false;
      }

      final preferences = prefDoc.data();
      if (preferences == null) {
        return false;
      }

      // Check if required fields are present
      final hasTone = preferences['conversationTone'] != null &&
          (preferences['conversationTone'] as String).isNotEmpty;
      final hasTopicsToAvoid = preferences['topicsToAvoid'] != null &&
          (preferences['topicsToAvoid'] is List) &&
          (preferences['topicsToAvoid'] as List).isNotEmpty;
      final hasRelationshipStatus = preferences['relationshipStatus'] != null &&
          (preferences['relationshipStatus'] as String).isNotEmpty;
      final hasSupportType = preferences['supportType'] != null &&
          (preferences['supportType'] as String).isNotEmpty;

      return hasTone && hasTopicsToAvoid && hasRelationshipStatus && hasSupportType;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get profile setup status error: $e');
      }
      return false;
    }
  }

  /// Update onboarding completion status for user
  Future<void> updateOnboardingCompletion(String userId) async {
    try {
      if (kDebugMode) {
        print('📚 Updating onboarding completion for user: $userId');
      }

      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update({
        'isOnboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Onboarding completion updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update onboarding completion error: $e');
      }
      rethrow;
    }
  }

  /// Delete user account
  /// Deletes preferences subcollection, Firestore document, and Firebase Auth account
  Future<void> deleteAccount(String userId, {String? password}) async {
    try {
      if (kDebugMode) {
        print('🗑️ Starting account deletion for user: $userId');
      }

      final currentUser = _firebaseService.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('User not authenticated or user ID mismatch');
      }

      // Step 1: Delete preferences subcollection (while user is still authenticated)
      try {
        await _firebaseService
            .collection(AppConstants.collectionUsers)
            .doc(userId)
            .collection(AppConstants.collectionUserPreferences)
            .doc(userId)
            .delete();

        if (kDebugMode) {
          print('✅ Preferences subcollection deleted');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error deleting preferences subcollection: $e');
        }
        // Continue with document deletion even if preferences deletion fails
      }

      // Step 2: Delete Firestore user document (while user is still authenticated)
      try {
        await _firebaseService
            .collection(AppConstants.collectionUsers)
            .doc(userId)
            .delete();

        if (kDebugMode) {
          print('✅ Firestore document deleted');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error deleting Firestore document: $e');
        }
        // Continue with Auth deletion even if Firestore fails
      }

      // Step 3: Delete Firebase Auth account (after Firestore operations, may require re-authentication)
      try {
        // Get fresh user reference
        final userToDelete = _firebaseService.auth.currentUser;
        if (userToDelete == null) {
          throw Exception('User is null before deletion');
        }

        await userToDelete.delete();
        if (kDebugMode) {
          print('✅ Firebase Auth account deleted (no re-authentication needed)');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          if (kDebugMode) {
            print('🔐 Re-authentication required before deletion');
          }

          // Get user providers to determine re-authentication method
          final userToReauth = _firebaseService.auth.currentUser;
          if (userToReauth == null) {
            throw Exception('User is null when re-authentication needed');
          }

          await userToReauth.reload();
          final updatedUser = _firebaseService.auth.currentUser;
          if (updatedUser == null) {
            throw Exception('User is null after reload');
          }

          final providers = updatedUser.providerData.map((p) => p.providerId).toList();
          final hasPasswordProvider = providers.contains('password');
          final hasGoogleProvider = providers.contains('google.com');

          // Re-authenticate if password is provided or if Google is available
          if (hasPasswordProvider && password != null) {
            // Re-authenticate with email/password
            final email = updatedUser.email;
            if (email == null || email.isEmpty) {
              throw ReauthenticationRequiredException(providers);
            }
            await reauthenticateWithEmailPassword(
              email: email,
              password: password,
            );
            // Try to delete again after re-authentication
            final reauthenticatedUser = _firebaseService.auth.currentUser;
            if (reauthenticatedUser != null) {
              await reauthenticatedUser.delete();
              if (kDebugMode) {
                print('✅ Firebase Auth account deleted after re-authentication');
              }
            }
          } else if (hasGoogleProvider) {
            // Re-authenticate with Google
            await reauthenticateWithGoogle();
            // Try to delete again after re-authentication
            final reauthenticatedUser = _firebaseService.auth.currentUser;
            if (reauthenticatedUser != null) {
              await reauthenticatedUser.delete();
              if (kDebugMode) {
                print('✅ Firebase Auth account deleted after Google re-authentication');
              }
            }
          } else {
            // Need re-authentication but method not available
            throw ReauthenticationRequiredException(providers, email: updatedUser.email);
          }
        } else {
          rethrow;
        }
      }

      // Step 3: Sign out from Google if applicable
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error signing out from Google: $e');
        }
        // Non-critical, continue
      }

      clearPendingGoogleCredential();

      if (kDebugMode) {
        print('✅ Account deletion completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Delete account error: $e');
      }
      rethrow;
    }
  }
}