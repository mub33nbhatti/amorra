import 'package:get/get.dart';
import '../controllers/home/home_controller.dart';

/// Home Binding
/// Initializes HomeController when HomeScreen is accessed
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}

