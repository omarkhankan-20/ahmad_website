import 'package:get/get.dart';

import '../../../core/data/models/course_models.dart';
import '../../../core/data/repository/courses_repository.dart';
import '../../../core/services/courses_service.dart';

class CourseViewController extends GetxController {
  final _repo = CoursesRepository();

  final course = Rxn<Course>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final selectedLesson = Rxn<CourseLesson>();

  /// The signed URL currently in the player. Fetched per lesson rather than
  /// reused from the course payload: those URLs carry an `expires` stamp and
  /// go dead while the page sits open.
  final playbackUrl = ''.obs;
  final isLoadingPlayback = false.obs;
  final playbackError = ''.obs;

  /// Which units are open. Only the unit holding the current lesson starts
  /// expanded, so a long course does not open as a wall of titles.
  final expandedUnits = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    var id = Get.arguments is int ? Get.arguments as int : null;

    // On a page refresh every service starts over, and CoursesService.load()
    // is still in flight when this runs. Waiting for it beats telling the
    // student there is no course.
    if (id == null) {
      if (coursesService.mainCourse == null) {
        await coursesService.load();
      }
      id = coursesService.mainCourse?.id;
    }

    if (id == null) {
      isLoading.value = false;
      errorMessage.value = 'ما في دورة متاحة حالياً';
      return;
    }

    final result = await _repo.details(id);

    isLoading.value = false;
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) {
        course.value = data;
        _selectFirstPlayable(data);
      },
    );
  }

  void _selectFirstPlayable(Course data) {
    for (final unit in data.units) {
      for (final lesson in unit.lessons) {
        if (lesson.canAccess) {
          expandedUnits.add(unit.id);
          selectLesson(lesson);
          return;
        }
      }
    }

    // Nothing unlocked: still show the first lesson so the page has content
    // and the visitor can see what they would be buying.
    final unitWithLessons =
        data.units.firstWhereOrNull((u) => u.lessons.isNotEmpty);
    if (unitWithLessons != null) {
      expandedUnits.add(unitWithLessons.id);
      selectLesson(unitWithLessons.lessons.first);
    }
  }

  void toggleUnit(int unitId) {
    if (expandedUnits.contains(unitId)) {
      expandedUnits.remove(unitId);
    } else {
      expandedUnits.add(unitId);
    }
  }

  bool isExpanded(int unitId) => expandedUnits.contains(unitId);

  Future<void> selectLesson(CourseLesson lesson) async {
    selectedLesson.value = lesson;
    playbackError.value = '';

    if (lesson.comingSoon) {
      playbackUrl.value = '';
      return;
    }

    // A locked lesson still has a preview, and showing it is the whole point:
    // it is what convinces someone to buy.
    if (!lesson.canAccess) {
      playbackUrl.value = lesson.previewUrl ?? '';
      return;
    }

    isLoadingPlayback.value = true;
    final result = await _repo.lessonPlayback(lesson.id);
    isLoadingPlayback.value = false;

    result.fold(
      (failure) {
        playbackError.value = failure.message;
        // Fall back to whatever came with the course payload; it may still be
        // inside its expiry window.
        playbackUrl.value = lesson.contentUrl ?? lesson.previewUrl ?? '';
      },
      (url) => playbackUrl.value = url,
    );
  }

  CourseUnit? get currentUnit {
    final lesson = selectedLesson.value;
    if (lesson == null) return null;
    return course.value?.units
        .firstWhereOrNull((u) => u.lessons.any((l) => l.id == lesson.id));
  }

  /// Flat order across units, used by the next-lesson button.
  List<CourseLesson> get _flatLessons =>
      course.value?.units.expand((u) => u.lessons).toList() ?? const [];

  CourseLesson? get nextLesson {
    final current = selectedLesson.value;
    if (current == null) return null;

    final all = _flatLessons;
    final index = all.indexWhere((l) => l.id == current.id);
    if (index == -1 || index + 1 >= all.length) return null;
    return all[index + 1];
  }

  void goToNext() {
    final next = nextLesson;
    if (next == null) return;

    final unit = course.value?.units
        .firstWhereOrNull((u) => u.lessons.any((l) => l.id == next.id));
    if (unit != null) expandedUnits.add(unit.id);

    selectLesson(next);
  }
}