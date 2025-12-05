import 'package:amorra/presentation/controllers/auth/profile_setup/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/common/app_dots_indicator.dart';
import '../../../widgets/common/app_large_button.dart';
import '../../../widgets/common/app_text_field_error_message.dart';
import '../../../widgets/auth/auth_main/auth_header.dart';
import '../../../widgets/auth/profile_setup/profile_setup_form_section.dart';
import '../../../widgets/auth/profile_setup/profile_setup_dropdown_field.dart';
import '../../../widgets/auth/profile_setup/profile_setup_topics_section.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/app_spacing/app_spacing.dart';
import '../../../../core/utils/app_texts/app_texts.dart';
/// Profile Setup Screen
/// Collects user preferences after age verification
/// Mandatory screen - prevents back navigation
class ProfileSetupScreen extends GetView<ProfileSetupController> {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Prevent back navigation - user must complete profile setup
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: Column(
          children: [
            // Step Indicator (Step 2 of 2) - Full width, equally split
            AppDotsIndicator(
              totalPages: 2,
              currentPage: 1, // Step 2 (Profile Setup)
              fullWidth: true,
              activeColor: AppColors.primary, // Completed steps
              inactiveColor: AppColors.secondary, // Remaining steps
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    AuthHeader(
                      title: AppTexts.profileSetupTitle,
                      subtitle: AppTexts.profileSetupSubtitle,
                    ),

                    // Conversation Tone
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileSetupFormSection(
                            label: AppTexts.conversationToneLabel,
                            field: ProfileSetupDropdownField(
                              value: controller.selectedTone.value.isEmpty
                                  ? null
                                  : controller.selectedTone.value,
                              items: controller.toneOptions,
                              onChanged: controller.updateTone,
                              hint: AppTexts.conversationToneHint,
                              errorText: controller.toneError.value,
                            ),
                          ),
                          // Error message
                          AppTextFieldErrorMessage(
                            errorText: controller.toneError.value,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vertical(context, 0.02),

                    // Topics to Avoid
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileSetupFormSection(
                            label: AppTexts.topicsToAvoidLabel,
                            hint: AppTexts.topicsToAvoidHint,
                            field: const ProfileSetupTopicsSection(),
                          ),
                          // Error message
                          AppTextFieldErrorMessage(
                            errorText: controller.topicsToAvoidError.value,
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
                            field: ProfileSetupDropdownField(
                              value: controller.selectedSupportType.value.isEmpty
                                  ? null
                                  : controller.selectedSupportType.value,
                              items: controller.supportTypeOptions,
                              onChanged: controller.updateSupportType,
                              hint: AppTexts.supportTypeHint,
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
                            field: ProfileSetupDropdownField(
                              value: controller.selectedRelationshipStatus.value.isEmpty
                                  ? null
                                  : controller.selectedRelationshipStatus.value,
                              items: controller.relationshipStatusOptions,
                              onChanged: controller.updateRelationshipStatus,
                              hint: AppTexts.relationshipStatusHint,
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
                    AppSpacing.vertical(context, 0.04),

                    // Save Button
                    Obx(
                      () => AppLargeButton(
                        text: AppTexts.profileSetupSaveButton,
                        onPressed: controller.savePreferences,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
                    AppSpacing.vertical(context, 0.02),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

