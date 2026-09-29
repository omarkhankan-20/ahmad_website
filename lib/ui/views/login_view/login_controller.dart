import 'package:ahmad_website/app/routes/app_routes.dart';
import 'package:ahmad_website/core/data/models/course_models.dart';
import 'package:ahmad_website/core/data/repository/auth_repository.dart';
import 'package:ahmad_website/core/services/auth_service.dart';
import 'package:ahmad_website/core/services/courses_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';


class LoginViewController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();

  final _auth = AuthRepository();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  /// Field name -> message, plus the key 'form' for a whole-form failure like
  /// wrong credentials. Errors render in the form, never as a snackbar.
  final errors = <String, String>{}.obs;

  /// Set when the visitor pressed a buy button and already has an account,
  /// null when they opened /login directly. Decides where they land after a
  /// successful login.
  Course? pendingOffer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Course) pendingOffer = args;
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
    final result = await _auth.login(
      email: email.text.trim(),
      password: password.text,
    );
    isLoading.value = false;

    result.fold((failure) => errors.value = failure.fields, (_) {
      auth.syncFromStorage();
      coursesService.reloadForSession();
      if (pendingOffer != null) {
        Get.offAllNamed(Routes.checkout, arguments: pendingOffer);
      } else {
        Get.offAllNamed(Routes.main);
      }
    });
  }
}
