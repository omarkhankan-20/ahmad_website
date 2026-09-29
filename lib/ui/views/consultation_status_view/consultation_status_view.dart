import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/consultation_models.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'consultation_status_view_controller.dart';

/// Where a client lands after booking, and where they come back to check on
/// it. Four states: under review, waiting for a slot, scheduled, done.
class ConsultationStatusView extends StatelessWidget {
  const ConsultationStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsultationStatusViewController());

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Obx(() {
                final booking = controller.booking.value;

                if (booking == null) {
                  return _Empty(isLoading: controller.isLoading.value);
                }

                return Column(
                  children: [
                    _Header(controller: controller),
                    const SizedBox(height: 20),
                    if (controller.isAwaitingSchedule ||
                        controller.status == ConsultationStatus.pending)
                      _BriefCard(booking: booking)
                    else
                      _SessionCard(controller: controller, booking: booking),
                    const SizedBox(height: 14),
                    AppButton(
                      label: controller.isLoading.value
                          ? 'عم نحدّث…'
                          : 'تحديث الحالة',
                      expand: true,
                      style: AppButtonStyle.outline,
                      onPressed:
                          controller.isLoading.value ? () {} : controller.load,
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => Get.offAllNamed(Routes.main),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: CustomText(
                          text: 'رجوع للصفحة الرئيسية',
                          styleType: TextStyleType.medium,
                          textColor: AppColors.textMuted,
                        ),
                      ),
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

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final ConsultationStatusViewController controller;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final String title;
    late final String subtitle;

    if (controller.status == ConsultationStatus.done) {
      icon = Icons.check_circle_outline;
      title = 'خلصت الجلسة';
      subtitle = 'إذا بدك جلسة تانية، احجز من الصفحة الرئيسية.';
    } else if (controller.status == ConsultationStatus.rejected) {
      icon = Icons.error_outline;
      title = 'الطلب انرفض';
      subtitle = 'تواصل مع أحمد ليشرحلك السبب ويساعدك تعيد الطلب.';
    } else if (controller.isAwaitingSchedule) {
      icon = Icons.event_available_outlined;
      title = 'طلبك مقبول';
      subtitle = 'أحمد عم يحدّد الموعد، وبيوصلك إشعار لما يتأكّد.';
    } else if (controller.status == ConsultationStatus.scheduled) {
      icon = Icons.videocam_outlined;
      title = 'جلستك محجوزة';
      subtitle = 'احضّر أسئلتك قبل الموعد بشوي.';
    } else {
      icon = Icons.schedule;
      title = 'طلبك وصل';
      subtitle = 'أحمد عم يراجع الإيصال. بيوصلك إشعار لما يتأكّد الحجز.';
    }

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.creamTint,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 24, color: AppColors.brown),
        ),
        const SizedBox(height: 14),
        CustomText(
          text: title,
          styleType: TextStyleType.h2,
          alignText: TextAlign.center,
        ),
        const SizedBox(height: 6),
        CustomText(
          text: subtitle,
          styleType: TextStyleType.medium,
          textColor: AppColors.textMuted,
          alignText: TextAlign.center,
          height: 1.7,
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.controller, required this.booking});

  final ConsultationStatusViewController controller;
  final ConsultationBooking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'التاريخ', value: booking.sessionDate ?? '—'),
          _Row(label: 'الوقت', value: booking.sessionTime ?? '—'),
          // The zone is shown with the time, never on its own line further
          // down: a client abroad reading "6:00" with no zone misses the call.
          if (booking.timezone.isNotEmpty)
            _Row(label: 'المنطقة الزمنية', value: booking.timezone),
          if (booking.hasMeetingLink) ...[
            const Divider(height: 22, color: AppColors.line, thickness: 0.8),
            const CustomText(
              text: 'رابط الجلسة',
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
            const SizedBox(height: 7),
            Obx(
              () => InkWell(
                onTap: controller.copyMeetingLink,
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.creamSunk,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: CustomText(
                            text: booking.meetingLink!,
                            styleType: TextStyleType.medium,
                            alignText: TextAlign.left,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        controller.copiedLink.value
                            ? Icons.check
                            : Icons.copy_rounded,
                        size: 16,
                        color: AppColors.brown,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.booking});

  final ConsultationBooking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'تفاصيل الطلب',
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          _Row(label: 'مجال الشغل', value: booking.industry),
          _Row(label: 'الوقت المفضّل', value: booking.preferredTimeLabel),
          _Row(label: 'رقم العملية', value: booking.transactionNumber),
          _Row(label: 'المبلغ', value: booking.amount),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // An empty value means the server has nothing yet; a blank row reads as a
    // bug, so it simply does not render.
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: CustomText(
              text: label,
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              styleType: TextStyleType.medium,
              alignText: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        if (isLoading)
          const CustomText(
            text: 'عم نحمّل…',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          )
        else ...[
          const CustomText(
            text: 'ما في عندك جلسة محجوزة',
            styleType: TextStyleType.h3,
          ),
          const SizedBox(height: 8),
          const CustomText(
            text: 'احجز جلسة ١:١ مع أحمد من الصفحة الرئيسية.',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
            alignText: TextAlign.center,
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'احجز جلسة',
            onPressed: () => Get.toNamed(Routes.consultation),
          ),
        ],
      ],
    );
  }
}