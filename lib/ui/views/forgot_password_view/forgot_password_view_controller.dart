import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/repository/auth_repository.dart';
import '../../../core/data/repository/storage_repository.dart';

/// One step only: collect the address and the new password, then hand off to
/// the shared verification screen. The backend takes the new password with
/// this request and uses the emailed code purely to confirm the account
/// belongs to whoever asked.
class ForgotPasswordViewController extends GetxController {
  final email = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final _auth = AuthRepository();

  final isLoading = false.obs;
  final obscure = true.obs;
  final errors = <String, String>{}.obs;

  void toggleObscure() => obscure.toggle();

  void clearError(String key) {
    if (errors.containsKey(key)) {
      errors.remove(key);
      errors.refresh();
    }
  }

  bool validate() {
    final next = <String, String>{};

    if (!RegExp(r'^[\w.\-+]+@[\w-]+\.[\w.-]+$').hasMatch(email.text.trim())) {
      next['email'] = 'البريد الإلكتروني غير صحيح';
    }

    if (newPassword.text.length < 8) {
      next['newPassword'] = 'كلمة المرور لازم تكون ٨ أحرف على الأقل';
    }

    // Confirmation matters more here than at signup: there is no "current
    // password" to fall back on if they mistype the one they are setting.
    if (confirmPassword.text != newPassword.text) {
      next['confirmPassword'] = 'كلمتا المرور مش متطابقتين';
    }

    errors.value = next;
    return next.isEmpty;
  }

  Future<void> submit() async {
    if (!validate()) return;

    isLoading.value = true;
    final result = await _auth.resetPassword(
      email: email.text.trim(),
      newPassword: newPassword.text,
    );
    isLoading.value = false;

    result.fold(
      (failure) => errors.value = failure.fields.isNotEmpty
          ? failure.fields
          : {'email': failure.message},
      (_) {
        // Stored rather than passed as an argument: arguments die on refresh,
        // and refreshing while waiting for the email is exactly what happens.
        storage.setPendingEmail(email.text.trim());

        // otp/verify cannot tell a reset code from a signup code, so the mode
        // travels with the route and decides where the user lands after.
        Get.toNamed(Routes.verify, arguments: {'mode': 'reset'});
      },
    );
  }

}