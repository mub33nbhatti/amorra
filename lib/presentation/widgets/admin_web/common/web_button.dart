import 'package:flutter/material.dart';
import 'package:amorra/core/utils/web/web_responsive/web_responsive.dart';
import 'package:amorra/core/utils/web/web_spacing/web_spacing.dart';
import 'package:amorra/core/utils/web/web_text_styles/web_text_styles.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';

/// Web Button Widget
/// Desktop-optimized button for admin dashboard
class WebButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;

  const WebButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final buttonColor = backgroundColor ?? AppColors.secondary;
    final finalTextColor = textColor ?? (isOutlined ? buttonColor : AppColors.white);

    return SizedBox(
      height: WebResponsive.isDesktop(context) ? 44 : 40,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isDisabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: buttonColor,
                side: BorderSide(color: buttonColor, width: 1.5),
                padding: WebSpacing.button(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    WebResponsive.radius(context, factor: 1.0),
                  ),
                ),
              ),
              child: _buildButtonContent(context, finalTextColor),
            )
          : ElevatedButton(
              onPressed: isDisabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? AppColors.grey.withOpacity(0.3)
                    : buttonColor,
                foregroundColor: finalTextColor,
                disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
                padding: WebSpacing.button(context),
                elevation: isDisabled ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    WebResponsive.radius(context, factor: 1.0),
                  ),
                ),
              ),
              child: _buildButtonContent(context, finalTextColor),
            ),
    );
  }

  Widget _buildButtonContent(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: WebResponsive.iconSize(context, factor: 0.7),
        width: WebResponsive.iconSize(context, factor: 0.7),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: WebResponsive.iconSize(context, factor: 0.8),
            color: textColor,
          ),
          WebSpacing.horizontalSpacing(context, 0.5),
          Text(
            text,
            style: WebTextStyles.buttonText(context).copyWith(
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: WebTextStyles.buttonText(context).copyWith(
        color: textColor,
      ),
    );
  }
}

