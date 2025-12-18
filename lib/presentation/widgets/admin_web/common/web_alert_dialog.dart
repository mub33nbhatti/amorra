import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_button.dart';
import 'package:amorra/core/utils/web/web_responsive/web_responsive.dart';
import 'package:amorra/core/utils/web/web_spacing/web_spacing.dart';
import 'package:amorra/core/utils/web/web_text_styles/web_text_styles.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_gradient/app_gradient.dart';

/// Web Alert Dialog Widget
/// Eye-catching, reusable dialog for admin dashboard
/// Supports confirmation dialogs, detail dialogs, and input dialogs
class WebAlertDialog extends StatelessWidget {
  final String title;
  final String? content;
  final List<DetailRow>? detailRows;
  final Widget? customContent;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final IconData? icon;
  final Color? iconColor;
  final DialogType dialogType;
  final TextEditingController? textController;
  final String? textFieldLabel;
  final String? textFieldHint;
  final int? textFieldMaxLines;
  final Function(String?)? onTextSubmitted;

  const WebAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.detailRows,
    this.customContent,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.icon,
    this.iconColor,
    this.dialogType = DialogType.confirmation,
    this.textController,
    this.textFieldLabel,
    this.textFieldHint,
    this.textFieldMaxLines,
    this.onTextSubmitted,
  }) : assert(
         content != null || detailRows != null || customContent != null,
         'Either content, detailRows, or customContent must be provided',
       );

  /// Show confirmation dialog
  static void show({
    required BuildContext context,
    required String title,
    String? content,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    IconData? icon,
    Color? iconColor,
  }) {
    Get.dialog(
      WebAlertDialog(
        title: title,
        content: content,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        primaryButtonColor: primaryButtonColor,
        secondaryButtonColor: secondaryButtonColor,
        icon: icon,
        iconColor: iconColor,
        dialogType: DialogType.confirmation,
      ),
      barrierDismissible: true,
    );
  }

  /// Show detail dialog
  static void showDetail({
    required BuildContext context,
    required String title,
    required List<DetailRow> detailRows,
    String? closeButtonText,
    VoidCallback? onClose,
    IconData? icon,
    Color? iconColor,
  }) {
    Get.dialog(
      WebAlertDialog(
        title: title,
        detailRows: detailRows,
        secondaryButtonText: closeButtonText,
        onSecondaryPressed: onClose ?? () => Get.back(),
        icon: icon,
        iconColor: iconColor,
        dialogType: DialogType.detail,
      ),
      barrierDismissible: true,
    );
  }

  /// Show input dialog
  static void showInput({
    required BuildContext context,
    required String title,
    String? content,
    required TextEditingController textController,
    String? textFieldLabel,
    String? textFieldHint,
    int? textFieldMaxLines,
    String? primaryButtonText,
    String? secondaryButtonText,
    Function(String?)? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    IconData? icon,
    Color? iconColor,
  }) {
    Get.dialog(
      WebAlertDialog(
        title: title,
        content: content,
        textController: textController,
        textFieldLabel: textFieldLabel,
        textFieldHint: textFieldHint,
        textFieldMaxLines: textFieldMaxLines,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onTextSubmitted: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed ?? () => Get.back(),
        primaryButtonColor: primaryButtonColor,
        secondaryButtonColor: secondaryButtonColor,
        icon: icon,
        iconColor: iconColor,
        dialogType: DialogType.input,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          WebResponsive.radius(context, factor: 1.5),
        ),
      ),
      elevation: 8,
      child: Container(
        width: WebResponsive.isDesktop(context) ? 600 : double.infinity,
        constraints: BoxConstraints(
          maxWidth: WebResponsive.isDesktop(context) ? 600 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            WebResponsive.radius(context, factor: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with gradient background
            _buildHeader(context),
            // Content area
            Flexible(
              child: SingleChildScrollView(
                padding: WebSpacing.all(context, factor: 2.0),
                child: _buildContent(context),
              ),
            ),
            // Action buttons
            if (primaryButtonText != null || secondaryButtonText != null)
              _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(WebResponsive.radius(context, factor: 1.5)),
          topRight: Radius.circular(WebResponsive.radius(context, factor: 1.5)),
        ),
      ).withAppGradient(),
      padding: WebSpacing.all(context, factor: 2.0),
      child: Row(
        children: [
          // Icon
          if (icon != null)
            Container(
              padding: EdgeInsets.all(
                WebResponsive.isDesktop(context) ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: WebResponsive.iconSize(context, factor: 1.2),
              ),
            ),
          if (icon != null) WebSpacing.horizontalSpacing(context, 1.0),
          // Title
          Expanded(
            child: Text(
              title,
              style: WebTextStyles.heading(
                context,
              ).copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (customContent != null) {
      return customContent!;
    }

    if (detailRows != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: detailRows!
            .map((row) => _buildDetailRow(context, row))
            .toList(),
      );
    }

    if (dialogType == DialogType.input) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (content != null) ...[
            Text(content!, style: WebTextStyles.bodyText(context)),
            WebSpacing.medium(context),
          ],
          TextField(
            controller: textController,
            maxLines: textFieldMaxLines ?? 3,
            decoration: InputDecoration(
              labelText: textFieldLabel,
              hintText: textFieldHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  WebResponsive.radius(context, factor: 1.0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  WebResponsive.radius(context, factor: 1.0),
                ),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    // Default content
    if (content != null) {
      return Text(content!, style: WebTextStyles.bodyText(context));
    }

    return const SizedBox.shrink();
  }

  Widget _buildDetailRow(BuildContext context, DetailRow row) {
    return Padding(
      padding: WebSpacing.symmetric(context, v: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: WebResponsive.isDesktop(context) ? 180 : 120,
            child: Text(
              '${row.label}:',
              style: WebTextStyles.label(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: row.value),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: WebSpacing.all(context, factor: 2.0),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            WebResponsive.radius(context, factor: 1.5),
          ),
          bottomRight: Radius.circular(
            WebResponsive.radius(context, factor: 1.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (secondaryButtonText != null) ...[
            WebButton(
              text: secondaryButtonText!,
              onPressed: onSecondaryPressed ?? () => Get.back(),
              isOutlined: true,
              backgroundColor: secondaryButtonColor,
            ),
            WebSpacing.horizontalSpacing(context, 0.75),
          ],
          if (primaryButtonText != null)
            WebButton(
              text: primaryButtonText!,
              onPressed: () {
                if (dialogType == DialogType.input && onTextSubmitted != null) {
                  final text = textController?.text;
                  onTextSubmitted!(text?.isEmpty == true ? null : text);
                } else if (onPrimaryPressed != null) {
                  onPrimaryPressed!();
                }
                Get.back();
              },
              backgroundColor: primaryButtonColor,
            ),
        ],
      ),
    );
  }
}

/// Dialog Type Enum
enum DialogType { confirmation, detail, input }

/// Detail Row Model
class DetailRow {
  final String label;
  final Widget value;

  const DetailRow({required this.label, required this.value});
}
