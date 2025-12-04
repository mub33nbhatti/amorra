import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';
import 'package:intl/intl.dart';

/// Chat Timestamp Widget
/// Displays formatted timestamp in 12-hour format (e.g., "2:30 PM")
class ChatTimestampWidget extends StatelessWidget {
  final DateTime timestamp;

  const ChatTimestampWidget({
    super.key,
    required this.timestamp,
  });

  String get _formattedTime {
    return DateFormat('h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime,
      style: AppTextStyles.hintText(context).copyWith(
        color: AppColors.grey,
        fontSize: AppResponsive.scaleSize(context, 11),
      ),
    );
  }
}

