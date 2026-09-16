/// Route names only - no widgets, no imports. This file is safe to import
/// from anywhere (controllers, services, middleware) without pulling the
/// whole view layer in with it.
///
/// These strings become real URLs in the browser, so they are also the site's
/// public structure: keep them short, lowercase, and meaningful.
abstract class Routes {
  Routes._();

  static const String main = '/';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Purchase flow
  static const String checkout = '/checkout';
  static const String pending = '/pending';
  static const String rejected = '/rejected';
  static const String consultation = '/consultation';
  static const String consultationStatus = '/consultation-status';

  // Member area
  static const String course = '/course';
  static const String myOrders = '/my-orders';

  /// Lesson pages carry the id in the path so a student can bookmark one
  /// lesson: /course/lesson/les_3
  static const String lesson = '/course/lesson/:id';
  static String lessonPath(String id) => '/course/lesson/$id';

  // Admin
  static const String admin = '/admin';

  // Legal - linked from the signup checkbox, so they must exist before launch
  static const String terms = '/terms';
  static const String privacy = '/privacy';
}
