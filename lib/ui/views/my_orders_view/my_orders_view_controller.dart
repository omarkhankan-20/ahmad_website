import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/purchase_request.dart';
import '../../../core/enums/offering_type.dart';
import '../../../core/enums/request_status.dart';

class MyOrdersViewController extends GetxController {
  final requests = <PurchaseRequest>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// GET /purchase-requests/mine, newest first.
  Future<void> load() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // TEMP: sample rows so the screen can be built and reviewed. Delete once
    // the endpoint is live.
    requests.assignAll([
      PurchaseRequest(
        id: 'req_3',
        productTitle: 'جلسة استشارية',
        type: OfferingType.consultation,
        senderName: 'عمر خنكان',
        transactionNumber: '416542682',
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PurchaseRequest(
        id: 'req_2',
        productTitle: 'الدورة الكاملة',
        type: OfferingType.course,
        senderName: 'عمر خنكان',
        transactionNumber: 'hjv12345',
        status: RequestStatus.rejected,
        rejectReason:
            'رقم العملية مش مطابق لأي تحويل وصل. تأكّد من الرقم بالإيصال وأعد الإرسال.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PurchaseRequest(
        id: 'req_1',
        productTitle: 'الدورة الكاملة',
        type: OfferingType.course,
        senderName: 'عمر خنكان',
        transactionNumber: '98606586880686',
        status: RequestStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
    ]);

    isLoading.value = false;
  }

  /// Every row ends in one action, decided by status. A list of orders with
  /// nothing to press on just moves the question to WhatsApp.
  void openRequest(PurchaseRequest request) {
    switch (request.status) {
      case RequestStatus.pending:
        Get.toNamed(Routes.pending, arguments: request);
      case RequestStatus.rejected:
        Get.toNamed(Routes.rejected, arguments: request);
      case RequestStatus.accepted:
        if (request.type == OfferingType.course) {
          Get.toNamed(Routes.course);
        } else {
          // Consultation approved: the scheduling state lives on its own
          // screen, which is still to be built.
          Get.toNamed(Routes.pending, arguments: request);
        }
    }
  }

  String actionLabel(PurchaseRequest request) {
    switch (request.status) {
      case RequestStatus.pending:
        return 'تتبّع الطلب';
      case RequestStatus.rejected:
        return 'عدّل وأعد الإرسال';
      case RequestStatus.accepted:
        return request.type == OfferingType.course
            ? 'افتح الدورة'
            : 'تفاصيل الجلسة';
    }
  }

  /// Relative rather than a date: "أمس" is read at a glance, "2026-09-14"
  /// has to be worked out.
  String whenLabel(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'من ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'من ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 30) return 'من ${diff.inDays} يوم';
    return 'من ${(diff.inDays / 30).floor()} شهر';
  }
}