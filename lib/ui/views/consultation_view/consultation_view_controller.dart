import 'package:ahmad_website/ui/views/consultation_view/consultation_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/enums/text_style_type.dart';
import '../../../core/utils/responsive.dart';
import '../../shared/app_button.dart';
import '../../shared/app_text_field.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';

class ConsultationView extends StatelessWidget {
  const ConsultationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsultationViewController());
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ahmad's own opening line. A pain question converts better
                  // than a feature heading, so it leads the page.
                  const CustomText(
                    text: 'تعبت من النشر بدون تقدّم حقيقي في أرقامك؟',
                    styleType: TextStyleType.h2,
                  ),
                  const SizedBox(height: 8),
                  const CustomText(
                    text: 'الجلسة مصمّمة لتشخيص حسابك أنت، مش نصائح عامة.',
                    styleType: TextStyleType.medium,
                    textColor: AppColors.textMuted,
                  ),
                  const SizedBox(height: 20),
                  const _Pillars(),
                  SizedBox(height: isMobile ? 22 : 26),
                  _Form(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pillars extends StatelessWidget {
  const _Pillars();

  static const _items = [
    (Icons.search, 'تشخيص دقيق', 'الأخطاء الخفية اللي بتمنع وصولك'),
    (Icons.map_outlined, 'استراتيجية مفصّلة', 'خطة مبنية على مجالك وأهدافك'),
    (Icons.bolt_outlined, 'تطبيق مباشر', 'خطوات تشوف أثرها بأسابيع'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final cards = <Widget>[];
    for (var i = 0; i < _items.length; i++) {
      if (i > 0) {
        cards.add(
          isMobile ? const SizedBox(height: 10) : const SizedBox(width: 10),
        );
      }
      final item = _items[i];
      final card = _PillarCard(icon: item.$1, title: item.$2, body: item.$3);
      cards.add(isMobile ? card : Expanded(child: card));
    }

    return isMobile
        ? Column(children: cards)
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards,
            ),
          );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.brown),
          const SizedBox(height: 9),
          CustomText(text: title, styleType: TextStyleType.h4),
          const SizedBox(height: 3),
          CustomText(
            text: body,
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
            height: 1.65,
          ),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.controller});

  final ConsultationViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      final errors = controller.errors;

      final pairs = <List<Widget>>[
        [
          AppTextField(
            label: 'الاسم',
            hint: 'اسمك الكامل',
            controller: controller.name,
            error: errors['name'],
          ),
          AppTextField(
            label: 'رقم واتساب',
            hint: '+961 …',
            controller: controller.whatsapp,
            error: errors['whatsapp'],
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
          ),
        ],
        [
          AppTextField(
            label: 'رابط حسابك',
            hint: 'instagram.com/…',
            controller: controller.accountLink,
            error: errors['accountLink'],
            keyboardType: TextInputType.url,
            textDirection: TextDirection.ltr,
          ),
          AppTextField(
            label: 'مجالك',
            hint: 'طبخ، رياضة، تعليم…',
            controller: controller.field,
            error: errors['field'],
          ),
        ],
      ];

      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.creamSoft,
          border: Border.all(color: AppColors.line, width: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final pair in pairs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: isMobile
                    ? Column(
                        children: [
                          pair[0],
                          const SizedBox(height: 12),
                          pair[1],
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: pair[0]),
                          const SizedBox(width: 12),
                          Expanded(child: pair[1]),
                        ],
                      ),
              ),
            AppTextField(
              label: 'شو هدفك من الجلسة؟',
              hint: 'اكتب بجملتين وين انت هلق ووين بدك توصل',
              controller: controller.goal,
              error: errors['goal'],
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            const CustomText(
              text: 'الوقت المفضّل',
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
            const SizedBox(height: 7),
            _TimePicker(controller: controller),
            const SizedBox(height: 18),
            const Divider(height: 1, color: AppColors.line, thickness: 0.8),
            const SizedBox(height: 16),
            _Footer(controller: controller, isMobile: isMobile),
          ],
        ),
      );
    });
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({required this.controller});

  final ConsultationViewController controller;

  @override
  Widget build(BuildContext context) {
    // A rough slot, not a calendar. Ahmad confirms the exact time by WhatsApp
    // after the payment clears, so a booking grid here would promise a
    // precision the flow cannot keep.
    return Row(
      children: [
        for (final time in ConsultationViewController.times) ...[
          if (time != ConsultationViewController.times.first)
            const SizedBox(width: 8),
          Expanded(
            child: Obx(() {
              final selected = controller.preferredTime.value == time.$1;
              return InkWell(
                onTap: () => controller.selectTime(time.$1),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.espresso
                        : const Color(0xFFFFFDFA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppColors.espresso
                          : AppColors.lineStrong,
                      width: 0.8,
                    ),
                  ),
                  child: CustomText(
                    text: time.$2,
                    styleType: TextStyleType.medium,
                    textColor: selected
                        ? AppColors.onDark
                        : AppColors.textPrimary,
                    fontWeight:
                        selected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller, required this.isMobile});

  final ConsultationViewController controller;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final price = controller.offering.priceLabel;

    final button = AppButton(
      label: controller.isLoading.value ? 'لحظة…' : 'تابع للدفع',
      expand: isMobile,
      onPressed: controller.isLoading.value ? () {} : controller.submit,
    );

    // Price only renders once GET /products supplies it.
    if (price == null) {
      return SizedBox(width: double.infinity, child: button);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'سعر الجلسة',
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
            CustomText(
              text: price,
              styleType: TextStyleType.h3,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        button,
      ],
    );
  }
}