import 'package:ahmad_website/ui/shared/site_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/models/app_data_models.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/app_text_field.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'consultation_view_controller.dart';

/// Brief and payment on one page, because the server takes them in a single
/// request. Splitting them across two screens would only add a place to drop
/// out between.
class ConsultationView extends StatelessWidget {
  const ConsultationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsultationViewController());

    return SitePage(
      child: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: 'احجز جلستك',
                    styleType: TextStyleType.h2,
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final price = controller.price;
                    return CustomText(
                      text: price == null
                          ? 'جلسة ١:١ مع أحمد، مبنية على وضعك أنت.'
                          : 'جلسة ١:١ مع أحمد · $price',
                      styleType: TextStyleType.medium,
                      textColor: AppColors.textMuted,
                    );
                  }),
                  const SizedBox(height: 20),
                  const _StepTitle(number: '١', title: 'عرّفنا على وضعك'),
                  const SizedBox(height: 10),
                  _BriefCard(controller: controller),
                  const SizedBox(height: 22),
                  const _StepTitle(number: '٢', title: 'حوّل المبلغ'),
                  const SizedBox(height: 10),
                  _Methods(controller: controller),
                  const SizedBox(height: 22),
                  const _StepTitle(number: '٣', title: 'أكّد التحويل'),
                  const SizedBox(height: 10),
                  _ConfirmCard(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.controller});

  final ConsultationViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final errors = controller.errors;

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
            AppTextField(
              label: 'رابط حسابك أو مشروعك',
              hint: 'instagram.com/username',
              controller: controller.accountLink,
              error: errors['account_link'],
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'مجال شغلك',
              hint: 'تسويق، مطاعم، تعليم…',
              controller: controller.industry,
              error: errors['industry'],
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'شو بدك تطلع فيه من الجلسة؟',
              hint: 'كل ما كنت أوضح، كل ما كانت الجلسة أنفع',
              controller: controller.objective,
              error: errors['session_objective'],
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            const CustomText(
              text: 'الوقت المفضّل',
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ConsultationViewController.timeOptions.entries
                  .map(
                    (entry) => _TimeChip(
                      label: entry.value,
                      selected: controller.preferredTime.value == entry.key,
                      onTap: () => controller.selectTime(entry.key),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Said plainly so nobody shows up at the hour they picked: the
            // slot is a request until Ahmad confirms it.
            const CustomText(
              text: 'هيدا تفضيل مش موعد — أحمد بيأكّدلك الموعد بعد المراجعة.',
              styleType: TextStyleType.small,
              textColor: AppColors.textFaint,
              height: 1.6,
            ),
          ],
        ),
      );
    });
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.espresso : AppColors.creamSunk,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.espresso : AppColors.line,
            width: 0.8,
          ),
        ),
        child: CustomText(
          text: label,
          styleType: TextStyleType.medium,
          textColor: selected ? AppColors.onDark : AppColors.textPrimary,
          fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _Methods extends StatelessWidget {
  const _Methods({required this.controller});

  final ConsultationViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final methods = controller.methods;

      if (methods.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.creamSoft,
            border: Border.all(color: AppColors.line, width: 0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const CustomText(
            text: 'ما في طريقة دفع متاحة حالياً. تواصل مع أحمد.',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          ),
        );
      }

      return Column(
        children: [
          for (var i = 0; i < methods.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _MethodCard(
              method: methods[i],
              controller: controller,
              selectable: methods.length > 1,
            ),
          ],
        ],
      );
    });
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.controller,
    this.selectable = true,
  });

  final AppPaymentMethod method;
  final ConsultationViewController controller;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected =
          !selectable || controller.selectedMethodCode.value == method.code;
      final copied = controller.copied.value && selected;

      return InkWell(
        onTap: selectable ? () => controller.selectMethod(method.code) : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.creamSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.espresso : AppColors.line,
              width: selected ? 2 : 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(text: method.name, styleType: TextStyleType.h4),
                  const Spacer(),
                  if (selectable)
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: selected
                          ? AppColors.espresso
                          : AppColors.lineStrong,
                    ),
                ],
              ),
              if (method.hasQr) ...[
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // White, not cream: scanners struggle with a tinted
                      // quiet zone around the code.
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line, width: 0.8),
                    ),
                    child: Image.network(
                      method.qrCodeUrl,
                      width: 150,
                      height: 150,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: CustomText(
                            text: 'استعمل الرقم تحت',
                            styleType: TextStyleType.small,
                            textColor: AppColors.textFaint,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: CustomText(
                    text: 'امسح الكود من تطبيقك، أو انسخ الحساب:',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
              ] else
                const SizedBox(height: 10),
              InkWell(
                onTap: controller.copyAccount,
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.creamSunk,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: CustomText(
                            text: method.accountCode,
                            styleType: TextStyleType.medium,
                            alignText: TextAlign.left,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        copied ? Icons.check : Icons.copy_rounded,
                        size: 16,
                        color: AppColors.brown,
                      ),
                      if (copied) ...[
                        const SizedBox(width: 5),
                        const CustomText(
                          text: 'تم النسخ',
                          styleType: TextStyleType.small,
                          textColor: AppColors.brown,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.controller});

  final ConsultationViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final errors = controller.errors;

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
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: AppColors.danger,
                    ),
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
              label: 'رقم العملية',
              hint: 'SC-CONS-100',
              controller: controller.transactionNumber,
              error: errors['transaction_number'],
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 14),
            _ReceiptField(controller: controller),
            const SizedBox(height: 16),
            AppButton(
              label: controller.isLoading.value ? 'عم نرسل…' : 'أرسل الطلب',
              expand: true,
              onPressed: controller.isLoading.value ? () {} : controller.submit,
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: AppColors.brown,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: CustomText(
                    text:
                        'بعد المراجعة بيتواصل معك أحمد ليأكّد الموعد ويبعتلك رابط الجلسة.',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _ReceiptField extends StatelessWidget {
  const _ReceiptField({required this.controller});

  final ConsultationViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.errors['receipt'];
      final bytes = controller.receiptBytes.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'إيصال التحويل',
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 6),
          if (bytes == null)
            InkWell(
              onTap: controller.pickReceipt,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: error != null
                        ? AppColors.danger
                        : AppColors.lineStrong,
                    width: 0.8,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 22,
                      color: AppColors.brown,
                    ),
                    SizedBox(height: 6),
                    CustomText(
                      text: 'اختر صورة أو ملف الإيصال',
                      styleType: TextStyleType.medium,
                    ),
                    SizedBox(height: 2),
                    CustomText(
                      text: 'JPG أو PNG أو PDF · حتى ١٠ ميغا',
                      styleType: TextStyleType.small,
                      textColor: AppColors.textFaint,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lineStrong, width: 0.8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: controller.receiptIsImage.value
                        ? Image.memory(
                            bytes,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 46,
                            height: 46,
                            color: AppColors.creamTint,
                            child: const Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 20,
                              color: AppColors.brown,
                            ),
                          ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: controller.receiptName.value,
                          styleType: TextStyleType.medium,
                          maxLine: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        CustomText(
                          text: '${controller.receiptSizeKb.value} كيلوبايت',
                          styleType: TextStyleType.small,
                          textColor: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.removeReceipt,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 15,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: CustomText(
                    text: error,
                    styleType: TextStyleType.small,
                    textColor: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsetsDirectional.only(end: 9),
          decoration: const BoxDecoration(
            color: AppColors.espresso,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: CustomText(
            text: number,
            styleType: TextStyleType.small,
            fontWeight: FontWeight.w700,
            textColor: AppColors.onDark,
          ),
        ),
        CustomText(text: title, styleType: TextStyleType.h4),
      ],
    );
  }
}
