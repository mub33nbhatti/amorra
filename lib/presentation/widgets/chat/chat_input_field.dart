import 'package:amorra/core/utils/app_gradient/app_gradient.dart';
import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:iconsax/iconsax.dart';

/// Chat Input Field Widget
/// Text field with send button for chat messages
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isLimitReached;
  final bool isReplying;
  final String? hintText;
  final FocusNode? focusNode;

  const ChatInputField({
    super.key,
    required this.controller,
    this.onSend,
    this.isLimitReached = false,
    this.isReplying = false,
    this.hintText,
    this.focusNode,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final canSend = hasText && !widget.isLimitReached && !widget.isReplying && widget.onSend != null;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightGrey,
          ),
        ),
      ),
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0).copyWith(left: 0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text Field
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: AppResponsive.screenHeight(context) * 0.2, // Max 20% of screen height
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  maxLines: null,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  scrollController: ScrollController(),
                  scrollPhysics: const ClampingScrollPhysics(),
                  style: AppTextStyles.bodyText(
                    context,
                  ).copyWith(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? AppTexts.chatInputHint,
                    hintStyle: AppTextStyles.hintText(
                      context,
                    ).copyWith(color: AppColors.grey),
                    contentPadding: AppSpacing.symmetric(
                      context,
                      h: 0.04,
                      v: 0.01,
                    ),
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
              onTap: canSend ? widget.onSend : null,
              child: Container(
                width: AppResponsive.iconSize(context, factor: 1.6),
                height: AppResponsive.iconSize(context, factor: 1.6),
                decoration: canSend
                    ? BoxDecoration(shape: BoxShape.circle).withAppGradient()
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey,
                      ),
                child: Icon(
                  Iconsax.send_1,
                  color: AppColors.white,
                  size: AppResponsive.iconSize(context, factor: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
