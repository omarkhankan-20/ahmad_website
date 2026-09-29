import 'package:ahmad_website/ui/shared/site_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/app_data_models.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'legal_view_controller.dart';

/// One screen serving both documents. They share a layout exactly, and two
/// near-identical files would drift the first time either is edited.
class LegalView extends StatelessWidget {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LegalViewController());

    return SitePage(
      child: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              // Narrower than the rest of the site: long legal prose at full
              // width is unreadable.
              constraints: const BoxConstraints(maxWidth: 620),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: controller.title,
                      styleType: TextStyleType.h2,
                    ),
                    const SizedBox(height: 6),
                    if (controller.lastUpdated.isNotEmpty)
                      CustomText(
                        text: 'آخر تحديث: ${controller.lastUpdated}',
                        styleType: TextStyleType.small,
                        textColor: AppColors.textMuted,
                      ),
                    const SizedBox(height: 22),
                    if (controller.clauses.isEmpty)
                      const CustomText(
                        text: 'عم نحمّل…',
                        styleType: TextStyleType.medium,
                        textColor: AppColors.textMuted,
                      )
                    else
                      for (final clause in controller.clauses)
                        _Section(clause: clause),
                    const SizedBox(height: 10),
                    const _Switcher(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.clause});

  final LegalClause clause;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: clause.title, styleType: TextStyleType.h4),
          const SizedBox(height: 7),
          CustomText(
            text: clause.description,
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
            height: 1.95,
          ),
        ],
      ),
    );
  }
}

/// Anyone reading one of these is often about to look for the other.
class _Switcher extends StatelessWidget {
  const _Switcher();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LegalViewController>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line, width: 0.8)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.offNamed(
              controller.isTerms ? Routes.privacy : Routes.terms,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CustomText(
                text: controller.isTerms ? 'سياسة الخصوصية' : 'الشروط والأحكام',
                styleType: TextStyleType.medium,
                textColor: AppColors.brown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Get.offAllNamed(Routes.main),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: CustomText(
                text: 'الصفحة الرئيسية',
                styleType: TextStyleType.medium,
                textColor: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
