import 'package:get/get.dart';

import '../data/models/course_models.dart';
import '../data/repository/courses_repository.dart';

/// Holds the catalogue. The landing page, the checkout summary and the course
/// player all read the same objects, so the price a buyer sees and the
/// course_id that gets submitted can never drift apart.
class CoursesService extends GetxService {
  final _repo = CoursesRepository();

  final courses = <Course>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// The site sells one course today, but the endpoint returns a list and
  /// Ahmad can publish more from the dashboard. Everything reads through this
  /// getter, so adding a second course later is a UI change, not a data one.
  Course? get mainCourse => courses.isEmpty ? null : courses.first;

  bool get hasCourse => mainCourse != null;

  /// Server-formatted, e.g. "22.00". Null while loading so the UI can hide the
  /// price row instead of flashing a zero.
  String? get mainPrice {
    final value = mainCourse?.price;
    return (value == null || value.isEmpty) ? null : value;
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repo.filter();

    isLoading.value = false;
    result.fold(
      (failure) => errorMessage.value = failure.message,
      courses.assignAll,
    );
  }

  /// is_purchased and can_access are per-user, so the catalogue has to be
  /// re-read whenever the session changes. Called after login, after otp
  /// verification, after logout, and once a purchase is approved.
  Future<void> reloadForSession() => load();
}

CoursesService get coursesService => Get.find<CoursesService>();