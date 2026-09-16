import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/main_content.dart';
import '../../../core/data/models/content_models.dart';
import '../../../core/enums/offering_type.dart';

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

  /// Carries the chosen offer into signup so the buyer lands back on checkout
  /// instead of the home page.
  ///
  /// Passed through Get.arguments for now; it moves to IntentService so the
  /// choice also survives a page refresh, and so a logged-in buyer skips
  /// straight to checkout.
  void startPurchase(Offering offering) {
    // Consultations collect the brief first: the answers are what Ahmad
    // prepares from, and filling them in is itself part of the sell.
    if (offering.type == OfferingType.consultation) {
      Get.toNamed(Routes.consultation);
      return;
    }
    Get.toNamed(Routes.register, arguments: offering);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
