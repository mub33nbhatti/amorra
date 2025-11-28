import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_images/app_images.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import '../../controllers/auth/signin_controller.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_large_button.dart';
import '../../widgets/common/app_social_button.dart';
import '../../../core/config/routes.dart';

/// Sign In Screen
class SigninScreen extends GetView<SigninController> {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Exit app when back button is pressed on signin screen
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
                AppTexts.signinTitle,
                style: AppTextStyles.headline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontSize: AppResponsive.scaleSize(context, 24),
                ),
              ),

              // Welcome Message
              Text(
                AppTexts.signinWelcomeMessage,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.grey,
                  fontSize: AppResponsive.scaleSize(context, 14),
                ),
              ),
              AppSpacing.vertical(context, 0.02),

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

              // Google Sign In Button
              AppSocialButton(
                text: AppTexts.continueWithGoogle,
                imagePath: AppImages.googleLogo,
                onPressed: controller.signInWithGoogle,
              ),
              AppSpacing.vertical(context, 0.04),

              // Sign Up Link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(color: AppColors.grey),
                    children: [
                      TextSpan(text: AppTexts.dontHaveAccount),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Get.offAllNamed(AppRoutes.signup),
                          child: Text(
                            AppTexts.registerLink,
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
