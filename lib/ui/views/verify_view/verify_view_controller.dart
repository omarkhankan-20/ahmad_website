import 'dart:async';

import 'package:ahmad_website/core/data/models/course_models.dart';
import 'package:ahmad_website/core/data/repository/storage_repository.dart';
import 'package:ahmad_website/core/services/auth_service.dart';
import 'package:ahmad_website/core/services/courses_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/content_models.dart';
import '../../../core/data/repository/auth_repository.dart';

class VerifyViewController extends GetxController {
  final code = TextEditingController();
  final _auth = AuthRepository();

  final isLoading = false.obs;
  final isResending = false.obs;
  final errors = <String, String>{}.obs;
  String mode = 'register';

  /// Confirmation shown after a successful resend, so the button press has a
  /// visible result rather than appearing to do nothing.
  final resentNotice = ''.obs;

  /// The account is identified by the email the code was sent to.
  String email = '';

  /// Carried through from the buy button so a verified buyer lands on
  /// checkout instead of the home page.
  Course? pendingOffer;

  final resendIn = 0.obs;
  Timer? _timer;

  static const int codeLength = 6;

  @override
  void onInit() {
    super.onInit();
    email = storage.pendingEmail;
    final args = Get.arguments;
    if (args is Map) {
      final offer = args['offer'];
      if (offer is Course) pendingOffer = offer;
      mode = args['mode'] as String? ?? 'register';
    }
    _startCooldown();
  }

  void clearError(String key) {
    if (errors.containsKey(key)) {
      errors.remove(key);
      errors.refresh();
    }
  }

  bool validate() {
    final value = code.text.trim();
    if (value.length < codeLength || int.tryParse(value) == null) {
      errors.value = {'code': 'اكتب الكود المكوّن من $codeLength أرقام'};
      return false;
    }
    errors.clear();
    return true;
  }

  Future<void> verify() async {
    if (!validate()) return;

    isLoading.value = true;
    final result = await _auth.verifyOtp(
      identifier: email,
      code: code.text.trim(),
    );
    isLoading.value = false;

    result.fold(
      (failure) {
        errors.value = failure.fields.isNotEmpty
            ? failure.fields
            : {'code': failure.message};
      },
      (_) {
        storage.clearPendingEmail();

        if (mode == 'reset') {
          // A password reset returns no token, and any old session is
          // meaningless now - leaving one behind would also bounce us off the
          // login screen, since GuestMiddleware guards it.
          storage.clearSession();
          auth.syncFromStorage();
          Get.offAllNamed(Routes.login);
          return;
        }

        // Signup verification does return a token, so the user is already
        // signed in and the login screen would be a step for nothing.
        auth.syncFromStorage();
        coursesService.reloadForSession();
        if (pendingOffer != null) {
          Get.offAllNamed(Routes.checkout, arguments: pendingOffer);
        } else {
          Get.offAllNamed(Routes.main);
        }
      },
    );
  }

  Future<void> resend() async {
    if (resendIn.value > 0 || isResending.value) return;

    isResending.value = true;
    final result = await _auth.resendOtp(identifier: email);
    isResending.value = false;

    result.fold((failure) => errors.value = {'code': failure.message}, (_) {
      resentNotice.value = 'بعتنالك كود جديد';
      code.clear();
      clearError('code');
      _startCooldown();
    });
  }

  /// Without a cooldown an impatient user taps five times, gets five emails,
  /// and then hits the server's rate limit thinking the site is broken.
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

  @override
  void onClose() {
    _timer?.cancel();
    code.dispose();
    super.onClose();
  }
}
