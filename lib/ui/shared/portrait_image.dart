import 'package:flutter/material.dart';

import '../../core/data/main_content.dart';
import '../../core/enums/text_style_type.dart';
import 'colors.dart';
import 'custom_text.dart';

/// Ahmad's photo, used by the hero and the about section. The asset path lives
/// here only - a wrong path should be one fix, not a hunt through two files.
class PortraitImage extends StatelessWidget {
  const PortraitImage({
    super.key,
    required this.height,
    this.assetPath = heroPhoto,
    this.alignment = const Alignment(0, -0.25),
    this.width,
  });

  static const String heroPhoto = 'assets/images/pngs/ahmad.png';

  final double height;
  final double? width;
  final String assetPath;

  /// Nudged up by default: a centred crop of a full-length shot lands on the
  /// torso and cuts the face.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        color: AppColors.creamTint,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: alignment,
          semanticLabel: MainContent.creatorName,
          // A missing or misnamed file falls back to the placeholder instead
          // of showing a red error box in front of the client.
          errorBuilder: (context, error, stackTrace) => const Center(
            child: CustomText(
              text: 'صورة أحمد',
              styleType: TextStyleType.small,
              textColor: AppColors.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}