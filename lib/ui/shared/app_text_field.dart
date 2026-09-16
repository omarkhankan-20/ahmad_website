import 'package:flutter/material.dart';

import '../../core/enums/text_style_type.dart';
import 'colors.dart';
import 'custom_text.dart';

/// One field for every form on the site. Label above, error below - never a
/// snackbar: a toast disappears in two seconds and a user on a slow
/// connection misses it, then retries blind.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textDirection,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  /// Emails, phone numbers and transaction ids read left-to-right even on an
  /// RTL page. Without this the cursor and any leading + jump to the wrong
  /// side while typing.
  final TextDirection? textDirection;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          styleType: TextStyleType.small,
          textColor: AppColors.textMuted,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textDirection: textDirection,
          maxLines: obscure ? 1 : maxLines,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textFaint,
            ),
            filled: true,
            fillColor: const Color(0xFFFFFDFA),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 19,
                      color: AppColors.textFaint,
                    ),
                  ),
            border: _border(AppColors.line),
            enabledBorder: _border(hasError ? AppColors.danger : AppColors.line),
            focusedBorder: _border(
              hasError ? AppColors.danger : AppColors.espresso,
              width: 1.2,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline,
                  size: 15, color: AppColors.danger),
              const SizedBox(width: 6),
              Expanded(
                child: CustomText(
                  text: error!,
                  styleType: TextStyleType.small,
                  textColor: AppColors.danger,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 0.8}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
}