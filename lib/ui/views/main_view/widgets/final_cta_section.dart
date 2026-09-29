import 'package:ahmad_website/app/routes/app_routes.dart';
import 'package:ahmad_website/core/services/app_data_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Contact details and the legal links. Everything here comes from the
/// dashboard, because a phone number or a social handle changing should not
/// need a rebuild.
class MainFooter extends StatelessWidget {
  const MainFooter({super.key});

  /// Arabic labels rather than brand icons: the palette is cream and espresso,
  /// and a row of blue-and-red logos would fight it. Only platforms the server
  /// actually returns are shown.
  static const _platformNames = <String, String>{
    'instagram': 'انستغرام',
    'youtube': 'يوتيوب',
    'tiktok': 'تيك توك',
    'facebook': 'فيسبوك',
    'telegram': 'تيليغرام',
    'linkedin': 'لينكدإن',
    'x': 'إكس',
    'snapchat': 'سناب شات',
    'threads': 'ثريدز',
  };

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
          constraints: const BoxConstraints(
            maxWidth: Responsive.maxContentWidth,
          ),
          child: Obx(() {
            final about = appData.aboutUs.value;
            final links = about?.socialLinks ?? const <String, String>{};

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (links.isNotEmpty) ...[
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      for (final entry in links.entries)
                        if (_platformNames.containsKey(entry.key))
                          _FooterLink(
                            label: _platformNames[entry.key]!,
                            onTap: () => _open(entry.value),
                          ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // WhatsApp gets its own line: with manual payment it is the
                // channel someone reaches for when a transfer goes wrong.
                if ((about?.whatsapp ?? '').isNotEmpty) ...[
                  _FooterLink(
                    label: 'تواصل عبر واتساب',
                    emphasised: true,
                    onTap: () => _open(
                      'https://wa.me/${about!.whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}',
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                const Divider(height: 1, color: AppColors.line, thickness: 0.8),
                const SizedBox(height: 14),

                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 10,
                  children: [
                    CustomText(
                      text: '${MainContent.creatorName} · جميع الحقوق محفوظة',
                      styleType: TextStyleType.small,
                      textColor: AppColors.textMuted,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Were plain text before: anyone wanting to read the
                        // terms before signing up had no way to reach them.
                        _FooterLink(
                          label: 'الشروط والأحكام',
                          onTap: () => Get.toNamed(Routes.terms),
                        ),
                        const SizedBox(width: 18),
                        _FooterLink(
                          label: 'سياسة الخصوصية',
                          onTap: () => Get.toNamed(Routes.privacy),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: CustomText(
          text: label,
          styleType: TextStyleType.small,
          textColor: emphasised ? AppColors.brown : AppColors.textMuted,
          fontWeight: emphasised ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}
