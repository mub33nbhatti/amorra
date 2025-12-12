import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/utils/app_responsive/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/presentation/controllers/main/main_navigation_controller.dart';
import 'package:amorra/core/utils/app_texts/app_texts.dart';
import 'package:amorra/presentation/screens/home/home_screen.dart';
import 'package:amorra/presentation/screens/chat/chat_screen.dart';
import 'package:amorra/presentation/screens/subscription/subscription_screen.dart';
import 'package:amorra/presentation/screens/profile/profile_screen.dart';

/// Main Navigation Screen
/// Contains bottom navigation bar and switches between main screens
class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const ChatScreen(),
      const SubscriptionScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => FlashyTabBar(
          selectedIndex: controller.currentIndex.value,
          showElevation: false,
          iconSize: AppResponsive.iconSize(context, factor: 1.2),
          onItemSelected: (index) => controller.changeTab(index),
          items: [
            FlashyTabBarItem(
              icon: Icon(Iconsax.home_1),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.secondary,
              title: Text(AppTexts.homeTitle),
            ),
            FlashyTabBarItem(
              icon: Icon(Iconsax.message),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.secondary,
              title: Text(AppTexts.chatTitle),
            ),
            FlashyTabBarItem(
              icon: Icon(Iconsax.card_send),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.secondary,
              title: Text(AppTexts.subscriptionTitle),
            ),
            FlashyTabBarItem(
              icon: Icon(Iconsax.profile_2user),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.secondary,
              title: Text(AppTexts.profileTitle),
            ),
          ],
        ),
      ),
    );
  }
}
