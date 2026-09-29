import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Local storage for the web app. GetStorage rather than shared_preferences
/// because reads are synchronous - NetworkConfig needs the token while
/// building headers, and an await there would spread through every call.
class StorageRepository {
  final _box = GetStorage();

  static const _kToken = 'token';
  static const _kUser = 'user_info';
  static const _kDeviceId = 'device_id';
  static const _kLang = 'app_language';
  static const _kIntent = 'purchase_intent';
  static const _kPendingEmail = 'pending_email';

  // ---------------------------------------------------------------- token
  void setToken(String token) => _box.write(_kToken, token);

  String get token => _box.read<String>(_kToken) ?? '';

  bool get isLoggedIn => token.isNotEmpty;

  // ----------------------------------------------------------------- user
  void setUser(Map<String, dynamic> user) =>
      _box.write(_kUser, jsonEncode(user));

  Map<String, dynamic>? get user {
    final raw = _box.read<String>(_kUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------ device id
  /// Generated once and kept. It must stay stable for this browser: the
  /// backend counts devices per account, so regenerating it on every login
  /// would burn through the limit and start signing the user out.
  String get deviceId {
    final existing = _box.read<String>(_kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random();
    final id = List.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    _box.write(_kDeviceId, id);
    return id;
  }

  // ------------------------------------------------------------- language
  void setLanguage(String code) => _box.write(_kLang, code);

  String get language => _box.read<String>(_kLang) ?? 'ar';

  // -------------------------------------------------------------- intent
  /// Survives the signup detour and a page refresh, so a buyer who presses
  /// "subscribe" lands back on checkout instead of the home page.
  void setPurchaseIntent(Map<String, dynamic> intent) =>
      _box.write(_kIntent, jsonEncode(intent));

  Map<String, dynamic>? get purchaseIntent {
    final raw = _box.read<String>(_kIntent);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }


    /// Cached application-data sections. Each one keeps its own last_updated so
  /// the next fetch can ask the server for changes only.
  void saveSection(String key, dynamic data, String? lastUpdated) {
    _box.write('section_$key', jsonEncode(data));
    if (lastUpdated != null) {
      _box.write('section_${key}_updated', lastUpdated);
    }
  }

  dynamic getSection(String key) {
    final raw = _box.read<String>('section_$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  String? getSectionUpdatedAt(String key) =>
      _box.read<String>('section_${key}_updated');

  /// Kept in storage, not only in route arguments: arguments die on refresh,
  /// and refreshing this page is exactly what someone does while waiting for
  /// the email to arrive.
  void setPendingEmail(String email) => _box.write(_kPendingEmail, email);

  String get pendingEmail => _box.read<String>(_kPendingEmail) ?? '';

  void clearPendingEmail() => _box.remove(_kPendingEmail);

  void clearPurchaseIntent() => _box.remove(_kIntent);

  // --------------------------------------------------------------- logout
  /// Device id and language stay: they are properties of this browser, not of
  /// the session.
  void clearSession() {
    _box.remove(_kToken);
    _box.remove(_kUser);
    _box.remove(_kIntent);
  }
}

/// Shorthand used by NetworkConfig and the controllers.
StorageRepository get storage => Get.find<StorageRepository>();
