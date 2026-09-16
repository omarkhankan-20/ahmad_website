import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/request_details_card.dart';
import '../../shared/section_shell.dart';
import 'rejected_view_controller.dart';

/// The screen that decides whether a rejected buyer fixes their request or
/// disappears with their money already transferred. Everything here points at
/// one action: correct it and send again.
class RejectedView extends StatelessWidget {
  const RejectedView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RejectedViewController());

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
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.report_problem_outlined,
                        size: 26,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Not "your request was rejected". The buyer already sent
                    // real money; blaming them at this moment is how you lose
                    // them for good.
                    const CustomText(
                      text: 'ما قدرنا نأكّد التحويل',
                      styleType: TextStyleType.h2,
                      alignText: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const CustomText(
                      text: 'مصاريك ما راحت. صحّح المعلومات وأعد الإرسال، وأحمد بيراجعها من جديد.',
                      styleType: TextStyleType.medium,
                      textColor: AppColors.textMuted,
                      alignText: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // The reason comes from Ahmad and is the only thing that
                    // tells the buyer what to change, so it gets the most
                    // weight on the page.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAECE7),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.danger, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            text: 'سبب المراجعة',
                            styleType: TextStyleType.small,
                            textColor: AppColors.danger,
                          ),
                          const SizedBox(height: 5),
                          CustomText(
                            text: controller.reason,
                            styleType: TextStyleType.medium,
                            textColor: AppColors.textPrimary,
                            height: 1.7,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (request != null) ...[
                      RequestDetailsCard(request: request),
                      const SizedBox(height: 16),
                    ],

                    const _WhatToCheck(),
                    const SizedBox(height: 18),

                    AppButton(
                      label: 'عدّل وأعد الإرسال',
                      expand: true,
                      onPressed: controller.resubmit,
                    ),
                    const SizedBox(height: 14),

                    // An escape hatch for the case where Ahmad got it wrong.
                    // Without one, the only remaining move is a public
                    // complaint.
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

class _WhatToCheck extends StatelessWidget {
  const _WhatToCheck();

  static const _items = [
    'رقم العملية مطابق تماماً لللي بالإيصال',
    'اسم المُرسِل زي ما هو على الحوالة',
    'صورة الإيصال واضحة وبتبيّن المبلغ والتاريخ',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'قبل ما تعيد الإرسال، تأكّد من:',
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

  final RejectedViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: controller.copyContact,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomText(
                text: 'بتعتقد إنو في غلط؟ تواصل مع أحمد ',
                styleType: TextStyleType.medium,
                textColor: AppColors.textMuted,
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: CustomText(
                  text: RejectedViewController.supportWhatsapp,
                  styleType: TextStyleType.medium,
                  textColor: AppColors.brown,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                controller.copiedContact.value
                    ? Icons.check
                    : Icons.copy_rounded,
                size: 15,
                color: AppColors.brown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}