import 'package:flutter/material.dart';

/// Brand palette from Ahmad's logos: cream ground, espresso and brown marks.
/// Espresso is the primary action colour on light surfaces; on dark surfaces
/// it disappears, so caramel takes the primary role there.
class AppColors {
  AppColors._();

  static const cream = Color(0xFFF4EFE7);
  static const creamSoft = Color(0xFFFBF8F3);
  static const creamTint = Color(0xFFEAE0D0);
  static const creamSunk = Color(0xFFF0EAE0);

  static const line = Color(0xFFE0D7C9);
  static const lineStrong = Color(0xFFC9BCA8);

  static const espresso = Color(0xFF3A2A22);
  static const espressoDeep = Color(0xFF2B211C);
  static const espressoSurface = Color(0xFF382C25);

  static const brown = Color(0xFF8A5C2E);
  static const brownDeep = Color(0xFF5C3A26);
  static const caramel = Color(0xFFC89355);

  static const textPrimary = Color(0xFF2B211C);
  static const textMuted = Color(0xFF7A6C5F);
  static const textFaint = Color(0xFF9C8B7A);
  static const onDark = Color(0xFFF4EFE7);
  static const onDarkMuted = Color(0xFFA8998B);
  static const onCaramel = Color(0xFF241A15);

  static const danger = Color(0xFFB04A3C);
  static const success = Color(0xFF5C7A4A);
}
