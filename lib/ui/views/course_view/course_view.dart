import 'package:ahmad_website/ui/shared/site_page.dart';
import 'package:ahmad_website/ui/shared/telegram_group_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/course_models.dart';
import '../../../core/enums/text_style_type.dart';
import '../../../core/utils/responsive.dart';
import '../../shared/app_button.dart';
import '../../shared/bunny_player.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text.dart';
import '../../shared/section_shell.dart';
import 'course_view_controller.dart';

/// Player on one side, unit list on the other. Units collapse because a
/// course of forty lessons is unreadable as one flat list.
class CourseView extends StatelessWidget {
  const CourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CourseViewController());
    final isMobile = Responsive.isMobile(context);

    return SitePage(
      child: SingleChildScrollView(
        child: SectionShell(
          child: Obx(() {
            if (controller.isLoading.value && controller.course.value == null) {
              return const _Centered(text: 'عم نحمّل الدورة…');
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _Centered(text: controller.errorMessage.value);
            }

            final course = controller.course.value;
            if (course == null) {
              return const _Centered(text: 'ما في دورة متاحة حالياً');
            }

            final player = _PlayerPane(controller: controller);
            final list = _UnitList(controller: controller, course: course);

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [player, const SizedBox(height: 18), list],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: player),
                const SizedBox(width: 18),
                SizedBox(width: 330, child: list),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _PlayerPane extends StatelessWidget {
  const _PlayerPane({required this.controller});

  final CourseViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lesson = controller.selectedLesson.value;
      final url = controller.playbackUrl.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.isLoadingPlayback.value)
            const _Surface(text: 'عم نجهّز الدرس…')
          else if (lesson?.comingSoon == true)
            const _Surface(text: 'هالدرس لسا قادم')
          else if (url.isEmpty)
            const _Surface(text: 'ما في فيديو لهالدرس')
          else
            BunnyPlayer(url: url),

          if (lesson != null) ...[
            const SizedBox(height: 16),
            // A preview is labelled as one. Letting someone think a 40-second
            // sample is the lesson turns into a refund request.
            if (!lesson.canAccess && !lesson.comingSoon)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.creamTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.brown,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: CustomText(
                        text: 'هيدي معاينة — اشترك لتشوف الدرس كامل.',
                        styleType: TextStyleType.small,
                        textColor: AppColors.textMuted,
                      ),
                    ),
                    AppButton(
                      label: 'اشترك',
                      onPressed: () => Get.toNamed(Routes.main),
                    ),
                  ],
                ),
              ),
            CustomText(
              text: controller.currentUnit?.title ?? '',
              styleType: TextStyleType.small,
              textColor: AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            CustomText(text: lesson.title, styleType: TextStyleType.h3),
            const SizedBox(height: 4),
            CustomText(
              text: lesson.durationForHumans,
              styleType: TextStyleType.small,
              textColor: AppColors.textFaint,
            ),
            if (controller.playbackError.value.isNotEmpty) ...[
              const SizedBox(height: 10),
              CustomText(
                text: controller.playbackError.value,
                styleType: TextStyleType.small,
                textColor: AppColors.danger,
              ),
            ],
            if (controller.nextLesson != null) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'الدرس التالي',
                style: AppButtonStyle.outline,
                onPressed: controller.goToNext,
              ),
            ],
          ],
        ],
      );
    });
  }
}

class _UnitList extends StatelessWidget {
  const _UnitList({required this.controller, required this.course});

  final CourseViewController controller;
  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        border: Border.all(color: AppColors.line, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TelegramGroupCard(),
          CustomText(text: course.title, styleType: TextStyleType.h4),
          const SizedBox(height: 3),
          CustomText(
            text: '${course.units.length} محاور · ${course.totalDuration}',
            styleType: TextStyleType.small,
            textColor: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          for (final unit in course.units)
            _UnitTile(controller: controller, unit: unit),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.controller, required this.unit});

  final CourseViewController controller;
  final CourseUnit unit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.isExpanded(unit.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.toggleUnit(unit.id),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CustomText(
                      text: unit.title,
                      styleType: TextStyleType.medium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CustomText(
                    text: '${unit.lessons.length} دروس',
                    styleType: TextStyleType.small,
                    textColor: AppColors.textFaint,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            for (final lesson in unit.lessons)
              _LessonRow(controller: controller, lesson: lesson),
          const Divider(height: 1, color: AppColors.line, thickness: 0.8),
        ],
      );
    });
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.controller, required this.lesson});

  final CourseViewController controller;
  final CourseLesson lesson;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedLesson.value?.id == lesson.id;

      return InkWell(
        onTap: () => controller.selectLesson(lesson),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.espresso : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                lesson.comingSoon
                    ? Icons.schedule
                    : lesson.canAccess
                    ? Icons.play_circle_outline
                    : Icons.lock_outline,
                size: 16,
                color: selected ? AppColors.onDark : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text: lesson.title,
                  styleType: TextStyleType.medium,
                  maxLine: 2,
                  textColor: selected
                      ? AppColors.onDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              CustomText(
                text: lesson.durationForHumans,
                styleType: TextStyleType.small,
                textColor: selected ? AppColors.creamTint : AppColors.textFaint,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.espresso,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: CustomText(
          text: text,
          styleType: TextStyleType.medium,
          textColor: AppColors.creamTint,
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Center(
        child: CustomText(
          text: text,
          styleType: TextStyleType.medium,
          textColor: AppColors.textMuted,
        ),
      ),
    );
  }
}
