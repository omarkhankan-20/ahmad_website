import 'package:ahmad_website/core/data/repository/storage_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/main_content.dart';
import '../../../core/data/models/content_models.dart';
import '../../../core/enums/offering_type.dart';
import '../../../core/services/courses_service.dart';

class MainViewController extends GetxController {
  final scrollController = ScrollController();

  /// Anchors for the nav links. They live here so the nav bar and the sections
  /// stay decoupled - neither needs a reference to the other.
  final offeringsKey = GlobalKey();
  final aboutKey = GlobalKey();
  final consultationKey = GlobalKey();

  Offering get consultationOffering => MainContent.offerings.firstWhere(
    (o) => o.type == OfferingType.consultation,
  );

  /// -1 means every question is collapsed.
  final expandedFaq = (-1).obs;

  void toggleFaq(int index) =>
      expandedFaq.value = expandedFaq.value == index ? -1 : index;

  void scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void startPurchase(Offering offering) {
    if (offering.type == OfferingType.consultation) {
      Get.toNamed(Routes.consultation);
      return;
    }

    final course = coursesService.mainCourse;
    if (course == null) return;
    if (course.isPurchased) {
      Get.toNamed(Routes.course);
      return;
    }

    // A signed-in buyer skips signup entirely; sending them to /register would
    // bounce off GuestMiddleware and look like the button is dead.
    Get.toNamed(
      storage.isLoggedIn ? Routes.checkout : Routes.register,
      arguments: course,
    );
  }

  /// Lets the nav bar on any page land on a home section by name.
  void scrollToSection(String section) {
    final key = switch (section) {
      'offerings' => offeringsKey,
      'about' => aboutKey,
      'consultation' => consultationKey,
      _ => null,
    };
    if (key != null) scrollTo(key);
  }

  /// Arriving from another page with a section to show: wait for the page to
  /// lay out, then scroll to it.
  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args is Map && args['section'] is String) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scrollToSection(args['section'] as String),
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
