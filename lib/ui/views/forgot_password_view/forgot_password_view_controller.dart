import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ForgotPasswordViewController extends GetxController {
  final email = TextEditingController();

  final isLoading = false.obs;
  final isSent = false.obs;
  final errors = <String, String>{}.obs;

  /// Seconds left before "resend" is allowed again. Without it, an impatient
  /// user taps five times and gets five emails - or gets rate limited by the
  /// server and thinks the site is broken.
  final resendIn = 0.obs;
  Timer? _timer;

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
    errors.value = next;
    return next.isEmpty;
  }

  Future<void> submit() async {
    if (!validate()) return;

    isLoading.value = true;
    // POST /auth/forgot-password
    //
    // The response is the same whether the address exists or not, and the
    // screen below says "if this email is registered". Confirming that an
    // address has an account here would hand an attacker a way to enumerate
    // Ahmad's customer list.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    isLoading.value = false;

    isSent.value = true;
    _startCooldown();
  }

  Future<void> resend() async {
    if (resendIn.value > 0) return;
    await submit();
  }

  void _startCooldown() {
    resendIn.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendIn.value <= 1) {
        resendIn.value = 0;
        t.cancel();
      } else {
        resendIn.value--;
      }
    });
  }

  /// Lets the user fix a typo without losing the screen.
  void editEmail() {
    isSent.value = false;
    _timer?.cancel();
    resendIn.value = 0;
  }

  @override
  void onClose() {
    _timer?.cancel();
    email.dispose();
    super.onClose();
  }
}