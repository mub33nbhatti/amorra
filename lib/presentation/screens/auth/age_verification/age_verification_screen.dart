import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/app_responsive/app_responsive.dart';
import '../../../../core/utils/app_spacing/app_spacing.dart';
import '../../../../core/utils/app_styles/app_text_styles.dart';
import '../../../../core/utils/app_texts/app_texts.dart';
import '../../../controllers/auth/age_verification/age_verification_controller.dart';
import '../../../widgets/common/app_date_picker.dart';
import '../../../widgets/common/app_large_button.dart';
import '../../../widgets/common/app_dots_indicator.dart';
import '../../../widgets/common/app_text_field_error_message.dart';
import '../../../widgets/auth/auth_main/auth_header.dart';
import '../../../widgets/auth/age_verification/age_display.dart';

/// Age Verification Screen
/// Mandatory screen for age verification (18+)
class AgeVerificationScreen extends GetView<AgeVerificationController> {
  const AgeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Prevent back navigation - user must complete verification
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Step Indicator (Step 1 of 2) - Full width, equally split
              AppDotsIndicator(
                totalPages: 2,
                currentPage: 0, // Step 1 (Age Verification)
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
                      // Auth Header
                      AuthHeader(
                        title: AppTexts.ageVerificationTitle,
                        subtitle: AppTexts.ageVerificationSubtitle,
                      ),

                // Date of Birth Label
                Text(
                  AppTexts.birthdayLabel,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                AppSpacing.vertical(context, 0.01),

                // Date Picker
                AppDatePicker(
                  initialDate: controller.selectedDate.value,
                  firstDate: DateTime(DateTime.now().year - 120, 1, 1),
                  lastDate: DateTime.now(),
                  onDateChanged: controller.updateSelectedDate,
                ),
                AppSpacing.vertical(context, 0.02),

                // Age Display
                Obx(
                  () => AgeDisplay(
                    age: controller.calculatedAge.value,
                    isValidAge: controller.isValidAge.value,
                  ),
                ),

                      // Error Message
                      Obx(
                        () => Padding(
                          padding: EdgeInsets.only(
                            top: AppResponsive.screenHeight(context) * 0.01,
                          ),
                          child: AppTextFieldErrorMessage(
                            errorText: controller.ageError.value,
                          ),
                        ),
                      ),
                      AppSpacing.vertical(context, 0.04),

                      // Verify Age Button
                      Obx(
                        () => AppLargeButton(
                          text: AppTexts.verifyAgeButton,
                          onPressed: controller.isValidAge.value && controller.isDateSelected.value
                              ? controller.verifyAge
                              : null,
                          isLoading: controller.isLoading.value,
                        ),
                      ),
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

