import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/presentation/controllers/auth/auth_main/signin_controller.dart';
import 'package:amorra/presentation/widgets/common/app_text_field.dart';
import 'package:amorra/presentation/widgets/common/app_large_button.dart';
import 'package:amorra/presentation/widgets/common/app_social_button.dart';
import 'package:amorra/presentation/widgets/common/app_checkbox.dart';
import 'package:amorra/presentation/widgets/auth/auth_main/auth_header.dart';
import 'package:amorra/presentation/widgets/auth/auth_main/auth_footer.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Header
              Padding(
                padding: AppSpacing.symmetric(
                  context,
                  h: 0.04,
                  v: 0.02,
                ).copyWith(bottom: 0),
                child: AuthHeader(
                  title: AppTexts.signinTitle,
                  subtitle: AppTexts.signinWelcomeMessage,
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.symmetric(
                    context,
                    h: 0.04,
                    v: 0.02,
                  ).copyWith(top: 0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            onTogglePassword:
                                controller.togglePasswordVisibility,
                            validator: controller.validatePassword,
                          ),
                        ),
                        AppSpacing.vertical(context, 0.015),

                        // Remember Me Checkbox
                        Obx(
                          () => AppCheckbox(
                            value: controller.rememberMe.value,
                            onChanged: controller.toggleRememberMe,
                            label: AppTexts.rememberMe,
                          ),
                        ),
                        AppSpacing.vertical(context, 0.04),

                        // Login Button
                        Obx(
                          () => AppLargeButton(
                            text: AppTexts.loginButton,
                            onPressed: controller.isFormValid.value
                                ? controller.signIn
                                : null,
                            isLoading: controller.isEmailPasswordSigninLoading.value,
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
                              padding: AppSpacing.symmetric(
                                context,
                                h: 0.02,
                                v: 0,
                              ),
                              child: Text(
                                AppTexts.orContinueWith,
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: AppResponsive.scaleSize(
                                    context,
                                    14,
                                  ),
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

                        // Google Sign In Button
                        Obx(
                          () => AppSocialButton(
                            text: AppTexts.continueWithGoogle,
                            imagePath: AppImages.googleLogo,
                            onPressed: controller.signInWithGoogle,
                            isLoading: controller.isGoogleSigninLoading.value,
                          ),
                        ),
                        AppSpacing.vertical(context, 0.04),

                        // Auth Footer
                        AuthFooter(type: AuthFooterType.signin),
                      ],
                    ),
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
