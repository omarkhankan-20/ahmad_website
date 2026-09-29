import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/app_data_models.dart';
import '../../../core/data/models/course_models.dart';
import '../../../core/data/repository/purchase_repository.dart';
import '../../../core/services/app_data_service.dart';
import '../../../core/services/courses_service.dart';

class CheckoutViewController extends GetxController {
  final transactionNumber = TextEditingController();

  final _purchases = PurchaseRepository();

  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  /// Which transfer method the buyer picked. There is one today, but the
  /// endpoint returns a list and Ahmad can add more from the dashboard.
  final selectedMethodCode = ''.obs;

  /// Bytes rather than a File: on web a picked file has no path, and the
  /// preview has to render from memory.
  final receiptBytes = Rxn<Uint8List>();
  final receiptName = ''.obs;
  final receiptSizeKb = 0.obs;
  final receiptIsImage = true.obs;

  /// Confirms the copy button did something, without firing a snackbar.
  final copied = false.obs;

  /// What is being paid for. Arrives from signup or straight from a buy
  /// button; falls back to the catalogue so a refresh on /checkout still works.
  Course? course;

  static const int maxReceiptKb = 5 * 1024;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Course) course = args;
    course ??= coursesService.mainCourse;
    if (course == null) _recoverCourse();

    final methods = appData.paymentMethods;
    if (methods.isNotEmpty) selectedMethodCode.value = methods.first.code;
  }

  List<AppPaymentMethod> get methods => appData.paymentMethods;

  AppPaymentMethod? get selectedMethod {
    if (methods.isEmpty) return null;
    return methods.firstWhereOrNull(
          (m) => m.code == selectedMethodCode.value,
        ) ??
        methods.first;
  }

  /// Checkout survives a refresh: the services reload from scratch, so the
  /// course has to be picked up again once the catalogue arrives.
  Future<void> _recoverCourse() async {
    await coursesService.load();
    course = coursesService.mainCourse;
    update();
  }

  void selectMethod(String code) => selectedMethodCode.value = code;

  Future<void> copyAccount() async {
    final code = selectedMethod?.accountCode ?? '';
    if (code.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: code));
    copied.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    copied.value = false;
  }

  /// File, not camera: nearly everyone screenshots the transfer, and some
  /// banking apps hand out a PDF receipt.
  Future<void> pickReceipt() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        // Required on web: without it, bytes come back null.
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        _setError('receipt', 'ما قدرنا نقرا الملف — جرّب مرة تانية');
        return;
      }

      final sizeKb = (bytes.lengthInBytes / 1024).round();
      if (sizeKb > maxReceiptKb) {
        _setError('receipt', 'الملف أكبر من ٥ ميغا — جرّب ملف أصغر');
        return;
      }

      receiptBytes.value = bytes;
      receiptName.value = file.name;
      receiptSizeKb.value = sizeKb;
      receiptIsImage.value = file.extension?.toLowerCase() != 'pdf';
      clearError('receipt');
    } catch (_) {
      _setError('receipt', 'ما قدرنا نفتح الملف — جرّب مرة تانية');
    }
  }

  void removeReceipt() {
    receiptBytes.value = null;
    receiptName.value = '';
    receiptSizeKb.value = 0;
    receiptIsImage.value = true;
  }

  void _setError(String field, String message) {
    errors[field] = message;
    errors.refresh();
  }

  void clearError(String field) {
    if (errors.containsKey(field)) {
      errors.remove(field);
      errors.refresh();
    }
  }

  bool validate() {
    final next = <String, String>{};

    final tx = transactionNumber.text.trim();
    if (tx.length < 4 || !RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(tx)) {
      next['transaction_number'] = 'رقم العملية غير صحيح';
    }

    if (receiptBytes.value == null) {
      next['receipt'] = 'لازم ترفع الإيصال';
    }

    if (selectedMethod == null) {
      next['form'] = 'ما في طريقة دفع متاحة حالياً';
    }

    errors.value = next;
    return next.isEmpty;
  }

  Future<void> submit() async {
    if (!validate()) return;

    final target = course;
    final method = selectedMethod;
    if (target == null || method == null) return;

    isLoading.value = true;
    final result = await _purchases.purchaseCourse(
      courseId: target.id,
      paymentMethodCode: method.code,
      transactionNumber: transactionNumber.text.trim(),
      receiptBytes: receiptBytes.value!,
      receiptName: receiptName.value,
    );
    isLoading.value = false;

    result.fold((failure) {
      // Only errors that have an input on screen are shown under a field.
      // Anything else - course_id, payment_method_code - has no widget to
      // land on, so it goes above the form instead of vanishing.
      const onScreen = {'transaction_number', 'receipt'};
      final mapped = <String, String>{};
      final orphans = <String>[];

      failure.fields.forEach((key, value) {
        if (onScreen.contains(key)) {
          mapped[key] = value;
        } else {
          orphans.add(value);
        }
      });

      if (mapped.isEmpty || orphans.isNotEmpty) {
        mapped['form'] = orphans.isNotEmpty ? orphans.first : failure.message;
      }

      errors.value = mapped;
    }, (request) => Get.offAllNamed(Routes.pending, arguments: request));
  }
}
