import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_images/app_images.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../controllers/auth/signup_controller.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_large_button.dart';
import '../../widgets/common/app_checkbox.dart';
import '../../widgets/common/app_social_button.dart';
import '../../../core/config/routes.dart';

/// Sign Up Screen
class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Exit app when back button is pressed on signup screen
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Logo
              Image.asset(
                AppImages.splashLogo,
                width: AppResponsive.screenWidth(context) * 0.35,
                height: AppResponsive.screenWidth(context) * 0.35,
                fit: BoxFit.contain,
              ),

              // Title
              Text(
                AppTexts.signupTitle,
                style: AppTextStyles.headline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontSize: AppResponsive.scaleSize(context, 24),
                ),
              ),

              // Subtitle
              Text(
                AppTexts.signupSubtitle,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.grey,
                  fontSize: AppResponsive.scaleSize(context, 14),
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Full Name Field
              AppTextField(
                label: AppTexts.fullNameLabel,
                hintText: AppTexts.fullNameHint,
                controller: controller.fullnameController,
                keyboardType: TextInputType.name,
                validator: controller.validateFullname,
              ),
              AppSpacing.vertical(context, 0.01),

              // Email Field
              AppTextField(
                label: AppTexts.emailLabel,
                hintText: AppTexts.emailHint,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              AppSpacing.vertical(context, 0.01),

              // Password Field
              Obx(
                () => AppTextField(
                  label: AppTexts.passwordLabel,
                  hintText: AppTexts.passwordHint,
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordVisible.value,
                  showPasswordToggle: true,
                  onTogglePassword: controller.togglePasswordVisibility,
                  validator: controller.validatePassword,
                ),
              ),
              AppSpacing.vertical(context, 0.01),

              // Age Verification Checkbox
              Obx(
                () => AppCheckbox(
                  value: controller.isAgeVerified.value,
                  onChanged: controller.setAgeVerified,
                  customLabel: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyText(
                        context,
                      ).copyWith(color: AppColors.black),
                      children: [
                        TextSpan(text: AppTexts.ageVerificationText),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.vertical(context, 0.04),

              // Register Button
              Obx(
                () => AppLargeButton(
                  text: AppTexts.registerButton,
                  onPressed: controller.isFormValid.value
                      ? controller.signUp
                      : null,
                  isLoading: controller.isLoading.value,
                ),
              ),
              AppSpacing.vertical(context, 0.04),

              // Divider with "Or continue with"
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.lightGrey, thickness: 1),
                  ),
                  Padding(
                    padding: AppSpacing.symmetric(context, h: 0.02, v: 0),
                    child: Text(
                      AppTexts.orContinueWith,
                      style: AppTextStyles.bodyText(
                        context,
                      ).copyWith(color: AppColors.grey),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.lightGrey, thickness: 1),
                  ),
                ],
              ),
              AppSpacing.vertical(context, 0.04),

              // Google Sign Up Button
              AppSocialButton(
                text: AppTexts.continueWithGoogle,
                imagePath: AppImages.googleLogo,
                onPressed: controller.signUpWithGoogle,
              ),
              AppSpacing.vertical(context, 0.04),

              // Terms & Privacy
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.grey,
                      fontSize: AppResponsive.scaleSize(context, 14),
                    ),
                    children: [
                      TextSpan(text: AppTexts.termsPrefix),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Navigate to terms
                          },
                          child: Text(
                            AppTexts.termsLink,
                            style: AppTextStyles.bodyText(context).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: AppResponsive.scaleSize(context, 14),
                            ),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: AppTexts.termsAnd,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.grey,
                          fontSize: AppResponsive.scaleSize(context, 14),
                        ),
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Navigate to privacy
                          },
                          child: Text(
                            AppTexts.privacyLink,
                            style: AppTextStyles.bodyText(context).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: AppResponsive.scaleSize(context, 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Login Link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(color: AppColors.grey),
                    children: [
                      TextSpan(text: AppTexts.alreadyHaveAccount),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Get.offAllNamed(AppRoutes.signin),
                          child: Text(
                            AppTexts.loginLink,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      ),
      ),
    );
  }
}
