import 'package:flutter/material.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/data/models/content_models.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/app_button.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../../../shared/portrait_image.dart';
import '../../../shared/section_shell.dart';
import '../main_view_controller.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.controller});

  final MainViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SectionShell(
      child: Column(
        children: [
          if (isMobile) ...[
            // The headline has to clear the fold. A portrait above it would
            // push both the hook and the buy button off the first screen.
            _Copy(controller: controller, isMobile: true),
            const SizedBox(height: 20),
            const PortraitImage(height: 300),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 13,
                  child: _Copy(controller: controller, isMobile: false),
                ),
                const SizedBox(width: 32),
                // Narrower and taller than before: the source photo is a
                // full-length vertical shot, so a wide box would crop away
                // most of him.
                const Expanded(flex: 7, child: PortraitImage(height: 440)),
              ],
            ),
          SizedBox(height: isMobile ? 24 : 36),
          const _Stats(),
        ],
      ),
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy({required this.controller, required this.isMobile});

  final MainViewController controller;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Pill(label: MainContent.eyebrow),
        const SizedBox(height: 16),
        const CustomText(
          text: MainContent.headline,
          styleType: TextStyleType.h1,
        ),
        const SizedBox(height: 12),
         ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520),
          child: CustomText(
            text: MainContent.subheadline,
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 22),
        if (isMobile) ...[
          AppButton(
            label: 'ابدأ الآن',
            expand: true,
            onPressed: () => controller.scrollTo(controller.offeringsKey),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'احجز استشارة',
            expand: true,
            style: AppButtonStyle.outline,
            onPressed: () => controller.scrollTo(controller.consultationKey),
          ),
        ] else
          Row(
            children: [
              AppButton(
                label: 'ابدأ الآن',
                onPressed: () => controller.scrollTo(controller.offeringsKey),
              ),
              const SizedBox(width: 10),
              AppButton(
                label: 'احجز استشارة',
                style: AppButtonStyle.outline,
                onPressed: () =>
                    controller.scrollTo(controller.consultationKey),
              ),
            ],
          ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final children = <Widget>[];
    for (var i = 0; i < MainContent.stats.length; i++) {
      if (i > 0) children.add(SizedBox(width: isMobile ? 8 : 12));
      children.add(Expanded(child: _StatCard(stat: MainContent.stats[i])));
    }
    return Row(children: children);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final Stat stat;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Spelled out rather than abbreviated: "+١م" reads as either
          // million or billion depending on the reader.
          CustomText(
            text: stat.value,
            styleType: TextStyleType.h3,
            fontWeight: FontWeight.w700,
            textColor: AppColors.brown,
            alignText: TextAlign.center,
            height: 1.25,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: stat.label,
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
            alignText: TextAlign.center,
            height: 1.4,
          ),
        ],
      ),
    );
  }
}