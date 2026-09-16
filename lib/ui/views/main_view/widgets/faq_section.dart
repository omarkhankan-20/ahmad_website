import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../../../shared/section_shell.dart';
import '../main_view_controller.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key, required this.controller});

  final MainViewController controller;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < MainContent.faqs.length; i++) {
      final faq = MainContent.faqs[i];
      final index = i;
      rows.add(
        Obx(
          () => _FaqRow(
            question: faq.question,
            answer: faq.answer,
            expanded: controller.expandedFaq.value == index,
            onTap: () => controller.toggleFaq(index),
            isLast: index == MainContent.faqs.length - 1,
          ),
        ),
      );
    }

    return SectionShell(
      topDivider: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'أسئلة متكررة'),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.onTap,
    required this.isLast,
  });

  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.line, width: 0.8),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: question,
                    styleType: TextStyleType.h4,
                  ),
                ),
                const SizedBox(width: 12),
                // Motion that answers the tap, not decoration.
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                    color: expanded ? AppColors.brown : AppColors.textFaint,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CustomText(
                  text: answer,
                  styleType: TextStyleType.medium,
                  textColor: AppColors.textMuted,
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}
