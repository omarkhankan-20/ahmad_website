import 'package:flutter/material.dart';

import '../../../../core/enums/text_style_type.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/app_button.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../../../shared/section_shell.dart';
import '../main_view_controller.dart';

class _Pillar {
  const _Pillar(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

class ConsultationSection extends StatelessWidget {
  const ConsultationSection({super.key, required this.controller});

  final MainViewController controller;

  static const _pillars = [
    _Pillar(
      Icons.search,
      'تشخيص دقيق',
      'الأخطاء الخفية اللي بتمنع وصولك للجمهور',
    ),
    _Pillar(
      Icons.map_outlined,
      'استراتيجية مفصّلة',
      'خطة عمل مبنية على مجالك وأهدافك',
    ),
    _Pillar(
      Icons.bolt_outlined,
      'تطبيق مباشر',
      'خطوات تشوف أثرها خلال الأسابيع الأولى',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final cards = <Widget>[];
    for (var i = 0; i < _pillars.length; i++) {
      if (i > 0) {
        cards.add(
          isMobile ? const SizedBox(height: 10) : const SizedBox(width: 12),
        );
      }
      final card = _PillarCard(pillar: _pillars[i]);
      cards.add(isMobile ? card : Expanded(child: card));
    }

    return SectionShell(
      topDivider: true,
      child: Column(
        key: controller.consultationKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ahmad's own opening line. A pain question outperforms a feature
          // heading, so it leads the section instead of sitting buried.
          const SectionHeader(
            title: 'تعبت من النشر بدون تقدّم حقيقي في أرقامك؟',
            subtitle: 'الجلسة مصمّمة لتشخيص حسابك أنت، مش نصائح عامة.',
          ),
          const SizedBox(height: 18),
          if (isMobile)
            Column(children: cards)
          else
            // Same reason as the offerings row: stretch inside a scroll view
            // needs a measured height.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cards,
              ),
            ),
          const SizedBox(height: 18),
          const CustomText(
            text: 'لا تخلّي حسابك مكان لجهد ضائع.',
            styleType: TextStyleType.h4,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'احجز جلستك',
            expand: isMobile,
            onPressed: () =>
                controller.startPurchase(controller.consultationOffering),
          ),
        ],
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({required this.pillar});

  final _Pillar pillar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(pillar.icon, size: 20, color: AppColors.brown),
          const SizedBox(height: 10),
          CustomText(text: pillar.title, styleType: TextStyleType.h4),
          const SizedBox(height: 4),
          CustomText(
            text: pillar.body,
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
            height: 1.7,
          ),
        ],
      ),
    );
  }
}
