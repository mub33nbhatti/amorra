import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/utils/app_texts/app_texts.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../base_controller.dart';


/// Profile Setup Controller
/// Handles profile setup form state and validation
class ProfileSetupController extends BaseController {
  final FirebaseService _firebaseService = FirebaseService();
  final _storage = GetStorage();

  // Form state
  final RxString selectedTone = ''.obs;
  final RxList<String> selectedTopicsToAvoid = <String>[].obs;
  final RxString selectedRelationshipStatus = ''.obs;
  final RxString selectedSupportType = ''.obs;

  // Error states (for AppTextField-style error display)
  final RxString toneError = ''.obs;
  final RxString topicsToAvoidError = ''.obs;
  final RxString relationshipStatusError = ''.obs;
  final RxString supportTypeError = ''.obs;

  // Available options
  final List<String> toneOptions = [
    AppTexts.conversationToneGentle,
    AppTexts.conversationToneSlightlyFlirty,
    AppTexts.conversationToneMorePractical,
  ];

  final List<String> topicsToAvoidOptions = [
    AppTexts.topicPolitics,
    AppTexts.topicReligion,
    AppTexts.topicHealthIssues,
    AppTexts.topicWorkStress,
    AppTexts.topicFamilyIssues,
    AppTexts.topicFinancialWorries,
  ];

  final List<String> relationshipStatusOptions = [
    AppTexts.relationshipStatusSingle,
    AppTexts.relationshipStatusDivorced,
    AppTexts.relationshipStatusWidowed,
    AppTexts.relationshipStatusOther,
  ];

  final List<String> supportTypeOptions = [
    AppTexts.supportTypeSupportiveFriend,
    AppTexts.supportTypeRomanticPartner,
    AppTexts.supportTypeCaringListener,
    AppTexts.supportTypeMentor,
    AppTexts.supportTypeCompanion,
  ];

  @override
  void onInit() {
    super.onInit();
    _loadExistingPreferences();
  }

  /// Load existing preferences from Firestore (if any)
  Future<void> _loadExistingPreferences() async {
    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) return;

      // Load existing preferences from Firestore subcollection
      final prefDoc = await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(currentUser.uid)
          .collection(AppConstants.collectionUserPreferences)
          .doc(currentUser.uid)
          .get();

      if (prefDoc.exists && prefDoc.data() != null) {
        final prefs = prefDoc.data()!;
        selectedTone.value = prefs['conversationTone'] ?? '';
        selectedTopicsToAvoid.value = List<String>.from(prefs['topicsToAvoid'] ?? []);
        selectedRelationshipStatus.value = prefs['relationshipStatus'] ?? '';
        selectedSupportType.value = prefs['supportType'] ?? '';
        
        if (kDebugMode) {
          print('✅ Loaded existing preferences from Firestore');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
    }
  }

  /// Update selected tone
  void updateTone(String? tone) {
    selectedTone.value = tone ?? '';
    // Clear error when user selects a value
    if (tone != null && tone.isNotEmpty) {
      toneError.value = '';
    }
  }

  /// Toggle topic to avoid
  void toggleTopicToAvoid(String topic) {
    if (selectedTopicsToAvoid.contains(topic)) {
      selectedTopicsToAvoid.remove(topic);
    } else {
      selectedTopicsToAvoid.add(topic);
    }
    // Clear error when user selects at least one topic
    if (selectedTopicsToAvoid.isNotEmpty) {
      topicsToAvoidError.value = '';
    }
  }

  /// Update relationship status
  void updateRelationshipStatus(String? status) {
    selectedRelationshipStatus.value = status ?? '';
    // Clear error when user selects a value
    if (status != null && status.isNotEmpty) {
      relationshipStatusError.value = '';
    }
  }

  /// Update support type
  void updateSupportType(String? supportType) {
    selectedSupportType.value = supportType ?? '';
    // Clear error when user selects a value
    if (supportType != null && supportType.isNotEmpty) {
      supportTypeError.value = '';
    }
  }

  /// Validate form
  /// Returns true if all required fields are valid
  /// Sets error messages in AppTextField style
  bool validateForm() {
    bool isValid = true;

    // Clear all errors first
    toneError.value = '';
    topicsToAvoidError.value = '';
    relationshipStatusError.value = '';
    supportTypeError.value = '';

    // Validate conversationTone (required)
    if (selectedTone.value.isEmpty) {
      toneError.value = 'Please select your preferred conversation tone';
      isValid = false;
    }

    // Validate topicsToAvoid (required)
    if (selectedTopicsToAvoid.isEmpty) {
      topicsToAvoidError.value = 'Please select at least one topic to avoid';
      isValid = false;
    }

    // Validate relationshipStatus (required)
    if (selectedRelationshipStatus.value.isEmpty) {
      relationshipStatusError.value = 'Please select your relationship status';
      isValid = false;
    }

    // Validate supportType (required)
    if (selectedSupportType.value.isEmpty) {
      supportTypeError.value = 'Please select the type of support you are looking for';
      isValid = false;
    }

    return isValid;
  }

  /// Save preferences and navigate to main
  Future<void> savePreferences() async {
    if (!validateForm()) {
      return;
    }

    try {
      setLoading(true);
      clearError();

      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        showError(
          'Authentication Required',
          subtitle: 'Please sign in to save your preferences',
        );
        setLoading(false);
        return;
      }

      // Prepare preferences map
      final preferences = {
        'conversationTone': selectedTone.value,
        'topicsToAvoid': selectedTopicsToAvoid.toList(),
        'relationshipStatus': selectedRelationshipStatus.value,
        'supportType': selectedSupportType.value,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // TODO: Replace with actual API call to save preferences
      // This will call ProfileApiService.savePreferences() when API is integrated
      await _savePreferencesToFirestore(currentUser.uid, preferences);

      // Mark profile setup as completed in local storage
      await _storage.write(AppConstants.storageKeyProfileSetupCompleted, true);

      if (kDebugMode) {
        print('✅ Profile setup completed and saved');
      }

      showSuccess(
        'Preferences Saved!',
        subtitle: 'Your preferences have been saved successfully',
      );

      // Wait a bit for user to see success message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to main app
      Get.offAllNamed(AppRoutes.mainNavigation);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving preferences: $e');
      }
      showError(
        'Save Failed',
        subtitle: 'We couldn\'t save your preferences. Please try again.',
      );
    } finally {
      setLoading(false);
    }
  }

  /// Save preferences to Firestore subcollection
  /// Saves to users/{userId}/preferences/{userId}
  /// TODO: Replace with ProfileApiService when API is integrated
  Future<void> _savePreferencesToFirestore(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      // Save to subcollection: users/{userId}/preferences/{userId}
      // Using set() with merge: true to create or update (overwrites existing)
      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionUserPreferences)
          .doc(userId)
          .set({
        'userId': userId,
        ...preferences,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Preferences saved to Firestore subcollection: users/$userId/preferences/$userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving preferences to Firestore: $e');
      }
      rethrow;
    }
  }
}

