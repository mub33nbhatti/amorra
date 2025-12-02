import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'themeMode';
  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  @override
  void onInit() {
    final v = _box.read<String>(_key);
    if (v == 'dark') {
      mode.value = ThemeMode.dark;
    } else if (v == 'light') {
      mode.value = ThemeMode.light;
    }
    super.onInit();
  }

  bool get isDark {
    final m = mode.value;
    if (m == ThemeMode.dark) return true;
    if (m == ThemeMode.light) return false;
    final b = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return b == Brightness.dark;
  }

  void toggle() {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    _box.write(_key, mode.value == ThemeMode.dark ? 'dark' : 'light');
    update();
  }

  void setMode(ThemeMode m) {
    mode.value = m;
    _box.write(_key, m == ThemeMode.dark ? 'dark' : 'light');
    update();
  }
}

