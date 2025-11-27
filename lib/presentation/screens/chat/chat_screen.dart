import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import '../../../core/utils/app_texts/app_texts.dart';

/// Chat Screen
/// Placeholder screen for chat tab
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          AppTexts.chatTitle,
          style: AppTextStyles.headline(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: AppResponsive.iconSize(context, factor: 5),
              color: AppColors.primary,
            ),
            AppSpacing.vertical(context, 0.03),
            Text(
              'Chat Screen',
              style: AppTextStyles.headline(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            AppSpacing.vertical(context, 0.01),
            Text(
              AppTexts.placeholderText,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

