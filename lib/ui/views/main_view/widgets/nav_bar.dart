import 'package:ahmad_website/app/routes/app_routes.dart';
import 'package:ahmad_website/core/services/auth_service.dart';
import 'package:ahmad_website/ui/shared/user_menu.dart';
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

  /// A sheet rather than a Drawer: the drawer lives on the Scaffold, and the
  /// nav bar is a child widget with no handle on it.
  void _openMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.creamSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetItem(
                label: 'الدورة',
                icon: Icons.school_outlined,
                onTap: () => _jump(sheetContext, controller.offeringsKey),
              ),
              _SheetItem(
                label: 'عن أحمد',
                icon: Icons.person_outline,
                onTap: () => _jump(sheetContext, controller.aboutKey),
              ),
              _SheetItem(
                label: 'الاستشارة',
                icon: Icons.chat_bubble_outline,
                onTap: () => _jump(sheetContext, controller.consultationKey),
              ),
              _SheetItem(
                label: 'تواصل معنا',
                icon: Icons.alternate_email,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.toNamed(Routes.about);
                },
              ),
              Obx(
                () => auth.isLoggedIn.value
                    ? const SizedBox.shrink()
                    : _SheetItem(
                        label: 'تسجيل الدخول',
                        icon: Icons.login,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Get.toNamed(Routes.login);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Close first, then scroll: scrolling underneath an open sheet lands the
  /// reader somewhere they cannot see.
  void _jump(BuildContext sheetContext, GlobalKey key) {
    Navigator.pop(sheetContext);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.scrollTo(key),
    );
  }

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
                InkWell(
                  onTap: () => _openMenu(context),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(end: 10),
                    child: Icon(
                      Icons.menu,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
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
                  child: Image.asset("assets/images/pngs/logo.png"),
                ),
              CustomText(
                text: MainContent.creatorName,
                styleType: TextStyleType.h4,
              ),
              const Spacer(),
              // TEMP: token check. Delete before launch.
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
                _NavLink(
                  label: 'تواصل معنا',
                  onTap: () => Get.toNamed(Routes.about),
                ),
                const SizedBox(width: 10),
              ],
              Obx(
                () => auth.isLoggedIn.value
                    ? UserMenu(compact: isMobile)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMobile) ...[
                            _NavLink(
                              label: 'دخول',
                              onTap: () => Get.toNamed(Routes.login),
                              emphasised: true,
                            ),
                            const SizedBox(width: 14),
                          ],
                          AppButton(
                            label: 'اشترك',
                            onPressed: () =>
                                controller.scrollTo(controller.offeringsKey),
                          ),
                        ],
                      ),
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

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.brown),
            const SizedBox(width: 12),
            CustomText(text: label, styleType: TextStyleType.medium),
          ],
        ),
      ),
    );
  }
}
