import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_alert_dialog.dart';
import 'package:amorra/core/utils/web/web_texts/web_texts.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';

/// User Action Dialogs
/// Collection of dialogs for user actions
class UserActionDialogs {
  /// Show block/unblock confirmation dialog
  static void showBlockUnblockDialog(
    BuildContext context,
    UserModel user,
    VoidCallback onConfirm,
  ) {
    WebAlertDialog.show(
      context: context,
      title: user.isBlocked ? WebTexts.usersUnblock : WebTexts.usersBlock,
      content: user.isBlocked
          ? '${WebTexts.usersUnblockConfirm} ${user.name}?'
          : '${WebTexts.usersBlockConfirm} ${user.name}?',
      icon: user.isBlocked ? Iconsax.tick_circle : Iconsax.close_circle,
      iconColor: user.isBlocked ? AppColors.success : AppColors.error,
      secondaryButtonText: WebTexts.actionCancel,
      primaryButtonText: user.isBlocked ? WebTexts.usersUnblock : WebTexts.usersBlock,
      primaryButtonColor: user.isBlocked ? AppColors.success : AppColors.error,
      onPrimaryPressed: onConfirm,
    );
  }

}

