import 'package:amorra/core/utils/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';

/// User Avatar Widget
/// Reusable user avatar with age-based images
class UserAvatar extends StatelessWidget {
  final int? age;
  final double? size;

  const UserAvatar({super.key, this.age, this.size});

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

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset(
          _getAvatarImage(),
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
