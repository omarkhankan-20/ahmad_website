import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/data/models/content_models.dart';

class LoginViewController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  /// Field name -> message, plus the key 'form' for a whole-form failure like
  /// wrong credentials. Errors render in the form, never as a snackbar.
  final errors = <String, String>{}.obs;

  /// Set when the visitor pressed a buy button and already has an account,
  /// null when they opened /login directly. Decides where they land after a
  /// successful login.
  Offering? pendingOffer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Offering) pendingOffer = args;
  }

  bool get isPurchaseFlow => pendingOffer != null;

  void toggleObscure() => obscurePassword.toggle();

  void clearError(String field) {
    if (errors.containsKey(field)) {
      errors.remove(field);
      errors.refresh();
    }
  }

  /// Shape only. Login never checks password strength - the account already
  /// exists, and rejecting a valid old password because it is 6 characters
  /// would lock a real customer out.
  bool validate() {
    final next = <String, String>{};

    if (!RegExp(r'^[\w.\-+]+@[\w-]+\.[\w.-]+$').hasMatch(email.text.trim())) {
      next['email'] = 'البريد الإلكتروني غير صحيح';
    }
    if (password.text.isEmpty) {
      next['password'] = 'اكتب كلمة المرور';
    }

    errors.value = next;
    return next.isEmpty;
  }

  Future<void> submit() async {
    if (!validate()) return;

    isLoading.value = true;
    // POST /auth/login goes here. On success, route by state:
    //   pendingOffer != null      -> Get.offNamed(Routes.checkout)
    //   user.isAdmin              -> Get.offAllNamed(Routes.admin)
    //   !user.hasCourseAccess     -> Get.offAllNamed(Routes.pending)
    //   otherwise                 -> Get.offAllNamed(Routes.course)
    //
    // On 401 set errors['form'] - a single message above the fields, not one
    // under each, so we never hint which half was wrong.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}