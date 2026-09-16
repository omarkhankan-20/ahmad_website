import 'package:flutter/material.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../../../shared/portrait_image.dart';
import '../../../shared/section_shell.dart';
import '../main_view_controller.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.controller});

  final MainViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'من هو ${MainContent.creatorName}'),
        const SizedBox(height: 10),
        const CustomText(
          text: MainContent.aboutBody,
          styleType: TextStyleType.medium,
          textColor: AppColors.textMuted,
        ),
        const SizedBox(height: 16),
        for (final item in MainContent.credentials)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.check, size: 16, color: AppColors.brown),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: CustomText(
                    text: item,
                    styleType: TextStyleType.medium,
                    textColor: AppColors.textMuted,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    // Tighter crop than the hero: this box is short and narrow, so centring on
    // the face reads better than showing the full figure twice on one page.
    final photo = PortraitImage(
      height: isMobile ? 280 : 340,
      alignment: const Alignment(0, -0.5),
    );

    return SectionShell(
      topDivider: true,
      child: Column(
        key: controller.aboutKey,
        children: [
          if (isMobile) ...[
            photo,
            const SizedBox(height: 18),
            copy,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 260, child: photo),
                const SizedBox(width: 32),
                Expanded(child: copy),
              ],
            ),
        ],
      ),
    );
  }
}