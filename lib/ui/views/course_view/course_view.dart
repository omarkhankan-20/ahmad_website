import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/course_content.dart';
import '../../../core/data/models/lesson.dart';
import '../../../core/enums/text_style_type.dart';
import '../../../core/utils/responsive.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import 'course_view_controller.dart';

class CourseView extends StatelessWidget {
  const CourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CourseViewController());
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: isMobile
            ? _MobileLayout(controller: controller)
            : _DesktopLayout(controller: controller),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.controller});

  final CourseViewController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: _LessonList(controller: controller)),
              const SizedBox(width: 20),
              Expanded(child: _PlayerPane(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.controller});

  final CourseViewController controller;

  @override
  Widget build(BuildContext context) {
    // Video first and full width: at 390px there is no room for a sidebar,
    // and a shrunken player is not watchable.
    return SingleChildScrollView(
      child: Column(
        children: [
          _PlayerPane(controller: controller),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _LessonList(controller: controller, collapsible: true),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PlayerPane extends StatelessWidget {
  const _PlayerPane({required this.controller});

  final CourseViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      final lesson = controller.current;
      final next = controller.nextLesson;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VideoSurface(controller: controller),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                CustomText(
                  text: 'المحور ${lesson.order} — ${lesson.title}',
                  styleType: TextStyleType.h3,
                ),
                const SizedBox(height: 6),
                CustomText(
                  text: lesson.description,
                  styleType: TextStyleType.medium,
                  textColor: AppColors.textMuted,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Kept on mobile too. It is part of what the student paid
                    // for, so it does not get dropped to save space.
                    if (lesson.attachmentUrl != null)
                      const _ChipButton(
                        icon: Icons.description_outlined,
                        label: 'ملف التمارين',
                      ),
                    if (next != null)
                      _ChipButton(
                        icon: Icons.arrow_back,
                        label: 'الدرس التالي',
                        onTap: controller.goNext,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// Everything video-specific lives here. Swapping the placeholder for a real
/// player (video_player + chewie, fed by the signed url) touches this widget
/// and nothing else.
class _VideoSurface extends StatelessWidget {
  const _VideoSurface({required this.controller});

  final CourseViewController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Obx(
      () => AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.espressoDeep,
            borderRadius:
                isMobile ? null : BorderRadius.circular(12),
          ),
          clipBehavior: isMobile ? Clip.none : Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (controller.isPreparing.value)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.caramel,
                  ),
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.caramel,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 30,
                    color: AppColors.onCaramel,
                  ),
                ),
              PositionedDirectional(
                bottom: 12,
                start: 14,
                end: 14,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A4A40),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: 0.35,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.caramel,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CustomText(
                      text: controller.current.durationLabel,
                      styleType: TextStyleType.small,
                      textColor: AppColors.onDarkMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({required this.controller, this.collapsible = false});

  final CourseViewController controller;
  final bool collapsible;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = !collapsible || controller.isListExpanded.value;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.creamSoft,
          border: Border.all(color: AppColors.line, width: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: collapsible ? controller.toggleList : null,
              child: Row(
                children: [
                  const Expanded(
                    child: CustomText(
                      text: CourseContent.courseTitle,
                      styleType: TextStyleType.h4,
                    ),
                  ),
                  CustomText(
                    text:
                        '${controller.completedCount} من ${controller.lessons.length}',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textMuted,
                  ),
                  if (collapsible)
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Not decoration: a student who can see progress finishes, and a
            // student who finishes does not ask for a refund.
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: controller.progress,
                minHeight: 5,
                backgroundColor: AppColors.creamTint,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.brown),
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              for (final lesson in controller.lessons)
                _LessonRow(
                  lesson: lesson,
                  isCurrent: lesson.id == controller.currentId.value,
                  onTap: () => controller.selectLesson(lesson.id),
                ),
            ],
          ],
        ),
      );
    });
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.isCurrent,
    required this.onTap,
  });

  final Lesson lesson;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.espresso
                : lesson.isCompleted
                    ? AppColors.creamSunk
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isCurrent
                    ? Icons.play_arrow_rounded
                    : lesson.isCompleted
                        ? Icons.check
                        : Icons.circle_outlined,
                size: 16,
                color: isCurrent ? AppColors.onDark : AppColors.brown,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: CustomText(
                  text: lesson.title,
                  styleType: TextStyleType.medium,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                  height: 1.3,
                  fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
                  textColor:
                      isCurrent ? AppColors.onDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              CustomText(
                text: lesson.durationLabel,
                styleType: TextStyleType.small,
                textColor: isCurrent
                    ? AppColors.onDarkMuted
                    : AppColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.creamSoft,
          border: Border.all(color: AppColors.line, width: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.brown),
            const SizedBox(width: 7),
            CustomText(text: label, styleType: TextStyleType.medium),
          ],
        ),
      ),
    );
  }
}