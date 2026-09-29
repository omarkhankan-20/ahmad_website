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
              child: Obx(() {
                final errors = controller.errors;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      text: 'نسيت كلمة المرور؟',
                      styleType: TextStyleType.h2,
                    ),
                    const SizedBox(height: 6),
                    const CustomText(
                      text:
                          'اكتب بريدك وكلمة المرور الجديدة، وبنبعتلك كود تأكيد على بريدك.',
                      styleType: TextStyleType.medium,
                      textColor: AppColors.textMuted,
                    ),
                    const SizedBox(height: 18),

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
                      label: 'كلمة المرور الجديدة',
                      hint: '٨ أحرف على الأقل',
                      controller: controller.newPassword,
                      error: errors['newPassword'],
                      obscure: controller.obscure.value,
                      onToggleObscure: controller.toggleObscure,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'تأكيد كلمة المرور',
                      controller: controller.confirmPassword,
                      error: errors['confirmPassword'],
                      obscure: controller.obscure.value,
                      onSubmitted: (_) => controller.submit(),
                    ),
                    const SizedBox(height: 16),

                    AppButton(
                      label: controller.isLoading.value
                          ? 'لحظة…'
                          : 'تعيين كلمة المرور',
                      expand: true,
                      onPressed: controller.isLoading.value
                          ? () {}
                          : controller.submit,
                    ),
                    const SizedBox(height: 14),

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
                          // Says plainly that the change is not live yet.
                          // Without this line someone tries the new password
                          // immediately, it fails, and they assume the reset
                          // was broken.
                          Expanded(
                            child: CustomText(
                              text:
                                  'كلمة المرور الجديدة بتفعّل بعد ما تأكّد الكود اللي بيوصلك.',
                              styleType: TextStyleType.small,
                              textColor: AppColors.textMuted,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: InkWell(
                        // offNamed: they came from login, so this closes the
                        // detour instead of stacking another page behind the
                        // back button.
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