import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'verify_view_controller.dart';

/// Sits between signup and everything else: the account exists but is unusable
/// until this code is entered. Anyone who drops here has already given their
/// details, so the job is to get them through with as little friction as
/// possible.
class VerifyView extends StatelessWidget {
  const VerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyViewController());

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Obx(
                () => Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.creamTint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.mark_email_unread_outlined,
                          size: 26, color: AppColors.brown),
                    ),
                    const SizedBox(height: 16),
                    const CustomText(
                      text: 'أكّد بريدك',
                      styleType: TextStyleType.h2,
                      alignText: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const CustomText(
                      text: 'بعتنالك كود من ٦ أرقام على بريدك.',
                      styleType: TextStyleType.medium,
                      textColor: AppColors.textMuted,
                      alignText: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: CustomText(
                        text: controller.email,
                        styleType: TextStyleType.medium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _CodeField(controller: controller),
                    if (controller.errors['code'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 15, color: AppColors.danger),
                          const SizedBox(width: 6),
                          Flexible(
                            child: CustomText(
                              text: controller.errors['code']!,
                              styleType: TextStyleType.small,
                              textColor: AppColors.danger,
                              alignText: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (controller.resentNotice.value.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CustomText(
                        text: controller.resentNotice.value,
                        styleType: TextStyleType.small,
                        textColor: AppColors.success,
                        alignText: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 18),
                    AppButton(
                      label: controller.isLoading.value ? 'لحظة…' : 'تأكيد',
                      expand: true,
                      onPressed:
                          controller.isLoading.value ? () {} : controller.verify,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.creamSoft,
                        border: Border.all(color: AppColors.line, width: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: AppColors.brown),
                          SizedBox(width: 9),
                          // Most "the code never arrived" messages are a spam
                          // folder. Saying it here removes a support message.
                          Expanded(
                            child: CustomText(
                              text: 'ما وصلك الكود؟ تفقّد مجلد الـ Spam.',
                              styleType: TextStyleType.small,
                              textColor: AppColors.textMuted,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: controller.resendIn.value > 0
                          ? 'إعادة الإرسال بعد ${controller.resendIn.value} ثانية'
                          : (controller.isResending.value
                              ? 'عم نبعت…'
                              : 'أعد إرسال الكود'),
                      expand: true,
                      style: AppButtonStyle.outline,
                      onPressed: controller.resendIn.value > 0 ||
                              controller.isResending.value
                          ? () {}
                          : controller.resend,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      // Back to signup, not just "back": a typo in the email
                      // cannot be fixed from this screen.
                      onTap: () => Get.offNamed(Routes.register),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: CustomText(
                          text: 'البريد غلط؟ رجوع للتسجيل',
                          styleType: TextStyleType.medium,
                          textColor: AppColors.textMuted,
                        ),
                      ),
                    ),
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

class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller});

  final VerifyViewController controller;

  @override
  Widget build(BuildContext context) {
    final hasError = controller.errors['code'] != null;

    // One wide field rather than six boxes. Six boxes look nicer but fight
    // with RTL and break pasting the code straight out of the email, which is
    // what most people actually do.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: controller.code,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: VerifyViewController.codeLength,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => controller.clearError('code'),
        onSubmitted: (_) => controller.verify(),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 12,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: '------',
          hintStyle: const TextStyle(
            fontSize: 26,
            letterSpacing: 12,
            color: AppColors.textFaint,
          ),
          filled: true,
          fillColor: const Color(0xFFFFFDFA),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasError ? AppColors.danger : AppColors.line,
              width: 0.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasError ? AppColors.danger : AppColors.espresso,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}