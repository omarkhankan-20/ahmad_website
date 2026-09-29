import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/purchase_request.dart';
import '../../../core/data/repository/purchase_repository.dart';
import '../../../core/enums/offering_type.dart';
import '../../../core/enums/request_status.dart';

class PendingViewController extends GetxController {
  final request = Rxn<PurchaseRequest>();
  final isRefreshing = false.obs;

  final _purchases = PurchaseRepository();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PurchaseRequest) {
      request.value = args;
    } else {
      // Opened directly or reloaded: the newest request is the one this
      // screen is about.
      refreshStatus();
    }
  }

  /// Status lives on the server, so the buyer needs a way to ask again without
  /// hunting for the browser reload button.
  Future<void> refreshStatus() async {
    isRefreshing.value = true;
    final result = await _purchases.myHistory();
    isRefreshing.value = false;

    result.fold((_) {}, (list) {
      if (list.isEmpty) return;

      final latest = list.first;
      request.value = latest;

      switch (latest.status) {
        case RequestStatus.accepted:
          Get.offAllNamed(Routes.course);
        case RequestStatus.rejected:
          Get.offAllNamed(Routes.rejected, arguments: latest);
        case RequestStatus.pending:
          break;
      }
    });
  }

  /// Compared against the enum, not a string: renaming the value should break
  /// the build, not silently fall through to the course wording.
  bool get isConsultation => request.value?.type == OfferingType.consultation;

  RequestStatus get status => request.value?.status ?? RequestStatus.pending;
}