import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/app_data_models.dart';
import '../../../core/data/repository/consultation_repository.dart';
import '../../../core/data/repository/storage_repository.dart';
import '../../../core/services/app_data_service.dart';

class ConsultationViewController extends GetxController {
  final accountLink = TextEditingController();
  final industry = TextEditingController();
  final objective = TextEditingController();
  final transactionNumber = TextEditingController();

  final _repo = ConsultationRepository();

  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  /// Closed set on the server: morning | afternoon | evening. Free text would
  /// be rejected, so the UI offers exactly these three.
  final preferredTime = 'morning'.obs;

  static const timeOptions = <String, String>{
    'morning': 'صباحاً',
    'afternoon': 'بعد الظهر',
    'evening': 'مساءً',
  };

  final selectedMethodCode = ''.obs;
  final copied = false.obs;

  final receiptBytes = Rxn<Uint8List>();
  final receiptName = ''.obs;
  final receiptSizeKb = 0.obs;
  final receiptIsImage = true.obs;

  static const int maxReceiptKb = 10 * 1024;

  @override
  void onInit() {
    super.onInit();
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

  void selectMethod(String code) => selectedMethodCode.value = code;

  void selectTime(String value) => preferredTime.value = value;

  String? get price => appData.consultationPrice;

  Future<void> copyAccount() async {
    final code = selectedMethod?.accountCode ?? '';
    if (code.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: code));
    copied.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    copied.value = false;
  }

  Future<void> pickReceipt() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
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
        _setError('receipt', 'الملف أكبر من ١٠ ميغا — جرّب ملف أصغر');
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

    final link = accountLink.text.trim();
    if (link.length < 4) {
      next['account_link'] = 'حطّ رابط حسابك أو مشروعك';
    }

    if (receiptBytes.value == null) {
      next['receipt'] = 'لازم ترفع الإيصال';
    }

    if (industry.text.trim().length < 2) {
      next['industry'] = 'اكتب مجال شغلك';
    }

    // The brief is what makes the session useful. A one-line answer wastes
    // the first ten minutes on questions Ahmad could have read beforehand.
    if (objective.text.trim().length < 20) {
      next['session_objective'] = 'اكتب هدفك بتفصيل أكتر — سطرين على الأقل';
    }

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
    // Booking needs a token, and the brief is long enough that losing it to a
    // redirect would be painful. Checked before the request, not after.
    if (!storage.isLoggedIn) {
      Get.toNamed(Routes.login);
      return;
    }

    if (!validate()) return;

    final method = selectedMethod;
    if (method == null) return;

    isLoading.value = true;
    final result = await _repo.book(
      accountLink: accountLink.text.trim(),
      industry: industry.text.trim(),
      sessionObjective: objective.text.trim(),
      preferredTime: preferredTime.value,
      paymentMethodCode: method.code,
      transactionNumber: transactionNumber.text.trim(),
      receiptBytes: receiptBytes.value!,
      receiptName: receiptName.value,
    );
    isLoading.value = false;

    result.fold(
      (failure) {
        const onScreen = {
          'account_link',
          'industry',
          'session_objective',
          'preferred_time',
          'transaction_number',
          'receipt',
        };
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
      },
      (booking) =>
          Get.offAllNamed(Routes.consultationStatus, arguments: booking),
    );
  }
}
