import 'package:flutter/widgets.dart';

/// One breakpoint, one source of truth. Every view builds mobile or desktop
/// from the same route and the same controller - never two route trees.
class Responsive {
  Responsive._();

  static const double breakpoint = 900;
  static const double maxContentWidth = 1120;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < breakpoint;

  static double gutter(BuildContext context) => isMobile(context) ? 20 : 48;

  static double sectionGap(BuildContext context) => isMobile(context) ? 44 : 76;

  static T pick<T>(
    BuildContext context, {
    required T mobile,
    required T desktop,
  }) =>
      isMobile(context) ? mobile : desktop;
}
