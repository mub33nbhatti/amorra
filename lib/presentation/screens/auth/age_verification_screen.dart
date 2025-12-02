import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../controllers/auth/age_verification_controller.dart';
import '../../widgets/common/app_date_picker.dart';
import '../../widgets/common/app_large_button.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/age_display.dart';

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
                  () => controller.ageError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: AppResponsive.screenHeight(context) * 0.01,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: AppResponsive.scaleSize(context, 16),
                                color: AppColors.error,
                              ),
                              AppSpacing.horizontal(context, 0.01),
                              Expanded(
                                child: Text(
                                  controller.ageError.value,
                                  style: AppTextStyles.bodyText(context).copyWith(
                                    color: AppColors.error,
                                    fontSize: AppResponsive.scaleSize(context, 12),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
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
      ),
    );
  }
}

