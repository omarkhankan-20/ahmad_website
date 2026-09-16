import 'package:flutter/material.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/data/models/content_models.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../../../shared/section_shell.dart';

class CurriculumSection extends StatelessWidget {
  const CurriculumSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      topDivider: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'محاور الدورة',
            subtitle: 'رحلة متكاملة من الصفر إلى امتلاك ظهورك الخاص.',
          ),
          const SizedBox(height: 18),
          for (final module in MainContent.modules)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ModuleRow(module: module),
            ),
        ],
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({required this.module});

  final Module module;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The modules are a real sequence, so the numbering carries meaning
          // here rather than decorating the list.
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.creamTint,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: CustomText(
              text: '${module.order}',
              styleType: TextStyleType.h4,
              fontWeight: FontWeight.w700,
              textColor: AppColors.brownDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: module.title, styleType: TextStyleType.h4),
                const SizedBox(height: 3),
                CustomText(
                  text: module.description,
                  styleType: TextStyleType.medium,
                  textColor: AppColors.textMuted,
                  height: 1.65,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
