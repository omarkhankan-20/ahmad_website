import 'dart:async';

import 'package:ahmad_website/core/data/models/content_models.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/main_content.dart';
import '../../../../core/enums/text_style_type.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/colors.dart';
import '../../../shared/custom_text.dart';
import '../../../shared/section_shell.dart';

/// Proof, placed before the prices.
///
/// These are screenshots of real reels with the view count already burned in,
/// so the image is the whole claim - no overlay, no number typed by us that a
/// reader could doubt.
class ResultsSection extends StatefulWidget {
  const ResultsSection({super.key});

  @override
  State<ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<ResultsSection> {
  final _scroll = ScrollController();
  Timer? _timer;

  /// Slow enough to read a number as it passes, fast enough not to look stuck.
  static const _pixelsPerTick = 0.4;

  bool _paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_paused || !_scroll.hasClients) return;

      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) return;

      final next = _scroll.offset + _pixelsPerTick;

      // The list is rendered twice, so jumping back by one set's width lands
      // on an identical frame - the loop is invisible.
      if (next >= max / 2) {
        _scroll.jumpTo(next - max / 2);
      } else {
        _scroll.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = MainContent.results;
    if (results.isEmpty) return const SizedBox.shrink();

    final isMobile = Responsive.isMobile(context);
    // Phone-shaped, because that is what the reader recognises as a reel.
    final cardWidth = isMobile ? 150.0 : 190.0;

    return SectionShell(
      topDivider: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'نتائج شغلنا',
            subtitle: 'فيديوهات اشتغلنا عليها، وأرقامها كما هي.',
          ),
          const SizedBox(height: 18),

          // Stops while the cursor is over it: a card sliding away mid-read is
          // worse than one that never moved.
          MouseRegion(
            onEnter: (_) => _paused = true,
            onExit: (_) => _paused = false,
            child: SizedBox(
              height: cardWidth * 16 / 9,
              child: ListView.builder(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                // Twice the list: the second pass is what the loop jumps back
                // into, so there is never an empty edge.
                itemCount: results.length * 2,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: _ResultCard(
                    result: results[index % results.length],
                    width: cardWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.width});

  final ResultShot result;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              // 9:16 - the shape of every reel these came from.
              aspectRatio: 9 / 16,
              child: Image.asset(
                result.asset,
                fit: BoxFit.cover,
                // A missing file must not leave a broken box on the page that
                // is meant to build trust.
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.creamTint,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 22,
                    color: AppColors.textFaint,
                  ),
                ),
              ),
            ),
          ),
          if (result.label != null) ...[
            const SizedBox(height: 7),
            CustomText(
              text: result.label!,
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
              maxLine: 2,
            ),
          ],
        ],
      ),
    );
  }
}
