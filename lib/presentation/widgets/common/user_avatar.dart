import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// User Avatar Widget
/// Reusable user avatar with age-based images or profile image
class UserAvatar extends StatelessWidget {
  final int? age;
  final double? size;
  final String? profileImageUrl;
  final bool showProfileImage; // If true, show profile image; if false, show avatar

  const UserAvatar({
    super.key,
    this.age,
    this.size,
    this.profileImageUrl,
    this.showProfileImage = false,
  });

  /// Get avatar image based on age
  String _getAvatarImage() {
    if (age == null) {
      return AppImages.avatarAge40; // Default
    }
    if (age! >= 70) {
      return AppImages.avatarAge70;
    } else if (age! >= 60) {
      return AppImages.avatarAge60;
    } else {
      return AppImages.avatarAge40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? AppResponsive.iconSize(context, factor: 2);
    final bool shouldShowProfileImage = showProfileImage &&
        profileImageUrl != null &&
        profileImageUrl!.isNotEmpty;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: shouldShowProfileImage
            ? CachedNetworkImage(
                imageUrl: profileImageUrl!,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: avatarSize,
                  height: avatarSize,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  _getAvatarImage(),
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                _getAvatarImage(),
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
