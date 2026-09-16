import 'package:get/get.dart';

/// App-level state that outlives any single view. Keep it small: anything
/// that belongs to one screen belongs in that screen's controller.
/// Filename keeps the existing spelling so current imports don't break -
/// worth renaming to my_app_controller.dart in one pass later.
class MyAppController extends GetxController {
  /// The site is Arabic-only for now. Kept as state so adding English later
  /// is a value change, not a refactor of every widget.
  final isRtl = true.obs;
}
