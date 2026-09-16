import 'package:ahmad_website/app/routes/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/data/models/content_models.dart';

class RegisterViewController extends GetxController {
  final name = TextEditingController();
  final whatsapp = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final isLoading = false.obs;
  final acceptedTerms = false.obs;
  final obscurePassword = true.obs;

  /// Field name -> message. Errors render under their own field, never as a
  /// snackbar.
  final errors = <String, String>{}.obs;

  /// Set when the visitor arrived by pressing a buy button, null when they
  /// opened /register directly. Drives the order summary and the step bar.
  ///
  /// Comes from Get.arguments for now; it moves to IntentService once that
  /// exists, so the choice also survives a page refresh.
  Offering? pendingOffer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Offering) pendingOffer = args;
  }

  bool get isPurchaseFlow => pendingOffer != null;

  void toggleObscure() => obscurePassword.toggle();
  void toggleTerms() => acceptedTerms.toggle();

  /// Local validation only - this is screen logic, not server logic, and it
  /// has to work before any API exists.
  bool validate() {
    final next = <String, String>{};

    if (name.text.trim().length < 3) {
      next['name'] = 'اكتب اسمك الكامل';
    }

    final phone = whatsapp.text.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(phone)) {
      next['whatsapp'] = 'رقم واتساب غير صحيح — ابدأ برمز الدولة';
    }

    if (!RegExp(r'^[\w.\-+]+@[\w-]+\.[\w.-]+$').hasMatch(email.text.trim())) {
      next['email'] = 'البريد الإلكتروني غير صحيح';
    }

    if (password.text.length < 8) {
      next['password'] = 'كلمة المرور لازم تكون ٨ أحرف على الأقل';
    }

    if (!acceptedTerms.value) {
      next['terms'] = 'لازم توافق على الشروط والأحكام';
    }

    errors.value = next;
    return next.isEmpty;
  }

  /// Clears a field's error as soon as the user starts fixing it. Leaving a
  /// red message under a field they already corrected reads as broken.
  void clearError(String field) {
    if (errors.containsKey(field)) {
      errors.remove(field);
      errors.refresh();
    }
  }

  Future<void> submit() async {
    if (!validate()) return;

    isLoading.value = true;
    // POST /auth/register goes here. On success: store the token, then
    // Get.offNamed(Routes.checkout) when pendingOffer != null, otherwise
    // Get.offAllNamed(Routes.main).
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
    Get.toNamed(Routes.checkout, arguments: pendingOffer);
  }

  @override
  void onClose() {
    name.dispose();
    whatsapp.dispose();
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
