import 'package:get/get.dart';

import '../../../core/data/course_content.dart';
import '../../../core/data/models/lesson.dart';

class CourseViewController extends GetxController {
  final lessons = <Lesson>[].obs;
  final currentId = ''.obs;

  /// Mobile only: the lesson list sits under the player and starts open.
  final isListExpanded = true.obs;

  /// Set while the signed playback url is being fetched.
  final isPreparing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Replaced by GET /lessons.
    lessons.assignAll(CourseContent.lessons);

    // Resume where the student stopped rather than always restarting at
    // lesson one - the whole point of a self-paced course.
    final next = lessons.firstWhereOrNull((l) => !l.isCompleted);
    currentId.value = (next ?? lessons.first).id;
  }

  Lesson get current =>
      lessons.firstWhere((l) => l.id == currentId.value, orElse: () => lessons.first);

  int get completedCount => lessons.where((l) => l.isCompleted).length;

  double get progress =>
      lessons.isEmpty ? 0 : completedCount / lessons.length;

  Lesson? get nextLesson {
    final i = lessons.indexWhere((l) => l.id == currentId.value);
    if (i < 0 || i + 1 >= lessons.length) return null;
    return lessons[i + 1];
  }

  Future<void> selectLesson(String id) async {
    if (id == currentId.value) return;
    currentId.value = id;
    await preparePlayback();
  }

  void goNext() {
    final next = nextLesson;
    if (next != null) selectLesson(next.id);
  }

  void toggleList() => isListExpanded.toggle();

  /// GET /lessons/{id}/stream returns a signed url that expires in 30 minutes.
  /// It is requested per play and never stored - if it expires mid-lesson,
  /// ask for a new one rather than caching a longer-lived link.
  ///
  /// Bunny applies the viewer's email as a burned-in watermark server-side,
  /// so nothing here needs to draw it - and nothing here could, since a client
  /// drawn overlay comes off with one line of CSS.
  Future<void> preparePlayback() async {
    isPreparing.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    isPreparing.value = false;
  }

  void markCurrentComplete() {
    final i = lessons.indexWhere((l) => l.id == currentId.value);
    if (i < 0) return;
    lessons[i] = lessons[i].copyWith(isCompleted: true);
    lessons.refresh();
  }
}