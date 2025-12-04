import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../base_controller.dart';
import '../../../core/config/routes.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/firebase_service.dart';

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
  final RxString selectedCheckInFrequency = ''.obs;

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

  final List<String> checkInFrequencyOptions = [
    AppTexts.checkInFrequencyDaily,
    AppTexts.checkInFrequencyFewTimesWeek,
    AppTexts.checkInFrequencyWeekly,
    AppTexts.checkInFrequencyAsNeeded,
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

      // TODO: Load existing preferences from Firestore
      // This will be implemented when API integration is done
      // For now, start with empty form
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
    }
  }

  /// Update selected tone
  void updateTone(String? tone) {
    selectedTone.value = tone ?? '';
  }

  /// Toggle topic to avoid
  void toggleTopicToAvoid(String topic) {
    if (selectedTopicsToAvoid.contains(topic)) {
      selectedTopicsToAvoid.remove(topic);
    } else {
      selectedTopicsToAvoid.add(topic);
    }
  }

  /// Update relationship status
  void updateRelationshipStatus(String? status) {
    selectedRelationshipStatus.value = status ?? '';
  }

  /// Update support type
  void updateSupportType(String? supportType) {
    selectedSupportType.value = supportType ?? '';
  }

  /// Update check-in frequency
  void updateCheckInFrequency(String? frequency) {
    selectedCheckInFrequency.value = frequency ?? '';
  }

  /// Validate form
  bool validateForm() {
    if (selectedTone.value.isEmpty) {
      showError(
        'Tone Required',
        subtitle: 'Please select your preferred conversation tone',
      );
      return false;
    }

    if (selectedSupportType.value.isEmpty) {
      showError(
        'Support Type Required',
        subtitle: 'Please select the type of support you are looking for',
      );
      return false;
    }

    return true;
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
        'relationshipStatus': selectedRelationshipStatus.value.isEmpty
            ? null
            : selectedRelationshipStatus.value,
        'supportType': selectedSupportType.value,
        'checkInFrequency': selectedCheckInFrequency.value.isEmpty
            ? null
            : selectedCheckInFrequency.value,
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

  /// Save preferences to Firestore (temporary implementation)
  /// TODO: Replace with ProfileApiService when API is integrated
  Future<void> _savePreferencesToFirestore(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    // For now, save directly to Firestore user document
    // This will be replaced with API call later
    try {
      await _firebaseService
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update({
        'preferences': preferences,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}

