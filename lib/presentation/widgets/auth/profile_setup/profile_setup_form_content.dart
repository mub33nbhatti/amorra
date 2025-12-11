import 'package:amorra/presentation/controllers/auth/profile_setup/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/presentation/widgets/common/app_large_button.dart';
import 'package:amorra/presentation/widgets/common/app_text_field_error_message.dart';
import 'package:amorra/presentation/widgets/auth/profile_setup/profile_setup_form_section.dart';
import 'package:amorra/presentation/widgets/auth/profile_setup/profile_setup_pill_button_group.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';

/// Profile Setup Form Content Widget
/// Reusable form content that can be used in ProfileSetupScreen or bottom sheets
class ProfileSetupFormContent extends GetView<ProfileSetupController> {
  final bool showSaveButton;
  final VoidCallback? onSave;

  const ProfileSetupFormContent({
    super.key,
    this.showSaveButton = true,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02).copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conversation Tone
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.conversationToneLabel,
                  hint: AppTexts.conversationToneHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.toneOptions,
                    selectedOptions: controller.selectedTone.value.isEmpty
                        ? []
                        : [controller.selectedTone.value],
                    onSelect: controller.updateTone,
                    errorText: controller.toneError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(errorText: controller.toneError.value),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Sexual Orientation
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.sexualOrientationLabel,
                  hint: AppTexts.sexualOrientationHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.sexualOrientationOptions,
                    selectedOptions:
                        controller.selectedSexualOrientation.value.isEmpty
                        ? []
                        : [controller.selectedSexualOrientation.value],
                    onSelect: controller.updateSexualOrientation,
                    errorText: controller.sexualOrientationError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.sexualOrientationError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Topics to Avoid
          Obx(() {
            final _ = controller.selectedTopicsToAvoid.length;
            final selectedTopics = controller.selectedTopicsToAvoid.toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.topicsToAvoidLabel,
                  hint: AppTexts.topicsToAvoidHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.topicsToAvoidOptions,
                    selectedOptions: selectedTopics,
                    onSelect: controller.updateTopicToAvoid,
                    errorText: controller.topicsToAvoidError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.topicsToAvoidError.value,
                ),
              ],
            );
          }),
          AppSpacing.vertical(context, 0.02),

          // Biggest Challenge
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.biggestChallengeLabel,
                  hint: AppTexts.biggestChallengeHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.biggestChallengeOptions,
                    selectedOptions:
                        controller.selectedBiggestChallenge.value.isEmpty
                        ? []
                        : [controller.selectedBiggestChallenge.value],
                    onSelect: controller.updateBiggestChallenge,
                    errorText: controller.biggestChallengeError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.biggestChallengeError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Support Type
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.supportTypeLabel,
                  hint: AppTexts.supportTypeHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.supportTypeOptions,
                    selectedOptions:
                        controller.selectedSupportType.value.isEmpty
                        ? []
                        : [controller.selectedSupportType.value],
                    onSelect: controller.updateSupportType,
                    errorText: controller.supportTypeError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.supportTypeError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Relationship Status
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.relationshipStatusLabel,
                  hint: AppTexts.relationshipStatusHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.relationshipStatusOptions,
                    selectedOptions:
                        controller.selectedRelationshipStatus.value.isEmpty
                        ? []
                        : [controller.selectedRelationshipStatus.value],
                    onSelect: controller.updateRelationshipStatus,
                    errorText: controller.relationshipStatusError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.relationshipStatusError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Daily Routine
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.dailyRoutineLabel,
                  hint: AppTexts.dailyRoutineHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.dailyRoutineOptions,
                    selectedOptions:
                        controller.selectedDailyRoutine.value.isEmpty
                        ? []
                        : [controller.selectedDailyRoutine.value],
                    onSelect: controller.updateDailyRoutine,
                    errorText: controller.dailyRoutineError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.dailyRoutineError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Interested In
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.interestedInLabel,
                  hint: AppTexts.interestedInHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.interestedInOptions,
                    selectedOptions:
                        controller.selectedInterestedIn.value.isEmpty
                        ? []
                        : [controller.selectedInterestedIn.value],
                    onSelect: controller.updateInterestedIn,
                    errorText: controller.interestedInError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.interestedInError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // AI Communication Style
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.aiCommunicationLabel,
                  hint: AppTexts.aiCommunicationHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.aiCommunicationOptions,
                    selectedOptions:
                        controller.selectedAiCommunication.value.isEmpty
                        ? []
                        : [controller.selectedAiCommunication.value],
                    onSelect: controller.updateAiCommunication,
                    errorText: controller.aiCommunicationError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.aiCommunicationError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // AI Tools Familiarity
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.aiToolsFamiliarityLabel,
                  hint: AppTexts.aiToolsFamiliarityHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.aiToolsFamiliarityOptions,
                    selectedOptions:
                        controller.selectedAiToolsFamiliarity.value.isEmpty
                        ? []
                        : [controller.selectedAiToolsFamiliarity.value],
                    onSelect: controller.updateAiToolsFamiliarity,
                    errorText: controller.aiToolsFamiliarityError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.aiToolsFamiliarityError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // AI Honesty Preference
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.aiHonestyLabel,
                  hint: AppTexts.aiHonestyHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.aiHonestyOptions,
                    selectedOptions: controller.selectedAiHonesty.value.isEmpty
                        ? []
                        : [controller.selectedAiHonesty.value],
                    onSelect: controller.updateAiHonesty,
                    errorText: controller.aiHonestyError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.aiHonestyError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Stress Response
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.stressResponseLabel,
                  hint: AppTexts.stressResponseHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.stressResponseOptions,
                    selectedOptions:
                        controller.selectedStressResponse.value.isEmpty
                        ? []
                        : [controller.selectedStressResponse.value],
                    onSelect: controller.updateStressResponse,
                    errorText: controller.stressResponseError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.stressResponseError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Time Dedication
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupFormSection(
                  label: AppTexts.timeDedicationLabel,
                  hint: AppTexts.timeDedicationHint,
                  field: ProfileSetupPillButtonGroup(
                    options: controller.timeDedicationOptions,
                    selectedOptions:
                        controller.selectedTimeDedication.value.isEmpty
                        ? []
                        : [controller.selectedTimeDedication.value],
                    onSelect: controller.updateTimeDedication,
                    errorText: controller.timeDedicationError.value,
                  ),
                ),
                // Error message
                AppTextFieldErrorMessage(
                  errorText: controller.timeDedicationError.value,
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Save Button
          if (showSaveButton)
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message if there are validation errors
                  if (controller.hasErrors)
                    AppTextFieldErrorMessage(
                      errorText: AppTexts.profileSetupFixErrorsMessage,
                    ),
                  if (controller.hasErrors) AppSpacing.vertical(context, 0.01),
                  AppLargeButton(
                    text: AppTexts.profileSetupSaveButton,
                    onPressed: onSave ?? controller.updatePreferences,
                    isLoading: controller.isLoading.value,
                  ),
                ],
              ),
            ),
          AppSpacing.vertical(context, 0.02),
        ],
      ),
    );
  }
}
