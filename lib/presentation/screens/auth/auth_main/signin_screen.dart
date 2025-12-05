import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/app_responsive/app_responsive.dart';
import '../../../../core/utils/app_spacing/app_spacing.dart';
import '../../../../core/utils/app_texts/app_texts.dart';
import '../../../controllers/auth/auth_main/signin_controller.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_large_button.dart';
import '../../../widgets/common/app_social_button.dart';
import '../../../widgets/auth/auth_main/auth_header.dart';
import '../../../widgets/auth/auth_main/auth_footer.dart';

/// Sign In Screen
class SigninScreen extends GetView<SigninController> {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Exit app when back button is pressed on signin screen
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
                title: AppTexts.signinTitle,
                subtitle: AppTexts.signinWelcomeMessage,
              ),

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

              // Forgot Password Link
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: GestureDetector(
              //     onTap: controller.forgotPassword,
              //     child: Text(
              //       AppTexts.forgotPassword,
              //       style: AppTextStyles.bodyText(context).copyWith(
              //         color: AppColors.primary,
              //         fontSize: AppResponsive.scaleSize(context, 14),
              //       ),
              //     ),
              //   ),
              // ),
              AppSpacing.vertical(context, 0.04),

              // Login Button
              Obx(
                () => AppLargeButton(
                  text: AppTexts.loginButton,
                  onPressed: controller.isFormValid.value
                      ? controller.signIn
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
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: AppResponsive.scaleSize(context, 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.lightGrey, thickness: 1),
                  ),
                ],
              ),
              AppSpacing.vertical(context, 0.04),

              // Google Sign In Button
              AppSocialButton(
                text: AppTexts.continueWithGoogle,
                imagePath: AppImages.googleLogo,
                onPressed: controller.signInWithGoogle,
              ),
              AppSpacing.vertical(context, 0.04),

              // Auth Footer
              AuthFooter(type: AuthFooterType.signin),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
