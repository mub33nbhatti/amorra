import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';
import 'package:iconsax/iconsax.dart';

/// Chat Input Field Widget
/// Text field with send button for chat messages
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isEnabled;
  final String? hintText;

  const ChatInputField({
    super.key,
    required this.controller,
    this.onSend,
    this.isEnabled = true,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      padding: AppSpacing.symmetric(context, h: 0.02, v: 0.015),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGrey,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 3),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  enabled: isEnabled,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (hasText && onSend != null) {
                      onSend!();
                    }
                  },
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText ?? AppTexts.chatInputHint,
                    hintStyle: AppTextStyles.hintText(context).copyWith(
                      color: AppColors.grey,
                    ),
                    contentPadding: AppSpacing.symmetric(context, h: 0.03, v: 0.02),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            AppSpacing.horizontal(context, 0.02),

            // Send Button
            GestureDetector(
              onTap: hasText && isEnabled ? onSend : null,
              child: Container(
                width: AppResponsive.iconSize(context, factor: 1.5),
                height: AppResponsive.iconSize(context, factor: 1.5),
                decoration: BoxDecoration(
                  color: hasText && isEnabled
                      ? AppColors.primary
                      : AppColors.grey.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.send_1,
                  color: AppColors.white,
                  size: AppResponsive.iconSize(context, factor: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

