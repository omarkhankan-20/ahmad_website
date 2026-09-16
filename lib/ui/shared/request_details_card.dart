import 'package:flutter/material.dart';

import '../../core/data/models/purchase_request.dart';
import '../../core/enums/text_style_type.dart';
import 'colors.dart';
import 'custom_text.dart';

/// Shared by the pending and rejected screens so both always show the same
/// fields in the same order.
class RequestDetailsCard extends StatelessWidget {
  const RequestDetailsCard({super.key, required this.request});

  final PurchaseRequest request;

  @override
  Widget build(BuildContext context) {
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
            text: 'تفاصيل الطلب',
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'المنتج', value: request.productTitle),
          _DetailRow(label: 'اسم المُرسِل', value: request.senderName),
          // Echoed back so the buyer can check it against their own receipt.
          // Most rejections start as a typo in this one field.
          _DetailRow(
            label: 'رقم العملية',
            value: request.transactionNumber,
            ltr: true,
          ),
          if (request.amountLabel != null)
            _DetailRow(label: 'المبلغ', value: request.amountLabel!),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.ltr = false,
  });

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: CustomText(
              text: label,
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: ltr
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: CustomText(
                      text: value,
                      styleType: TextStyleType.medium,
                      alignText: TextAlign.right,
                    ),
                  )
                : CustomText(text: value, styleType: TextStyleType.medium),
          ),
        ],
      ),
    );
  }
}