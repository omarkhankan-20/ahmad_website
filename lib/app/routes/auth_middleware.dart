import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/data/repository/storage_repository.dart';
import 'app_routes.dart';

/// Blocks the member area for signed-out visitors.
///
/// It only checks that a token exists - not what the token is allowed to do.
/// Entitlement lives on the server: every protected endpoint verifies it, and
/// the screens handle an empty or refused response. A middleware cannot wait
/// on a network call anyway, since redirect() is synchronous.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (storage.isLoggedIn) return null;
    return const RouteSettings(name: Routes.login);
  }
}

/// Keeps a signed-in user off the auth screens. Landing on a login form while
/// already logged in reads as a bug, and signing in twice creates a second
/// device against the device limit.
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!storage.isLoggedIn) return null;
    return const RouteSettings(name: Routes.main);
  }
}