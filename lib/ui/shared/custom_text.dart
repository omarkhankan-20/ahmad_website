import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/enums/text_style_type.dart';
import '../../core/utils/responsive.dart';
import 'colors.dart';

/// Size, weight and family per style type. Each type carries a mobile and a
/// desktop size, so a responsive heading is `TextStyleType.h1` everywhere
/// instead of a hand-written ternary at every call site.
class _Spec {
  const _Spec(this.mobile, this.desktop, this.weight, this.serif, this.height);

  final double mobile;
  final double desktop;
  final FontWeight weight;
  final bool serif;
  final double height;
}

const Map<TextStyleType, _Spec> _specs = {
  // Serif display sizes - they tie the page back to Ahmad's logos.
  TextStyleType.h1: _Spec(27, 38, FontWeight.w700, true, 1.4),
  TextStyleType.h2: _Spec(21, 26, FontWeight.w700, true, 1.45),
  TextStyleType.large: _Spec(22, 30, FontWeight.w700, true, 1.45),

  TextStyleType.h3: _Spec(15, 19, FontWeight.w500, false, 1.4),
  TextStyleType.h4: _Spec(14, 15, FontWeight.w500, false, 1.5),

  // Body copy sits loose: Arabic paragraphs are hard to scan when cramped.
  TextStyleType.medium: _Spec(13, 14, FontWeight.w400, false, 1.85),
  TextStyleType.small: _Spec(11, 12, FontWeight.w400, false, 1.75),

  TextStyleType.button: _Spec(13, 14, FontWeight.w500, false, 1.3),
  TextStyleType.input: _Spec(13, 14, FontWeight.w400, false, 1.4),
};

class CustomText extends StatelessWidget {
  final String text;
  final TextStyleType? styleType;
  final Color? textColor;
  final TextAlign? alignText;

  final FontWeight? fontWeight;
  final double? fontSize;
  final bool? lineThrough;
  final bool? underline;
  final TextOverflow? overflow;
  final int? maxLine;
  final double? height;

  /// Overrides the family for this one call. Null keeps the style type's own
  /// default.
  final bool? serif;

  const CustomText({
    super.key,
    required this.text,
    this.styleType,
    this.textColor,
    this.fontWeight,
    this.fontSize,
    this.alignText,
    this.lineThrough,
    this.underline,
    this.overflow,
    this.maxLine,
    this.height,
    this.serif,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _style(context),
      textAlign: alignText,
      maxLines: maxLine,
      overflow: overflow,
    );
  }

  TextStyle _style(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final spec = _specs[styleType];

    // fontSize always wins, so a one-off size never needs a new enum value.
    final size =
        fontSize ??
        (spec == null ? 14 : (isMobile ? spec.mobile : spec.desktop));

    final base = TextStyle(
      fontSize: size,
      fontWeight: fontWeight ?? spec?.weight ?? FontWeight.w400,
      color: textColor ?? AppColors.textPrimary,
      height: height ?? spec?.height ?? 1.8,
      decoration: underline == true
          ? TextDecoration.underline
          : lineThrough == true
          ? TextDecoration.lineThrough
          : null,
      decorationColor: AppColors.brown,
    );

    // Applied once, at the end, so no branch can forget it.
    return (serif ?? spec?.serif ?? false)
        ? GoogleFonts.amiri(textStyle: base)
        : GoogleFonts.tajawal(textStyle: base);
  }
}
