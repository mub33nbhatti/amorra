import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/presentation/controllers/admin/admin_auth_controller.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_text_field.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_button.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_card.dart';
import 'package:amorra/core/utils/web/web_responsive/web_responsive.dart';
import 'package:amorra/core/utils/web/web_spacing/web_spacing.dart';
import 'package:amorra/core/utils/web/web_text_styles/web_text_styles.dart';
import 'package:amorra/core/utils/web/web_texts/web_texts.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:amorra/core/config/routes.dart';

/// Admin Login Screen
/// Desktop-optimized login screen for admin dashboard
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final AdminAuthController controller;

  @override
  void initState() {
    super.initState();
    // Initialize controllers once in initState
    emailController = TextEditingController();
    passwordController = TextEditingController();
    
    // Ensure controller is initialized
    if (!Get.isRegistered<AdminAuthController>()) {
      Get.put(AdminAuthController());
    }
    controller = Get.find<AdminAuthController>();

    // Check if already authenticated and redirect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isAuthenticated.value && controller.isAdmin.value) {
        if (Get.currentRoute != AppRoutes.adminDashboard) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers when widget is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.lightGrey.withOpacity(0.3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: WebSpacing.all(context, factor: 1.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: WebResponsive.isDesktop(context)
                    ? 480
                    : double.infinity,
              ),
              child: WebCard(
                padding: WebSpacing.all(context, factor: 2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Title Section
                    Column(
                      children: [
                        Image.asset(
                          AppImages.splashLogo,
                          width: WebResponsive.iconSize(context, factor: 4.0),
                          height: WebResponsive.iconSize(context, factor: 4.0),
                          fit: BoxFit.contain,
                        ),
                        WebSpacing.large(context),
                        Text(
                          WebTexts.adminLoginTitle,
                          style: WebTextStyles.largeHeading(context).copyWith(
                            color: AppColors.primary
                          ),
                          textAlign: TextAlign.center,
                        ),
                        WebSpacing.medium(context),
                        Text(
                          WebTexts.adminLoginSubtitle,
                          style: WebTextStyles.bodyText(
                            context,
                          ).copyWith(color: AppColors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    WebSpacing.extraLarge(context),

                    // Email Field
                    WebTextField(
                      controller: emailController,
                      label: WebTexts.adminEmailLabel,
                      hintText: WebTexts.adminEmailHint,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    WebSpacing.large(context),

                    // Password Field
                    WebTextField(
                      controller: passwordController,
                      label: WebTexts.adminPasswordLabel,
                      hintText: WebTexts.adminPasswordHint,
                      obscureText: true,
                    ),

                    WebSpacing.extraLarge(context),

                    // Sign In Button
                    Obx(() {
                      final isLoading = controller.isLoading.value;
                      return WebButton(
                        text: isLoading
                            ? WebTexts.adminSigningIn
                            : WebTexts.adminSignInButton,
                        onPressed: isLoading ? null : _handleSignIn,
                        isLoading: isLoading,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignIn() {
    final email = emailController.text;
    final password = passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      controller.showError(
        WebTexts.messageValidationError,
        subtitle: WebTexts.messageValidationError,
      );
      return;
    }

    controller.signIn(email.trim(), password);
  }
}
