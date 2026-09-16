import 'package:ahmad_website/ui/shared/request_details_card.dart';
import 'package:ahmad_website/ui/views/pinding_view/pinding_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/purchase_request.dart';
import '../../../core/data/payment_content.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';

/// Shown after a payment request is submitted. The job here is to stop the
/// buyer feeling like the money went into a void - and to give them something
/// to do while they wait, because a dead-end page is what turns into a refund
/// request an hour later.
class PendingView extends StatelessWidget {
  const PendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PendingViewController());

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Obx(() {
                final request = controller.request.value;

                return Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.creamTint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.schedule,
                        size: 27,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CustomText(
                      text: 'طلبك وصل',
                      styleType: TextStyleType.h2,
                      alignText: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: controller.isConsultation
                          ? 'أحمد عم يراجع الإيصال، وبيتواصل معك لتحديد موعد الجلسة بعد التأكيد.'
                          : 'أحمد عم يراجع الإيصال. بيوصلك إشعار لما يتفعّل حسابك.',
                      styleType: TextStyleType.medium,
                      textColor: AppColors.textMuted,
                      alignText: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const _StatusTrack(),
                    const SizedBox(height: 24),
                    if (request != null) RequestDetailsCard(request: request),
                    if (request != null) const SizedBox(height: 16),

                    // A button, not a dead page. Someone watching a lesson
                    // waits; someone staring at a spinner closes the tab.
                    AppButton(
                      label: 'شوف الدرس المجاني لحدّ ما يتفعّل',
                      expand: true,
                      onPressed: () => Get.toNamed(Routes.main),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: controller.isRefreshing.value
                          ? 'عم نتحقق…'
                          : 'تحديث الحالة',
                      expand: true,
                      style: AppButtonStyle.outline,
                      onPressed: controller.isRefreshing.value
                          ? () {}
                          : controller.refreshStatus,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 15,
                          color: AppColors.textFaint,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: CustomText(
                            text: PaymentContent.reviewNote,
                            styleType: TextStyleType.small,
                            textColor: AppColors.textMuted,
                            alignText: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}



/// Three states, with the current one named. "Under review" is vague on its
/// own; showing it as the middle of three makes the wait feel finite.
class _StatusTrack extends StatelessWidget {
  const _StatusTrack();

  static const _steps = ['تم الإرسال', 'قيد المراجعة', 'تفعيل الحساب'];

  @override
  Widget build(BuildContext context) {
    const current = 1;
    final children = <Widget>[];

    for (var i = 0; i < _steps.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            width: 32,
            height: 1,
            margin: const EdgeInsets.only(bottom: 22),
            color: i <= current ? AppColors.lineStrong : AppColors.line,
          ),
        );
      }

      final done = i < current;
      final active = i == current;

      children.add(
        SizedBox(
          width: 86,
          child: Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.espresso
                      : active
                      ? AppColors.caramel
                      : AppColors.creamTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check, size: 14, color: AppColors.onDark)
                    : CustomText(
                        text: '${i + 1}',
                        styleType: TextStyleType.small,
                        fontWeight: FontWeight.w700,
                        textColor: active
                            ? AppColors.onCaramel
                            : AppColors.textFaint,
                      ),
              ),
              const SizedBox(height: 6),
              CustomText(
                text: _steps[i],
                styleType: TextStyleType.small,
                alignText: TextAlign.center,
                height: 1.4,
                textColor: done || active
                    ? AppColors.textPrimary
                    : AppColors.textFaint,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              ),
            ],
          ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }
}
