import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../controllers/profile_setup/profile_setup_controller.dart';
import '../../widgets/common/app_large_button.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/profile_setup/profile_setup_dropdown_field.dart';
import '../../widgets/profile_setup/profile_setup_form_section.dart';
import '../../widgets/profile_setup/profile_setup_topics_section.dart';

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
                () => ProfileSetupFormSection(
                  label: AppTexts.conversationToneLabel,
                  field: ProfileSetupDropdownField(
                    value: controller.selectedTone.value.isEmpty
                        ? null
                        : controller.selectedTone.value,
                    items: controller.toneOptions,
                    onChanged: controller.updateTone,
                    hint: AppTexts.conversationToneHint,
                  ),
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Support Type
              Obx(
                () => ProfileSetupFormSection(
                  label: AppTexts.supportTypeLabel,
                  field: ProfileSetupDropdownField(
                    value: controller.selectedSupportType.value.isEmpty
                        ? null
                        : controller.selectedSupportType.value,
                    items: controller.supportTypeOptions,
                    onChanged: controller.updateSupportType,
                    hint: AppTexts.supportTypeHint,
                  ),
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // // Topics to Avoid
              // ProfileSetupFormSection(
              //   label: AppTexts.topicsToAvoidLabel,
              //   hint: AppTexts.topicsToAvoidHint,
              //   field: const ProfileSetupTopicsSection(),
              // ),
              // AppSpacing.vertical(context, 0.02),
              //
              // // Relationship Status (Optional)
              // Obx(
              //   () => ProfileSetupFormSection(
              //     label: AppTexts.relationshipStatusLabel,
              //     isOptional: true,
              //     field: ProfileSetupDropdownField(
              //       value: controller.selectedRelationshipStatus.value.isEmpty
              //           ? null
              //           : controller.selectedRelationshipStatus.value,
              //       items: controller.relationshipStatusOptions,
              //       onChanged: controller.updateRelationshipStatus,
              //       hint: AppTexts.relationshipStatusHint,
              //     ),
              //   ),
              // ),
              // AppSpacing.vertical(context, 0.02),
              //
              // // Check-in Frequency (Optional)
              // Obx(
              //   () => ProfileSetupFormSection(
              //     label: AppTexts.checkInFrequencyLabel,
              //     isOptional: true,
              //     field: ProfileSetupDropdownField(
              //       value: controller.selectedCheckInFrequency.value.isEmpty
              //           ? null
              //           : controller.selectedCheckInFrequency.value,
              //       items: controller.checkInFrequencyOptions,
              //       onChanged: controller.updateCheckInFrequency,
              //       hint: AppTexts.checkInFrequencyHint,
              //     ),
              //   ),
              // ),
              // AppSpacing.vertical(context, 0.04),

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
      ),
    );
  }
}

