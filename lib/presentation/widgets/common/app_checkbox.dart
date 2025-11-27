import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Custom Checkbox Widget
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Widget? customLabel;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          onChanged!(!value);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SizedBox(
            width: AppResponsive.iconSize(context, factor: 1.2),
            height: AppResponsive.iconSize(context, factor: 1.2),
            child: Checkbox(
              value: value,
              onChanged: (newValue) {
                // Call both the direct checkbox change and the wrapper handler
                if (onChanged != null) {
                  onChanged!(newValue);
                }
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppResponsive.radius(context, factor: 0.5),
                ),
              ),
            ),
          ),
          if (label != null || customLabel != null) ...[
            AppSpacing.horizontal(context, 0.02),
            Expanded(
              child: customLabel ??
                  Text(
                    label!,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.black,
                    ),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

