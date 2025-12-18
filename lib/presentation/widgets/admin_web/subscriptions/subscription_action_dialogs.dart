import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/data/models/subscription_model.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_alert_dialog.dart';
import 'package:amorra/core/utils/web/web_texts/web_texts.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';

/// Subscription Action Dialogs
/// Collection of dialogs for subscription actions
class SubscriptionActionDialogs {
  /// Show cancel subscription dialog
  static void showCancelDialog(
    BuildContext context,
    SubscriptionModel subscription,
    Function(String?) onConfirm,
  ) {
    final reasonController = TextEditingController();
    WebAlertDialog.showInput(
      context: context,
      title: WebTexts.subscriptionsCancel,
      content: WebTexts.subscriptionsCancelConfirm,
      icon: Iconsax.close_circle,
      iconColor: AppColors.error,
      textController: reasonController,
      textFieldLabel: WebTexts.subscriptionsCancelReason,
      textFieldHint: WebTexts.subscriptionsCancelReasonHint,
      textFieldMaxLines: 3,
      secondaryButtonText: WebTexts.actionCancel,
      primaryButtonText: WebTexts.subscriptionsConfirmCancel,
      primaryButtonColor: AppColors.error,
      onPrimaryPressed: (reason) => onConfirm(reason),
    );
  }

  /// Show reactivate subscription dialog
  static void showReactivateDialog(
    BuildContext context,
    SubscriptionModel subscription,
    VoidCallback onConfirm,
  ) {
    WebAlertDialog.show(
      context: context,
      title: WebTexts.subscriptionsReactivate,
      content: '${WebTexts.subscriptionsReactivateConfirm} ${subscription.userId}?',
      icon: Iconsax.tick_circle,
      iconColor: AppColors.success,
      secondaryButtonText: WebTexts.actionCancel,
      primaryButtonText: WebTexts.subscriptionsReactivate,
      primaryButtonColor: AppColors.success,
      onPrimaryPressed: onConfirm,
    );
  }
}

