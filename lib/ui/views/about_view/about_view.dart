import 'package:ahmad_website/ui/shared/site_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../../../app/routes/app_routes.dart';
import '../../../core/enums/text_style_type.dart';
import '../../../core/services/app_data_service.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';

/// Contact details, straight from the dashboard.
///
/// Separate from the "من هو أحمد" section on the home page: that one sells,
/// this one is what someone opens when a transfer went wrong and they need to
/// reach a human.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

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

  void _open(String url) => web.window.open(url, '_blank');

  @override
  Widget build(BuildContext context) {
    return SitePage(
      // backgroundColor: AppColors.cream,
      child: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Obx(() {
                final about = appData.aboutUs.value;

                if (about == null) {
                  return const SizedBox(
                    height: 260,
                    child: Center(
                      child: CustomText(
                        text: 'عم نحمّل…',
                        styleType: TextStyleType.medium,
                        textColor: AppColors.textMuted,
                      ),
                    ),
                  );
                }

                final links = about.socialLinks;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      text: 'تواصل معنا',
                      styleType: TextStyleType.h2,
                    ),
                    if (about.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CustomText(
                        text: about.description,
                        styleType: TextStyleType.medium,
                        textColor: AppColors.textMuted,
                        height: 1.9,
                      ),
                    ],
                    const SizedBox(height: 22),

                    // WhatsApp leads: with manual payment it is the channel
                    // people actually use when something goes wrong.
                    if (about.whatsapp.isNotEmpty)
                      _ContactTile(
                        icon: Icons.chat_outlined,
                        label: 'واتساب',
                        value: about.whatsapp,
                        emphasised: true,
                        onTap: () => _open(
                          'https://wa.me/${about.whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}',
                        ),
                      ),
                    if (about.phoneNumber.isNotEmpty)
                      _ContactTile(
                        icon: Icons.phone_outlined,
                        label: 'الهاتف',
                        value: about.phoneNumber,
                        onTap: () => _open('tel:${about.phoneNumber}'),
                      ),
                    if (about.email.isNotEmpty)
                      _ContactTile(
                        icon: Icons.mail_outline,
                        label: 'البريد الإلكتروني',
                        value: about.email,
                        onTap: () => _open('mailto:${about.email}'),
                      ),
                    if (about.address.isNotEmpty)
                      _ContactTile(
                        icon: Icons.place_outlined,
                        label: 'العنوان',
                        value: about.address,
                      ),

                    if (links.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const CustomText(
                        text: 'تابعنا',
                        styleType: TextStyleType.h4,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final entry in links.entries)
                            if (_platformNames.containsKey(entry.key))
                              _SocialChip(
                                label: _platformNames[entry.key]!,
                                onTap: () => _open(entry.value),
                              ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 26),
                    const Divider(
                      height: 1,
                      color: AppColors.line,
                      thickness: 0.8,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _TextLink(
                          label: 'الشروط والأحكام',
                          onTap: () => Get.toNamed(Routes.terms),
                        ),
                        const SizedBox(width: 18),
                        _TextLink(
                          label: 'سياسة الخصوصية',
                          onTap: () => Get.toNamed(Routes.privacy),
                        ),
                        const Spacer(),
                        _TextLink(
                          label: 'الصفحة الرئيسية',
                          onTap: () => Get.offAllNamed(Routes.main),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: emphasised ? AppColors.brown : AppColors.line,
          width: emphasised ? 1.2 : 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  styleType: TextStyleType.small,
                  textColor: AppColors.textMuted,
                ),
                const SizedBox(height: 2),
                // Numbers and addresses read left-to-right even on an RTL
                // page; leaving them to the page direction mangles them.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: CustomText(
                    text: value,
                    styleType: TextStyleType.medium,
                    alignText: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.open_in_new, size: 15, color: AppColors.textFaint),
        ],
      ),
    );

    if (onTap == null) return tile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: tile,
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.creamSunk,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line, width: 0.8),
        ),
        child: CustomText(text: label, styleType: TextStyleType.medium),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: CustomText(
          text: label,
          styleType: TextStyleType.small,
          textColor: AppColors.textMuted,
        ),
      ),
    );
  }
}
