import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/data/main_content.dart';
import '../../core/enums/text_style_type.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/responsive.dart';
import '../views/main_view/main_view_controller.dart';
import 'app_button.dart';
import 'colors.dart';
import 'custom_text.dart';
import 'user_menu.dart';

/// The one navigation bar, on every page.
///
/// Section links ("الدورة", "عن أحمد", "الاستشارة") point at parts of the home
/// page. On the home page they scroll; anywhere else they go home first and
/// scroll once it has built, so the same link works from every screen.
class SiteNavBar extends StatelessWidget {
  const SiteNavBar({super.key, this.minimal = false});

  /// For signup, login and checkout: logo and account only. A full menu there
  /// adds exits from the middle of a purchase.
  final bool minimal;

  static void goToSection(String section) {
    final onHome = Get.currentRoute == Routes.main ||
        Get.currentRoute == '/' ||
        Get.currentRoute.isEmpty;

    if (onHome && Get.isRegistered<MainViewController>()) {
      Get.find<MainViewController>().scrollToSection(section);
      return;
    }
    Get.offAllNamed(Routes.main, arguments: {'section': section});
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.creamSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        void close(VoidCallback action) {
          Navigator.pop(sheetContext);
          // After the sheet is gone: scrolling or navigating underneath an
          // open sheet lands the reader somewhere they cannot see.
          WidgetsBinding.instance.addPostFrameCallback((_) => action());
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetItem(
                  label: 'الرئيسية',
                  icon: Icons.home_outlined,
                  onTap: () => close(() => Get.offAllNamed(Routes.main)),
                ),
                _SheetItem(
                  label: 'الدورة',
                  icon: Icons.school_outlined,
                  onTap: () => close(() => goToSection('offerings')),
                ),
                _SheetItem(
                  label: 'عن أحمد',
                  icon: Icons.person_outline,
                  onTap: () => close(() => goToSection('about')),
                ),
                _SheetItem(
                  label: 'الاستشارة',
                  icon: Icons.chat_bubble_outline,
                  onTap: () => close(() => goToSection('consultation')),
                ),
                _SheetItem(
                  label: 'تواصل معنا',
                  icon: Icons.alternate_email,
                  onTap: () => close(() => Get.toNamed(Routes.about)),
                ),
                Obx(
                  () => auth.isLoggedIn.value
                      ? const SizedBox.shrink()
                      : _SheetItem(
                          label: 'تسجيل الدخول',
                          icon: Icons.login,
                          onTap: () => close(() => Get.toNamed(Routes.login)),
                        ),
                ),
              ],
            ),
          ),
        );
      },
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
          constraints:
              const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: Row(
            children: [
              if (isMobile && !minimal)
                InkWell(
                  onTap: () => _openMenu(context),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(end: 10),
                    child: Icon(Icons.menu,
                        size: 22, color: AppColors.textPrimary),
                  ),
                ),

              // The logo always leads home - the one link everyone expects.
              InkWell(
                onTap: () => Get.offAllNamed(Routes.main),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMobile)
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.espresso,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Image.asset('images/pngs/logo.png'),
                      ),
                    CustomText(
                      text: MainContent.creatorName,
                      styleType: TextStyleType.h4,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              if (!isMobile && !minimal) ...[
                _NavLink(
                  label: 'الدورة',
                  onTap: () => goToSection('offerings'),
                ),
                _NavLink(
                  label: 'عن أحمد',
                  onTap: () => goToSection('about'),
                ),
                _NavLink(
                  label: 'الاستشارة',
                  onTap: () => goToSection('consultation'),
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
                    : minimal
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isMobile) ...[
                                _NavLink(
                                  label: 'دخول',
                                  emphasised: true,
                                  onTap: () => Get.toNamed(Routes.login),
                                ),
                                const SizedBox(width: 14),
                              ],
                              AppButton(
                                label: 'اشترك',
                                onPressed: () => goToSection('offerings'),
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