import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/core/config/routes.dart';

/// Auth Footer Widget
/// Reusable footer for auth screens
/// Can display either:
/// - Signup Link (for signin screen)
/// - Terms & Privacy + Login Link (for signup screen)
class AuthFooter extends StatelessWidget {
  final AuthFooterType type;

  const AuthFooter({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AuthFooterType.signin:
        return _buildSigninFooter(context);
      case AuthFooterType.signup:
        return _buildSignupFooter(context);
    }
  }

  /// Build footer for signin screen (Signup Link)
  Widget _buildSigninFooter(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(color: AppColors.grey),
          children: [
                TextSpan(text: AppTexts.dontHaveAccount),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
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
    );
  }

  /// Build footer for signup screen (Terms & Privacy + Login Link)
  Widget _buildSignupFooter(BuildContext context) {
    return Column(
      children: [
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
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
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
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
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
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
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
    );
  }
}

/// Auth Footer Type
enum AuthFooterType {
  signin,
  signup,
}

