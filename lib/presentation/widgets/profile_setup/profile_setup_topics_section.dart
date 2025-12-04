import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../widgets/common/app_checkbox.dart';
import '../../controllers/profile_setup/profile_setup_controller.dart';

/// Profile Setup Topics Section Widget
/// Displays topics to avoid with checkboxes
class ProfileSetupTopicsSection extends GetView<ProfileSetupController> {
  const ProfileSetupTopicsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.topicsToAvoidOptions.map((topic) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: AppResponsive.screenHeight(context) * 0.01,
            ),
            child: AppCheckbox(
              value: controller.selectedTopicsToAvoid.contains(topic),
              onChanged: (value) => controller.toggleTopicToAvoid(topic),
              label: topic,
            ),
          );
        }).toList(),
      ),
    );
  }
}

