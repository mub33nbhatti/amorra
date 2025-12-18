import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/presentation/controllers/admin/admin_user_controller.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/presentation/widgets/admin_web/common/page_header.dart';
import 'package:amorra/presentation/widgets/admin_web/common/empty_state.dart';
import 'package:amorra/presentation/widgets/admin_web/common/loading_state.dart';
import 'package:amorra/presentation/widgets/admin_web/common/filter_chips_row.dart';
import 'package:amorra/presentation/widgets/admin_web/users/user_table.dart';
import 'package:amorra/presentation/widgets/admin_web/users/user_list.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_alert_dialog.dart';
import 'package:amorra/presentation/widgets/admin_web/users/user_action_dialogs.dart';
import 'package:amorra/core/utils/web/web_responsive/web_responsive.dart';
import 'package:amorra/core/utils/web/web_spacing/web_spacing.dart';
import 'package:amorra/core/utils/web/web_text_styles/web_text_styles.dart';
import 'package:amorra/core/utils/web/web_texts/web_texts.dart';

/// Admin Users Screen
/// Desktop-optimized user management screen
class AdminUsersScreen extends GetView<AdminUserController> {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminUserController());

    final searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Section (Fixed at top)
        PageHeader(
            title: WebTexts.usersTitle,
            searchHint: WebTexts.usersSearchHint,
            searchController: searchController,
            onSearchChanged: (value) {
              controller.searchQuery.value = value;
              if (value.isEmpty) {
                controller.loadUsers();
              }
            },
            filterChips: Obx(() => FilterChipsRow(
                  chips: [
                    FilterChipItem(
                      label: WebTexts.usersFilterAll,
                      isSelected: controller.selectedFilter.value == 'all',
                      onTap: () => controller.setFilter('all'),
                    ),
                    FilterChipItem(
                      label: WebTexts.usersFilterBlocked,
                      isSelected: controller.selectedFilter.value == 'blocked',
                      onTap: () => controller.setFilter('blocked'),
                    ),
                    FilterChipItem(
                      label: WebTexts.usersFilterSubscribed,
                      isSelected: controller.selectedFilter.value == 'subscribed',
                      onTap: () => controller.setFilter('subscribed'),
                    ),
                    FilterChipItem(
                      label: WebTexts.usersFilterFree,
                      isSelected: controller.selectedFilter.value == 'free',
                      onTap: () => controller.setFilter('free'),
                    ),
                  ],
                )),
          ),

        WebSpacing.section(context),

        // Users Table/List (Scrollable)
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingState();
            }

            if (controller.users.isEmpty) {
              return EmptyState(
                icon: Iconsax.profile_2user,
                message: WebTexts.usersNoUsersFound,
              );
            }

            // Use DataTable for desktop, ListView for mobile
            if (WebResponsive.isDesktop(context)) {
              return SingleChildScrollView(
                child: UserTable(
                  users: controller.users,
                  onViewDetails: (user) => _showUserDetails(context, user),
                  onBlockUnblock: (user) => _handleBlockUnblock(context, user),
                ),
              );
            } else {
              // ListView handles its own scrolling, no need for SingleChildScrollView
              return UserList(
                users: controller.users,
                onViewDetails: (user) => _showUserDetails(context, user),
                onBlockUnblock: (user) => _handleBlockUnblock(context, user),
              );
            }
          }),
        ),
      ],
    );
  }

  void _showUserDetails(BuildContext context, UserModel user) {
    WebAlertDialog.showDetail(
      context: context,
      title: '${WebTexts.userDetailsTitle}: ${user.name}',
      icon: Iconsax.profile_2user,
      detailRows: [
        DetailRow(
          label: WebTexts.userDetailsName,
          value: Text(
            user.name,
            style: WebTextStyles.bodyText(context),
          ),
        ),
        if (user.email != null)
          DetailRow(
            label: WebTexts.userDetailsEmail,
            value: Text(
              user.email!,
              style: WebTextStyles.bodyText(context),
            ),
          ),
        if (user.age != null)
          DetailRow(
            label: WebTexts.userDetailsAge,
            value: Text(
              user.age.toString(),
              style: WebTextStyles.bodyText(context),
            ),
          ),
        DetailRow(
          label: WebTexts.userDetailsUserId,
          value: Text(
            user.id,
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.userDetailsCreated,
          value: Text(
            _formatDate(user.createdAt),
            style: WebTextStyles.bodyText(context),
          ),
        ),
        if (user.updatedAt != null)
          DetailRow(
            label: WebTexts.userDetailsUpdated,
            value: Text(
              _formatDate(user.updatedAt!),
              style: WebTextStyles.bodyText(context),
            ),
          ),
        DetailRow(
          label: WebTexts.userDetailsSubscriptionStatus,
          value: Text(
            user.subscriptionStatus,
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.userDetailsIsSubscribed,
          value: Text(
            user.isSubscribed.toString(),
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.userDetailsAgeVerified,
          value: Text(
            user.isAgeVerified.toString(),
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.userDetailsOnboardingComplete,
          value: Text(
            user.isOnboardingCompleted.toString(),
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.userDetailsIsBlocked,
          value: Text(
            user.isBlocked.toString(),
            style: WebTextStyles.bodyText(context),
          ),
        ),
      ],
      closeButtonText: WebTexts.userDetailsClose,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handleBlockUnblock(BuildContext context, UserModel user) {
    // Capture the action type at the time the dialog is shown
    final bool shouldUnblock = user.isBlocked;
    final String userId = user.id;
    
    UserActionDialogs.showBlockUnblockDialog(
      context,
      user,
      () {
        // Use the captured action type instead of checking user.isBlocked again
        if (shouldUnblock) {
          controller.unblockUser(userId);
        } else {
          controller.blockUser(userId);
        }
      },
    );
  }
}
