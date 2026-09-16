import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/purchase_request.dart';
import '../../../core/enums/offering_type.dart';
import '../../../core/enums/request_status.dart';
import '../../../core/enums/text_style_type.dart';
import '../../shared/app_button.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'my_orders_view_controller.dart';

/// Where a buyer checks on their own money without messaging Ahmad. Matters
/// most for someone who bought both products and has two requests in flight.
class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyOrdersViewController());

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
                  const CustomText(text: 'طلباتي', styleType: TextStyleType.h2),
                  const SizedBox(height: 6),
                  const CustomText(
                    text: 'كل طلباتك وحالتها بمكان واحد.',
                    styleType: TextStyleType.medium,
                    textColor: AppColors.textMuted,
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.brown,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.requests.isEmpty) {
                      return const _EmptyState();
                    }

                    return Column(
                      children: [
                        for (final request in controller.requests)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderCard(
                              request: request,
                              controller: controller,
                            ),
                          ),
                      ],
                    );
                  }),
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
  const _OrderCard({required this.request, required this.controller});

  final PurchaseRequest request;
  final MyOrdersViewController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                request.type == OfferingType.course
                    ? Icons.school_outlined
                    : Icons.chat_bubble_outline,
                size: 20,
                color: AppColors.brown,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: request.productTitle,
                      styleType: TextStyleType.h4,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      text: controller.whenLabel(request.createdAt),
                      styleType: TextStyleType.small,
                      textColor: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              _StatusPill(status: request.status),
            ],
          ),

          // The rejection reason sits on the card itself: making someone open
          // another screen to find out what went wrong is one step too many
          // when they have already paid.
          if (request.status == RequestStatus.rejected &&
              request.rejectReason != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFAECE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomText(
                text: request.rejectReason!,
                styleType: TextStyleType.small,
                textColor: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: CustomText(
                    text: request.transactionNumber,
                    styleType: TextStyleType.small,
                    textColor: AppColors.textFaint,
                    alignText: TextAlign.right,
                    maxLine: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: controller.actionLabel(request),
                style: request.status == RequestStatus.rejected
                    ? AppButtonStyle.solid
                    : AppButtonStyle.outline,
                onPressed: () => controller.openRequest(request),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RequestStatus.pending => ('قيد المراجعة', AppColors.caramel),
      RequestStatus.accepted => ('مفعّل', AppColors.success),
      RequestStatus.rejected => ('بحاجة تعديل', AppColors.danger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: label,
        styleType: TextStyleType.small,
        textColor: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.creamTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.receipt_long_outlined,
                size: 23, color: AppColors.brown),
          ),
          const SizedBox(height: 14),
          const CustomText(text: 'ما في طلبات بعد', styleType: TextStyleType.h4),
          const SizedBox(height: 6),
          const CustomText(
            text: 'لما تشترك بالدورة أو تحجز جلسة، بتلاقي طلبك هون.',
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
            alignText: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // An empty state with a way out, not a dead end.
          AppButton(
            label: 'شوف الدورة',
            onPressed: () => Get.toNamed(Routes.main),
          ),
        ],
      ),
    );
  }
}