import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_images/app_images.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import 'app_large_button.dart';
import 'app_text_field.dart';

/// App Password Dialog Widget
/// Dialog for password input (used for re-authentication)
class AppPasswordDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String confirmButtonText;
  final String cancelButtonText;
  final Function(String password)? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const AppPasswordDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmButtonText,
    required this.cancelButtonText,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<AppPasswordDialog> createState() => _AppPasswordDialogState();
}

class _AppPasswordDialogState extends State<AppPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onConfirm?.call(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
      ),
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo and Title Row
              Row(
                children: [
                  // App Logo
                  Image.asset(
                    AppImages.splashLogo,
                    width: AppResponsive.iconSize(context, factor: 3),
                    height: AppResponsive.iconSize(context, factor: 2),
                    fit: BoxFit.contain,
                  ),
                  AppSpacing.horizontal(context, 0.02),
                  // Title (centered in remaining space)
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.headline(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: AppResponsive.scaleSize(context, 20),
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vertical(context, 0.02),

              // Subtitle
              Text(
                widget.subtitle,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.grey,
                  fontSize: AppResponsive.scaleSize(context, 14),
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Password Field
              AppTextField(
                label: AppTexts.profileReauthenticatePasswordLabel,
                hintText: AppTexts.profileReauthenticatePasswordHint,
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                showPasswordToggle: true,
                onTogglePassword: _togglePasswordVisibility,
                validator: _validatePassword,
              ),
              AppSpacing.vertical(context, 0.03),

              // Action Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: AppLargeButton(
                      text: widget.cancelButtonText,
                      onPressed: widget.isLoading ? null : widget.onCancel,
                      isLoading: false,
                      backgroundColor: AppColors.lightGrey,
                      textColor: AppColors.black,
                    ),
                  ),
                  AppSpacing.horizontal(context, 0.02),
                  // Confirm Button
                  Expanded(
                    child: AppLargeButton(
                      text: widget.confirmButtonText,
                      onPressed: widget.isLoading ? null : _handleConfirm,
                      isLoading: widget.isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

