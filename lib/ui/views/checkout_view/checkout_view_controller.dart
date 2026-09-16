import 'package:ahmad_website/app/routes/app_routes.dart';
import 'package:ahmad_website/core/data/models/purchase_request.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
// Aliased: another FilePicker in scope was shadowing the package's one.
import 'package:file_picker/file_picker.dart';

import '../../../core/data/models/content_models.dart';
import '../../../core/data/models/payment_method.dart';
import '../../../core/data/payment_content.dart';

class CheckoutViewController extends GetxController {
  final senderName = TextEditingController();
  final transactionNumber = TextEditingController();

  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  /// Which transfer method the buyer picked. Defaults to the first so the
  /// page always shows one number ready to copy.
  final selectedMethodId = PaymentContent.methods.first.id.obs;

  /// Bytes rather than a File: on web there is no file path, and the preview
  /// has to render from memory.
  final receiptBytes = Rxn<Uint8List>();
  final receiptName = ''.obs;
  final receiptSizeKb = 0.obs;

  /// PDF receipts have no thumbnail, so the UI needs to know which it got.
  final receiptIsImage = true.obs;

  /// Which number was just copied, so the button can confirm itself for a
  /// moment instead of firing a snackbar.
  final copiedMethodId = ''.obs;

  /// What is being paid for. Arrives from signup or from a buy button.
  Offering? offering;

  static const int maxReceiptKb = 5 * 1024;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Offering) offering = args;

    // Coming back from a rejection: carry the old values so only the wrong
    // one needs fixing.
    if (args is PurchaseRequest) {
      senderName.text = args.senderName;
      transactionNumber.text = args.transactionNumber;
    }
  }

  PaymentMethod get selectedMethod =>
      PaymentContent.methods.firstWhere((m) => m.id == selectedMethodId.value);

  void selectMethod(String id) => selectedMethodId.value = id;

  Future<void> copyNumber(PaymentMethod method) async {
    await Clipboard.setData(ClipboardData(text: method.number));
    copiedMethodId.value = method.id;
    await Future<void>.delayed(const Duration(seconds: 2));
    if (copiedMethodId.value == method.id) copiedMethodId.value = '';
  }

  /// File, not camera: nearly everyone screenshots the transfer, and some
  /// banking apps hand out a PDF receipt. A camera button would be a third
  /// choice almost nobody needs.
  Future<void> pickReceipt() async {
    try {
      // file_picker 11 dropped the `.platform` getter - the call sits on the
      // class now.
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
        errors['receipt'] = 'ما قدرنا نقرا الملف — جرّب مرة تانية';
        errors.refresh();
        return;
      }

      final sizeKb = (bytes.lengthInBytes / 1024).round();
      if (sizeKb > maxReceiptKb) {
        errors['receipt'] = 'الملف أكبر من ٥ ميغا — جرّب ملف أصغر';
        errors.refresh();
        return;
      }

      receiptBytes.value = bytes;
      receiptName.value = file.name;
      receiptSizeKb.value = sizeKb;
      receiptIsImage.value = file.extension?.toLowerCase() != 'pdf';
      clearError('receipt');
    } catch (_) {
      errors['receipt'] = 'ما قدرنا نفتح الملف — جرّب مرة تانية';
      errors.refresh();
    }
  }

  void removeReceipt() {
    receiptBytes.value = null;
    receiptName.value = '';
    receiptSizeKb.value = 0;
    receiptIsImage.value = true;
  }

  void clearError(String field) {
    if (errors.containsKey(field)) {
      errors.remove(field);
      errors.refresh();
    }
  }

  bool validate() {
    final next = <String, String>{};

    // The transfer arrives under whoever sent it - often a brother or a
    // friend. Without this name Ahmad cannot match the money to the request.
    if (senderName.text.trim().length < 3) {
      next['senderName'] = 'اكتب اسم اللي حوّل زي ما هو بالإيصال';
    }

    final tx = transactionNumber.text.trim();
    if (tx.length < 4 || !RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(tx)) {
      next['transactionNumber'] = 'رقم العملية غير صحيح';
    }

    if (receiptBytes.value == null) {
      next['receipt'] = 'لازم ترفع الإيصال';
    }

    errors.value = next;
    return next.isEmpty;
  }

  Future<void> submit() async {
    if (!validate()) return;

    isLoading.value = true;
    // POST /purchase-requests (multipart) goes here: productId, senderName,
    // transactionNumber, receipt.
    //
    // On 201 -> Get.offAllNamed(Routes.pending)
    // On 409 -> the buyer already has a pending request for this product;
    //           show the server message, do not create a second one.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    isLoading.value = false;
    // Temporary until the API lands.
    Get.offAllNamed(Routes.pending);
  }

  @override
  void onClose() {
    senderName.dispose();
    transactionNumber.dispose();
    super.onClose();
  }
}
