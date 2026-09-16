import 'package:flutter/material.dart';

import '../../core/enums/text_style_type.dart';
import 'colors.dart';
import 'custom_text.dart';

enum AppButtonStyle { solid, outline, caramel }

/// One button, three surfaces. Espresso is the primary action on cream; on the
/// dark sections espresso disappears, so caramel takes the primary role.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.solid,
    this.expand = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonStyle style;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;
    Color? borderColor;

    switch (style) {
      case AppButtonStyle.solid:
        background = AppColors.espresso;
        foreground = AppColors.onDark;
      case AppButtonStyle.caramel:
        background = AppColors.caramel;
        foreground = AppColors.onCaramel;
      case AppButtonStyle.outline:
        background = Colors.transparent;
        foreground = AppColors.textPrimary;
        borderColor = AppColors.lineStrong;
    }

    return SizedBox(
      width: expand ? double.infinity : null,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor, width: 0.8),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: 8),
                ],
                CustomText(
                  text: label,
                  styleType: TextStyleType.button,
                  textColor: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
