import 'package:amorra/presentation/controllers/auth/profile_setup/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/app_responsive/app_responsive.dart';
import '../../../../core/utils/app_spacing/app_spacing.dart';
import '../../common/app_checkbox.dart';


/// Profile Setup Topics Section Widget
/// Displays topics to avoid with checkboxes
class ProfileSetupTopicsSection extends GetView<ProfileSetupController> {
  const ProfileSetupTopicsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final hasError = controller.topicsToAvoidError.value.isNotEmpty;
        
        return Container(
          padding: AppSpacing.symmetric(context, h: 0.02, v: 0.015),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.lightGrey,
              width: hasError ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, factor: 1.5),
            ),
          ),
          child: Column(
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
      },
    );
  }
}

