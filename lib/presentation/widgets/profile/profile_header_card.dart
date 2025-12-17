import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:amorra/core/utils/app_spacing/app_spacing.dart';
import 'package:amorra/core/utils/app_gradient/app_gradient.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/presentation/widgets/common/user_avatar.dart';
import 'package:amorra/presentation/widgets/common/app_loading_indicator.dart';
import 'profile_name_display.dart';
import 'profile_name_edit_field.dart';

/// Profile Header Card Widget
/// Displays gradient card with avatar/profile image (swipeable) and editable name
class ProfileHeaderCard extends StatefulWidget {
  final String userName;
  final int? userAge;
  final String? profileImageUrl;
  final bool isEditingName;
  final bool isUploadingImage;
  final int currentImageIndex;
  final TextEditingController nameController;
  final VoidCallback onEditTap;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onUploadImage;
  final Function(int) onImageSwipe;

  const ProfileHeaderCard({
    super.key,
    required this.userName,
    this.userAge,
    this.profileImageUrl,
    required this.isEditingName,
    required this.isUploadingImage,
    required this.currentImageIndex,
    required this.nameController,
    required this.onEditTap,
    required this.onSave,
    required this.onCancel,
    required this.onUploadImage,
    required this.onImageSwipe,
  });

  @override
  State<ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<ProfileHeaderCard> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentImageIndex);
  }

  @override
  void didUpdateWidget(ProfileHeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update page controller if index changed externally
    if (oldWidget.currentImageIndex != widget.currentImageIndex &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        widget.currentImageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = AppResponsive.screenWidth(context) * (widget.isEditingName ? 0.25 : 0.35);
    final hasProfileImage = widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: AppSpacing.symmetric(
        context,
        h: 0.04,
        v: widget.isEditingName ? 0.02 : 0.01,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 2),
        ),
      ).withAppGradient(),
      child: Column(
        children: [
          // Swipeable Avatar/Profile Image Container
          Stack(
            alignment: Alignment.center,
            children: [
              // Swipeable PageView for Avatar and Profile Image
              SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    widget.onImageSwipe(index);
                  },
                  itemCount: hasProfileImage ? 2 : 1,
                  physics: hasProfileImage
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: avatarSize,
                      height: avatarSize,
                      child: UserAvatar(
                        age: widget.userAge,
                        size: avatarSize,
                        profileImageUrl: widget.profileImageUrl,
                        showProfileImage: index == 1,
                      ),
                    );
                  },
                ),
              ),
              
              // Upload Button Overlay (only show when not editing name)
              if (!widget.isEditingName)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.isUploadingImage ? null : widget.onUploadImage,
                    child: Container(
                      width: AppResponsive.iconSize(context, factor: 1.5),
                      height: AppResponsive.iconSize(context, factor: 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: widget.isUploadingImage
                          ? const Center(
                              child: AppLoadingIndicator(),
                            )
                          : Icon(
                              Iconsax.camera,
                              color: AppColors.primary,
                              size: AppResponsive.iconSize(context, factor: 0.8),
                            ),
                    ),
                  ),
                ),
              
              // Page Indicator (only show if both avatar and profile image exist)
              if (hasProfileImage && !widget.isEditingName)
                Positioned(
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.screenWidth(context) * 0.02,
                      vertical: AppResponsive.screenHeight(context) * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(2, (index) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.currentImageIndex == index
                                ? AppColors.white
                                : AppColors.white.withValues(alpha: 0.5),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
            ],
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
            child: widget.isEditingName
                ? ProfileNameEditField(
                    key: const ValueKey('edit'),
                    nameController: widget.nameController,
                    onSave: widget.onSave,
                    onCancel: widget.onCancel,
                  )
                : ProfileNameDisplay(
                    key: const ValueKey('display'),
                    userName: widget.userName,
                    onEditTap: widget.onEditTap,
                  ),
          ),
        ],
      ),
    );
  }
}

