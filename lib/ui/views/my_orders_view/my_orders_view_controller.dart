import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/repository/consultation_repository.dart';
import '../../../core/data/repository/purchase_repository.dart';

class MyOrdersViewController extends GetxController {
  final orders = <OrderItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final _purchases = PurchaseRepository();
  final _consultations = ConsultationRepository();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    // Fired together rather than one after the other: two round trips in
    // sequence would double the wait on a screen that is just a list.
    final results = await Future.wait([
      _purchases.myHistory(),
      _consultations.myConsultations(),
    ]);

    final merged = <OrderItem>[];
    var failures = 0;

    results[0].fold(
      (_) => failures++,
      (list) => merged.addAll(
        (list as List).map((e) => OrderItem.fromPurchase(e)),
      ),
    );

    results[1].fold(
      (_) => failures++,
      (list) => merged.addAll(
        (list as List).map((e) => OrderItem.fromBooking(e)),
      ),
    );

    // Newest first, across both products.
    merged.sort((a, b) {
      final left = a.createdAt;
      final right = b.createdAt;
      if (left == null && right == null) return 0;
      if (left == null) return 1;
      if (right == null) return -1;
      return right.compareTo(left);
    });

    orders.assignAll(merged);
    isLoading.value = false;

    // Only an error if nothing at all came back; one endpoint failing while
    // the other returns rows is better shown as a partial list than as a
    // blank error page.
    if (failures == 2) {
      errorMessage.value = 'ما قدرنا نجيب طلباتك — جرّب مرة تانية';
    }
  }

  /// Every row ends in one action, decided by status. A list of orders with
  /// nothing to press on just moves the question to WhatsApp.
  void openOrder(OrderItem order) {
    if (!order.isCourse) {
      Get.toNamed(Routes.consultationStatus, arguments: order.booking);
      return;
    }

    switch (order.status) {
      case OrderStatus.pending:
        Get.toNamed(Routes.pending, arguments: order.purchase);
      case OrderStatus.rejected:
        Get.toNamed(Routes.rejected, arguments: order.purchase);
      case OrderStatus.accepted:
      case OrderStatus.scheduled:
      case OrderStatus.done:
        Get.toNamed(Routes.course);
    }
  }

  String actionLabel(OrderItem order) {
    if (!order.isCourse) {
      return switch (order.status) {
        OrderStatus.pending => 'تتبّع الطلب',
        OrderStatus.rejected => 'شوف السبب',
        OrderStatus.accepted => 'تفاصيل الجلسة',
        OrderStatus.scheduled => 'تفاصيل الجلسة',
        OrderStatus.done => 'تفاصيل الجلسة',
      };
    }

    return switch (order.status) {
      OrderStatus.pending => 'تتبّع الطلب',
      OrderStatus.rejected => 'عدّل وأعد الإرسال',
      _ => 'افتح الدورة',
    };
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