import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_spacing/app_spacing.dart';
import '../../../core/utils/app_gradient/app_gradient.dart';
import 'profile_name_display.dart';
import 'profile_name_edit_field.dart';

/// Profile Header Card Widget
/// Displays gradient card with avatar and editable name
class ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final bool isEditingName;
  final TextEditingController nameController;
  final VoidCallback onEditTap;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ProfileHeaderCard({
    super.key,
    required this.userName,
    required this.isEditingName,
    required this.nameController,
    required this.onEditTap,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: AppSpacing.symmetric(
        context,
        h: 0.04,
        v: isEditingName ? 0.04 : 0.02,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 2),
        ),
      ).withAppGradient(),
      child: Column(
        children: [
          // Avatar Circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: AppResponsive.screenWidth(context) * (isEditingName ? 0.15 : 0.25),
            height: AppResponsive.screenWidth(context) * (isEditingName ? 0.15 : 0.25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.white,
                width: 3,
              ),
            ),
            child: Icon(
              Iconsax.profile_2user,
              size: AppResponsive.iconSize(context, factor: isEditingName ? 2.5 : 4),
              color: AppColors.white,
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Name Display/Edit with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                ),
              );
            },
            child: isEditingName
                ? ProfileNameEditField(
                    key: const ValueKey('edit'),
                    nameController: nameController,
                    onSave: onSave,
                    onCancel: onCancel,
                  )
                : ProfileNameDisplay(
                    key: const ValueKey('display'),
                    userName: userName,
                    onEditTap: onEditTap,
                  ),
          ),
        ],
      ),
    );
  }
}

