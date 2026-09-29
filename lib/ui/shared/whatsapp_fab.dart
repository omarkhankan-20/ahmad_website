import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../../core/services/app_data_service.dart';

/// Floating contact button, pinned to the corner of the main page.
///
/// The number lives in the dashboard rather than here: a phone number that
/// changes should not need a rebuild.
class WhatsappFab extends StatelessWidget {
  const WhatsappFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final number = appData.whatsappNumber;
      if (number == null) return const SizedBox.shrink();

      return Padding(
        // Clears the bottom edge on phones with a home indicator.
        padding: EdgeInsets.only(
          bottom: 16 + MediaQuery.of(context).padding.bottom,
          left: 16,
        ),
        child: Tooltip(
          message: 'تواصل معنا على واتساب',
          child: InkWell(
            onTap: () => web.window.open('https://wa.me/$number', '_blank'),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/svgs/whatsapp.svg',
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
