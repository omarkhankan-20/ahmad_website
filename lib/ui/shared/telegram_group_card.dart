import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../../core/enums/text_style_type.dart';
import '../../core/services/app_data_service.dart';
import 'colors.dart';
import 'custom_text.dart';

/// The students' Telegram group, shown to people who already have access.
///
/// The link lives in the dashboard, not here: an invite link changes often
/// enough that needing a rebuild for it would mean a dead link for days.
class TelegramGroupCard extends StatelessWidget {
  const TelegramGroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = appData.telegramGroupUrl;
      if (url == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.creamTint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lineStrong, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 19,
                  color: AppColors.brown,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: CustomText(
                    text: 'مجموعة الطلاب',
                    styleType: TextStyleType.h4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const CustomText(
              text: 'اسأل أحمد والطلاب، وشوف شغل غيرك.',
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
              height: 1.6,
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => web.window.open(url, '_blank'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.espresso,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const CustomText(
                  text: 'انضم للمجموعة',
                  styleType: TextStyleType.medium,
                  textColor: AppColors.onDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Says it up front: the group is private and Ahmad approves each
            // request, so "pending" is not a failure.
            const CustomText(
              text: 'المجموعة خاصة — أحمد بيوافق على طلبك خلال شوي.',
              styleType: TextStyleType.small,
              textColor: AppColors.textFaint,
              height: 1.6,
            ),
          ],
        ),
      );
    });
  }
}
