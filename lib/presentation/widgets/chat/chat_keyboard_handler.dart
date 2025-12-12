import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amorra/presentation/controllers/chat/chat_controller.dart';

/// Chat Keyboard Handler Widget
/// Handles keyboard visibility and scroll adjustments
class ChatKeyboardHandler extends StatefulWidget {
  final Widget child;
  final FocusNode inputFocusNode;

  const ChatKeyboardHandler({
    super.key,
    required this.child,
    required this.inputFocusNode,
  });

  @override
  State<ChatKeyboardHandler> createState() => _ChatKeyboardHandlerState();
}

class _ChatKeyboardHandlerState extends State<ChatKeyboardHandler>
    with WidgetsBindingObserver {
  double _lastKeyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to input field focus changes
    widget.inputFocusNode.addListener(() {
      if (widget.inputFocusNode.hasFocus) {
        // Input field is focused (keyboard will open)
        // Delay to let keyboard start appearing
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && widget.inputFocusNode.hasFocus) {
            _handleKeyboardOpen();
          }
        });
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // This is called when keyboard opens/closes
    if (mounted) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (keyboardHeight > 0 && keyboardHeight != _lastKeyboardHeight) {
        _lastKeyboardHeight = keyboardHeight;
        _handleKeyboardOpen();
      } else if (keyboardHeight == 0 && _lastKeyboardHeight > 0) {
        _lastKeyboardHeight = 0;
      }
    }
  }

  void _handleKeyboardOpen() {
    final controller = Get.find<ChatController>();
    controller.scrollUpForKeyboard(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

