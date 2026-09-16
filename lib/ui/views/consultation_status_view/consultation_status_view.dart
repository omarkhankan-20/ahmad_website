import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/models/consultation.dart';
import '../../../core/enums/consultation_status.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'consultation_status_view_controller.dart';

/// What a buyer sees after their consultation payment is approved. Three
/// states, all driven by the server's status - never by which screen they
/// came from.
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
              constraints: const BoxConstraints(maxWidth: 560),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                  );
                }

                final consultation = controller.consultation.value;
                if (consultation == null) return const SizedBox.shrink();

                return Column(
                  children: [
                    _Header(controller: controller),
                    const SizedBox(height: 20),
                    if (controller.status == ConsultationStatus.scheduled)
                      _ScheduleCard(controller: controller),
                    if (controller.status == ConsultationStatus.scheduled)
                      const SizedBox(height: 14),
                    _BriefCard(consultation: consultation),
                    const SizedBox(height: 14),
                    if (controller.status != ConsultationStatus.done)
                      const _PrepareCard(),
                    if (controller.status != ConsultationStatus.done)
                      const SizedBox(height: 16),
                    _ContactRow(controller: controller),
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
    final (icon, color, title, body) = switch (controller.status) {
      ConsultationStatus.awaiting => (
          Icons.verified_outlined,
          AppColors.brown,
          'تم تأكيد دفعتك',
          // Says exactly who acts next and by when. "We will contact you"
          // with no window is what turns into a chasing message.
          'أحمد بيتواصل معك على الواتساب خلال ٤٨ ساعة لتحديد موعد الجلسة.',
        ),
      ConsultationStatus.scheduled => (
          Icons.event_available_outlined,
          AppColors.success,
          'موعدك مؤكد',
          'بيوصلك تذكير قبل الجلسة بساعة.',
        ),
      ConsultationStatus.done => (
          Icons.check_circle_outline,
          AppColors.success,
          'خلصت الجلسة',
          'إذا في شي ما وضح معك، تواصل مع أحمد.',
        ),
    };

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 27, color: color),
        ),
        const SizedBox(height: 16),
        CustomText(
          text: title,
          styleType: TextStyleType.h2,
          alignText: TextAlign.center,
        ),
        const SizedBox(height: 8),
        CustomText(
          text: body,
          styleType: TextStyleType.medium,
          textColor: AppColors.textMuted,
          alignText: TextAlign.center,
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.controller});

  final ConsultationStatusViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.espressoDeep,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: CustomText(
                    text: 'موعد الجلسة',
                    styleType: TextStyleType.small,
                    textColor: AppColors.onDarkMuted,
                  ),
                ),
                if (controller.countdownLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.espressoSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: controller.countdownLabel,
                      styleType: TextStyleType.small,
                      textColor: AppColors.caramel,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CustomText(
              text: controller.scheduleLabel,
              styleType: TextStyleType.h3,
              textColor: AppColors.onDark,
              fontWeight: FontWeight.w700,
            ),
            if (controller.consultation.value?.meetingLink != null) ...[
              const SizedBox(height: 14),
              // Copy rather than a plain link: the buyer is likely to join
              // from their phone, not from the browser tab they are in now.
              InkWell(
                onTap: controller.copyMeetingLink,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.espressoSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: CustomText(
                            text: controller.consultation.value!.meetingLink!,
                            styleType: TextStyleType.small,
                            textColor: AppColors.onDark,
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
                        color: AppColors.caramel,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.consultation});

  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'اللي رح يحضّر عليه أحمد',
            styleType: TextStyleType.h4,
          ),
          const SizedBox(height: 4),
          // Reflected back so the buyer can spot a wrong link before the
          // session instead of discovering it during it.
          const CustomText(
            text: 'إذا في شي غلط، خبّر أحمد قبل الموعد.',
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          _BriefRow(
            label: 'الحساب',
            value: consultation.accountLink,
            ltr: true,
          ),
          _BriefRow(label: 'المجال', value: consultation.field),
          _BriefRow(label: 'الهدف', value: consultation.goal),
        ],
      ),
    );
  }
}

class _BriefRow extends StatelessWidget {
  const _BriefRow({
    required this.label,
    required this.value,
    this.ltr = false,
  });

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: CustomText(
              text: label,
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: ltr
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: CustomText(
                      text: value,
                      styleType: TextStyleType.medium,
                      alignText: TextAlign.right,
                    ),
                  )
                : CustomText(
                    text: value,
                    styleType: TextStyleType.medium,
                    height: 1.7,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PrepareCard extends StatelessWidget {
  const _PrepareCard();

  static const _items = [
    'خلّي حسابك مفتوح وجاهز للعرض',
    'اكتب أكتر ٣ أسئلة بتلحّ عليك',
    'كون بمكان هادي ونتّك ثابت',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // An unprepared buyer spends half the hour on introductions and
          // leaves feeling the session was thin - then blames the price.
          const CustomText(
            text: 'حضّر حالك للجلسة',
            styleType: TextStyleType.h4,
          ),
          const SizedBox(height: 10),
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.check, size: 15, color: AppColors.brown),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(
                      text: item,
                      styleType: TextStyleType.medium,
                      textColor: AppColors.textMuted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.controller});

  final ConsultationStatusViewController controller;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'تواصل مع أحمد',
      expand: true,
      style: AppButtonStyle.outline,
      icon: Icons.chat_outlined,
      onPressed: () {},
    );
  }
}