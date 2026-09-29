import 'package:get/get.dart';

import '../data/models/app_data_models.dart';
import '../data/repository/app_data_repository.dart';
import '../data/repository/storage_repository.dart';

/// Holds everything Ahmad edits from the dashboard: payment methods, the legal
/// texts, the contact block and the consultation price.
///
/// Served from storage first so screens render instantly, then refreshed in
/// the background. Sections the server says are unchanged are simply left
/// alone.
class AppDataService extends GetxService {
  final _repo = AppDataRepository();

  final paymentMethods = <AppPaymentMethod>[].obs;
  final terms = <LegalClause>[].obs;
  final privacy = <LegalClause>[].obs;
  final aboutUs = Rxn<AboutUs>();
  final consultationSettings = Rxn<ConsultationSettings>();
  final generalSettings = Rxn<GeneralSettings>();

  final isLoading = false.obs;

  static const _kPayment = 'payment_methods';
  static const _kTerms = 'terms_and_conditions';
  static const _kPrivacy = 'privacy_policy';
  static const _kAbout = 'about_us';
  static const _kConsultation = 'consultation_settings';
  static const _kGeneral = 'general_settings';

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    refreshData();
  }

  /// Instant, synchronous. Whatever was fetched last time is on screen before
  /// the network call even starts.
  void _loadFromCache() {
    final cachedPayment = storage.getSection(_kPayment);
    if (cachedPayment is List) {
      paymentMethods.assignAll(
        cachedPayment.whereType<Map>().map(
          (e) => AppPaymentMethod.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    }

    final cachedTerms = storage.getSection(_kTerms);
    if (cachedTerms is List) {
      terms.assignAll(
        cachedTerms.whereType<Map>().map(
          (e) => LegalClause.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    }

    final cachedPrivacy = storage.getSection(_kPrivacy);
    if (cachedPrivacy is List) {
      privacy.assignAll(
        cachedPrivacy.whereType<Map>().map(
          (e) => LegalClause.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    }

    final cachedAbout = storage.getSection(_kAbout);
    if (cachedAbout is Map) {
      aboutUs.value = AboutUs.fromJson(Map<String, dynamic>.from(cachedAbout));
    }

    final cachedConsultation = storage.getSection(_kConsultation);
    if (cachedConsultation is Map) {
      consultationSettings.value = ConsultationSettings.fromJson(
        Map<String, dynamic>.from(cachedConsultation),
      );
    }

    final cachedGeneral = storage.getSection(_kGeneral);
    if (cachedGeneral is Map) {
      generalSettings.value = GeneralSettings.fromJson(
        Map<String, dynamic>.from(cachedGeneral),
      );
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;

    final result = await _repo.fetch(
      generalSettings: storage.getSectionUpdatedAt('general_settings'),
      aboutUs: storage.getSectionUpdatedAt(_kAbout),
      terms: storage.getSectionUpdatedAt(_kTerms),
      privacy: storage.getSectionUpdatedAt(_kPrivacy),
    );

    isLoading.value = false;

    result.fold(
      // A failed refresh is not an error state: the cached copy is still on
      // screen, and legal text does not change often enough to interrupt
      // anyone over.
      (_) {},
      _apply,
    );
  }

  void _apply(Map<String, dynamic> model) {
    // Payment methods and the consultation price carry no last_updated in the
    // request, so the server always returns them.
    final payment = model[_kPayment];
    if (payment is Map && payment['data'] is List) {
      final list = (payment['data'] as List)
          .whereType<Map>()
          .map((e) => AppPaymentMethod.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      paymentMethods.assignAll(list);
      storage.saveSection(
        _kPayment,
        list.map((e) => e.toJson()).toList(),
        payment['last_updated']?.toString(),
      );
    }

    final consultation = model[_kConsultation];
    if (consultation is Map && consultation['data'] is Map) {
      final settings = ConsultationSettings.fromJson(
        Map<String, dynamic>.from(consultation['data'] as Map),
      );
      consultationSettings.value = settings;
      storage.saveSection(
        _kConsultation,
        settings.toJson(),
        consultation['last_updated']?.toString(),
      );
    }

    final about = model[_kAbout];
    if (about is Map && about['data'] is Map) {
      final parsed = AboutUs.fromJson(
        Map<String, dynamic>.from(about['data'] as Map),
      );
      aboutUs.value = parsed;
      storage.saveSection(
        _kAbout,
        parsed.toJson(),
        about['last_updated']?.toString(),
      );
    }

    final general = model[_kGeneral];
    if (general is Map && general['data'] is Map) {
      final parsed = GeneralSettings.fromJson(
        Map<String, dynamic>.from(general['data'] as Map),
      );
      generalSettings.value = parsed;
      storage.saveSection(
        _kGeneral,
        parsed.toJson(),
        general['last_updated']?.toString(),
      );
    }

    _applyLegal(model[_kTerms], _kTerms, terms);
    _applyLegal(model[_kPrivacy], _kPrivacy, privacy);
  }

  void _applyLegal(dynamic section, String key, RxList<LegalClause> target) {
    if (section is! Map) return;
    final clauses = LegalClause.listFrom(section['data']);
    if (clauses.isEmpty) return;

    target.assignAll(clauses);
    storage.saveSection(
      key,
      clauses.map((e) => e.toJson()).toList(),
      section['last_updated']?.toString(),
    );
  }

  /// Consultation price as the server states it. Null until it loads, so the
  /// UI can hide the row rather than print a placeholder.
  String? get consultationPrice {
    final value = consultationSettings.value?.price;
    return (value == null || value.isEmpty) ? null : value;
  }

  String? get telegramGroupUrl => generalSettings.value?.telegramGroupUrl;

  /// Digits only: wa.me rejects spaces, dashes and the leading plus.
  String? get whatsappNumber {
    final n = aboutUs.value?.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    return (n == null || n.isEmpty) ? null : n;
  }
}

AppDataService get appData => Get.find<AppDataService>();
