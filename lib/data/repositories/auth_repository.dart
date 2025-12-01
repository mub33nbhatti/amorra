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

  /// Check if email exists in Firebase Authentication
  Future<bool> _emailExistsInAuth(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final signInMethods = await _firebaseService.auth.fetchSignInMethodsForEmail(normalizedEmail);
      if (kDebugMode) {
        print('📋 Sign-in methods for $normalizedEmail: $signInMethods');
      }
      return signInMethods.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error checking email in Auth: $e');
      }
      return false;
    }
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

  /// Check if user exists in Firestore by UID
  Future<bool> _userExistsInFirestore(String uid) async {
    try {
      final userDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(uid)
          .get();

      return userDoc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error checking user existence: $e');
      }
      return false;
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
}