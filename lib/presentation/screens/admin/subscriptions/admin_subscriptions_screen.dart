import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/presentation/controllers/admin/admin_subscription_controller.dart';
import 'package:amorra/data/models/subscription_model.dart';
import 'package:amorra/presentation/widgets/admin_web/common/page_header.dart';
import 'package:amorra/presentation/widgets/admin_web/common/empty_state.dart';
import 'package:amorra/presentation/widgets/admin_web/common/loading_state.dart';
import 'package:amorra/presentation/widgets/admin_web/common/filter_chips_row.dart';
import 'package:amorra/presentation/widgets/admin_web/common/analytics_cards_row.dart';
import 'package:amorra/presentation/widgets/admin_web/subscriptions/subscription_table.dart';
import 'package:amorra/presentation/widgets/admin_web/subscriptions/subscription_list.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_alert_dialog.dart';
import 'package:amorra/presentation/widgets/admin_web/subscriptions/subscription_action_dialogs.dart';
import 'package:amorra/core/utils/web/web_responsive/web_responsive.dart';
import 'package:amorra/core/utils/web/web_spacing/web_spacing.dart';
import 'package:amorra/core/utils/web/web_text_styles/web_text_styles.dart';
import 'package:amorra/core/utils/web/web_texts/web_texts.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/constants/app_constants.dart';

