import 'package:amorra/presentation/widgets/common/ai_avatar.dart';
import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/presentation/widgets/chat/chat_date_label.dart';
import 'package:get/get.dart';
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';
import 'package:amorra/presentation/controllers/auth/auth_controller.dart';
import 'package:iconsax/iconsax.dart';

/// Chat Header Widget
/// Header with AI name and status
class ChatHeader extends GetView<ChatController> {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGrey, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main header content
          Padding(
            padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
            child: Row(
              children: [
                // AI Avatar
                AIAvatar(),
                AppSpacing.horizontal(context, 0.02),

                // AI Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppTexts.chatAIPersonaName,
                        style: AppTextStyles.heading(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontSize: AppResponsive.scaleSize(context, 18),
                            height: 1.3
                        ),
                      ),
                      Obx(() {
                        // Listen to user changes to update status
                        String userName = '';
                        try {
                          if (Get.isRegistered<AuthController>()) {
                            final authController = Get.find<AuthController>();
                            userName = authController.currentUser.value?.name ?? '';
                          }
                        } catch (e) {
                          // AuthController not available, use default
                          userName = '';
                        }

                        // Get first name
                        String firstName = '';
                        if (userName.isNotEmpty) {
                          final nameParts = userName.trim().split(' ');
                          firstName = nameParts.isNotEmpty ? nameParts[0] : '';
                        }

                        // Build status message
                        final statusMessage = firstName.isNotEmpty
                            ? '${AppTexts.chatAIStatusWithName} $firstName!'
                            : AppTexts.chatAIStatus;

                        return Text(
                          statusMessage,
                          style: AppTextStyles.hintText(context).copyWith(
                            color: AppColors.success,
                            fontSize: AppResponsive.scaleSize(context, 12),
                              height: 1.3
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Change Profile Setup Preferences
                IconButton(
                  icon: Icon(
                    Iconsax.setting_3,
                    color: AppColors.black,
                    size: AppResponsive.iconSize(context, factor: 1.2),
                  ),
                  onPressed: controller.showProfileSetupBottomSheet,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Date label on border
          Center(child: ChatDateLabel(date: DateTime.now())),
        ],
      ),
    );
  }
}
