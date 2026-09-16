import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/app_text_field.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'forgot_password_view_controller.dart';

/// Two states on one screen: ask for the address, then confirm it was sent.
/// Splitting them across two routes would let a refresh land the user on a
/// confirmation page with nothing behind it.
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordViewController());

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Obx(
                () => controller.isSent.value
                    ? _SentState(controller: controller)
                    : _RequestState(controller: controller),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestState extends StatelessWidget {
  const _RequestState({required this.controller});

  final ForgotPasswordViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'نسيت كلمة المرور؟',
            styleType: TextStyleType.h2,
          ),
          const SizedBox(height: 6),
          const CustomText(
            text: 'اكتب بريدك وبنبعتلك رابط لتعيين كلمة مرور جديدة.',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'البريد الإلكتروني',
            hint: 'name@email.com',
            controller: controller.email,
            error: controller.errors['email'],
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            onSubmitted: (_) => controller.submit(),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: controller.isLoading.value ? 'لحظة…' : 'ابعت الرابط',
            expand: true,
            onPressed: controller.isLoading.value ? () {} : controller.submit,
          ),
          const SizedBox(height: 14),
          const _BackToLogin(),
        ],
      ),
    );
  }
}

class _SentState extends StatelessWidget {
  const _SentState({required this.controller});

  final ForgotPasswordViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
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
            child: const Icon(Icons.mark_email_read_outlined,
                size: 26, color: AppColors.brown),
          ),
          const SizedBox(height: 16),
          const CustomText(
            text: 'بعتنا الرابط',
            styleType: TextStyleType.h2,
            alignText: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Deliberately conditional: confirming that an address has an
          // account would let anyone test emails against Ahmad's customer list.
          CustomText(
            text:
                'إذا هالبريد مسجّل عنا، بيوصلك رابط تعيين كلمة المرور خلال دقائق.',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
            alignText: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomText(
              text: controller.email.text.trim(),
              styleType: TextStyleType.medium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

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
                Icon(Icons.info_outline, size: 16, color: AppColors.brown),
                SizedBox(width: 9),
                // Most "the email never arrived" messages are a spam folder.
                // Saying it up front removes a support message.
                Expanded(
                  child: CustomText(
                    text:
                        'ما وصلك؟ تفقّد مجلد الـ Spam. الرابط بينتهي بعد ساعة.',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppButton(
            label: controller.resendIn.value > 0
                ? 'إعادة الإرسال بعد ${controller.resendIn.value} ثانية'
                : 'أعد إرسال الرابط',
            expand: true,
            style: AppButtonStyle.outline,
            onPressed:
                controller.resendIn.value > 0 ? () {} : controller.resend,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: controller.editEmail,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: CustomText(
                text: 'البريد غلط؟ عدّلو',
                styleType: TextStyleType.medium,
                textColor: AppColors.brown,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _BackToLogin(),
        ],
      ),
    );
  }
}

class _BackToLogin extends StatelessWidget {
  const _BackToLogin();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        // offNamed: the user came from login, so this closes the detour
        // instead of stacking another page behind the back button.
        onTap: () => Get.offNamed(Routes.login),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: CustomText(
            text: 'رجوع لتسجيل الدخول',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}