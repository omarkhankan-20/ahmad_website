import 'package:flutter/material.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/data/models/content_models.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/app_button.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../../../shared/section_shell.dart';
import '../main_view_controller.dart';

class OfferingsSection extends StatelessWidget {
  const OfferingsSection({super.key, required this.controller});

  final MainViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    // On desktop the eye takes in both cards at once, so the featured one can
    // sit last. On mobile the first card gets most of the attention and many
    // readers stop there - so the course leads.
    final offerings = List<Offering>.from(MainContent.offerings);
    if (isMobile) {
      offerings.sort((a, b) {
        if (a.featured == b.featured) return 0;
        return a.featured ? -1 : 1;
      });
    }

    final cards = <Widget>[];
    for (var i = 0; i < offerings.length; i++) {
      if (i > 0) {
        cards.add(
          isMobile ? const SizedBox(height: 10) : const SizedBox(width: 12),
        );
      }
      final card = _OfferingCard(offering: offerings[i], controller: controller);
      cards.add(isMobile ? card : Expanded(child: card));
    }

    return SectionShell(
      topDivider: true,
      child: Column(
        key: controller.offeringsKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'من وين تبدأ',
            subtitle: 'مستويان حسب المرحلة اللي أنت فيها.',
          ),
          const SizedBox(height: 20),
          if (isMobile)
            Column(children: cards)
          else
            // stretch alone would ask for infinite height inside a scroll
            // view; IntrinsicHeight measures the tallest card first so both
            // cards end up level.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cards,
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferingCard extends StatelessWidget {
  const _OfferingCard({required this.offering, required this.controller});

  final Offering offering;
  final MainViewController controller;

  @override
  Widget build(BuildContext context) {
    final featured = offering.featured;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: featured ? AppColors.espresso : AppColors.line,
          width: featured ? 2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(offering.icon, size: 22, color: AppColors.brown),
              const Spacer(),
              if (offering.badge != null) Pill(label: offering.badge!),
            ],
          ),
          const SizedBox(height: 12),
          CustomText(text: offering.title, styleType: TextStyleType.h3),
          const SizedBox(height: 3),
          CustomText(
            text: offering.meta,
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          for (final bullet in offering.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
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
                      text: bullet,
                      styleType: TextStyleType.medium,
                      textColor: AppColors.textMuted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          AppButton(
            label: offering.ctaLabel,
            expand: true,
            style: featured ? AppButtonStyle.solid : AppButtonStyle.outline,
            onPressed: () => controller.startPurchase(offering),
          ),
        ],
      ),
    );
  }
}
