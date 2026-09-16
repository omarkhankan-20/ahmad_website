import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/purchase_request.dart';

class RejectedViewController extends GetxController {
  final request = Rxn<PurchaseRequest>();
  final copiedContact = false.obs;

  /// TODO(ahmad): real support number.
  static const String supportWhatsapp = '+961 XX XXX XXX';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PurchaseRequest) request.value = args;
  }

  String get reason =>
      request.value?.rejectReason ??
      'ما قدرنا نطابق التحويل مع الطلب.';

  /// Sends the buyer back to checkout carrying the old request, so the fields
  /// arrive filled in. Making someone retype everything because one digit was
  /// wrong is how a paying customer walks away.
  void resubmit() {
    Get.offNamed(Routes.checkout, arguments: request.value);
  }

  Future<void> copyContact() async {
    await Clipboard.setData(const ClipboardData(text: supportWhatsapp));
    copiedContact.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    copiedContact.value = false;
  }
}