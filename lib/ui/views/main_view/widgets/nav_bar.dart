import 'package:ahmad_website/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/app_button.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../main_view_controller.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.controller});

  final MainViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.gutter(context),
        vertical: isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(bottom: BorderSide(color: AppColors.line, width: 0.8)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Responsive.maxContentWidth,
          ),
          child: Row(
            children: [
              // Directional padding, not left/right: on an RTL page a literal
              // `left` puts the gap on the wrong side.
              if (isMobile)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 10),
                  child: Icon(
                    Icons.menu,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                )
              else
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.espresso,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const CustomText(
                    text: 'أ',
                    styleType: TextStyleType.h4,
                    textColor: AppColors.onDark,
                  ),
                ),
              CustomText(
                text: MainContent.creatorName,
                styleType: TextStyleType.h4,
              ),
              const Spacer(),
              if (!isMobile) ...[
                _NavLink(
                  label: 'الدورة',
                  onTap: () => controller.scrollTo(controller.offeringsKey),
                ),
                _NavLink(
                  label: 'عن أحمد',
                  onTap: () => controller.scrollTo(controller.aboutKey),
                ),
                _NavLink(
                  label: 'الاستشارة',
                  onTap: () => controller.scrollTo(controller.consultationKey),
                ),
                const SizedBox(width: 10),
                // Returning students need a way in, but it must never compete
                // with the buy button - so it stays plain text.
                _NavLink(
                  label: 'دخول',
                  onTap: () => Get.toNamed(Routes.login),
                  emphasised: true,
                ),
                const SizedBox(width: 14),
              ],
              AppButton(
                label: 'اشترك',
                onPressed: () => controller.scrollTo(controller.offeringsKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: CustomText(
          text: label,
          styleType: TextStyleType.medium,
          height: 1.2,
          textColor: emphasised ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
