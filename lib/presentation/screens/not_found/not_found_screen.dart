import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Not Found Screen
/// Displayed when navigating to an unknown route
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Screen Not Found',
          style: AppTextStyles.headline(context).copyWith(
            color: AppColors.black,
            fontSize: AppResponsive.scaleSize(context, 20),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.close_circle,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            AppSpacing.vertical(context, 0.01),
            Text('404', style: AppTextStyles.headline(context).copyWith(
              color: AppColors.black,
              fontSize: AppResponsive.scaleSize(context, 30),
            ),),
            AppSpacing.vertical(context, 0.02),
            Text(
              'Screen Not Found',
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.black,
                fontSize: AppResponsive.scaleSize(context, 20),
              ),
            ),
            Text(
              'The screen you are looking for does not exist.',
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.black,
                fontSize: AppResponsive.scaleSize(context, 14),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
