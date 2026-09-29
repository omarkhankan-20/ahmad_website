import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../data/repository/storage_repository.dart';
import 'auth_service.dart';

/// Central handling for an expired or revoked token.
///
/// Every request funnels its status code through here, so a dead session ends
/// in one place instead of surfacing as a different confusing error on each
/// screen.
class SessionHandler {
  SessionHandler._();

  /// Guards against a stampede: a screen that fires three requests at once
  /// would otherwise clear the session and redirect three times.
  static bool _handling = false;

  /// Called by NetworkUtil on every response.
  static void checkStatus(int statusCode) {
    if (statusCode != 401) return;

    // A 401 with no token stored is an ordinary failed login, not an expired
    // session. Reacting to it would wipe the error the login screen is about
    // to show and bounce the user off the form they are standing on.
    if (!storage.isLoggedIn) return;

    expire();
  }

  static void expire() {
    if (_handling) return;
    _handling = true;

    storage.clearSession();

    // The service may not exist yet if this fires during startup.
    if (Get.isRegistered<AuthService>()) {
      auth.syncFromStorage();
    }

     WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(Routes.login);
    });

    Get.snackbar(
      'انتهت الجلسة',
      'سجّل دخولك من جديد لتكمّل.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );

    // Long enough for the redirect to settle, short enough that a genuine
    // second expiry later in the session is still handled.
    Future<void>.delayed(const Duration(seconds: 3), () => _handling = false);
  }
}