import 'package:ahmad_website/core/services/courses_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../data/repository/auth_repository.dart';
import '../data/repository/storage_repository.dart';

/// Single owner of "is someone signed in, and who". Storage holds the values;
/// this exposes them reactively so the nav bar changes the moment a login or
/// logout happens, without every widget reading storage itself.
class AuthService extends GetxService {
  final isLoggedIn = false.obs;
  final isBooting = false.obs;
  final userName = ''.obs;
  final isLoggingOut = false.obs;

  final _auth = AuthRepository();

  @override
  void onInit() {
    super.onInit();
    syncFromStorage();

    // A stored token only proves someone logged in once. It says nothing
    // about whether the token still works - so it gets checked, but after the
    // first frame: SessionHandler needs a live navigator to redirect, and
    // during onInit there isn't one yet.
    if (isLoggedIn.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => verifySession());
    }
  }

  /// Validates the token and refreshes the cached user in one call. A 401 is
  /// handled centrally by SessionHandler, so nothing is done with it here.
  Future<void> verifySession() async {
    if (!storage.isLoggedIn) return;

    isBooting.value = true;
    final result = await _auth.generalUserData();
    isBooting.value = false;

    result.fold(
      // Network failures are left alone on purpose: a dropped connection is
      // not an expired session, and signing someone out because their wifi
      // blinked would be worse than letting them retry.
      (_) {},
      (data) {
        final info = data['user_information'];
        final user = info is Map ? info['data'] : null;
        if (user is Map) {
          storage.setUser(Map<String, dynamic>.from(user));
          syncFromStorage();
        }
      },
    );
  }

  /// Called after login, after otp verification, and on app start.
  void syncFromStorage() {
    isLoggedIn.value = storage.isLoggedIn;
    userName.value = (storage.user?['name'] ?? '').toString();
  }

  /// First letter of the name for the avatar circle.
  String get initial =>
      userName.value.trim().isEmpty ? 'ح' : userName.value.trim()[0];

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;

    // The server call is best effort: if it fails the local session still has
    // to end, otherwise the user is stuck signed in on a broken session.
    await _auth.logout();

    storage.clearSession();
    syncFromStorage();
    coursesService.reloadForSession();
    isLoggingOut.value = false;

    Get.offAllNamed(Routes.main);
  }
}

AuthService get auth => Get.find<AuthService>();
