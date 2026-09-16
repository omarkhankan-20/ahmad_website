import 'package:flutter/material.dart';

import '../../core/enums/text_style_type.dart';
import '../../core/utils/responsive.dart';
import 'colors.dart';
import 'custom_text.dart';

/// Centres a section on the max content width and applies the page gutter,
/// so no section reimplements page margins.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    this.background,
    this.topDivider = false,
  });

  final Widget child;
  final Color? background;
  final bool topDivider;

  @override
  Widget build(BuildContext context) {
    // Container asserts colour and decoration are never both set, so the
    // background lives inside the decoration.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        border: topDivider
            ? const Border(top: BorderSide(color: AppColors.line, width: 0.8))
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.gutter(context),
        vertical: Responsive.sectionGap(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: title, styleType: TextStyleType.h2),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          CustomText(
            text: subtitle!,
            styleType: TextStyleType.medium,
            textColor: AppColors.textMuted,
          ),
        ],
      ],
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.onDark = false});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: onDark ? AppColors.espressoSurface : AppColors.creamTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: label,
        styleType: TextStyleType.small,
        textColor: onDark ? AppColors.caramel : AppColors.brownDeep,
      ),
    );
  }
}
