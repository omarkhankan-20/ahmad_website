import 'package:ahmad_website/ui/views/register_view/register_controller.dart';
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

/// One screen for both entry points. With a pending offer it renders as step
/// one of the purchase flow; opened directly it is a plain signup page.
/// Two separate screens would mean two files to keep in sync - and one of
/// them always falls behind.
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterViewController());
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  if (controller.isPurchaseFlow) ...[
                    const _StepBar(),
                    const SizedBox(height: 24),
                  ],
                  if (isMobile) ...[
                    if (controller.isPurchaseFlow) ...[
                      _OrderSummary(controller: controller),
                      const SizedBox(height: 14),
                    ],
                    _Form(controller: controller),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _Form(controller: controller)),
                        if (controller.isPurchaseFlow) ...[
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 230,
                            child: _OrderSummary(controller: controller),
                          ),
                        ],
                      ],
                    ),
                ],
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

  final RegisterViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      final errors = controller.errors;

      final fields = [
        AppTextField(
          label: 'الاسم الكامل',
          hint: 'اسمك',
          controller: controller.name,
          error: errors['name'],
          onSubmitted: (_) => controller.clearError('name'),
        ),
        AppTextField(
          label: 'رقم واتساب',
          hint: '+961 …',
          controller: controller.whatsapp,
          error: errors['whatsapp'],
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
        ),
        AppTextField(
          label: 'البريد الإلكتروني',
          hint: 'name@email.com',
          controller: controller.email,
          error: errors['email'],
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
        ),
        AppTextField(
          label: 'كلمة المرور',
          hint: '٨ أحرف على الأقل',
          controller: controller.password,
          error: errors['password'],
          obscure: controller.obscurePassword.value,
          onToggleObscure: controller.toggleObscure,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: controller.isPurchaseFlow
                ? 'أنشئ حسابك لتكمّل الشراء'
                : 'أنشئ حسابك',
            styleType: TextStyleType.h2,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: controller.isPurchaseFlow
                ? 'دقيقة وحدة — هالحساب هو اللي بتوصل منّو لدروسك.'
                : 'دقيقة وحدة وبتكون جاهز.',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 18),

          // One field per row on mobile: a long value like an email in a
          // half-width box is unreadable while you type it.
          if (isMobile)
            for (final field in fields)
              Padding(padding: const EdgeInsets.only(bottom: 12), child: field)
          else
            for (var i = 0; i < fields.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: fields[i]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: i + 1 < fields.length
                          ? fields[i + 1]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

          const SizedBox(height: 2),
          _TermsCheckbox(controller: controller),
          const SizedBox(height: 16),
          AppButton(
            label: controller.isLoading.value
                ? 'لحظة…'
                : (controller.isPurchaseFlow ? 'تابع للدفع' : 'إنشاء الحساب'),
            expand: true,
            onPressed: controller.isLoading.value ? () {} : controller.submit,
          ),
          const SizedBox(height: 14),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const CustomText(
                  text: 'عندك حساب من قبل؟ ',
                  styleType: TextStyleType.medium,
                  textColor: AppColors.textMuted,
                ),
                InkWell(
                  onTap: () => Get.toNamed(
                    Routes.login,
                    arguments: controller.pendingOffer,
                  ),
                  child: const CustomText(
                    text: 'سجّل دخولك',
                    styleType: TextStyleType.medium,
                    textColor: AppColors.brown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 15, color: AppColors.brown),
              SizedBox(width: 6),
              // Says plainly that no card details are asked for. With manual
              // local payment this is the exact thing people worry about.
              CustomText(
                text: 'ما منطلب أي معلومة دفع هون',
                styleType: TextStyleType.small,
                textColor: AppColors.textMuted,
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.controller});

  final RegisterViewController controller;

  @override
  Widget build(BuildContext context) {
    final hasError = controller.errors.containsKey('terms');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            controller.toggleTerms();
            controller.clearError('terms');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsetsDirectional.only(top: 2, end: 9),
                  decoration: BoxDecoration(
                    color: controller.acceptedTerms.value
                        ? AppColors.espresso
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: hasError ? AppColors.danger : AppColors.lineStrong,
                      width: 0.8,
                    ),
                  ),
                  child: controller.acceptedTerms.value
                      ? const Icon(
                          Icons.check,
                          size: 13,
                          color: AppColors.onDark,
                        )
                      : null,
                ),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const CustomText(
                        text: 'بوافق على ',
                        styleType: TextStyleType.medium,
                        textColor: AppColors.textMuted,
                      ),
                      InkWell(
                        onTap: () => Get.toNamed(Routes.terms),
                        child: const CustomText(
                          text: 'الشروط والأحكام',
                          styleType: TextStyleType.medium,
                          textColor: AppColors.brown,
                        ),
                      ),
                      const CustomText(
                        text: ' و',
                        styleType: TextStyleType.medium,
                        textColor: AppColors.textMuted,
                      ),
                      InkWell(
                        onTap: () => Get.toNamed(Routes.privacy),
                        child: const CustomText(
                          text: 'سياسة الخصوصية',
                          styleType: TextStyleType.medium,
                          textColor: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 27),
            child: CustomText(
              text: controller.errors['terms']!,
              styleType: TextStyleType.small,
              textColor: AppColors.danger,
            ),
          ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.controller});

  final RegisterViewController controller;

  @override
  Widget build(BuildContext context) {
    final offer = controller.pendingOffer!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'طلبك',
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 8),
          CustomText(text: offer.title, styleType: TextStyleType.h4),
          const SizedBox(height: 3),
          CustomText(
            text: offer.meta,
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          // The total only appears once GET /products supplies a price.
          // Showing an invented number here would be a lie the buyer catches
          // one screen later.
          if (offer.priceLabel != null) ...[
            const Divider(height: 24, color: AppColors.line, thickness: 0.8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const CustomText(
                  text: 'المجموع',
                  styleType: TextStyleType.small,
                  textColor: AppColors.textMuted,
                ),
                CustomText(
                  text: offer.priceLabel!,
                  styleType: TextStyleType.h3,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar();

  static const _steps = ['الحساب', 'الدفع', 'المراجعة'];

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < _steps.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            width: 40,
            height: 1,
            margin: const EdgeInsets.only(bottom: 20),
            color: AppColors.line,
          ),
        );
      }
      final active = i == 0;
      children.add(
        SizedBox(
          width: 92,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: active ? AppColors.espresso : AppColors.creamTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: '${i + 1}',
                  styleType: TextStyleType.small,
                  fontWeight: FontWeight.w700,
                  textColor: active ? AppColors.onDark : AppColors.textFaint,
                ),
              ),
              const SizedBox(height: 5),
              CustomText(
                text: _steps[i],
                styleType: TextStyleType.small,
                textColor: active ? AppColors.textPrimary : AppColors.textFaint,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              ),
            ],
          ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }
}
