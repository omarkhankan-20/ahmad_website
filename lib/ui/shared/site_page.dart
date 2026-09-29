import 'package:flutter/material.dart';

import 'colors.dart';
import 'site_nav_bar.dart';

/// Shell for every page except home: the nav bar pinned on top, the page
/// scrolling underneath. Pinned rather than scrolling away, so the way back
/// is always one tap - which is the whole reason it is here.
class SitePage extends StatelessWidget {
  const SitePage({super.key, required this.child, this.minimalNav = false});

  final Widget child;

  /// Logo and account only - for signup, login and checkout.
  final bool minimalNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          SiteNavBar(minimal: minimalNav),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}