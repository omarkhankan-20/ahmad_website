import 'package:flutter/material.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/app_button.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../main_view_controller.dart';

/// The last thing the reader sees before deciding, so it runs on the dark half
/// of the palette - maximum contrast against everything above it.
class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key, required this.controller});

  final MainViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: AppColors.espressoDeep,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.gutter(context),
        vertical: isMobile ? 44 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              const CustomText(
                text: MainContent.finalCtaTitle,
                styleType: TextStyleType.large,
                textColor: AppColors.onDark,
                alignText: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const CustomText(
                text: MainContent.finalCtaBody,
                styleType: TextStyleType.medium,
                textColor: AppColors.onDarkMuted,
                alignText: TextAlign.center,
              ),
              const SizedBox(height: 22),
              AppButton(
                label: 'اشترك الآن',
                expand: isMobile,
                style: AppButtonStyle.caramel,
                onPressed: () => controller.scrollTo(controller.offeringsKey),
              ),
              const SizedBox(height: 14),
              const CustomText(
                text: 'دفع محلي · التفعيل خلال ٢٤ ساعة',
                styleType: TextStyleType.small,
                textColor: AppColors.onDarkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainFooter extends StatelessWidget {
  const MainFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.cream,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.gutter(context),
        vertical: 22,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            children: [
              CustomText(
                text: '${MainContent.creatorName} · جميع الحقوق محفوظة',
                styleType: TextStyleType.small,
                textColor: AppColors.textMuted,
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: 'الشروط والأحكام',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textMuted,
                  ),
                  SizedBox(width: 18),
                  CustomText(
                    text: 'سياسة الخصوصية',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
