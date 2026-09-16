import 'package:ahmad_website/ui/views/login_view/loginView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/main_content.dart';
import '../../../core/enums/text_style_type.dart';
import '../../../core/utils/responsive.dart';
import '../../shared/app_button.dart';
import '../../shared/app_text_field.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';


class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginViewController());
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: isMobile
                  ? _Form(controller: controller)
                  : Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.line, width: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: _Form(controller: controller),
                              ),
                            ),
                            const SizedBox(width: 250, child: _BrandPanel()),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.controller});

  final LoginViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final errors = controller.errors;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: controller.isPurchaseFlow
                ? 'سجّل دخولك لتكمّل الشراء'
                : 'أهلاً فيك مرجوع',
            styleType: TextStyleType.h2,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: controller.isPurchaseFlow
                ? 'عندك حساب أصلاً — ادخل وكمّل من وين وقفت.'
                : 'سجّل دخولك لتكمّل الدورة.',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 18),

          // A failed login shows one message above both fields. Saying which
          // of the two was wrong tells an attacker which emails exist.
          if (errors['form'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAECE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(
                      text: errors['form']!,
                      styleType: TextStyleType.medium,
                      textColor: AppColors.danger,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          AppTextField(
            label: 'البريد الإلكتروني',
            hint: 'name@email.com',
            controller: controller.email,
            error: errors['email'],
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'كلمة المرور',
            controller: controller.password,
            error: errors['password'],
            obscure: controller.obscurePassword.value,
            onToggleObscure: controller.toggleObscure,
            onSubmitted: (_) => controller.submit(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InkWell(
              onTap: () => Get.toNamed(Routes.forgotPassword),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: CustomText(
                  text: 'نسيت كلمة المرور؟',
                  styleType: TextStyleType.small,
                  textColor: AppColors.brown,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: controller.isLoading.value ? 'لحظة…' : 'تسجيل الدخول',
            expand: true,
            onPressed: controller.isLoading.value ? () {} : controller.submit,
          ),
          const SizedBox(height: 14),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const CustomText(
                  text: 'ما عندك حساب؟ ',
                  styleType: TextStyleType.medium,
                  textColor: AppColors.textMuted,
                ),
                InkWell(
                  // offNamed, not toNamed: bouncing between login and signup
                  // would otherwise stack a dozen pages in the back button.
                  onTap: () => Get.offNamed(
                    Routes.register,
                    arguments: controller.pendingOffer,
                  ),
                  child: const CustomText(
                    text: 'أنشئ واحد',
                    styleType: TextStyleType.medium,
                    textColor: AppColors.brown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// Reminds the visitor what they are logging in to. Cheap trust, and it fills
/// what would otherwise be dead space beside a two-field form.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.espressoDeep,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.onDark,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const CustomText(
              text: 'أ',
              styleType: TextStyleType.h4,
              fontWeight: FontWeight.w700,
              textColor: AppColors.espressoDeep,
            ),
          ),
          const SizedBox(height: 16),
          const CustomText(
            text: MainContent.headline,
            styleType: TextStyleType.h3,
            serif: true,
            fontWeight: FontWeight.w700,
            textColor: AppColors.onDark,
            height: 1.6,
          ),
          const SizedBox(height: 12),
          const CustomText(
            text: 'أكثر من مليون متابع · أكثر من ١٠٠ مليون مشاهدة',
            styleType: TextStyleType.small,
            textColor: AppColors.onDarkMuted,
          ),
        ],
      ),
    );
  }
}