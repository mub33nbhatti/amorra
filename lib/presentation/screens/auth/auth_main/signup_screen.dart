import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:amorra/presentation/controllers/auth/auth_main/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/app_responsive/app_responsive.dart';
import '../../../../core/utils/app_spacing/app_spacing.dart';
import '../../../../core/utils/app_texts/app_texts.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_large_button.dart';
import '../../../widgets/common/app_social_button.dart';
import '../../../widgets/auth/auth_main/auth_header.dart';
import '../../../widgets/auth/auth_main/auth_footer.dart';

/// Sign Up Screen
class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Exit app when back button is pressed on signup screen
          SystemNavigator.pop();
        }
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
                  // Auth Header
                  AuthHeader(
                    title: AppTexts.signupTitle,
                    subtitle: AppTexts.signupSubtitle,
                  ),

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
                        child: Divider(
                          color: AppColors.lightGrey,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: AppSpacing.symmetric(context, h: 0.02, v: 0),
                        child: Text(
                          AppTexts.orContinueWith,
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: AppResponsive.scaleSize(context, 14),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.lightGrey,
                          thickness: 1,
                        ),
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

                  // Auth Footer
                  AuthFooter(type: AuthFooterType.signup),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
