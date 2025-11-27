import 'package:get/get.dart';
import '../base_controller.dart';

/// Main Navigation Controller
/// Handles bottom navigation bar state
class MainNavigationController extends BaseController {
  final RxInt currentIndex = 0.obs;

  /// Change tab index
  void changeTab(int index) {
    currentIndex.value = index;
  }
}