/// Admin Subscriptions Screen
/// Desktop-optimized subscription management screen
class AdminSubscriptionsScreen extends GetView<AdminSubscriptionController> {
  const AdminSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminSubscriptionController());

    final searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Analytics Cards (Always show to maintain layout)
        Obx(() {
          final analytics = controller.subscriptionAnalytics;
          return AnalyticsCardsRow(
            cards: [
              AnalyticsCardItem(
                label: WebTexts.analyticsTotal,
                value: analytics['totalSubscriptions']?.toString() ?? '0',
                color: AppColors.primary,
                icon: Iconsax.card_send,
              ),
              // AnalyticsCardItem(
              //   label: WebTexts.analyticsActive,
              //   value: analytics['activeSubscriptions']?.toString() ?? '0',
              //   color: AppColors.success,
              //   icon: Iconsax.tick_circle,
              // ),
              // AnalyticsCardItem(
              //   label: WebTexts.analyticsCancelled,
              //   value: analytics['cancelledSubscriptions']?.toString() ?? '0',
              //   color: Colors.orange,
              //   icon: Iconsax.close_circle,
              // ),
              AnalyticsCardItem(
                label: WebTexts.analyticsMRR,
                value:
                    '\$${((analytics['monthlyRevenue'] ?? 0.0) as double).toStringAsFixed(2)}',
                color: AppColors.secondary,
                icon: Iconsax.dollar_circle,
              ),
            ],
          );
        }),

        WebSpacing.section(context),

        // Header Section (Fixed at top)
        // PageHeader(
        //   title: WebTexts.subscriptionsTitle,
        //   searchHint: WebTexts.subscriptionsSearchHint,
        //   searchController: searchController,
        //   onSearchChanged: (value) {
        //     controller.searchQuery.value = value;
        //     if (value.isEmpty) {
        //       controller.loadSubscriptions();
        //     }
        //   },
        //   filterChips: Obx(() => FilterChipsRow(
        //         chips: [
        //           FilterChipItem(
        //             label: WebTexts.subscriptionsFilterAll,
        //             isSelected: controller.selectedFilter.value == 'all',
        //             onTap: () => controller.setFilter('all'),
        //           ),
        //           FilterChipItem(
        //             label: WebTexts.subscriptionsFilterActive,
        //             isSelected:
        //                 controller.selectedFilter.value ==
        //                     AppConstants.subscriptionStatusActive,
        //             onTap: () =>
        //                 controller.setFilter(AppConstants.subscriptionStatusActive),
        //           ),
        //           FilterChipItem(
        //             label: WebTexts.subscriptionsFilterCancelled,
        //             isSelected:
        //                 controller.selectedFilter.value ==
        //                     AppConstants.subscriptionStatusCancelled,
        //             onTap: () => controller
        //                 .setFilter(AppConstants.subscriptionStatusCancelled),
        //           ),
        //           FilterChipItem(
        //             label: WebTexts.subscriptionsFilterExpired,
        //             isSelected:
        //                 controller.selectedFilter.value ==
        //                     AppConstants.subscriptionStatusExpired,
        //             onTap: () =>
        //                 controller.setFilter(AppConstants.subscriptionStatusExpired),
        //           ),
        //         ],
        //       )),
        // ),

        WebSpacing.section(context),

        // Subscriptions Table/List (Scrollable)
        Expanded(
          child: Obx(() {
            // Watch both subscriptions and userEmails for reactivity
            final subscriptions = controller.subscriptions;
            final userEmails = controller.userEmails;

            if (controller.isLoading.value) {
              return const LoadingState();
            }

            if (subscriptions.isEmpty) {
              return EmptyState(
                icon: Iconsax.card_send,
                message: WebTexts.subscriptionsNoSubscriptionsFound,
              );
            }

            // Use DataTable for desktop, ListView for mobile
            if (WebResponsive.isDesktop(context)) {
              return SingleChildScrollView(
                child: SubscriptionTable(
                  subscriptions: subscriptions,
                  userEmails: userEmails,
                  onViewDetails: (subscription) =>
                      _showSubscriptionDetails(context, subscription),
                  onCancel: (subscription) =>
                      _handleCancelSubscription(context, subscription),
                  onReactivate: (subscription) =>
                      _handleReactivateSubscription(context, subscription),
                ),
              );
            } else {
              // ListView handles its own scrolling, no need for SingleChildScrollView
              return SubscriptionList(
                subscriptions: subscriptions,
                userEmails: userEmails,
                onViewDetails: (subscription) =>
                    _showSubscriptionDetails(context, subscription),
                onCancel: (subscription) =>
                    _handleCancelSubscription(context, subscription),
                onReactivate: (subscription) =>
                    _handleReactivateSubscription(context, subscription),
              );
            }
          }),
        ),
      ],
    );
  }

  void _showSubscriptionDetails(
      BuildContext context, SubscriptionModel subscription) {
    WebAlertDialog.showDetail(
      context: context,
      title: WebTexts.subscriptionDetailsTitle,
      icon: Iconsax.card_send,
      detailRows: [
        DetailRow(
          label: WebTexts.subscriptionDetailsId,
          value: Text(
            subscription.id,
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.subscriptionDetailsUserId,
          value: Text(
            subscription.userId,
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.subscriptionDetailsStatus,
          value: Text(
            subscription.status,
            style: WebTextStyles.bodyText(context),
          ),
        ),
        DetailRow(
          label: WebTexts.subscriptionDetailsPlanName,
          value: Text(
            subscription.planName ?? WebTexts.subscriptionDetailsNA,
            style: WebTextStyles.bodyText(context),
          ),
        ),
        if (subscription.price != null)
          DetailRow(
            label: WebTexts.subscriptionDetailsPrice,
            value: Text(
              '\$${subscription.price!.toStringAsFixed(2)}',
              style: WebTextStyles.bodyText(context),
            ),
          ),
        if (subscription.startDate != null)
          DetailRow(
            label: WebTexts.subscriptionDetailsStartDate,
            value: Text(
              _formatDate(subscription.startDate!),
              style: WebTextStyles.bodyText(context),
            ),
          ),
        if (subscription.endDate != null)
          DetailRow(
            label: WebTexts.subscriptionDetailsEndDate,
            value: Text(
              _formatDate(subscription.endDate!),
              style: WebTextStyles.bodyText(context),
            ),
          ),
        if (subscription.cancelledAt != null)
          DetailRow(
            label: WebTexts.subscriptionDetailsCancelledAt,
            value: Text(
              _formatDate(subscription.cancelledAt!),
              style: WebTextStyles.bodyText(context),
            ),
          ),
        if (subscription.stripeSubscriptionId != null)
          DetailRow(
            label: WebTexts.subscriptionDetailsStripeSubscriptionId,
            value: Text(
              subscription.stripeSubscriptionId!,
              style: WebTextStyles.bodyText(context),
            ),
          ),
        if (subscription.stripeCustomerId != null)
          DetailRow(
            label: WebTexts.subscriptionDetailsStripeCustomerId,
            value: Text(
              subscription.stripeCustomerId!,
              style: WebTextStyles.bodyText(context),
            ),
          ),
        DetailRow(
          label: WebTexts.subscriptionDetailsCreated,
          value: Text(
            _formatDate(subscription.createdAt),
            style: WebTextStyles.bodyText(context),
          ),
        ),
        if (subscription.updatedAt != null)
          DetailRow(
            label: WebTexts.subscriptionDetailsUpdated,
            value: Text(
              _formatDate(subscription.updatedAt!),
              style: WebTextStyles.bodyText(context),
            ),
          ),
      ],
      closeButtonText: WebTexts.userDetailsClose,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleCancelSubscription(
      BuildContext context, SubscriptionModel subscription) {
    SubscriptionActionDialogs.showCancelDialog(
      context,
      subscription,
      (reason) => controller.cancelSubscription(
        subscription.id,
        reason: reason,
      ),
    );
  }

  void _handleReactivateSubscription(
      BuildContext context, SubscriptionModel subscription) {
    SubscriptionActionDialogs.showReactivateDialog(
      context,
      subscription,
      () => controller.reactivateSubscription(subscription.id),
    );
  }
}
