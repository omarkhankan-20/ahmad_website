import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/models/app_data_models.dart';
import '../../../core/enums/text_style_type.dart';
import '../../../core/utils/responsive.dart';
import '../../shared/app_button.dart';
import '../../shared/app_text_field.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'checkout_view_controller.dart';

/// Two numbered steps and nothing else. This is where a manual-payment buyer
/// hesitates, so every extra field here is a leak.
class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutViewController());

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: SectionShell(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepBar(),
                  const SizedBox(height: 24),
                  const CustomText(
                    text: 'إتمام الطلب',
                    styleType: TextStyleType.h2,
                  ),
                  const SizedBox(height: 6),
                  const CustomText(
                    text: 'خطوتين بس، وحسابك بينفتح بعد المراجعة.',
                    styleType: TextStyleType.medium,
                    textColor: AppColors.textMuted,
                  ),
                  const SizedBox(height: 18),
                  _OrderCard(controller: controller),
                  const SizedBox(height: 22),
                  const _StepTitle(number: '١', title: 'حوّل المبلغ'),
                  const SizedBox(height: 10),
                  _Methods(controller: controller),
                  const SizedBox(height: 22),
                  const _StepTitle(number: '٢', title: 'أكّد التحويل'),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.controller});

  final CheckoutViewController controller;

  @override
  Widget build(BuildContext context) {
    final course = controller.course;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: course?.title ?? '',
                  styleType: TextStyleType.h4,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: course?.totalDuration ?? '',
                  styleType: TextStyleType.small,
                  textColor: AppColors.textMuted,
                ),
              ],
            ),
          ),
          // The server's price, never a number typed into the app - it has to
          // match what the buyer is about to transfer.
          if ((course?.price ?? '').isNotEmpty)
            CustomText(
              text: '\$${course!.price}',
              styleType: TextStyleType.h3,
              fontWeight: FontWeight.w700,
            ),
        ],
      ),
    );
  }
}

class _Methods extends StatelessWidget {
  const _Methods({required this.controller});

  final CheckoutViewController controller;

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

      // A single method needs no chooser - showing a radio next to one option
      // is a decision that isn't one.
      if (methods.length == 1) {
        return _MethodCard(
          method: methods.first,
          controller: controller,
          selectable: false,
        );
      }

      return Column(
        children: [
          for (final method in methods)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MethodCard(method: method, controller: controller),
            ),
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
  final CheckoutViewController controller;
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

              // The QR leads: the buyer scans it in their wallet app and the
              // account fills itself in. No digits to mistype.
              if (method.hasQr) ...[
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line, width: 0.8),
                    ),
                    child: Image.network(
                      method.qrCodeUrl,
                      width: 168,
                      height: 168,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      fit: BoxFit.contain,
                      // A broken QR must not leave a dead grey box - the code
                      // below it is still a working way to pay.
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 168,
                        height: 168,
                        child: Center(
                          child: CustomText(
                            text: 'تعذّر تحميل الكود',
                            styleType: TextStyleType.small,
                            textColor: AppColors.textFaint,
                          ),
                        ),
                      ),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const SizedBox(
                              width: 168,
                              height: 168,
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.brown,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: CustomText(
                    // Says why the code is there, and gives the alternative
                    // for anyone browsing on the same phone as their wallet.
                    text: 'امسح الكود من تطبيقك، أو انسخ الحساب:',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
              ] else
                const SizedBox(height: 10),

              InkWell(
                onTap: () {
                  if (selectable) controller.selectMethod(method.code);
                  controller.copyAccount();
                },
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
                            fontWeight: FontWeight.w500,
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

  final CheckoutViewController controller;

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
              hint: '312321',
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
                // Addresses the one fear manual payment creates: money sent
                // into a void with no way to follow it up.
                Expanded(
                  child: CustomText(
                    text:
                        'إذا في أي مشكلة بالتحويل، أحمد بيتواصل معك — ما بينرفض طلبك بصمت.',
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

  final CheckoutViewController controller;

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
            _PickButton(hasError: error != null, onTap: controller.pickReceipt)
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
                  // A thumbnail, not just a filename: the buyer should see they
                  // attached the right screenshot before sending.
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

class _PickButton extends StatelessWidget {
  const _PickButton({required this.onTap, required this.hasError});

  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasError ? AppColors.danger : AppColors.lineStrong,
            width: 0.8,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.upload_file_outlined, size: 22, color: AppColors.brown),
            SizedBox(height: 6),
            CustomText(
              text: 'اختر صورة أو ملف الإيصال',
              styleType: TextStyleType.medium,
            ),
            SizedBox(height: 2),
            // States the limits up front instead of failing after the pick.
            CustomText(
              text: 'JPG أو PNG أو PDF · حتى ٥ ميغا',
              styleType: TextStyleType.small,
              textColor: AppColors.textFaint,
            ),
          ],
        ),
      ),
    );
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

class _StepBar extends StatelessWidget {
  const _StepBar();

  static const _steps = ['الحساب', 'الدفع', 'المراجعة'];

  @override
  Widget build(BuildContext context) {
    const current = 1;
    final isMobile = Responsive.isMobile(context);
    final children = <Widget>[];

    for (var i = 0; i < _steps.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            width: isMobile ? 26 : 40,
            height: 1,
            margin: const EdgeInsets.only(bottom: 20),
            color: AppColors.line,
          ),
        );
      }
      final done = i < current;
      final active = i == current;

      children.add(
        SizedBox(
          width: isMobile ? 74 : 92,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColors.espresso
                      : AppColors.creamTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check, size: 14, color: AppColors.onDark)
                    : CustomText(
                        text: '${i + 1}',
                        styleType: TextStyleType.small,
                        fontWeight: FontWeight.w700,
                        textColor: active
                            ? AppColors.onDark
                            : AppColors.textFaint,
                      ),
              ),
              const SizedBox(height: 5),
              CustomText(
                text: _steps[i],
                styleType: TextStyleType.small,
                textColor: done || active
                    ? AppColors.textPrimary
                    : AppColors.textFaint,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
