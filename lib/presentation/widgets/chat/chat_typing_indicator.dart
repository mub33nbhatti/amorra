import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';

/// Chat Typing Indicator Widget
/// Animated dots showing AI is typing
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _dotIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotIndex = (_dotIndex + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.screenWidth(context) * 0.03,
        vertical: AppResponsive.screenHeight(context) * 0.015,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppResponsive.screenWidth(context) * 0.01,
            ),
            width: AppResponsive.scaleSize(context, 8),
            height: AppResponsive.scaleSize(context, 8),
            decoration: BoxDecoration(
              color: _dotIndex == index
                  ? AppColors.success
                  : AppColors.success.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

