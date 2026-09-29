import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/enums/text_style_type.dart';
import '../../core/services/auth_service.dart';
import 'colors.dart';
import 'custom_text.dart';

/// The signed-in half of the nav bar: an avatar that opens lessons, orders and
/// sign out.
///
/// "دروسي" is shown to every signed-in user, not only buyers. Someone who just
/// paid looks for it immediately, and an empty state with a buy button is a
/// better answer than a missing link.
class UserMenu extends StatelessWidget {
  const UserMenu({super.key, this.compact = false});

  /// Mobile drops the name and keeps the avatar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopupMenuButton<String>(
        tooltip: '',
        offset: const Offset(0, 44),
        color: AppColors.creamSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.line, width: 0.8),
        ),
        onSelected: (value) {
          switch (value) {
            case 'course':
              Get.toNamed(Routes.course);
            case 'orders':
              Get.toNamed(Routes.myOrders);
            case 'logout':
              auth.logout();
          }
        },
        itemBuilder: (_) => [
          _item('course', Icons.play_circle_outline, 'دروسي'),
          _item('orders', Icons.receipt_long_outlined, 'طلباتي'),
          const PopupMenuDivider(height: 1),
          _item('logout', Icons.logout, 'تسجيل الخروج', danger: true),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.creamTint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: auth.initial,
                styleType: TextStyleType.h4,
                fontWeight: FontWeight.w700,
                textColor: AppColors.brownDeep,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: CustomText(
                  text: auth.userName.value,
                  styleType: TextStyleType.medium,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: AppColors.textMuted),
            ],
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(
    String value,
    IconData icon,
    String label, {
    bool danger = false,
  }) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Row(
        children: [
          Icon(icon, size: 18, color: danger ? AppColors.danger : AppColors.brown),
          const SizedBox(width: 10),
          CustomText(
            text: label,
            styleType: TextStyleType.medium,
            textColor: color,
          ),
        ],
      ),
    );
  }
}