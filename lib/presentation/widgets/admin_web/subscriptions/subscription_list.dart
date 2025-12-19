import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amorra/data/models/subscription_model.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_badge.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_card.dart';
import 'package:amorra/core/utils/web/web_responsive/web_responsive.dart';
import 'package:amorra/core/utils/web/web_spacing/web_spacing.dart';
import 'package:amorra/core/utils/web/web_text_styles/web_text_styles.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/constants/app_constants.dart';

/// Subscription List Widget
/// Mobile-optimized list view for subscriptions
class SubscriptionList extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;
  final Function(SubscriptionModel) onViewDetails;
  final Function(SubscriptionModel) onCancel;
  final Function(SubscriptionModel) onReactivate;
  final Map<String, Map<String, String>> userInfo;

  const SubscriptionList({
    super.key,
    required this.subscriptions,
    required this.onViewDetails,
    required this.onCancel,
    required this.onReactivate,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: WebSpacing.all(context, factor: 0.5),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return WebCard(
          margin: EdgeInsets.only(bottom: WebSpacing.medium(context).height!),
          padding: WebSpacing.all(context, factor: 1.0),
          borderColor: _getStatusColor(subscription.status),
          onTap: () => onViewDetails(subscription),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.card_send,
                    color: _getStatusColor(subscription.status),
                    size: WebResponsive.iconSize(context, factor: 1.0),
                  ),
                  WebSpacing.horizontalSpacing(context, 1.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.planName ?? 'Unknown Plan',
                          style: WebTextStyles.bodyText(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Name: ${userInfo[subscription.userId]?['name'] ?? '-'}',
                          style: WebTextStyles.bodyText(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Email: ${userInfo[subscription.userId]?['email'] ?? '-'}',
                          style: WebTextStyles.caption(context),
                        ),
                      ],
                    ),
                  ),
                  WebBadge(
                    text: subscription.status,
                    color: _getStatusColor(subscription.status),
                  ),
                ],
              ),
              WebSpacing.medium(context),
              if (subscription.price != null)
                Text(
                  'Price: \$${subscription.price!.toStringAsFixed(2)}',
                  style: WebTextStyles.bodyText(context),
                ),
              if (subscription.startDate != null)
                Text(
                  'Start: ${_formatDate(subscription.startDate!)}',
                  style: WebTextStyles.caption(context),
                ),
              if (subscription.endDate != null)
                Text(
                  'End: ${_formatDate(subscription.endDate!)}',
                  style: WebTextStyles.caption(context),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.subscriptionStatusActive:
        return AppColors.success;
      case AppConstants.subscriptionStatusCancelled:
        return Colors.orange;
      case AppConstants.subscriptionStatusExpired:
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

