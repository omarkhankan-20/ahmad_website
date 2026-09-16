import 'package:get/get.dart';

import '../../../core/data/models/purchase_request.dart';
import '../../../core/enums/request_status.dart';

class PendingViewController extends GetxController {
  final request = Rxn<PurchaseRequest>();
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PurchaseRequest) request.value = args;
    // Otherwise the page was opened directly or reloaded: fetch from
    // GET /purchase-requests/mine and take the newest one.
  }

  /// Status lives on the server, so the buyer needs a way to ask again
  /// without hunting for the browser reload button.
  Future<void> refreshStatus() async {
    isRefreshing.value = true;
    // GET /purchase-requests/mine -> newest request.
    // If it came back accepted  -> Get.offAllNamed(Routes.course)
    // If it came back rejected  -> Get.offAllNamed(Routes.rejected, arguments: r)
    await Future<void>.delayed(const Duration(milliseconds: 700));
    isRefreshing.value = false;
  }

  bool get isConsultation =>
      request.value != null &&
      request.value!.type.name == 'consultation';

  RequestStatus get status => request.value?.status ?? RequestStatus.pending;
}