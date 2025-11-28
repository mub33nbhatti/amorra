import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Reusable Text Field Widget
class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTogglePassword;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTogglePassword,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey<FormFieldState<String>>();
  bool _hasInteracted = false;

  String? get _errorText {
    return _fieldKey.currentState?.hasError == true
        ? _fieldKey.currentState?.errorText
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: (value) {
            _hasInteracted = true;
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null;
          },
          onChanged: (value) {
            widget.onChanged?.call(value);
            // Trigger validation after change and update state
            if (_hasInteracted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fieldKey.currentState?.validate();
                if (mounted) {
                  setState(() {
                    // Trigger rebuild to show/hide error
                  });
                }
              });
            }
          },
          onTap: () {
            _hasInteracted = true;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.bodyText(context).copyWith(
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.hintText(context).copyWith(
              color: AppColors.grey,
            ),
            suffixIcon: widget.showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      widget.obscureText ? Iconsax.eye_slash : Iconsax.eye,
                      color: AppColors.grey,
                      size: AppResponsive.iconSize(context),
                    ),
                    onPressed: widget.onTogglePassword,
                  )
                : null,
            contentPadding: AppSpacing.symmetric(context, h: 0.03, v: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(
                color: _errorText != null ? AppColors.error : AppColors.lightGrey,
                width: _errorText != null ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(
                color: _errorText != null ? AppColors.error : AppColors.primary,
                width: _errorText != null ? 2 : 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 1.5),
              ),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              height: 0,
              fontSize: 0,
            ),
            helperText: null,
          ),
        ),
        // Error message display below the field
        if (_errorText != null && _hasInteracted)
          Padding(
            padding: EdgeInsets.only(
              top: AppResponsive.screenHeight(context) * 0.008,
              left: AppResponsive.screenWidth(context) * 0.01,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: AppResponsive.scaleSize(context, 14),
                  color: AppColors.error,
                ),
                AppSpacing.horizontal(context, 0.01),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.error,
                      fontSize: AppResponsive.scaleSize(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

