import 'package:flutter/material.dart';
import 'package:amorra/data/models/subscription_model.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_data_table.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_badge.dart';
import 'package:amorra/presentation/widgets/admin_web/common/web_card.dart';
import 'package:amorra/presentation/widgets/admin_web/subscriptions/subscription_actions_menu.dart';
import 'package:amorra/core/utils/web/web_responsive/web_responsive.dart';
import 'package:amorra/core/utils/web/web_text_styles/web_text_styles.dart';
import 'package:amorra/core/utils/web/web_texts/web_texts.dart';
import 'package:amorra/core/utils/app_colors/app_colors.dart';
import 'package:amorra/core/constants/app_constants.dart';

/// Subscription Table Widget
/// Desktop-optimized data table for subscriptions
class SubscriptionTable extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;
  final Function(SubscriptionModel) onViewDetails;
  final Function(SubscriptionModel) onCancel;
  final Function(SubscriptionModel) onReactivate;
  final Map<String, Map<String, String>> userInfo;

  const SubscriptionTable({
    super.key,
    required this.subscriptions,
    required this.onViewDetails,
    required this.onCancel,
    required this.onReactivate,
    required this.userInfo,
  });

  List<DataColumn> _buildColumns(BuildContext context) {
    return [
      DataColumn(
        label: Text(
          WebTexts.tableHeaderName,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
      DataColumn(
        label: Text(
          WebTexts.tableHeaderEmail,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
      DataColumn(
        label: Text(
          WebTexts.tableHeaderPlan,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
      DataColumn(
        label: Text(
          WebTexts.tableHeaderPrice,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
      DataColumn(
        label: Text(
          WebTexts.tableHeaderStatus,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
      DataColumn(
        label: Text(
          WebTexts.tableHeaderStartDate,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
      DataColumn(
        label: Text(
          WebTexts.tableHeaderEndDate,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
      DataColumn(
        label: Text(
          WebTexts.tableHeaderActions,
          style: WebTextStyles.tableHeader(context),
        ),
      ),
    ];
  }

  List<DataRow> _buildRows(BuildContext context) {
    return subscriptions.map((subscription) {
      final userInfoData = userInfo[subscription.userId];
      final userName = userInfoData?['name'];
      final userEmail = userInfoData?['email'];
      
      return DataRow(
        cells: [
          DataCell(
            Text(
              userName ?? '-',
              style: WebTextStyles.tableCell(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(
              userEmail ?? '-',
              style: WebTextStyles.tableCell(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(
              subscription.planName ?? WebTexts.subscriptionDetailsNA,
              style: WebTextStyles.tableCell(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(
              subscription.price != null
                  ? '\$${subscription.price!.toStringAsFixed(2)}'
                  : '-',
              style: WebTextStyles.tableCell(context),
            ),
          ),
          DataCell(
            WebBadge(
              text: subscription.status,
              color: _getStatusColor(subscription.status),
            ),
          ),
          DataCell(
            Text(
              subscription.startDate != null
                  ? _formatDate(subscription.startDate!)
                  : '-',
              style: WebTextStyles.tableCell(context),
            ),
          ),
          DataCell(
            Text(
              subscription.endDate != null
                  ? _formatDate(subscription.endDate!)
                  : '-',
              style: WebTextStyles.tableCell(context),
            ),
          ),
          DataCell(
            SubscriptionActionsMenu(
              subscription: subscription,
              onViewDetails: () => onViewDetails(subscription),
              onCancel: () => onCancel(subscription),
              onReactivate: () => onReactivate(subscription),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final columns = _buildColumns(context);
    final rows = _buildRows(context);

    return WebCard(
      padding: EdgeInsets.zero,
      child: WebResponsive.isDesktop(context)
          ? WebDataTable(
              columns: columns,
              rows: rows,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: WebDataTable(
                columns: columns,
                rows: rows,
              ),
            ),
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

